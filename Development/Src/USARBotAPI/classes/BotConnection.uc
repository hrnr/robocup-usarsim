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
var BotController TheBot;
var MessageParser Parser;
var config bool bIterative;

// Socket established, send game information
event Accepted()
{
	if (bDebug)
		LogInternal("Accepted BotConnection " $ self);
	SendGameInfo();
	gotoState('monitoring', 'WaitingForInit');
}

// Socket closed, clean up
event Closed()
{
	if (bDebug)
		LogInternal("BotConnection: Closed");
	if (TheBot != None)
	{
		Parent.Parent.DeleteBotController(TheBot);
		TheBot.Destroy();
	}
	Destroy();
}

// Extracts a pose from the command message, assuming Location has location (m) and Rotation
// has rotation (rad), and returns it in position and rotation
simulated function GetPose(ParsedMessage msg, out vector pPosition, out rotator pRotation)
{
	local vector pos, rot;
	
	pos = class'Utilities'.static.ParseVector(msg.GetArgVal("Location"));
	rot = class'Utilities'.static.ParseVector(msg.GetArgVal("Rotation"));
	pPosition = class'UnitsConverter'.static.LengthVectorToUU(pos);
	pRotation = class'UnitsConverter'.static.AngleVectorToUU(rot);
}

// Sets the parent properly so that the connection is cleaned up when the server dies
function PreBeginPlay()
{
	Parent = BotServer(Owner);
	if (bDebug)
		LogInternal("BotConnection: Spawned");
}

// Manipulates actuators using new "ACT" API
function ProcessAct(ParsedMessage parsedMessage)
{
	local Actuator act;
	local int i;
	local array<String> receivedArgs;
	local array<String> receivedVals;
	
	act = USARVehicle(TheBot.Pawn).GetActuator(parsedMessage.GetArgVal("Name"));
	// Found actuator, update
	if (act != None)
	{
		receivedArgs = parsedMessage.GetArguments();
		receivedVals = parsedMessage.GetValues();
		for (i = 0; i < receivedArgs.Length; i++) 
		{
			// Case 1: Link Value
			if (i + 1 < receivedArgs.Length && receivedArgs[i] == "Link" &&
					receivedArgs[i + 1] == "Value")
				act.SetLinkTarget(int(receivedVals[i++]), float(receivedVals[i++]));
			// Case 2: Gripper
			else if (receivedArgs[i] == "Gripper")
				act.SetGripper(int(receivedVals[i]));
			// Case 3: Sequence
			else if (receivedArgs[i] == "Sequence")
				act.RunSequence(int(receivedVals[i]));
		}
	}
}

function ProcessAction(ParsedMessage parsedMessage)
{
	local USARVehicle usarVehicle;
	local String type;
	
	type = Caps(parsedMessage.GetCommandType());
	if (bDebug)
		LogInternal("BotConnection: Received Command type " $ type);
	if (bIterative)
		WorldInfo.Pauser = None;
	switch (type)
	{
	case "INIT":
		ProcessInit(parsedMessage);
		break;
	case "GETSTARTPOSES":
		ProcessGetStartPoses(parsedMessage);
		break;
	case "CONTROL":
		ProcessWorldController(parsedMessage);
		break;
	default:
	}
	
	if (TheBot != None && TheBot.Pawn != None && TheBot.Pawn.isA('USARVehicle'))
	{
		usarVehicle = USARVehicle(TheBot.Pawn);
		
		// Vehicle must have battery life remaining for these messages
		if (usarVehicle.GetBatteryLife() > 0)
			switch (type)
			{
			case "TEST":
				ProcessTest(parsedMessage);
				break;
			case "DRIVE":
				ProcessDrive(parsedMessage);
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
				// Deprecated. May be removed in future releases without warning
				ProcessMisPkg(parsedMessage);
				break;
			case "ACT":
				ProcessAct(parsedMessage);
				break;
			case "MOVE":
				ProcessMove(parsedMessage);
				break;
			default:
			}
	}
	
	if (TheBot != None && TheBot.Pawn != None && TheBot.Pawn.isA('USARAvatarCommon'))
	{
		switch (type)
		{
		case "MOVE":
			ProcessMove(parsedMessage);
			break;
		}
	}
}

// Handle a DRIVE command which varies by robot
function ProcessDrive(ParsedMessage parsedMessage)
{
	local USARVehicle bot;
	local String value;
	
	bot = USARVehicle(TheBot.Pawn);
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


//==========================================
// Handle a MOVE command to control Avatars
//==========================================
function ProcessMove(ParsedMessage parsedMessage)
{
  local USARAvatarCommon bot;
  local String moveType;
  local Vector pos;          //-- Coordinates (x,y) that the avatar has to reach
  local Vector pos2D;          //-- Coordinates (x,y) that the avatar has to reach
  local String vPathnode;    //-- Name of the pathnode that the avatar has to reach
  local String moveAction;      //-- Type of action that the avatar has to perform
  local String moveLocation;

  // Define the bot
  bot = USARAvatarCommon(TheBot.Pawn);

  // Retrieve the parameter Type passed to the MOVE command
  moveType = parsedMessage.GetArgVal("Type");
  // Retrieve the parameter Action passed to the MOVE command
  moveAction = parsedMessage.GetArgVal("Action");
  // Retrive the Location passed to the command
  If (moveType == "Walk_Forward" || moveType == "Walk_Backward" || moveType == "Run")
  {
    if (moveAction=="New" || moveAction=="Append")   // new or append require Location or Pathnode
    {
      moveLocation = parsedMessage.GetArgVal("Location");

      if (moveLocation != "")
      {
        if (bot!=none)
        {
          pos = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
          pos2D.X=pos.x;
          pos2D.Y=pos.Z;
          pos2D.Z=1.47;

          //`log("Position: "@pos.X@pos.Y@pos.X);

          /* Since the controller and the bot are in different classes
          we need to use the controller class (USARAIController) associated
          to perform the actions (MoveForwardToLocation in this case) */
          USARAIController(bot.Controller).MoveForwardToLocation(moveType, pos2D, moveAction);
        }
      }
      // In case Pathnode is used instead of Location
      else if (vPathnode != "")
      {
        vPathnode = parsedMessage.GetArgVal("Pathnode");

        if (bot!=none)
        {
          USARAIController(bot.Controller).MoveForwardToPathnode(vPathnode, moveAction);
        }
      }
      else
      {
          LogInternal ("**** ERROR: Location or Pathnode is required ****");
      }
    }
  }
  else if (moveType =="")
  {
    // PAUSE command
    if (moveAction=="Pause")
    {
      `log ("**** PAUSE ****");
         USARAIController(bot.Controller).PauseAction();
    }
    // RESUME command
    else if (moveAction=="Resume")
         USARAIController(bot.Controller).ResumeAction();
    else
         `log ("**** ERROR: An action is required ****");
  }
}

// Gets configuration information from the robot
function ProcessGetConf(ParsedMessage parsedMessage) 
{
  local String Type;
  local USARVehicle bot;
  
  Type = parsedMessage.GetArgVal("Type");
  bot = USARVehicle(TheBot.Pawn);
  
  if (Type == "Robot")
     SendLine(bot.GetConfData());
  else if (Type == "MisPkg")
  // Deprecated
     SendLine(bot.GetMisPkgConfData());
  else
      SendLine(bot.GetGeneralConfData(Type, parsedMessage.GetArgVal("Name")));
}

// Gets geometric configuration from the robot
function ProcessGetGeo(ParsedMessage parsedMessage)
{
  local String Type;
  local USARVehicle bot;
  
  Type = parsedMessage.GetArgVal("Type");
  bot = USARVehicle(TheBot.Pawn);
  
  if (Type == "Robot")
     SendLine(bot.GetGeoData());
  else if (Type == "MisPkg")
       // Deprecated
	   LogInternal( "GetGeo for MisPkg deprecated. Please use ACT" );
 //      SendLine(bot.GetMisPkgGeoData());
  else
      SendLine(bot.GetGeneralGeoData(Type, parsedMessage.GetArgVal("Name")));
}

// Returns a list of valid starting positions for a robot
function ProcessGetStartPoses(ParsedMessage parsedMessage)
{
  local String outstring, locations;
	local PlayerStart start;
	local vector l, vr;
	local int num;

	foreach AllActors(class 'PlayerStart', start)
	{
		l = class'UnitsConverter'.static.LengthVectorFromUU(start.Location);
		vr = class'UnitsConverter'.static.AngleVectorFromUU(start.Rotation);
		if (num > 0)
			locations = locations $ " " $ start.Tag $ " " $ l.X $ "," $ l.Y $"," $ l.Z $ " " $
				vr.X $ "," $ vr.Y $ "," $vr.Z;
		else
			locations = start.Tag $ " " $ l.X $ "," $ l.Y $ "," $ l.Z $ " " $ vr.X $ "," $
				vr.Y $ "," $ vr.Z;
		num++;
	}
	outstring = "NFO {StartPoses " $ num $ "}";
	if (num > 0)
		outstring = outstring $ " {" $ locations $ "}";
	SendLine(outstring);
}

// Event occuring when initialization string is first received from
// the client socket.  At this point, the bot itself *hasn't been created*.
// Robot-centric initialization done here may cause problems with multi-
// client distribution, as robot pawn may not be created yet.
function ProcessInit(ParsedMessage parsedMessage)
{
	local String startName;
	local PlayerStart start;
	local vector newLocation;
	local rotator newRotation;

	if (bDebug)
		LogInternal("BotConnection: ProcessInit");
	// Find player start if specified
	startName = Caps(parsedMessage.GetArgVal("Start"));
	if (startName != "")
	{
		foreach AllActors(class 'PlayerStart', start)
			if (Caps(String(start.Tag)) == startName)
			{
				newLocation = start.Location; // stays in UU
				newRotation = start.Rotation;
				break;
			}
	}
	else
		GetPose(parsedMessage, newLocation, newRotation);
	// Add robot
	LogInternal("Adding robot at location: " $ newLocation $ ", rotation: " $ newRotation);
	Parent.Parent.AddBotController(self, parsedMessage.GetArgVal("Name"), newLocation,
		newRotation, parsedMessage.GetArgVal("ClassName"));
	gotoState('monitoring', 'WaitingForController');
}

// Manipulates actuators using legacy "mission package" API
function ProcessMisPkg(ParsedMessage parsedMessage)
{
	local Actuator act;
	local int i;
	local array<String> receivedArgs;
	local array<String> receivedVals;
	
	// Find actuator on vehicle
	act = USARVehicle(TheBot.Pawn).GetActuator(parsedMessage.GetArgVal("Name"));
	// Found actuator, update
	if (act != None)
	{
		ReceivedArgs = parsedMessage.GetArguments();
		ReceivedVals = parsedMessage.GetValues();
		for (i = 0; i < ReceivedArgs.Length; i++) 
		{
			// Case 1: Link Value Order
			if (i + 2 < ReceivedArgs.Length && ReceivedArgs[i] == "Link" &&
					ReceivedArgs[i + 1] == "Value" && ReceivedArgs[i + 2] == "Order")
				act.SetThisRotation(int(ReceivedVals[i++]), float(ReceivedVals[i++]),
					int(ReceivedVals[i]));
			// Case 2: Gripper
			else if (ReceivedArgs[i] == "Gripper") 
				act.SetGripper(int(ReceivedVals[i]));
			// Case 3: Sequence
			else if (ReceivedArgs[i] == "Seq") 
				act.RunSequence(int(ReceivedVals[i]));
		}
	}
}

// Sets joint angles or other related parameters
function ProcessSet(ParsedMessage parsedMessage)
{
	local String itemName, opcode, type;
	local float param;
	local USARVehicle bot;
	
	bot = USARVehicle(TheBot.Pawn);
	itemName = parsedMessage.GetArgVal("Name");
	opcode = parsedMessage.GetArgVal("Opcode");
	type = parsedMessage.GetArgVal("Type");
	if (type == "Joint")
	{
		// Send to joint processor
		param = float(parsedMessage.GetArgVal("Params"));
		if (opcode == "Angle" || opcode == "Target")
		{
			if (itemName != "AllAngles" && itemName != "AllJoints")
				bot.SetJointTargetByName(itemName, param);
			else
				bot.SetAllJointTargets(param);
		}
		else if (opcode == "Stiffness")
			bot.SetJointStiffnessByName(itemName, param);
	}
	else
	{
		// Send to the robot and look for sensor/actuator to handle
		bot.SetCommand(type, itemName, opcode, parsedMessage.GetArgVal("Params"));
	}
}

// Enters "TEST" mode
function ProcessTest(ParsedMessage parsedMessage)
{
	if (TheBot != None) 
		TheBot.GotoState('Startup', 'Test');
}

// Manipulate objects in the world
function ProcessWorldController(ParsedMessage parsedMessage)
{
	local WorldController control;
	local vector loc, end, scale;
	local rotator rot;
	local PlayerStart start;
	local String startName, objName, type, minPos, maxPos;
	
	// Sanity
	if (TheBot == None || !TheBot.Pawn.IsA('WorldController'))
	{
		LogInternal("BotConnection: Bot is not a world controller");
		return;
	}
	// Initialize
	control = WorldController(TheBot.Pawn);
	type = parsedMessage.GetArgVal("Type");
	objName = parsedMessage.GetArgVal("Name");
	if (bDebug)
		LogInternal("BotConnection: Received WC command " $ type);
	// CONTROL {Type RelMove} {Name name} {Location x,y,z} {Rotation x,y,z}
	if (type == "RelMove")
	{
		GetPose(parsedMessage, loc, rot);
		control.RelMove(objName, loc, rot);
	}
	// CONTROL {Type AbsMove} {Name name} {Location x,y,z} {Rotation x,y,z}
	else if (type == "AbsMove")
	{
		GetPose(parsedMessage, loc, rot);
		control.AbsMove(objName, loc, rot);
	}
	// CONTROL {Type Create} {ClassName class} {Name name} {Memory memory} {Location x,y,z}
	// {Rotation x,y,z} {Physics None/RigidBody} {Permanent true/false}
	else if (type == "Create")
	{
		startName = Caps(parsedMessage.GetArgVal("Start"));
		if (startName != "") 
		{
			foreach AllActors(class 'PlayerStart', start) 
				if (Caps(String(start.Tag)) == startName)
				{
					// Convert to meters
					loc = start.Location;
					rot = start.Rotation;
					break;
				}
		}
		else 
			GetPose(parsedMessage, loc, rot);
		scale = class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Scale"));
		// Prevent a zero-size scale
		if (scale.X == 0 && scale.Y == 0 && scale.Z == 0)
			scale = vect(1, 1, 1);
		// Create object
		control.Create(parsedMessage.GetArgVal("ClassName"), objName,
			parsedMessage.GetArgVal("Memory"), loc, rot, scale,
			parsedMessage.GetArgVal("Physics"), parsedMessage.GetArgVal("Material"),
			Caps(parsedMessage.GetArgVal("Permanent")) == "TRUE");
	}
	// CONTROL {Type Kill} {Name name}
	else if (type == "Kill")
		control.Kill(objName);
	// CONTROL {Type KillAll} {MinPos x, y, z} {MaxPos x, y, z}
	else if (type == "KillAll")
	{
		maxPos = parsedMessage.GetArgVal("MaxPos");
		minPos = parsedMessage.GetArgVal("MinPos");
		if (minPos == "" || maxPos == "")
		{
			// Destroy all
			loc = vect(0, 0, 0); end = loc;
		}
		else
		{
			// Destroy in rectangle
			loc = class'UnitsConverter'.static.LengthVectorToUU(
				class'Utilities'.static.ParseVector(minPos));
			end = class'UnitsConverter'.static.LengthVectorToUU(
				class'Utilities'.static.ParseVector(maxPos));
		}
		control.KillAll(loc, end);
	}
	// CONTROL {Type GetSTA} {ClassName type} {Name name}
	else if (type == "GetSTA")
		SendLine(control.GetSTA(parsedMessage.GetArgVal("ClassName"), objName)); 
	// CONTROL {Type Conveyor} {Name name} {Speed speed}
	else if (type == "Conveyor")
		control.SetZoneVel(objName, float(parsedMessage.GetArgVal("Speed")));
	// CONTROL {Type Rotate} {Name name} {Speed x,y,z}
	else if (type == "Rotate")
	{
		rot = class'UnitsConverter'.static.AngleVectorToUU(
			class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Speed")));
		control.Rotate(objName, rot);
	}
	// CONTROL {Type AddWP} {WP x,y,z;x,y,z;...}
	else if (type == "AddWP")
		control.AddWP(objName, parsedMessage.GetArgVal("WP"));
	// CONTROL {Type ClearWP} {Name name}
	else if (type == "ClearWP")
		control.ClearWP(objName);
	// CONTROL {Type SetWP} {Name name} {...} (see file header comment in WorldController.uc)
	else if (type == "SetWP")
		control.SetWP(objName, parsedMessage);
	else
		LogInternal("BotConnection: Unsupported world controller command " $ type);
}

// Parse input message into lines and call ReceivedLine
event ReceivedText(String Text)
{
	local ParsedMessage parsedMessage;
	local name curBotState;

	if (bDebug)
		LogInternal("BotConnection: Received " $ Text);
	if (TheBot != None)
		curBotState = TheBot.GetStateName();
	Parser.ReceiveText(Text);
	parsedMessage = Parser.getNextMessage();
	while (parsedMessage != None)
	{
		if (LinkState == STATE_Connected && curBotState != 'Dying' && curBotState != 'GameEnded')
			ProcessAction(parsedMessage);
		parsedMessage = Parser.getNextMessage();
	}
}

// Delegate for robots to send messages back to the client
function ReceiveMessage(String Text)
{
	SendLine(Text);
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

// Sends a line of text to the client
function SendLine(String text, optional bool bNoCRLF)
{
	if (text != "")
	{
		if (bDebug)
			LogInternal("BotConnection: Sending " $ text);
		if (bNoCRLF)
			SendText(text);
		else
			SendText(text $ Chr(13) $ Chr(10));
	}
}

// Event occurs when bot has been created on server.  Client socket is 
// bound to bot pawn here.  All post-robot-creation initialization should
// be done here to be compatible with multi-client distribution.
event SetController(BotController bc)
{
	local USARVehicle usarVehicle;
	
	if (bDebug)
		LogInternal("BotConnection: SetController");
	TheBot = bc;
	TheBot.TheBotConnection = self;
	if (TheBot != None && TheBot.Pawn.isA('USARVehicle'))
	{
		usarVehicle = USARVehicle(TheBot.Pawn);
		if (usarVehicle != None)
			usarVehicle.MessageSendDelegate = ReceiveMessage;
	}
	gotoState('monitoring', 'Running');
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
	
	Begin Object Class=MessageParser Name=theParser
	End Object
	Parser=theParser
}
