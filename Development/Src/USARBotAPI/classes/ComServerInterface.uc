class ComServerInterface extends TcpLink
		config(USAR);
var config int iListenPort;
var string gameClass;
var bool bBound;
var config bool bLogWCS;
var int ConnectionCount;
var array<string> ParsedMessg;
var string MsgSplit;
var string MsgEnd;
var string PartMsg;
var FileLog  ComLog;
struct StrPair {
	var string str1;
	var string str2;
};
// The names and IP's of robots registered
var array<StrPair> RegRobots;
var int numReg;
// The name and port of robots which are listening
var array<StrPair> Listening;
var int numListen;
//Connections between two robots set up by the server
var array<ComConnection> Connected;
var int numCon;
//Variables controlling the dropping of packets
var config float ePdo;
var config float eDo;
var config float eN;
var config float eCutoff;
var config float eAttenFac;
var config float eMaxObs;

// Get number of obstacles between v1 and v2 UU locations
// r1 and r2 specifies actors that are not counted as obstacles and only used when counting obstacles between actors
function float getNumObsBetweenUULocations(vector v1,vector v2,Actor r1,Actor r2)
{
	local float ctr,stepSize,maxLength;
	local actor it,prevIt;
	local vector v,hitLoc,hitNorm,step;
	local Bool endReached;
	
	//local int i,steps; // used by test code
	
	if (bDebug) LogInternal("ComServer: calculating number of obstacles between UU locations");
	ctr=0;
	
	/*
	// using TraceActor doesn't work as each collision object is listed only ones
	// so a level with many walls will be listed ones so we can not count the walls
	foreach TraceActors(class'Actor', it, hitLoc, hitNorm, v2, v1)
	{
		if (bDebug) LogInternal("ComServer: TraceActors found actor "$it.name$" of type "$it.class);
		if (it.class==class'Brush' || it.class==class'StaticMeshActor' || it.class==class'BlockingVolume' || it.class==class'LevelInfo')
		{
			ctr+=1;
		}
	}
	*/
	
	/*
	// test code that uses Trace in a fixed number of steps
	steps=100;
	step=(v2-v1)/steps;
	v=v1;
	for (i=0; i<steps; i++)
	{
	   it=Trace(hitLoc, hitNorm, v+step, v, true);
	   if (bDebug) LogInternal("ComServer: Trace step: "$i$" of "$steps);
	   if (it!=None)
	   {
	     if (bDebug) LogInternal("ComServer: Trace found actor "$it.name$" of type "$it.class$" at "
			                         $class'UnitsConverter'.static.Str_LengthVectorFromUU(hitLoc));
	   }
	   v+=step;
	}
	*/
	
	stepSize=50; // size of step taken to get out of any current collision object
	step=stepSize*Normal(v2-v1);
	maxLength=VSize(v2-v1); // length of line to check collisions on
	endReached=false;
	v=v1; // set start point
	prevIt=None;
	while (true)
	{
	    if (bDebug) LogInternal("ComServer: Trace from "$class'UnitsConverter'.static.Str_LengthVectorFromUU(v)$
		                                          " to "$class'UnitsConverter'.static.Str_LengthVectorFromUU(v2));
		it=Trace(hitLoc, hitNorm, v2, v, true); // find first collision from v point to end point v2
		if (it==None || endReached) // end of line reached, done
		{
			break;
		}
		// if 'it' is different from previous value or
		// if distance from start point to collision is larger than stepSize then we found a new collision object
		if (it!=prevIt || VSize(hitLoc-v)>stepSize)
		{
			
			if (it!=r1 && it!=r2 &&   // only count when obstacle is not one of the robots between which the obstacles are counted
			    (it.class==class'Brush' || it.class==class'StaticMeshActor' ||   // and if it is of these types
				 it.class==class'BlockingVolume' ||it.class==class'WorldInfo'))
			{
				if (bDebug) LogInternal("ComServer: count collision with "$it.name$" of type "$it.class$" at "
	                                    $class'UnitsConverter'.static.Str_LengthVectorFromUU(hitLoc));
				ctr+=1;
			}
			else
			{
				if (bDebug) LogInternal("ComServer: ignore collision with "$it.name$" of type "$it.class$" at "
	                                    $class'UnitsConverter'.static.Str_LengthVectorFromUU(hitLoc));
			}
		}
		v=hitLoc+step; // move 'step' forward to get eventually out of the current collision object
		if (VSize(v-v1)>maxLength) // if v goes past end point v2 then correct v
		{
			v=v2;
			endReached=true;
		}
		prevIt=it; // remember previous 'it' value
	}
	return ctr;
}

//Get number of obstacles between locations
function float getNumObsBetweenLocations(vector v1,vector v2)
{
	if (bDebug) LogInternal("ComServer: calculating number of obstacles between locations");
	// convert to UU
	v1=class'UnitsConverter'.static.LengthVectorToUU(v1);
	v2=class'UnitsConverter'.static.LengthVectorToUU(v2);
	return getNumObsBetweenUULocations(v1,v2,None,None);
}

//Get number of obstacles between robots
function float getNumObs(string r1,string r2)
{
	local BotDeathMatch UsarGame;
	local BotController bot1,bot2;
	local float numObs;
	
	if (bDebug) LogInternal("ComServer: calculating number of obstacles between robots");
	UsarGame = BotDeathMatch(WorldInfo.Game);
	bot1=UsarGame.GetRobot(r1);
	if (bot1==None)
	{
		if (bDebug) LogInternal("ComServer: robot '"$r1$"' not found");
		return -1;
	}
	bot2=UsarGame.GetRobot(r2);
	if (bot2==None)
	{
	    if (bDebug) LogInternal("ComServer: robot '"$r2$"' not found");
		return -1;
	}
	
	numObs = getNumObsBetweenUULocations(bot1.Pawn.Location,bot2.Pawn.Location,
										 bot1.Pawn,bot2.Pawn);
	return numObs;
}

//Get Position of robots
function string getPosAll()
{
	local BotDeathMatch UsarGame;
	local USARVehicle vehicle;
	local int len,i;
	local string outstring;
	
	if (bDebug) LogInternal("ComServer: get position of all bots");
    UsarGame = BotDeathMatch(WorldInfo.Game);
	len=UsarGame.botList.length;
	if (bDebug) LogInternal("ComServer: found "$len$" bots");
	outstring="POSITIONS {Robots "$len$"}";
	for (i=0;i<len;i++)
	{
		outstring@="{Name "$UsarGame.botList[i].PlayerReplicationInfo.PlayerName;
		outstring@="Location "$class'UnitsConverter'.static.Str_LengthVectorFromUU(UsarGame.botList[i].Pawn.Location);
		vehicle=USARVehicle(UsarGame.botList[i].Pawn);
		if (vehicle.VehicleBattery.isDead())
			outstring@="BatteryEmpty True}";
		else
			outstring@="BatteryEmpty False}";
	}
	return outstring;
}

function PostBeginPlay()
{
	local bool temp;
	Super.PostBeginPlay();
	LinkMode=MODE_Text;
    if(!bBound)
    {
		BindPort( iListenPort );
		if(bDebug)
    		LogInternal("ComServerInterface bound to port "$iListenPort);
		temp=Listen();
		if(temp)
			bBound = true;
		else
		{
			if(bDebug)
				LogInternal("ComServer: Not able to listen");
		}
    }
}
function fWCSLogInternal(string x) {
    local string filename;
    filename = "WCS-ComServer-log";
    //UsarGame = USARDeathMatch(Level.Game);
    if(ComLog == None) {
        ComLog = spawn(class'FileLog');
        if(ComLog != None) {
            ComLog.OpenLog(filename);
            ComLog.Logf(x);
        } else {
            LogInternal(x);
        }
    } else {
        ComLog.Logf(x);
    }
}
/*
event ReceivedLine( string Line )
{
	HandleLine(Line,Self,IpAddrToString(RemoteAddr));
}
//If you receive text instead of by line
event ReceivedText( string Text )
{
	local int i;
	local string Msg;
	i=0;
    if(bDebug)
    	LogInternal("ComServer: Received Text in Server - "$Text);
	i=InStr(Text,MsgEnd);
	if(i==-1)				//Incomplete message
	{
		PartMsg$=Text;		//Concatenate
	}
	else
	{
		Msg=PartMsg$Left(Text,i+1);
		PartMsg=Mid(Text,i+1);
		HandleLine(Msg,Self,IpAddrToString(RemoteAddr));
	}
}
*/
//If you receive a binary message
event ReceivedBinary( int Count, byte B[255] )
{
	if(bDebug)
		LogInternal("ComServer: Received some binary message (should not occur)");
}
//Whena connection is accepted
event Accepted()
{
	if(bDebug)
		LogInternal("ComServer: Connected to "$IpAddrToString(RemoteAddr));
}
//Closed on other end
event Closed()
{
	//local bool temp;
	if(LinkState!=STATE_Listening && LinkState!=STATE_Connecting && LinkState!=STATE_Connected)
	{
		//temp=Listen();
	}
	if(bDebug)
	{
		//LogInternal(temp);
		//LogInternal(LinkState);
		LogInternal("ComServer: Old connection closed, listening for new connections");
	}
}
//called everytime a new botconnection is spawned
event GainedChild( Actor C )
{
	local ComServerNewCon con;
	con=ComServerNewCon(C);
	con.MessageHandler=Self;
	if (bDebug) LogInternal("ComServer: New connection Initialized");
}
event LostChild( Actor C )
{
	local ComServerCon con;
	con=ComServerCon(C);
	con.MessageHandler=None;
	if (bDebug) LogInternal("ComServer: Old connection de-initialized");
}
defaultproperties
{
	AcceptClass=USARBotApi.ComServerNewCon
     //iListenPort=7435 // Moved to config file
	 bBound=false
	 bDebug=false
	 //bLogWCS=true // Moved to config file
	 ConnectionCount=0
	 MsgSplit=" "
	 MsgEnd=";"
	 numReg=0
	 numListen=0
	 numCon=0
	 PartMsg=""
	 //ePdo=-49.67 // Moved to config file
	 //eDo=2 // Moved to config file
	 //eN=1 // Moved to config file
	 //eCutoff=-93 // Moved to config file
	 //eAttenFac=6.325 // Moved to config file
	 //eMaxObs=5 // Moved to config file
}
