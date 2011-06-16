/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * BotConnection: Responsible for handling all TCP connections
 */
class BotConnection extends TcpLink config(USAR);

var BotServer Parent;
var BotController theBot;
var MessageParser messageParser;
var config bool bIterative;

// Socket established
event Accepted()
{
	if (bDebug)
		LogInternal("Accepted BotConnection " $ self);

	SendGameInfo();
	gotoState('monitoring', 'WaitingForInit');
}

// Sends game information over the socket
function SendGameInfo()
{
	local String timeLimitStr, gameInfoClass, levelName;
	local int i;

	timeLimitStr = String(Parent.Parent.GetTimeLimit());
	gameInfoClass = Parent.Parent.GetGameInfoClass();
	levelName = GetURLMap();
	i = InStr(Caps(levelName), ".LEVELINFO");
	if (i != -1)
		levelName = Left(levelName, i);
	SendLine("NFO {Gametype " $ gameInfoClass $ "} {Level " $ levelName $ "} {TimeLimit " $
		timeLimitStr $ "}");
}

// Event occuring when initialization string is first received from
// the client socket.  At this point, the bot itself *hasn't been created*.
// Robot-centric initialization done here may cause problems with multi-
// client distribution, as robot pawn may not be created yet.
event InitReceived(ParsedMessage parsedMessage)
{
	local String clientName, startName, teamString, className;
	local PlayerStart P;
	local int teamNum;
	local vector startLocation, newLocation;
	// x,y,z corresponds to roll,pitch,yaw
	local vector startRotation;
	local rotator newRotation;

	if (bDebug)
		LogInternal("BotConnection: InitReceived");
	clientName = parsedMessage.GetArgVal("Name");
	teamString = parsedMessage.GetArgVal("Team");
	startName = parsedMessage.GetArgVal("Start");
	if (startName != "")
	{
		foreach AllActors(class 'PlayerStart', P)
			if (Caps(String(P.Tag)) == Caps(startName))
			{
				newLocation = P.Location; // Stays in UU
				newRotation = P.Rotation;
				break;
			}
	}
	else
	{
		startLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		startRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		newLocation = class'UnitsConverter'.static.LengthVectorToUU(startLocation);
		newRotation = class'UnitsConverter'.static.AngleVectorToUU(startRotation);
	}
	className = parsedMessage.GetArgVal("ClassName");
	if (teamString == "")
		teamNum = 255;
	else
		teamNum = int(teamString);
	LogInternal("Adding robot at location: " $ newLocation $ ", rotation: " $ newRotation);
	Parent.Parent.AddBotController(self, clientName, teamNum, newLocation, newRotation, className);
	gotoState('monitoring', 'WaitingForController');
}

// Event occurs when bot has been created on server.  Client socket is 
// bound to bot pawn here.  All post-robot-creation initialization should
// be done here to be compatible with multi-client distribution.
event SetController(BotController bc)
{
	local USARVehicle usarVehicle;
	
	if (bDebug)
		LogInternal("BotConnection: SetController");
	theBot = bc;
	theBot.theBotConnection = self;
	if (theBot != None)
	{
		usarVehicle = USARVehicle(theBot.pawn);
		if (usarVehicle != None)
			usarVehicle.MessageSendDelegate = receiveMessage;
	}
	gotoState('monitoring', 'Running');
}

event Closed()
{
	if (bDebug)
		LogInternal("BotConnection: Closed");
	if (theBot != None)
	{
		Parent.Parent.DeleteBotController(theBot);
		theBot.Destroy();
	}
	Destroy();
}

// Receive info - parse into lines and call ReceivedLine
event ReceivedText(string Text)
{
	local ParsedMessage parsedMessage;
	local name curBotState;

	if (bDebug)
		LogInternal("BotConnection: Received " $ Text);
	if (theBot != None)
		curBotState = theBot.GetStateName();
	messageParser.ReceiveText(Text);
	while (true)
	{
		parsedMessage = messageParser.getNextMessage();
		if (parsedMessage == None)
			break;
		if (LinkState == STATE_Connected && curBotState != 'Dying' && curBotState != 'GameEnded')
			ProcessAction(parsedMessage);
	}
}

function PreBeginPlay()
{
	Parent = BotServer(Owner);
	if (bDebug)
		LogInternal("BotConnection: Spawned");
}

function ProcessAction(ParsedMessage parsedMessage)
{
	local USARVehicle usarVehicle;

	if (bDebug)
		LogInternal("BotConnection: Received Command type " $ parsedMessage.GetCommandType());
	if (bIterative)
		WorldInfo.Pauser = None;
	switch (Caps(parsedMessage.GetCommandType()))
	{
	case "INIT":
		InitReceived(parsedMessage);
		break;
	case "POSALL":
		ProcessPosAll(parsedMessage);
		break;
	case "TRACE":
		ProcessTrace(parsedMessage);
		break;
	case "PAUSE":
		ProcessPause(parsedMessage);
		break;
	case "GETSTARTPOSES":
		ProcessGetStartPoses(parsedMessage);
		break;
	case "CONTROL":
		ProcessWorldController(parsedMessage);
		break;
	default:
	}
	if (theBot == None) return;
	usarVehicle = USARVehicle(theBot.Pawn);
	
	// Vehicle must have battery life remaining for these messages
	if (usarVehicle != None && usarVehicle.GetBatteryLife() > 0)
		switch (Caps(parsedMessage.GetCommandType()))
		{
		case "TEST":
			ProcessTest(parsedMessage);
			break;
		case "CAMERA":
			ProcessCamera(parsedMessage);
			break;
		case "TURN":
			ProcessTurn(parsedMessage);
			break;
		case "DRIVE":
			ProcessDrive(parsedMessage);
			break;
		case "SETBALL":
			ProcessSetball(parsedMessage);
			break;
		case "FACTORY":
			ProcessFactoryController(parsedMessage);
			break;
		case "SENSOR":
			ProcessSensor(parsedMessage);
			break;
		case "EFFECTOR":
			ProcessEffector(parsedMessage);
			break;
		case "GETGEO":
			ProcessGetGeo(parsedMessage);
			break;
		case "GETCONF":
			ProcessGetConf(parsedMessage);
			break;
		case "SET":
			ProcessSet(parsedMessage);
			break;
		case "MISPKG":
			ProcessMisPkg(parsedMessage);
			break;
		default:
		}
}

// Enters "TEST" mode
function ProcessTest(ParsedMessage parsedMessage)
{
	if (theBot != None) 
		theBot.GotoState('Startup', 'Test');
}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessCamera(ParsedMessage parsedMessage)
{

}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessTurn(ParsedMessage parsedMessage)
{

}

// Handle a DRIVE command which varies by robot
function ProcessDrive(ParsedMessage parsedMessage)
{
	local USARVehicle bot;
	local String value;
	
	bot = USARVehicle(theBot.Pawn);
	// Check if normalized drive command was received
	value = parsedMessage.GetArgVal("Normalized");
	if (value != "")
		bot.SetNormalized(value == "true");
	// Check for headlight command
	value = parsedMessage.GetArgVal("Light");
	if (value != "")
		bot.SetHeadLights(value == "true");
	// Individual vehicle drives
	bot.Drive(parsedMessage);
}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessSetBall(ParsedMessage parsedMessage)
{

}

// Manipulate objects in the world
function ProcessWorldController(ParsedMessage parsedMessage)
{
	local WorldController control;
	local vector myLocation, myLocation2;
	local vector myRotation;
	local vector myScale;
	local String myName;
	local String startName;
	local PlayerStart P;
	local bool permanent;

	if (bDebug)
		LogInternal("BotConnection: Received world control message type: " $
			parsedMessage.GetArgVal("Type"));
	if (theBot == None || !theBot.Pawn.IsA('WorldController'))
	{
		LogInternal("BotConnection: Bot is not a world controller");
		return;
	}
	control = WorldController(theBot.Pawn);
	// CONTROL {Type RelMove} {Name name} {Location x,y,z} {Rotation x,y,z}
	if (parsedMessage.GetArgVal("Type") == "RelMove")
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		control.RelMove(myName, myLocation, myRotation);
	}
	// CONTROL {Type AbsMove} {Name name} {Location x,y,z} {Rotation x,y,z}
	else if (parsedMessage.GetArgVal("Type") == "AbsMove")
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		control.AbsMove(myName, myLocation, myRotation);
	}
	// CONTROL {Type Create} {ClassName class} {Name name} {Memory memory} {Location x,y,z}
	// {Rotation x,y,z} {Physics None/Ground/Falling} {Permanent true/false}	
	else if (parsedMessage.GetArgVal("Type") == "Create")
	{
		startName = parsedMessage.GetArgVal("Start");
		if (startName != "") 
		{
			foreach AllActors(class 'PlayerStart', P) 
				if (string(P.Tag) == startName) 
				{
					// Convert to meters
					myLocation = class'UnitsConverter'.static.LengthVectorFromUU(P.Location);
					myRotation = class'UnitsConverter'.static.AngleVectorFromUU(P.Rotation);
					break;
				}
		}
		else 
		{
			myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
			myRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));	   
		}
		myScale = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Scale"));
		if (myScale == vect(0,0,0))
			myScale = vect(1,1,1);
		permanent = (Caps(parsedMessage.GetArgVal("Permanent")) == "TRUE");
		control.Create(parsedMessage.GetArgVal("ClassName"), parsedMessage.GetArgVal("Name"),
			parsedMessage.getArgVal("Memory"), myLocation, myRotation, myScale,
			parsedMessage.GetArgVal("Physics"), permanent);
	}
	// CONTROL {Type Kill} {Name name}
	else if (parsedMessage.GetArgVal("Type") == "Kill")
		control.Kill(parsedMessage.GetArgVal("Name"));
	// CONTROL {Type KillAll} {MinPos x, y, z} {MaxPos x, y, z}
	else if (parsedMessage.GetArgVal("Type") == "KillAll")
	{
		if (parsedMessage.GetArgVal("MinPos") == "" || parsedMessage.GetArgVal("MaxPos") == "")
		{
			// Destroy all
			myLocation = vect(0, 0, 0);
			myLocation2 = vect(0, 0, 0);
		}
		else
		{
			// Destroy in rectangle
			myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MinPos"));
			myLocation2 = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MaxPos"));
		}
		control.KillAll(myLocation, myLocation2);
	} 
	// CONTROL {Type GetSTA} {ClassName type} {Name name}
	else if (parsedMessage.GetArgVal("Type") == "GetSTA")
		SendLine(control.GetSTA(parsedMessage.GetArgVal("ClassName"),
			parsedMessage.GetArgVal("Name"))); 
	// CONTROL {Type Conveyor} {Name name} {Speed speed}
	else if (parsedMessage.GetArgVal("Type") == "Conveyor")
		control.SetZoneVel(parsedMessage.GetArgVal("Name"),
			float(parsedMessage.GetArgVal("Speed")));
	else
		LogInternal("BotConnection: Unsupported world controller command " $
			parsedMessage.GetArgVal("Type"));
}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessFactoryController(ParsedMessage parsedMessage)
{

}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessSensor(ParsedMessage parsedMessage)
{

}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessEffector(ParsedMessage parsedMessage)
{

}

// Gets geometric configuration from the robot
function ProcessGetGeo(ParsedMessage parsedMessage)
{
	local String Type;
	local USARVehicle bot;

	Type = parsedMessage.GetArgVal("Type");
	bot = USARVehicle(theBot.Pawn);
	if (Type == "Robot")
		SendLine(bot.GetGeoData());
	else if (Type == "MisPkg")
		SendLine(bot.GetMisPkgGeoData());
	else
		SendLine(bot.GetGeneralGeoData(Type, parsedMessage.GetArgVal("Name")));
}

// Gets configuration information from the robot
function ProcessGetConf(ParsedMessage parsedMessage) 
{
	local String Type;
	local USARVehicle bot;

	Type = parsedMessage.GetArgVal("Type");
	bot = USARVehicle(theBot.Pawn);
	if (Type == "Robot")
		SendLine(bot.GetConfData());
	else if (Type == "MisPkg")
		SendLine(bot.GetMisPkgConfData());
	else
		SendLine(bot.GetGeneralConfData(Type, parsedMessage.GetArgVal("Name")));
}

// Sets joint angles or other related parameters
function ProcessSet(ParsedMessage parsedMessage)
{
	local String jointName, opcode;
	local float param;
	local USARVehicle bot;

	bot = USARVehicle(theBot.Pawn);
	jointName = parsedMessage.GetArgVal("Name");
	opcode = parsedMessage.GetArgVal("Opcode");
	param = float(parsedMessage.GetArgVal("Params"));
	if (opcode == "Angle")
	{
		if (JointName != "AllAngles")
			bot.SetJointTargetByName(JointName, param);
		else
			bot.SetAllJointTargets(param);
	}
	else if (opcode == "Stiffness")
		bot.SetJointStiffnessByName(Name(JointName), param);
	else if (opcode == "MaxTorque" && bot.IsA('WheeledVehicle'))
		WheeledVehicle(bot).SetMaxTorque(param);
}

// Manipulates mission packages
function ProcessMisPkg(ParsedMessage parsedMessage)
{
	local String misPkgName;
	local int i;
	local int argCount;
	local int link;
	local float value;
	local int order;
	local int gripper;
	local int seq;
	local array<String> receivedArgs;
	local array<String> receivedVals;
	
	MisPkgName = parsedMessage.GetArgVal("Name");
	for (i = 0; i < theBot.Pawn.Children.length; i++)
		if (theBot.Pawn.Children[i].Tag == name(MisPkgName))
		{
			ReceivedArgs = parsedMessage.GetArguments();
			ReceivedVals = parsedMessage.GetValues();
			for (argCount = 0; argCount < ReceivedArgs.Length; argCount++) 
			{
				// Case 1: Link Value Order
				if (Caps(ReceivedArgs[argCount]) == "LINK") 
				{
					Link = int(ReceivedVals[argCount]);
					argCount++;
					if (argCount < ReceivedArgs.Length && Caps(ReceivedArgs[argCount]) == "VALUE") 
					{
						Value = float(ReceivedVals[argCount]);
						argCount++;
						if (argCount < ReceivedArgs.Length && Caps(ReceivedArgs[argCount]) == "ORDER") 
						{
							Order = int(ReceivedVals[argCount]);
							MissionPackage(theBot.Pawn.Children[i]).setThisRotation(Link, Value, Order);
						}
					}
					else if (argCount < ReceivedArgs.Length)
						argCount--;
				}
				// Case 2: Gripper
				if (Caps(ReceivedArgs[argCount]) == "GRIPPER") 
				{
					if (bDebug)
						LogInternal("Gripper Command called");
					Gripper = int(ReceivedVals[argCount]);
					MissionPackage(theBot.Pawn.Children[i]).setGripperToBox(Gripper);
				}
				// Case 3: Sequence
				if (Caps(ReceivedArgs[argCount]) == "SEQ") 
				{
					if (bDebug)
						LogInternal("Sequence Command called");
					Seq = int(ReceivedVals[argCount]);
					MissionPackage(theBot.Pawn.Children[i]).runSequence(Seq);
				}
			}
			return;
		}
}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessPosAll(ParsedMessage parsedMessage)
{

}

// TODO It does not appear that tracing works in the UT3 implementation
function ProcessTrace(ParsedMessage parsedMessage)
{

}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function ProcessPause(ParsedMessage parsedMessage)
{

}

// Returns a list of valid starting positions for a robot
function ProcessGetStartPoses(ParsedMessage parsedMessage)
{
	local String outstring, locations;
	local PlayerStart P;
	local vector l,vr;
	local int num;

	foreach AllActors(class 'PlayerStart', P)
	{
		l = class'UnitsConverter'.static.LengthVectorFromUU(P.Location);
		vr = class'UnitsConverter'.static.AngleVectorFromUU(P.Rotation);
		if (num > 0)
			locations = locations $ " " $ P.Tag $ " " $ l.X $ "," $ l.Y $"," $ l.Z $ " " $
				vr.X $ "," $ vr.Y $ "," $vr.Z;
		else
			locations = P.Tag $ " " $  l.X $ "," $ l.Y $ "," $ l.Z $ " " $ vr.X $ "," $
				vr.Y $ "," $ vr.Z;
		num++;
	}
	outstring = "NFO {StartPoses " $ num $ "}";
	if (num > 0)
		outstring = outstring $ " {" $ locations $ "}";
	if (bDebug)
		LogInternal(outstring);
	SendLine(outstring);
}

// Delegate for robots to send messages back to the client
function receiveMessage(String Text)
{
	SendLine(Text);
}

// Sends a line of text to the client
function SendLine(String text, optional bool bNoCRLF)
{
	if (text != "") {
		if (bDebug)
			LogInternal("BotConnection: Sending " $ text);
		if (bNoCRLF)
			SendText(text);
		else
			SendText(text $ Chr(13) $ Chr(10));
	}
}

// TODO Not sure what this function should do - not in the wiki API nor in UT3 implementation
function int findFirstCameraMisPkg()
{

}

// Fire right up into the loop for sending updates
auto state monitoring
{
	Begin:
	WaitingForInit:
		sleep(0.1);
		goto 'WaitingForInit';
	WaitingForController:
		sleep(0.1);
		goto 'WaitingForController';
	Running:
		sleep(0.1);
		goto 'Running';
}

defaultproperties
{
	bDebug=false
	Begin Object Class=MessageParser Name=newMessageParser
	End Object
	messageParser=newMessageParser
}
