class ComServer extends TcpLink
		config(USAR);


var config int ListenPort;

var string gameClass;
var bool bBound;
//var config bool bDebug; //Now included in Actor
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

//Check if a robot is registered with the server
// if it is registered, then return the registration number
// else return -1
function int isRegistered(string sName)
{
	local int i;
	i=0;
	while(i<numReg)
	{
		if(sName==RegRobots[i].str1)
		{
			return i;
		}
		i++;
	}
	return -1;
}

//Check if a robot is listening
function bool isListening(string sName)
{
	local int i;
	i=0;
	while(i<numListen)
	{
		if(sName==Listening[i].str1)
		{
			return true;
		}
		i++;
	}
	return false;
}

//Check if a robot is listening at a specific port
function bool isListening2(string sName, string sPort)
{
	local int i;
	i=0;
	while(i<numListen)
	{
		if(sName==Listening[i].str1 && sPort==Listening[i].str2)
		{
			return true;
		}
		i++;
	}
	return false;
}

//Get the index of the robot listening at the specific port
function int getListenerNum(string sName, string sPort)
{
	local int i;
	i=0;
	while(i<numListen)
	{
		if(sName==Listening[i].str1 && sPort==Listening[i].str2)
		{
			return i;
		}
		i++;
	}
	return -1;
}

//Get the IP of the robot
function string getRobotIP(string sName)
{
	local int i;
	i=0;
	while(i<numReg)
	{
		if(sName==RegRobots[i].str1)
		{
			return RegRobots[i].str2;
		}
		i++;
	}
	return "";
}

//Get the port the robot is listening at
function string getRobotPort(string sName)
{
	local int i;
	i=0;
	while(i<numListen)
	{
		if(sName==Listening[i].str1)
		{
			return Listening[i].str2;
		}
		i++;
	}
	return "";
}

//Get Signal Strength
function float getSigStrength(string r1,string r2)
{
	if (bDebug) LogInternal("ComServer: Cannot calculate signal strength");
	return 1;
}

//Check for connectivity
function bool isReachable(string r1,string r2)
{
	if(bDebug)
		LogInternal("ComServer: Cannot get robot information");
	return true;
}

function PostBeginPlay()
{
	local bool temp;
	Super.PostBeginPlay();
	LinkMode=MODE_Text;
    if(!bBound)
    {
		BindPort( ListenPort );
		if(bDebug)
    		LogInternal("ComServer bound to port "$ListenPort);
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

function HandleLine(string Line,TCPLink ep,string remoteip)
{
    //Parsing the message
	local string cmdType;
	local int attrNum, i,j, regNo;
	local bool b1,b2;
	local float ss;
    
	if ( bLogWCS )  
		fWCSLogInternal(WorldInfo.TimeSeconds$" "$Line); 
   
	if(bDebug)
    	LogInternal("ComServer: Received Message - "$Line);

	//Removing end of message delim
	i=InStr(Line,MsgEnd);
	if(i == -1)
	{
		i=Len(Line);
		if(bDebug)
			LogInternal("ComServer: Received Message does not terminate well - "$Line);
	}
	Line=left(Line,i);
	
	if(bDebug)
		LogInternal("ComServer: After removing end of message limiter - "$Line);

	//Splitting message	
    //old set array [before,splitString,after]
    //new sets string to before, returns after
    ParseStringIntoArray(Line,ParsedMessg,MsgSplit,True);
    attrNum=ParsedMessg.Length ;
    
	if(bDebug)
		LogInternal("ComServer: Message contained "@attrNum$" words");
	
	cmdType=ParsedMessg[0];
   	cmdType = Caps(cmdType);
	
	//Processing the command
	switch(cmdType)
	{
		case "REGISTER":
			//Checking for correct message length
			if(attrNum!=3)
			{
				if(bDebug) LogInternal("ComServer: Incorrect message length in "$Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			//Checking if a robot with the same name is registered
			regNo = isRegistered(ParsedMessg[1]);
			if(regNo != -1)
			{
				if( RegRobots[regNo].str2!=ParsedMessg[2] )
				{
					if(bDebug) LogInternal("ComServer: Robot with name "$ParsedMessg[1]$" already registerd");
					ep.SendText("Fail: Robot with name "$ParsedMessg[1]$" already registered;");
					break;
				}
				else
				{
					if(bDebug)
					{
						LogInternal("ComServer: "$RegRobots[numReg].str1$" re-registered with IP "$RegRobots[numReg].str2);
						LogInternal("ComServer: "$(numReg+1)$" robots registered");
					}
				}
			}
			else
			{
				//Registering
				RegRobots.insert(numReg,1);
				RegRobots[numReg].str1$=ParsedMessg[1];
				RegRobots[numReg].str2$=ParsedMessg[2];
				if(bDebug)
				{
					LogInternal("ComServer: "$RegRobots[numReg].str1$" registered with IP "$RegRobots[numReg].str2);
					LogInternal("ComServer: "$(numReg+1)$" robots registered");
				}
				numReg++;
			}
			ep.SendText("OK;");
			break;
		case "LISTEN":
			//Checking for correct message length
			if(attrNum!=3)
			{
				if(bDebug) LogInternal("ComServer: Incorrect message length in "$Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			//Checking if the robot is registered
			if(isRegistered(ParsedMessg[1]) == -1)
			{
				if(bDebug) LogInternal("ComServer: Robot "$ParsedMessg[1]$" not registered");
				ep.SendText("Fail: Robot "$ParsedMessg[1]$" not registered;");
				break;
			}
			//Checking if a robot with the same name is listening at the same port
			if(isListening(ParsedMessg[1]))
			{
				if(getRobotPort(ParsedMessg[1])==ParsedMessg[2])
				{
					if(bDebug) LogInternal("ComServer: Robot with name "$ParsedMessg[1]$" already listening at port "$ParsedMessg[2]);
					ep.SendText("Fail: Robot with name "$ParsedMessg[1]$" already listening at port "$ParsedMessg[2]$";");
					break;
				}
			}
			//Adding to listening list
			Listening.insert(numListen,1);
			Listening[numListen].str1$=ParsedMessg[1];
			Listening[numListen].str2$=ParsedMessg[2];
			if(bDebug)
			{
				LogInternal("ComServer: "$Listening[numListen].str1$" listening at port "$Listening[numListen].str2);
				LogInternal("ComServer: "$(numListen+1)$" robots listening");
			}
			numListen++;
			ep.SendText("OK;");
			break;
		case "OPEN":
			//Checking for correct message length
			if(attrNum!=5)
			{
				if(bDebug) LogInternal("ComServer: Incorrect message length in "$Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			//Check if host is listening on specified port
			if(!isListening2(ParsedMessg[3],ParsedMessg[4]))
			{
				if(bDebug) LogInternal("ComServer: "$ParsedMessg[3]$" not listening on port "$ParsedMessg[4]);
				ep.SendText("Fail: "$ParsedMessg[3]$" not listening on port "$ParsedMessg[4]$";");
				break;
			}
			//Check for connectivity
			if(!isReachable(ParsedMessg[1],ParsedMessg[3]))
			{
				if(bDebug) LogInternal("ComServer: Cannot connect to "$ParsedMessg[3]);
				ep.SendText("Fail: Cannot connect to "$ParsedMessg[3]$";");
				break;
			}
			//Try setting up the needed connections
			Connected.insert(numCon,1);
			Connected[numCon]=spawn(class'ComConnection',self);
			Connected[numCon].setUp(ParsedMessg[1],ParsedMessg[3]);
			
			Connected[numCon].link1.Connect(getRobotIP(ParsedMessg[1]),ParsedMessg[2]);
			Connected[numCon].link2.Connect(getRobotIP(ParsedMessg[3]),ParsedMessg[4]);
			
			//Checking if the connection was established
			b1=(Connected[numCon].link1.LinkState==STATE_Connecting || Connected[numCon].link1.LinkState==STATE_Connected);
			b2=(Connected[numCon].link2.LinkState==STATE_Connecting || Connected[numCon].link2.LinkState==STATE_Connected);
			//If the connection was established
			if(b1 && b2)
			{
				//Remove listening robot
				i=getListenerNum(ParsedMessg[3],ParsedMessg[4]);
				Listening.remove(i,1);
				numListen--;
				if(bDebug)
				{
					LogInternal("ComServer: "$ParsedMessg[1]$" connected to "$ParsedMessg[3]);
					LogInternal("ComServer: "$(numCon+1)$" connections created");
				}
				ep.SendText("OK;");
				numCon++;
			}
			else
			{
				Connected.remove(numCon,1);
				if(bDebug)	LogInternal("ComServer: "$ParsedMessg[1]$" could not connect to "$ParsedMessg[3]);
				ep.SendText("Fail: Could not establish connection;");
			}
			break;
		//Command to get signal strength between two robots
		case "GETSS":
			//Checking for correct message length
			if(attrNum!=3)
			{
				if(bDebug) LogInternal("ComServer: Incorrect message length in "$Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			//Check for 3rd party requests
			j=InStr(remoteip,":");
			if(j == -1)
			{
			}
			else
			{
				remoteip=left(remoteip,j);
			}
			if(getRobotIP(ParsedMessg[1])==remoteip || getRobotIP(ParsedMessg[2])==remoteip)
			{
			}
			else
			{
				LogInternal(remoteip$" "$getRobotIP(ParsedMessg[1])$" "$getRobotIP(ParsedMessg[2]));
				if (bDebug) LogInternal("ComServer: Third party request for Sig Strength!!!!!");
				ep.SendText("Fail: Server does not accept third party requests");
				break;
			}
			ss=getSigStrength(ParsedMessg[1],ParsedMessg[2]);
			if(bDebug) LogInternal("ComServer: Signal strength between "$ParsedMessg[1]$" and "$ParsedMessg[2]$" is "$ss);
			if (ss>0) 
			{
				ep.SendText("Fail: Could not calculate signal strength;");
			}
			else
			{
				ep.SendText("OK:"$ss$";");
			}
			break;
		//These cases should not occur here
		case "SEND":
		case "CLOSE":
		default:
			if(bDebug) LogInternal("ComServer: Unknown message - "$Line);
			ep.SendText("Fail: Unknown message;");
	}
}

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
	local bool temp;
	if(LinkState!=STATE_Listening && LinkState!=STATE_Connecting && LinkState!=STATE_Connected)
	{
		temp=Listen();
	}
	if(bDebug)
	{
		LogInternal(temp);
		LogInternal(LinkState);
		LogInternal("ComServer: Old connection closed, listening for new connections");
	}
}

//called everytime a new botconnection is spawned
event GainedChild( Actor C )
{
	local ComServerCon con;
	con=ComServerCon(C);
	con.MessageHandler=Self;
	con.bInit=true;
	if (bDebug) LogInternal("ComServer: New connection Initialized");
}

event LostChild( Actor C )
{
	local ComServerCon con;
	con=ComServerCon(C);
	con.MessageHandler=None;
	con.bInit=false;
	if (bDebug) LogInternal("ComServer: Old connection de-initialized");
}

defaultproperties
{
	AcceptClass=USARBotApi.ComServerCon
    // ListenPort=5874 // Moved to config file
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
