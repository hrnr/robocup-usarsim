/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * Every BotController created has an associated BotConnection which is a TCP connection from
 * which the BotController was created.
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
	local String clientName;
	local String startName;
	local String teamString;
	local String className;
	local PlayerStart P;
	local int teamNum;
	local vector startLocation;
	// x,y,z corresponds to roll,pitch,yaw
	local vector startRotation;
	local vector newLocation;
	local rotator newRotation;

	if (bDebug)
		LogInternal("BotConnection:InitReceived");

	clientName = parsedMessage.GetArgVal("Name");
	teamString = parsedMessage.GetArgVal("Team");

	startName = parsedMessage.GetArgVal("Start");
	if (startName != "")
		foreach AllActors(class 'PlayerStart', P)
			if (string(P.Tag) == startName)
			{
				newLocation = P.Location; // stays in UU
				newRotation = P.Rotation;
				break;
			}
	else
	{
		/*
		 * The 'Rotator' class has integer fields 'roll', 'pitch' and 'yaw'.
		 * We need to take special care to convert these to and from UU
		 * since any intermediate integer step will be truncated.
		*/
		startLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		startRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		newLocation = class'UnitsConverter'.static.LengthVectorToUU(startLocation);
		newRotation = class'UnitsConverter'.static.DeprecatedRotatorToUU(startRotation);
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
		LogInternal("BotConnection:SetController");
	theBot = bc;
	theBot.theBotConnection = self;
	if (theBot != None)
	{
		usarVehicle = USARVehicle(theBot.pawn);
		usarVehicle.MessageSendDelegate = receiveMessage;
	}
	gotoState('monitoring', 'Running');
}

event Closed()
{
	if (bDebug)
		LogInternal("BotConnection:Closed");
	if (theBot != None)
	{
		Parent.Parent.DeleteBotController(theBot);
		theBot.RemoteDestroy();
	}
	else
		LogInternal("BotConnection: None encountered in Closed()");
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
	
	// Vehicle must have a battery for these messages
	if (usarVehicle != None && (usarVehicle.VehicleBattery == None ||
			!usarVehicle.VehicleBattery.isDead()))
		switch(Caps(parsedMessage.GetCommandType()))
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

function ProcessTest(ParsedMessage parsedMessage)
{
	if (theBot != None) 
		theBot.GotoState('Startup', 'Test');
}

function ProcessCamera(ParsedMessage parsedMessage)
{

}

function ProcessTurn(ParsedMessage parsedMessage)
{

}

// Commands to handle:
//  DRIVE {Left float} {Right float} {Normalized bool} {Light bool}
//  DRIVE {Speed float} {FrontSteer float} {RearSteer float} {Normalized bool} {Light bool} {Flip bool}
//  DRIVE {Propeller float} {Rudder float} {SternPlane float} {Normalized bool} {Light bool}
//  DRIVE {AltitudeVelocity float} {LinearVelocity float} {LateralVelocity float} {RotationalVelocity float} {Normalized bool}
//  DRIVE {WheelNumber int} {WheelSpeed float} {WheelSteer float} {WheelNumber int} (WheeSpeed float} ...
//  DRIVE (Name string} {Steer int} {Order int} {Value float}
//  DRIVE {Name string} {Bone name} {Order int} {Value float} {Axis string(one letter)}
//  DRIVE {Left float} {Right float}
function ProcessDrive(ParsedMessage parsedMessage)
{
	local float leftSpeed, rightSpeed;

	if (theBot.Pawn.IsA('SkidSteeredVehicle'))
	{
		leftSpeed = float(parsedMessage.GetArgVal("Left"));
		rightSpeed = float(parsedMessage.GetArgVal("Right"));
		SkidSteeredVehicle(theBot.Pawn).SetDriveSpeed(leftSpeed, rightSpeed);
	}
	// Check if normalized drive command was received
	if (parsedMessage.GetArgVal("Normalized") != "")
		USARVehicle(theBot.Pawn).setNormalized(bool(parsedMessage.GetArgVal("Normalized")));
	else
		USARVehicle(theBot.Pawn).setNormalized(false);
	// Check for headlight command
	if (parsedMessage.GetArgVal("Light") != "")
		USARVehicle(theBot.Pawn).setHeadLights(bool(parsedMessage.GetArgVal("Light")));
}


function ProcessSetBall(ParsedMessage parsedMessage)
{

}

function ProcessWorldController(ParsedMessage parsedMessage)
{
	local vector myLocation, myLocation2;
	local vector myRotation;
	local vector myScale;
	local String myName;
	local String startName;
	local PlayerStart P;
	local bool permanent;

	if (bDebug)
		LogInternal("BotConnection: Received world control message type: " $
			parsedmessage.GetArgVal("Type"));
	if (theBot == None || !theBot.Pawn.IsA('WorldController'))
    {
		LogInternal("BotConnection: Bot is not a world controller");
		return;
	}
	// CONTROL {Type RelMove} {Name name} {location x,y,z} {rotation x,y,z}
	if (parsedMessage.GetArgVal("Type") == "RelMove")
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		WorldController(theBot.pawn).RelMove(myName, myLocation, myRotation);
	}
	// CONTROL {Type AbsMove} {Name name} {location x,y,z} {rotation x,y,z}
	else if (parsedMessage.GetArgVal("Type") == "AbsMove")
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		WorldController(theBot.pawn).AbsMove(myName, myLocation, myRotation);
	}
	// CONTROL {Type Create} {ClassName class} {Name name} {Memory memory} {location x,y,z}
	// {rotation x,y,z} {Physics None/Ground/Falling} {Permanent true/false}	
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
					myRotation = class'UnitsConverter'.static.DeprecatedRotatorFromUU(P.Rotation);
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
		WorldController(theBot.pawn).Create(parsedMessage.GetArgVal("ClassName"),
			parsedMessage.GetArgVal("Name"), parsedMessage.getArgVal("Memory"), myLocation,
			myRotation, myScale, parsedMessage.GetArgVal("Physics"), permanent);
	}
	// CONTROL {Type Kill} {Name name}
	else if (parsedMessage.GetArgVal("Type") == "Kill")
		WorldController(theBot.pawn).Kill(parsedMessage.GetArgVal("Name"));
	// CONTROL {Type KillAll} {MinPos x, y, z} {MaxPos x, y, z}
	else if (parsedMessage.GetArgVal("Type") == "KillAll")
	{
		if (parsedMessage.GetArgVal("MinPos") == "" || parsedMessage.GetArgVal("MaxPos") == "")
		{
			// Destroy all
			myLocation = vect(0,0,0);
			myLocation2 = vect(0,0,0);
		}
		else
		{
			// Destroy in rectangle
			myLocation = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MinPos"));
			myLocation2 = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MaxPos"));
		}
		WorldController(theBot.pawn).KillAll(myLocation, myLocation2);
	} 
	// CONTROL {Type GetSTA}
	else if (parsedMessage.GetArgVal("Type") == "GetSTA")
		SendLine(WorldController(theBot.pawn).GetSTA(parsedMessage.GetArgVal("ClassName"),
			parsedMessage.GetArgVal("Name"))); 
	// CONTROL {Type Conveyor}
	else if (parsedMessage.GetArgVal("Type") == "Conveyor")
		WorldController(theBot.pawn).SetZoneVel(parsedMessage.GetArgVal("Name"),
			float(parsedMessage.GetArgVal("Speed")));
	else
		LogInternal("BotConnection: Unsupported world controller command " $
			parsedMessage.GetArgVal("Type"));
}

function ProcessFactoryController(ParsedMessage parsedMessage)
{

}

function ProcessSensor(ParsedMessage parsedMessage)
{

}

function ProcessEffector(ParsedMessage parsedMessage)
{

}

function ProcessGetGeo(ParsedMessage parsedMessage)
{
	local String Type;

	Type = parsedMessage.GetArgVal("Type");

	if (Type == "Robot")
		SendLine(USARVehicle(theBot.Pawn).GetGeoData());
	else if (Type == "MisPkg")
		SendLine(USARVehicle(theBot.Pawn).GetMisPkgGeoData());
	else if (Type == "Gripper")
		SendLine(USARVehicle(theBot.Pawn).GetEffectorGeoData(Type, parsedMessage.GetArgVal("Name")));
	else if (Type == "Sensor")
		SendLine(USARVehicle(theBot.Pawn).GetSensorGeoData(Type, parsedMessage.GetArgVal("Name")));
}

function ProcessGetConf(ParsedMessage parsedMessage) 
{
	local String Type;

	LogInternal("In BotConnection: ProcessGetConf()");

	Type = parsedMessage.GetArgVal("Type");

	if (Type=="Robot")
		SendLine(USARVehicle(theBot.Pawn).GetConfData());
	else if (Type=="MisPkg")
		SendLine(USARVehicle(theBot.Pawn).GetMisPkgConfData());
	else if (Type=="Gripper")
		SendLine(USARVehicle(theBot.Pawn).GetEffectorConfData(Type, parsedMessage.GetArgVal("Name")));
	else if (Type == "Sensor")
		SendLine(USARVehicle(theBot.Pawn).GetSensorConfData(Type, parsedMessage.GetArgVal("Name")));
}

function ProcessSet(ParsedMessage parsedMessage)
{
    local String JointName, Opcode;

	JointName = parsedMessage.GetArgVal("Name");
	Opcode = parsedMessage.GetArgVal("Opcode");

	if (Opcode == "Angle")
	{
		if (theBot.Pawn.IsA('LeggedRobot'))
			LeggedRobot(theBot.Pawn).SetJointAngle(JointName,
				class'UnitsConverter'.static.AngleToUU(float(parsedMessage.GetArgVal("Params"))));
		else if (JointName != "AllAngles" && theBot.Pawn.IsA('USARVehicle'))
			USARVehicle(theBot.Pawn).SetJointAngle(JointName,
				class'UnitsConverter'.static.AngleToUU(float(parsedMessage.GetArgVal("Params"))));
		else if (JointName == "AllAngles")
			WheeledVehicle(theBot.Pawn).SetAllJointAngles(
				class'UnitsConverter'.static.AngleToUU(float(parsedMessage.GetArgVal("Params"))));
	}
	else if (Opcode == "Stiffness" && theBot.Pawn.IsA('LeggedRobot'))
		LeggedRobot(theBot.Pawn).SetJointStiffnessByName(Name(JointName),
			float(parsedMessage.GetArgVal("Params")));
	else if (Opcode == "MaxTorque" && theBot.Pawn.IsA('WheeledVehicle'))
	{
			// TODO WheeledVehicle(theBot.Pawn).SetMaxTorque(float(parsedMessage.GetArgVal("Params")));
	}
}

function ProcessMisPkg(ParsedMessage parsedMessage)
{
	local String MisPkgName;
	local int i;
	local int argCount;
	local int Link;
	local float Value;
	local int Order;
	local int Gripper;
	local int Seq;
	local array<String> ReceivedArgs;
	local array<String> ReceivedVals;
	
	if (parsedMessage.GetArgVal("Name") != "")
		MisPkgName = parsedMessage.GetArgVal("Name");
	for (i = 0; i < theBot.Pawn.Children.length; i++)
		if (theBot.Pawn.Children[i].Tag == name(MisPkgName))
		{
			ReceivedArgs = parsedMessage.GetArguments();
			ReceivedVals = parsedMessage.GetValues();
			for (argCount = 0; argCount < ReceivedArgs.Length; argCount++) 
			{
				// Case 1: Link Value Order
				if (Caps(ReceivedArgs[argCount])=="LINK") 
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
					else 
					{
						if (argCount < ReceivedArgs.Length)
							argCount--;
					}
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

function ProcessPosAll(ParsedMessage parsedMessage)
{

}

function ProcessTrace(ParsedMessage parsedMessage)
{

}

function ProcessPause(ParsedMessage parsedMessage)
{
    
}

function ProcessGetStartPoses(ParsedMessage parsedMessage)
{
	local String outstring, locations;
	local PlayerStart P;
	local vector l,vr;
	local int num;

	foreach AllActors(class 'PlayerStart', P)
	{
		l = class'UnitsConverter'.static.LengthVectorFromUU(P.Location);
		vr = class'UnitsConverter'.static.DeprecatedRotatorFromUU(P.Rotation);
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

function receiveMessage(string Text)
{
	SendLine(Text);
}

function SendLine(String Text, optional bool bNoCRLF)
{
	if (bDebug)
		LogInternal("BotConnection: Sending " $ Text);
	if (bNoCRLF)
		SendText(Text);
	else
		SendText(Text $ Chr(13) $ Chr(10));
}

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
	bDebug=false;
	Begin Object Class=MessageParser Name=newMessageParser
	End Object
	messageParser=newMessageParser;
}
