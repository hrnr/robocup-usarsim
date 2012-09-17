/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * ComServerInterface: Similar to ComServer but acts like a robot monitor
 */
class ComServerInterface extends TcpLink config(USAR);

var config int iListenPort;
var String gameClass;
var bool bBound;
var config bool bLogWCS;
var int ConnectionCount;
var array<String> ParsedMessg;
var String MsgSplit;
var String MsgEnd;
var String PartMsg;
var FileLog  ComLog;

struct StrPair {
	var String str1;
	var String str2;
};

// The names and IP's of robots registered
var array<StrPair> RegRobots;
var int numReg;
// The name and port of robots which are listening
var array<StrPair> Listening;
var int numListen;
// Connections between two robots set up by the server
var array<ComConnection> Connected;
var int numCon;
// Variables controlling the dropping of packets
var config float ePdo;
var config float eDo;
var config float eN;
var config float eCutoff;
var config float eAttenFac;
var config float eMaxObs;

// Get number of obstacles between v1 and v2 UU locations
// r1 and r2 specifies actors that are not counted as obstacles and only used when counting obstacles between actors
function float getNumObsBetweenUULocations(vector v1, vector v2, Actor r1, Actor r2)
{
	local float stepSize, maxLength;
	local int ctr;
	local Actor it, prevIt;
	local vector v, hitLoc, hitNorm, step;
	local bool endReached;
	
	if (bDebug)
	LogInternal("ComServer: Calculating number of obstacles between UU locations");
	// Start trace through world counting colliding objects
	ctr = 0;
	stepSize = 50;
	step = stepSize * Normal(v2 - v1);
	maxLength = VSize(v2 - v1);
	endReached = false;
	v = v1;
	prevIt = None;

	while (!endReached)
	{
		// Find first collision from v point to end point v2

		it = Trace(hitLoc, hitNorm, v2, v, true);

		if (it == None)
		break;

			// If 'it' is different from previous value or distance from start point to collision
		// is larger than stepSize, then we found a new collision object
		if (it != prevIt || VSize(hitLoc - v) > stepSize)
		{
			// Must not be a robot and be one of these types
			if (it != r1 && it != r2 && (it.class == class'Brush' ||
				it.class == class'StaticMeshActor' || it.class == class'BlockingVolume' ||
				it.class == class'WorldInfo'))
			ctr++;
		}
		v = hitLoc + step;
		if (VSize(v - v1) > maxLength)
		{
			v = v2;
			endReached = true;
		}
		prevIt = it;
	}
	return float(ctr);
}

// Get number of obstacles between locations
function float getNumObsBetweenLocations(vector v1, vector v2)
{
	if (bDebug)
	LogInternal("ComServer: calculating number of obstacles between locations");
	// Convert to UU
	v1 = class'UnitsConverter'.static.LengthVectorToUU(v1);
	v2 = class'UnitsConverter'.static.LengthVectorToUU(v2);
	return getNumObsBetweenUULocations(v1, v2, None, None);
}

// Get number of obstacles between robots
function float getNumObs(String r1, String r2)
{
	local BotDeathMatch UsarGame;
	local BotController bot1, bot2;
	local float numObs;
	
	if (bDebug)
	LogInternal("ComServer: calculating number of obstacles between robots");
	UsarGame = BotDeathMatch(WorldInfo.Game);
	bot1 = UsarGame.GetRobot(r1);
	if (bot1 == None)
	{
		if (bDebug)
		LogInternal("ComServer: Robot '" $ r1 $ "' not found");
		return -1;
	}
	bot2 = UsarGame.GetRobot(r2);
	if (bot2 == None)
	{
		if (bDebug) LogInternal("ComServer: Robot '" $ r2 $ "' not found");
		return -1;
	}
	
	//numObs = getNumObsBetweenLocations(ConvertActorToVector(bot1.Pawn),ConvertActorToVector(bot2.Pawn));
	numObs = getNumObsBetweenUULocations(ConvertActorToVector(bot1.Pawn), ConvertActorToVector(bot2.Pawn),
		bot1.Pawn, bot2.Pawn);
	return numObs;
}

// Get Position of robots
function String getPosAll()
{
	local BotDeathMatch UsarGame;
	local USARVehicle vehicle;
	local int len, i;
	local String outString;
	
	if (bDebug)
	LogInternal("ComServer: Get position of all bots");
	UsarGame = BotDeathMatch(WorldInfo.Game);
	len = UsarGame.botList.length;
	outString = "POSITIONS {Robots " $ len $ "}";
	for (i = 0; i < len; i++)
	{
		vehicle = USARVehicle(UsarGame.botList[i].Pawn);
		outString @= "{Name " $ UsarGame.botList[i].BotName;
		outString @= "Location " $
		class'UnitsConverter'.static.Str_LengthVectorFromUU(vehicle.CenterItem.Location);
		if (vehicle.GetBatteryLife() > 0)
		outString @= "BatteryEmpty False}";
		else
		outString @= "BatteryEmpty True}";
	}
	return outString;
}

function vector ConvertActorToVector(Actor actor)
{
	local USARVehicle vehicle;
	vehicle = USARVehicle(actor);
	return vehicle.CenterItem.Location;
}
// Listens for connections
function PostBeginPlay()
{
	super.PostBeginPlay();
	LinkMode = MODE_Text;
	if (!bBound)
	{
		BindPort(iListenPort);
		if (bDebug)
		LogInternal("ComServerInterface: Listening on port " $ iListenPort);
		if (Listen())
		bBound = true;
		else
		{
			if (bDebug)
			LogInternal("ComServer: Cannot listen");
		}
	}
}

// Logs events to the specified file
function fWCSLogInternal(String x)
{
	local String filename;

	filename = "WCS-ComServer-log";
	if (ComLog == None)
	{
		ComLog = Spawn(class'FileLog');
		if (ComLog != None)
		{
			ComLog.OpenLog(filename);
			ComLog.Logf(x);
		}
		else
		LogInternal(x);
	}
	else
	ComLog.Logf(x);
}

// Called when a binary message is received
event ReceivedBinary(int count, byte B[255])
{
	if (bDebug)
	LogInternal("ComServer: Binary message recieved");
}

// Logs when a connection is accepted
event Accepted()
{
	if (bDebug)
	LogInternal("ComServer: Connected to " $ IpAddrToString(RemoteAddr));
}

// Cleans up when a connection is closed
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

// Called when a new ComServerNewCon is spawned
event GainedChild(Actor C)
{
	local ComServerNewCon con;
	
	con = ComServerNewCon(C);
	con.MessageHandler = self;
	if (bDebug)
	LogInternal("ComServer: Accepted connection");
}

// Called when a connection is closed
event LostChild(Actor C)
{
	local ComServerCon con;
	con = ComServerCon(C);
	con.MessageHandler = None;
	if (bDebug)
	LogInternal("ComServer: Closed connection");
}

defaultproperties
{
	AcceptClass=USARBotApi.ComServerNewCon
	bBound=false
	bDebug=false
	ConnectionCount=0
	MsgSplit=" "
	MsgEnd=";"
	numReg=0
	numListen=0
	numCon=0
	PartMsg=""
}
