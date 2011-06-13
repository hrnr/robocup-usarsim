/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * ComConnection: communicates between two sockets
 */
class ComConnection extends Actor config(USAR);

var ComLink link1, link2;
var bool bInit;
var class<ComLink> CLclass;
var FileLog ComLog;
var config bool bLogWCS;

// Initializes the two ComLink classes
function SetUp(String id1, String id2)
{
	if (!bInit)
	{
		// Spawn two ComLink objects
		link1 = Spawn(CLclass,self);
		if (link1 != None)
			link1.setUp(id1);
		link2 = Spawn(CLclass,self);
		if (link2 != None)
			link2.setUp(id2);
		if (link1 != None && link2 != None)
			bInit = true;
		else if (bDebug)
			LogInternal("ComConnection: Cannot create links");
	}
}

// Verifies that the owner can be reached by both clients
function bool checkConnectivity()
{
	return ComServer(Owner).isReachable(link1.id, link2.id);
}

// Logs events to the specified file
function fWCSLogInternal(String x)
{
	local String filename;

	filename = "WCS-ComConnection-log";
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

// Process requests sent by the robot
function processMessage(String cmd, int count, byte M[255], String id)
{	
	if (bLogWCS)
	{
		if (id == link1.id)
			fWCSLogInternal("@" $ WorldInfo.TimeSeconds $ " (" $ link1.id $ " > " $ link2.id $
				") " $ count $ ": " $ cmd);
		else
			fWCSLogInternal("@" $ WorldInfo.TimeSeconds $ " (" $ link2.id $ " > " $ link1.id $
				") " $ count $ ": " $ cmd);			
	}
	
	switch (cmd)
	{
		case "SEND":
			if (id == link1.id && link2.bInit)
				link2.SendBinary(Count, M);
			else if (id != link1.id && link1.bInit)
				link1.SendBinary(Count,M);
			break;
		case "CLOSE":
			if (link1.bInit)
			{
				if (bDebug)
					LogInternal("ComConnection: Closing connection to " $ link1.id);
				link1.Close();
				link1.bInit = false;
			}
			if (link2.bInit)
			{
				if (bDebug)
					LogInternal("ComConnection: Closing connection to " $ link2.id);
				link2.Close();
				link2.bInit = false;
			}
			break;
		default:
			if (bDebug)
				LogInternal("ComConnection: Unknown message - " $ cmd);
			if (id == link1.id)
				Link1.SendText("Fail: Unknown message;");
			else
				Link2.SendText("Fail: Unknown message;");
	}
}

defaultproperties
{
	CLclass=USARBotApi.ComLink
	bInit=false
	bDebug=false
}
