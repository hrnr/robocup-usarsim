/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

/*
 * ComServer: creates ComLink in order to manage connections between robot and controller
 */
class ComServer extends TcpLink config(USAR);

var config int ListenPort;
var String gameClass;
var bool bBound;
var config bool bLogWCS;
var int ConnectionCount;
var array<String> ParsedMessg;
var String MsgSplit;
var String MsgEnd;
var String PartMsg;
var FileLog ComLog;

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

// Check if a robot is registered with the server
// If it is registered, then return the registration number; else return -1
function int isRegistered(String sName)
{
	local int i;
	
	for (i = 0; i < numReg; i++)
		if (sName == RegRobots[i].str1)
			return i;
	return -1;
}

// Check if a robot is listening
function bool isListening(String sName)
{
	local int i;
	
	for (i = 0; i < numListen; i++)
		if (sName == Listening[i].str1)
			return true;
	return false;
}

// Check if a robot is listening at a specific port
function bool isListening2(String sName, String sPort)
{
	local int i;
	
	for (i = 0; i < numListen; i++)
		if (sName == Listening[i].str1 && sPort == Listening[i].str2)
			return true;
	return false;
}

// Get the index of the robot listening at the specific port
function int getListenerNum(String sName, String sPort)
{
	local int i;
	
	for (i = 0; i < numListen; i++)
		if (sName == Listening[i].str1 && sPort == Listening[i].str2)
			return i;
		i++;
	return -1;
}

// Get the IP of the robot
function String getRobotIP(String sName)
{
	local int i;
	
	for (i = 0; i < numReg; i++)
		if (sName == RegRobots[i].str1)
			return RegRobots[i].str2;
	return "";
}

// Get the port the robot is listening at
function String getRobotPort(String sName)
{
	local int i;
	
	for (i = 0; i < numListen; i++)
		if (sName == Listening[i].str1)
			return Listening[i].str2;
	return "";
}

// Server can't get Signal Strength
function float getSigStrength(String r1, String r2)
{
	if (bDebug)
		LogInternal("ComServer: Cannot calculate signal strength");
	return 1;
}

// Server can't check for connectivity
function bool isReachable(String r1, String r2)
{
	if (bDebug)
		LogInternal("ComServer: Cannot get robot information");
	return true;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	LinkMode = MODE_Text;
    if (!bBound)
    {
		BindPort(ListenPort);
		if (bDebug)
    		LogInternal("ComServer: Listening on " $ ListenPort);
		if (Listen())
			bBound = true;
		else if (bDebug)
			LogInternal("ComServer: Cannot listen");
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

// Parses the specified message
function HandleLine(String Line, TCPLink ep, String remoteip)
{
	local String cmdType;
	local int attrNum, i,j, regNo;
	local bool b1,b2;
	local float ss;
    
	if (bLogWCS)
		fWCSLogInternal(WorldInfo.TimeSeconds $ " " $ Line);
	if (bDebug)
		LogInternal("ComServer: Received " $ Line);
	// Removes end of message delimiter
	i = InStr(Line, MsgEnd);
	if (i == -1)
	{
		i = Len(Line);
		if (bDebug)
			LogInternal("ComServer: Missing end terminator: " $ Line);
	}
	Line = Left(Line,i);
	// Splits message	
    // old set array [before,splitString,after]
    // new sets String to before, returns after
    ParseStringIntoArray(Line, ParsedMessg, MsgSplit, true);
    attrNum = ParsedMessg.Length;
	if (bDebug)
		LogInternal("ComServer: Message contained " $ attrNum $ " words");
	cmdType = ParsedMessg[0];
   	cmdType = Caps(cmdType);
	
	// Process the command
	switch (cmdType)
	{
		case "REGISTER":
			// Check for correct message length
			if (attrNum != 3)
			{
				if (bDebug)
					LogInternal("ComServer: Incorrect message length: " $ Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			// Check if a robot with the same name is registered
			regNo = isRegistered(ParsedMessg[1]);
			if (regNo != -1)
			{
				if (RegRobots[regNo].str2 != ParsedMessg[2])
				{
					if (bDebug)
						LogInternal("ComServer: Robot " $ ParsedMessg[1] $ " already registered");
					ep.SendText("Fail: Robot with name " $ ParsedMessg[1] $ " already registered;");
					break;
				}
				else if (bDebug)
				{
					LogInternal("ComServer: " $ RegRobots[numReg].str1 $
						" re-registered with IP " $ RegRobots[numReg].str2);
					LogInternal("ComServer: " $ (numReg + 1) $ " robots registered");
				}
			}
			else
			{
				// Register robot
				RegRobots.insert(numReg, 1);
				RegRobots[numReg].str1 = ParsedMessg[1];
				RegRobots[numReg].str2 = ParsedMessg[2];
				if (bDebug)
				{
					LogInternal("ComServer: " $ RegRobots[numReg].str1 $ " registered with IP " $
						RegRobots[numReg].str2);
					LogInternal("ComServer: " $ (numReg + 1) $ " robots registered");
				}
				numReg++;
			}
			ep.SendText("OK;");
			break;
		case "LISTEN":
			// Check for correct message length
			if (attrNum != 3)
			{
				if (bDebug)
					LogInternal("ComServer: Incorrect message length: " $ Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			// Check if the robot is registered
			if (isRegistered(ParsedMessg[1]) == -1)
			{
				if (bDebug)
					LogInternal("ComServer: Robot " $ ParsedMessg[1] $ " not registered");
				ep.SendText("Fail: Robot " $ ParsedMessg[1] $ " not registered;");
				break;
			}
			// Check if a robot with the same name is listening at the same port
			if (isListening(ParsedMessg[1]))
			{
				if (getRobotPort(ParsedMessg[1]) == ParsedMessg[2])
				{
					if (bDebug) LogInternal("ComServer: Robot " $ ParsedMessg[1] $
						" already listening at port " $ ParsedMessg[2]);
					ep.SendText("Fail: Robot with name " $ ParsedMessg[1] $
						" already listening at port " $ ParsedMessg[2] $ ";");
					break;
				}
			}
			// Add to listening list
			Listening.insert(numListen, 1);
			Listening[numListen].str1 = ParsedMessg[1];
			Listening[numListen].str2 = ParsedMessg[2];
			if (bDebug)
			{
				LogInternal("ComServer: " $ Listening[numListen].str1 $ " listening at port " $
					Listening[numListen].str2);
				LogInternal("ComServer: " $ (numListen + 1) $ " robots listening");
			}
			numListen++;
			ep.SendText("OK;");
			break;
		case "OPEN":
			// Check for correct message length
			if (attrNum != 5)
			{
				if (bDebug)
					LogInternal("ComServer: Incorrect message length: " $ Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			// Check if host is listening on specified port
			if (!isListening2(ParsedMessg[3], ParsedMessg[4]))
			{
				if (bDebug)
					LogInternal("ComServer: " $ ParsedMessg[3] $ " not listening on port " $
						ParsedMessg[4]);
				ep.SendText("Fail: " $ ParsedMessg[3] $ " not listening on port " $
					ParsedMessg[4] $ ";");
				break;
			}
			// Check for connectivity
			if (!isReachable(ParsedMessg[1],ParsedMessg[3]))
			{
				if (bDebug)
					LogInternal("ComServer: Cannot connect to " $ ParsedMessg[3]);
				ep.SendText("Fail: Cannot connect to " $ ParsedMessg[3] $ ";");
				break;
			}
			// Set up the connections
			Connected.insert(numCon, 1);
			Connected[numCon] = Spawn(class'ComConnection',self);
			Connected[numCon].setUp(ParsedMessg[1], ParsedMessg[3]);
			Connected[numCon].link1.Connect(getRobotIP(ParsedMessg[1]), ParsedMessg[2]);
			Connected[numCon].link2.Connect(getRobotIP(ParsedMessg[3]), ParsedMessg[4]);
			// Check if the connection was established
			b1 = (Connected[numCon].link1.LinkState == STATE_Connecting ||
				Connected[numCon].link1.LinkState == STATE_Connected);
			b2 = (Connected[numCon].link2.LinkState == STATE_Connecting ||
				Connected[numCon].link2.LinkState == STATE_Connected);
			//If the connection was established
			if (b1 && b2)
			{
				// Remove listening robot
				i = getListenerNum(ParsedMessg[3], ParsedMessg[4]);
				Listening.remove(i, 1);
				numListen--;
				if (bDebug)
				{
					LogInternal("ComServer: " $ ParsedMessg[1] $ " connected to " $ ParsedMessg[3]);
					LogInternal("ComServer: " $ (numCon + 1) $ " connections created");
				}
				ep.SendText("OK;");
				numCon++;
			}
			else
			{
				Connected.remove(numCon, 1);
				if (bDebug)
					LogInternal("ComServer: " $ ParsedMessg[1] $ " could not connect to " $
						ParsedMessg[3]);
				ep.SendText("Fail: Could not establish connection;");
			}
			break;
		// Command to get signal strength between two robots
		case "GETSS":
			// Check for correct message length
			if (attrNum != 3)
			{
				if (bDebug)
					LogInternal("ComServer: Incorrect message length: " $ Line);
				ep.SendText("Fail: Incorrect Message;");
				break;
			}
			// Check for 3rd party requests
			j = InStr(remoteip,":");
			if (j >= 0)
				remoteip = Left(remoteip, j);
			if (getRobotIP(ParsedMessg[1]) != remoteip && getRobotIP(ParsedMessg[2]) != remoteip)
			{
				LogInternal(remoteip $ " " $ getRobotIP(ParsedMessg[1]) $ " " $
					getRobotIP(ParsedMessg[2]));
				if (bDebug)
					LogInternal("ComServer: Third party request for Sig Strength!");
				ep.SendText("Fail: Server does not accept third party requests;");
				break;
			}
			ss = getSigStrength(ParsedMessg[1],ParsedMessg[2]);
			if (bDebug)
				LogInternal("ComServer: Signal strength between " $ ParsedMessg[1] $ " and " $
					ParsedMessg[2] $ " is " $ ss);
			if (ss > 0)
				ep.SendText("Fail: Could not calculate signal strength;");
			else
				ep.SendText("OK:" $ ss $ ";");
			break;
		default:
			if (bDebug)
				LogInternal("ComServer: Unknown message: " $ Line);
			ep.SendText("Fail: Unknown Message;");
	}
}

event ReceivedLine(String Line)
{
	HandleLine(Line, Self, IpAddrToString(RemoteAddr));
}

// If you receive text instead of by line
event ReceivedText(String text)
{
	local int i;
	local String msg;
	
	i = 0;
    if (bDebug)
    	LogInternal("ComServer: Received " $ text);
	
	i = InStr(text, MsgEnd);
	// If incomplete
	if (i < 0)
		PartMsg $= Text;
	else
		msg = PartMsg $ Left(text, i + 1);
		PartMsg = Mid(text, i + 1);
		HandleLine(msg, self, IpAddrToString(RemoteAddr));
}

// If a binary message is received
event ReceivedBinary(int count, byte B[255])
{
	if (bDebug)
		LogInternal("ComServer: Received binary message");
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
	if (LinkState != STATE_Listening && LinkState != STATE_Connecting &&
			LinkState != STATE_Connected)
		Listen();
	if (bDebug)
	{
		LogInternal(LinkState);
		LogInternal("ComServer: Old connection closed, listening for new connections");
	}
}

// Called every time a new connection is spawned
event GainedChild(Actor C)
{
	local ComServerCon con;
	con = ComServerCon(C);
	con.MessageHandler = self;
	con.bInit = true;
	if (bDebug)
		LogInternal("ComServer: Accepted connection");
}

// Called every time a connection is closed
event LostChild(Actor C)
{
	local ComServerCon con;
	con = ComServerCon(C);
	con.MessageHandler = None;
	con.bInit = false;
	if (bDebug)
		LogInternal("ComServer: Closed connection");
}

defaultproperties
{
	AcceptClass=USARBotApi.ComServerCon
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
