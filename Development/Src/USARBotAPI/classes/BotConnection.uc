/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/
// Every BotController created has an associated BotConnection which is a TCP connection from which the BotController
// receives commands and sends status messages.  

class BotConnection extends TcpLink
config(USAR);

var BotServer Parent;
var BotController theBot;
var MessageParser messageParser;

// set true for iterative mode
var config bool bIterative;

//-----------------------EVENTS------------------//

// Socket established
event Accepted()
{
  if(bDebug)
    LogInternal("Accepted BotConnection" @ self);
    
  SendGameInfo();
  gotoState('monitoring','WaitingForInit');
    
} // event Accepted

function SendGameInfo()
{
  local string timeLimitStr, gameInfoClass, levelName;
  local int i;

  timeLimitStr = string(Parent.Parent.GetTimeLimit());
  gameInfoClass = Parent.Parent.GetGameInfoClass();
  levelName = GetURLMap();
  i = InStr(Caps(levelName), ".LEVELINFO");
    
  if(i != -1)
    levelName = Left(levelName, i);

  SendLine("NFO {Gametype "$gameInfoClass$"} {Level "$levelName$"} {TimeLimit "$timeLimitStr$"}");
}

// InitReceived 
//      Event occuring when initialization string is first received from
//      the client socket.  At this point, the bot itself *hasn't been created*.
//      Robot-centric initialization done here may cause problems with multi-
//      client distribution, as robot pawn may not be created yet.
event InitReceived(ParsedMessage parsedMessage)
{
  local string clientName;
  local string startName;
  local string teamString;
  local PlayerStart P;
  local int teamNum;
  local vector startLocation;
  local vector startRotation;	// x,y,z correspond to floats roll,pitch,yaw
  local vector newLocation;
  local rotator newRotation;
  local string className;

  if(bDebug)
	LogInternal( "BotConnection:InitReceived called" );

  clientName = parsedMessage.GetArgVal("Name");
  teamString = parsedMessage.GetArgVal("Team");

  startName = parsedMessage.GetArgVal("Start");
  if (startName != "") {
    foreach AllActors(class 'PlayerStart', P) {
      if (string(P.Tag) == startName) {
	newLocation = P.Location; // stays in UU
	newRotation = P.Rotation; // stays in UU
	break;
      }
    }
  } else {
    /*
      The 'Rotator' class has integer fields 'roll', 'pitch' and 'yaw'.
      We need to take special care to convert these to and from UU
      since any intermediate integer step will be truncated.
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

  if(bDebug)
    LogInternal("InitReceived");
		
  LogInternal("Calling AddBotController with converted location "$newLocation$" and rotation "$newRotation$".");

  Parent.Parent.AddBotController(self, clientName, teamNum, newLocation, newRotation, className);

  gotoState('monitoring','WaitingForController');
} // event InitReceived

// SetController
//      Event occurs when bot has been created on server.  Client socket is 
//      bound to bot pawn here.  All post-robot-creation initialization should
//      be done here to be compatible with multi-client distribution.
event SetController(BotController bc)
{
  local USARVehicle usarVehicle;

  // TODO: RemoteDestroy any existing BotConnection?
  LogInternal( "BotConnection:SetController called" );

  theBot = bc;
  theBot.theBotConnection = self;
  if (theBot != None) {
    usarVehicle=USARVehicle(theBot.pawn);
    usarVehicle.MessageSendDelegate=receiveMessage; // create callback te receive messages
  }
  gotoState('monitoring','Running');
}

//Closed on other end
/* Replaced by MCD version
   event Closed()
   {
   local Pawn tempPawn;
   LogInternal( "BotConnection:event Closed called" );
   if( theBot != None ) // delete from games bot controller list
   Parent.Parent.DeleteBotController(theBot);
   else
   LogInternal( "BotConnection: event Closed has theBot=None" );

   if ( theBot != None && theBot.Pawn != None ) {
   theBot.SetLocation(theBot.Pawn.Location);
   theBot.Pawn.RemoteRole = ROLE_SimulatedProxy;
   //theBot.Pawn.UnPossessed();
   tempPawn = theBot.Pawn;
   theBot.Pawn = None;
   tempPawn.Destroy();
   }

   if(theBot != None) {
   theBot.Destroy();
   }

   Destroy();
    
   } // event Closed
*/

// Begin MCD
event Closed()
{
  LogInternal( "BotConnection: Closed called" );
  if(theBot != None){
    Parent.Parent.DeleteBotController(theBot);
    theBot.RemoteDestroy();
  }else
    LogInternal( "BotConnection: event Closed has theBot=None" );


  Destroy();
}
//End MCD

// Receive info - parse into lines and call ReceivedLine
event ReceivedText( string Text )
{
  local ParsedMessage parsedMessage;
  local name curBotState;
	
  if(bDebug) LogInternal("BotConnection: Received - "$Text);
  if( theBot != none )
    curBotState = theBot.GetStateName();
  messageParser.ReceiveText(Text);
  while(true)
    {
      parsedMessage=messageParser.getNextMessage();
      if (parsedMessage==None)
	break;
      if (LinkState==STATE_Connected && curBotState!='Dying' && curBotState!='GameEnded')
	ProcessAction(parsedMessage);
    }
} // event ReceivedText

//--------------------Functions-------------------//

function PreBeginPlay()
{
  Parent = BotServer(Owner);
  if(bDebug)
    LogInternal("Spawned BotConnection");
} // PreBeginPlay

function ProcessAction(ParsedMessage parsedMessage)
{
  local USARVehicle usarVehicle;
    
  if(bDebug)
    LogInternal("comandType: "$parsedMessage.GetCommandType());

  if (bIterative)
    WorldInfo.Pauser=None;
  switch(Caps(parsedMessage.GetCommandType())) //process messages unconditionally
  {
    case "INIT":  InitReceived(parsedMessage);  break;
    case "POSALL":  ProcessPosAll(parsedMessage);  break;
    case "TRACE":  ProcessTrace(parsedMessage);  break;
    case "PAUSE":  ProcessPause(parsedMessage);  break;
    case "GETSTARTPOSES":  ProcessGetStartPoses(parsedMessage); break;
	case "CONTROL":  ProcessWorldController(parsedMessage);  break;
  }
  
  if (theBot == None) return;

  usarVehicle=USARVehicle(theBot.Pawn);
  if (usarVehicle!=None)
  {
      switch(Caps(parsedMessage.GetCommandType())) // process messages to valid USARVehicle
      {
      }
      if (usarVehicle.VehicleBattery==None || !usarVehicle.VehicleBattery.isDead()) 
      {
        switch(Caps(parsedMessage.GetCommandType())) // process messages to USARVehicle with no battery or battery power
       	{
       	  case "TEST":  ProcessTest(parsedMessage);  break;
	  case "CAMERA":   ProcessCamera(parsedMessage);   break;
	  case "TURN":  ProcessTurn(parsedMessage);  break;
	  case "DRIVE":  ProcessDrive(parsedMessage);  break;
	  //case "MULTIDRIVE":  ProcessMultiDrive(parsedMessage);  break;
	  case "SETBALL":  ProcessSetball(parsedMessage);  break;
	  case "FACTORY":  ProcessFactoryController(parsedMessage);  break;
	  case "SENSOR":  ProcessSensor(parsedMessage);  break;
	  case "EFFECTOR":  ProcessEffector(parsedMessage);  break;
	  case "GETGEO":  ProcessGetGeo(parsedMessage);  break;
	  case "GETCONF":  ProcessGetConf(parsedMessage);  break;
	  case "SET":  ProcessSet(parsedMessage);  break;
	  case "MISPKG":  ProcessMisPkg(parsedMessage);  break;
	}  	
      }
  }
}

//------------------------------------------------------------------------------------------------------------------//

function ProcessTest(ParsedMessage parsedMessage)
{
  if(theBot != None) 
    theBot.GotoState('Startup', 'Test');
    
} // ProcessTest

//------------------------------------------------------------------------------------------------------------------//

function ProcessCamera(ParsedMessage parsedMessage)  // UT3: Need to port
{
    
} // ProcessCamera

//------------------------------------------------------------------------------------------------------------------//

function ProcessTurn(ParsedMessage parsedMessage)  // UT3: Need to port
{
    
} // ProcessTurn

//------------------------------------------------------------------------------------------------------------------//
// Commands to handle:
//      DRIVE {Left float} {Right float} {Normalized bool} {Light bool}
//      DRIVE {Speed float} {FrontSteer float} {RearSteer float} {Normalized bool} {Light bool} {Flip bool}
//      DRIVE {Propeller float} {Ridder float} {SternPlane float} {Normalized bool} {Light bool}
//      DRIVE {AltitudeVelocity float} {LinearVelocity float} {LateralVelocity float} {RotationalVelocity float} {Normalized bool}
//      DRIVE {WheelNumber int} {WheelSpeed float} {WheelSteer float} {WheelNumber int} (WheeSpeed float} ...
//      DRIVE (Name string} {Steer int} {Order int} {Value float}
//      DRIVE {Name string} {Bone name} {Order int} {Value float} {Axis string(one letter)}
//      DRIVE {Left float} {Right float}

function ProcessDrive(ParsedMessage parsedMessage) // UT3: Need to port
{
	local float leftSpeed, rightSpeed;

  // !!! Error messages below should be routed in message
// Start Taylor's changes for driving static mesh robot
	if(theBot.Pawn.IsA('SkidSteeredVehicle'))
	{
		leftSpeed=float(parsedMessage.GetArgVal("Left"));
		rightSpeed=float(parsedMessage.GetArgVal("Right"));
		SkidSteeredVehicle(theBot.Pawn).SetDriveSpeed(leftSpeed, rightSpeed);
	}
// End Taylor's changes for driving static mesh robot

	/*
  if (parsedMessage.GetArgVal("PGain")!="") 
    {
      if(theBot.Pawn.IsA('SkidSteeredRobot'))
	SkidSteeredRobot(theBot.Pawn).setPGain(float(parsedMessage.GetArgVal("PGain")));
	if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	AckermanSteeredRobot(theBot.Pawn).setPGain(float(parsedMessage.GetArgVal("PGain")));
    }
  if (parsedMessage.GetArgVal("IGain")!="") 
    {
      if(theBot.Pawn.IsA('SkidSteeredRobot'))
	SkidSteeredRobot(theBot.Pawn).setIGain(float(parsedMessage.GetArgVal("IGain")));
	if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	AckermanSteeredRobot(theBot.Pawn).setIGain(float(parsedMessage.GetArgVal("IGain")));
    }
	if (parsedMessage.GetArgVal("DGain")!="") 
    {
      if(theBot.Pawn.IsA('SkidSteeredRobot'))
	 SkidSteeredRobot(theBot.Pawn).setDGain(float(parsedMessage.GetArgVal("DGain")));
	if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	 AckermanSteeredRobot(theBot.Pawn).setDGain(float(parsedMessage.GetArgVal("DGain")));
    }
  if (parsedMessage.GetArgVal("MaxTorque")!="") 
    {
      if(theBot.Pawn.IsA('SkidSteeredRobot'))
	SkidSteeredRobot(theBot.Pawn).setMaxTorque(float(parsedMessage.GetArgVal("MaxTorque")));
	
    }

  // Ackerman drive vehicle specific
  if (parsedMessage.GetArgVal("Speed")!="")
    {
      if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	AckermanSteeredRobot(theBot.Pawn).setSpeed(float(parsedMessage.GetArgVal("Speed")));
    }
  if (parsedMessage.GetArgVal("FrontSteer")!="")
    {
      if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	AckermanSteeredRobot(theBot.Pawn).setFrontSteer(float(parsedMessage.GetArgVal("FrontSteer")));
    }
  if(parsedMessage.GetArgVal("RearSteer")!="")
    {
      if(theBot.Pawn.IsA('AckermanSteeredRobot'))
	AckermanSteeredRobot(theBot.Pawn).setRearSteer(float(parsedMessage.GetArgVal("RearSteer")));
    }

		
		//Ravi's changes to set speeds for OpenFrameUnderwaterVehicle
	if(theBot.Pawn.IsA('OpenFrameUnderwaterVehicle')){
		if(parsedMessage.GetArgVal("LateralVelocity")!="")
		{
			OpenFrameUnderwaterVehicle(theBot.Pawn).setLateralVelocity(float(parsedMessage.GetArgVal("LateralVelocity")));
		}
		if(parsedMessage.GetArgVal("AltitudeVelocity")!=""){
			OpenFrameUnderwaterVehicle(theBot.Pawn).setAltitudeVelocity(float(parsedMessage.GetArgVal("AltitudeVelocity")));
		}
		if(parsedMessage.GetArgVal("LinearVelocity")!=""){
			OpenFrameUnderwaterVehicle(theBot.Pawn).setLinearVelocity(float(parsedMessage.GetArgVal("LinearVelocity")));
		}
		if(parsedMessage.GetArgVal("RotationVelocity")!=""){
			OpenFrameUnderwaterVehicle(theBot.Pawn).setRotationVelocity(float(parsedMessage.GetArgVal("RotationVelocity")));
		}
	}

	
    if(parsedMessage.GetArgVal("Bone")!=""){
        if(theBot.Pawn.IsA('HumanoidRobot')){
            BoneName = name(parsedMessage.GetArgVal("BONE"));
            if (parsedMessage.GetArgVal("Order")!=""){
                    Order = int(parsedMessage.GetArgVal("Order"));
                if(parsedMessage.GetArgVal("Value")!=""){
                    Value = float(parsedMessage.GetArgVal("Value"));
                    if(parsedMessage.GetArgVal("Axis")!=""){
                        axisDelta = parsedMessage.GetArgVal("Axis");
                        if(len(axisDelta)==1)
                            HumanoidRobot(theBot.Pawn).setThisBone(boneName,Value,Order,axisDelta);
                    }
                }
            }
        }
    }
*/
		
	
			//end of ravi's changes
			
  // Check if normalized drive command was received
  if (parsedMessage.GetArgVal("Normalized")!="")
    USARVehicle(theBot.Pawn).setNormalized(bool(parsedMessage.GetArgVal("Normalized")));
  else
    USARVehicle(theBot.Pawn).setNormalized(false);

  // Check for headlight command
  if (parsedMessage.GetArgVal("Light")!="")
    USARVehicle(theBot.Pawn).setHeadLights(bool(parsedMessage.GetArgVal("Light")));

    
} //ProcessDrive
//------------------------------------------------------------------------------------------------------------------//

function ProcessSetBall(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessSetBall

//------------------------------------------------------------------------------------------------------------------//

function ProcessWorldController(ParsedMessage parsedMessage)
{
	local vector myLocation, myLocation2;
	local vector myRotation;
	local vector myScale;
	local String myName;
	local String startName;
	local PlayerStart P;
	local bool permanent;
  
	if(bDebug)
		LogInternal( "BotConnection: Received world controller message of type: " $ parsedmessage.GetArgVal("Type") );
	if(	theBot == None || !theBot.Pawn.IsA('WorldController'))
    {
		LogInternal("BotConnection:ProcessWorldController:No Bot or Bot is not a world controller!");
		return;
	}
	if( parsedMessage.GetArgVal("Type") == "RelMove" ) // CONTROL {Type RelMove} {Name name} {location x,y,z} {rotation x,y,z}
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		//		LogInternal("BotConnection:ProcessWorldController: RelMove");
		//		LogInternal("	" $ Location $ "	" $ Rotation);
		WorldController(theBot.pawn).RelMove(myName, myLocation, myRotation);
	}
	else if( parsedMessage.GetArgVal("Type") == "AbsMove" ) // CONTROL {Type AbsMove} {Name name} {location x,y,z} {rotation x,y,z}
	{
		myName = parsedMessage.GetArgVal("Name");
		myLocation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
		myRotation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));
		//		LogInternal("BotConnection:ProcessWorldController: AbsMove");
		//		LogInternal("	" $ Location $ "	" $ Rotation);
		WorldController(theBot.pawn).AbsMove(myName, myLocation, myRotation);
	} 
	else if( parsedMessage.GetArgVal("Type") == "Create" ) // CONTROL {Type Create} {ClassName class} {Name name} {Memory memory} {location x,y,z} {rotation x,y,z}{Physics None/Ground/Falling} {Permanent true/false}
	{
		startName = parsedMessage.GetArgVal("Start");
		if (startName != "") 
		{
			foreach AllActors(class 'PlayerStart', P) 
			{
				if (string(P.Tag) == startName) 
				{
					myLocation = class'UnitsConverter'.static.LengthVectorFromUU(P.Location); // put in meters
					myRotation = class'UnitsConverter'.static.DeprecatedRotatorFromUU(P.Rotation); // put in meters
		//			LogInternal( "BotConnection: Spawning at: " $ myLocation );
					break;
				}
			}
		}
		else 
		{
			myLocation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Location"));
			myRotation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Rotation"));	   
		}
		myScale=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("Scale"));
		if( myScale == vect(0,0,0) )
		{
			myScale = vect(1,1,1);
		}
		if( parsedMessage.GetArgVal("Permanent") == "true" )
			permanent = true;
		else
			permanent = false;
		WorldController(theBot.pawn).Create(parsedMessage.GetArgVal("ClassName"), parsedMessage.GetArgVal("Name"), 
		   parsedMessage.getArgVal("Memory"), myLocation, myRotation, myScale, parsedMessage.GetArgVal("Physics"),
		   permanent);
	} 
	else if( parsedMessage.GetArgVal("Type") == "Kill" ) // CONTROL {Type Kill} {Name name}
	{
		WorldController(theBot.pawn).Kill(parsedMessage.GetArgVal("Name"));
	} 
	else if( parsedMessage.GetArgVal("Type") == "KillAll" ) // CONTROL {Type KillALL} {MinPos x, y, z} {MaxPos x, y, z}
	{
		if( parsedMessage.GetArgVal("MinPos")=="" || parsedMessage.GetArgVal("MaxPos")=="" )
		{
			myLocation = vect(0,0,0);
			myLocation2 = vect(0,0,0);
		}
		else
		{
			myLocation=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MinPos"));
			myLocation2=class'Utilities'.static.ParseVector(parsedMessage.GetArgVal("MaxPos"));
		}
		WorldController(theBot.pawn).KillAll(myLocation, myLocation2);
	} 
	else if( parsedMessage.GetArgVal("Type") == "GetSTA" ) // CONTROL {Type GetSTA}
	{
		SendLine(WorldController(theBot.pawn).GetSTA(parsedMessage.GetArgVal("ClassName"), parsedMessage.GetArgVal("Name"))); 
	} 
	else if( parsedMessage.GetArgVal("Type") == "Conveyor" ) // CONTROL {Type Conveyor}
	{	
		WorldController(theBot.pawn).SetZoneVel(parsedMessage.GetArgVal("Name"), float(parsedMessage.GetArgVal("Speed")));
	}
	// unknown key value
	else
		LogInternal("BotConnection:ProcessWorldController: Bad key value: " $ parsedMessage.GetArgVal("Type"));
            
		//				WorldController(theBot.Pawn).setSpeedLeft(float(parsedMessage.GetArgVal("Left")));    
}  // ProcessWorldController

//------------------------------------------------------------------------------------------------------------------//

function ProcessFactoryController(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessFactoryController

//------------------------------------------------------------------------------------------------------------------//

function ProcessSensor(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessSensor

function ProcessEffector(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessEffector

//------------------------------------------------------------------------------------------------------------------//

function ProcessGetGeo(ParsedMessage parsedMessage)
{
  local string Type;

  Type = parsedMessage.GetArgVal("Type");

  if (Type=="Robot"){
    SendLine(USARVehicle(theBot.Pawn).GetGeoData());
  }else if (Type=="MisPkg"){
    SendLine(USARVehicle(theBot.Pawn).GetMisPkgGeoData());
  }else if (Type=="Gripper"){
    SendLine(USARVehicle(theBot.Pawn).GetEffectorGeoData(Type, parsedMessage.GetArgVal("Name")));
  }else{ // must be a sensor
    SendLine(USARVehicle(theBot.Pawn).GetSensorGeoData(Type, parsedMessage.GetArgVal("Name")));
  }
} // ProcessGetGeo

//------------------------------------------------------------------------------------------------------------------//

function ProcessGetConf(ParsedMessage parsedMessage) 
{
  local string Type;

  LogInternal( "In BotConnection: ProcessGetConf()");

  Type = parsedMessage.GetArgVal("Type");

  if (Type=="Robot"){
    SendLine(USARVehicle(theBot.Pawn).GetConfData());
  }else if (Type=="MisPkg"){
    SendLine(USARVehicle(theBot.Pawn).GetMisPkgConfData());
  }else if (Type=="Gripper"){
    SendLine(USARVehicle(theBot.Pawn).GetEffectorConfData(Type, parsedMessage.GetArgVal("Name")));
  }else{ // must be a sensor
    SendLine(USARVehicle(theBot.Pawn).GetSensorConfData(Type, parsedMessage.GetArgVal("Name")));
  }
} // ProcessGetConf

//------------------------------------------------------------------------------------------------------------------//

function ProcessSet(ParsedMessage parsedMessage) // UT3: Need to port
{
    local string /*Type,*/JointName, Opcode;

	//LogInternal( "In BotConnection: ProcessSet()");

	//Type = parsedMessage.GetArgVal("Type");
	JointName = parsedMessage.GetArgVal("Name");
	Opcode = parsedMessage.GetArgVal("Opcode");

	if (Opcode=="Angle") {
		/*
		// Temp hardcoded
		if( theBot.Pawn.IsA('Nao') )
		{
			if( Joint == "HeadYaw" )
				Nao(theBot.Pawn).DesiredYaw = class'UnitsConverter'.static.AngleToUU( float(parsedMessage.GetArgVal("Params")) );
			else if( Joint == "HeadPitch" )
				Nao(theBot.Pawn).DesiredPitch = class'UnitsConverter'.static.AngleToUU( float(parsedMessage.GetArgVal("Params")) );
			else
				LogInternal("Unknown joint " $ Joint );
		}
*/
		if( theBot.Pawn.IsA('LeggedRobot') )
		{
			LeggedRobot(theBot.Pawn).SetJointAngle( JointName, class'UnitsConverter'.static.AngleToUU( float(parsedMessage.GetArgVal("Params")) ) );
		}
		else if (JointName!="AllAngles" && theBot.Pawn.IsA('USARVehicle'))
		{
			USARVehicle(theBot.Pawn).SetJointAngle( JointName, class'UnitsConverter'.static.AngleToUU( float(parsedMessage.GetArgVal("Params")) ) );
		}
		else if (JointName=="AllAngles")
		{
			WheeledVehicle(theBot.Pawn).SetAllJointAngles(class'UnitsConverter'.static.AngleToUU( float(parsedMessage.GetArgVal("Params")) ) );
		}
	}
	else if (Opcode=="Stiffness") {
		if( theBot.Pawn.IsA('LeggedRobot') )
		{
			LeggedRobot(theBot.Pawn).SetJointStiffnessByName( Name(JointName), float(parsedMessage.GetArgVal("Params")) );
		}
	}
	else if (Opcode=="MaxTorque") 
	{
		if(theBot.Pawn.IsA('WheeledVehicle'))
		{
			// TODO WheeledVehicle(theBot.Pawn).SetMaxTorque(float(parsedMessage.GetArgVal("Params")));
		}
	}

} // ProcessSet

//------------------------------------------------------------------------------------------------------------------//

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
local array<string> ReceivedArgs;
local array<string> ReceivedVals;


//		LogInternal( "In BotConnection:ProcessMisPkg with children: "$theBot.Pawn.Children.length );
if (parsedMessage.GetArgVal("Name") != "") {
	MisPkgName = parsedMessage.GetArgVal("Name");
}

for (i = 0; i < theBot.Pawn.Children.length; i++) 
{
	//LogInternal( "child: "$i$" is called: " $theBot.Pawn.Children[i].Tag );
	if (theBot.Pawn.Children[i].Tag==name(MisPkgName)) 
	{
		ReceivedArgs=parsedMessage.GetArguments();
		ReceivedVals=parsedMessage.GetValues();

		for (argCount=0;argCount<ReceivedArgs.Length;argCount++) 
		{
			// Case 1: Link Value Order
			if(Caps(ReceivedArgs[argCount])=="LINK") 
			{
				Link = int(ReceivedVals[argCount]);
				argCount++;
				if(argCount < ReceivedArgs.Length && Caps(ReceivedArgs[argCount])=="VALUE") 
				{
					Value = float(ReceivedVals[argCount]);
					argCount++;
					if (argCount < ReceivedArgs.Length && Caps(ReceivedArgs[argCount])=="ORDER") 
					{
						Order = int(ReceivedVals[argCount]);
                        //LogInternal( "BotConnection:setThisRotation called for link "$Link$" with value"$Value$" order "$Order);
						MissionPackage(theBot.Pawn.Children[i]).setThisRotation(Link,Value,Order);
					}
				}
				else 
				{
					if (argCount < ReceivedArgs.Length)
					argCount--;
				}
			}

			// Case 2: Gripper
			if(Caps(ReceivedArgs[argCount])=="GRIPPER") 
			{
				if( bDebug )
					LogInternal("Gripper Command called");
				Gripper = int(ReceivedVals[argCount]);
				MissionPackage(theBot.Pawn.Children[i]).setGripperToBox(Gripper);
			}

			// Case 3: Sequence
			if(Caps(ReceivedArgs[argCount])=="SEQ") 
			{
				LogInternal("Sequence Command called");
				Seq = int(ReceivedVals[argCount]);
				MissionPackage(theBot.Pawn.Children[i]).runSequence(Seq);
			}

		}
		return;
	}
}

} // ProcessMisMkg
//------------------------------------------------------------------------------------------------------------------//

function ProcessPosAll(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessPosAll

//------------------------------------------------------------------------------------------------------------------//

function ProcessTrace(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} // ProcessTrace

//------------------------------------------------------------------------------------------------------------------//

function ProcessPause(ParsedMessage parsedMessage) // UT3: Need to port
{
    
} //

//------------------------------------------------------------------------------------------------------------------//

function ProcessGetStartPoses(ParsedMessage parsedMessage)
{
  local string outstring, locations;
  local PlayerStart P;
  local vector l,vr;
  local int num;

  foreach AllActors(class 'PlayerStart', P) {
    l = class'UnitsConverter'.static.LengthVectorFromUU(P.Location);
    vr = class'UnitsConverter'.static.DeprecatedRotatorFromUU(P.Rotation);
		
    if (num > 0) {
      locations = locations $ " " $ P.Tag $ " " $ l.X $ "," $ l.Y $"," $ l.Z $ " " $ vr.X $ "," $ vr.Y $ "," $vr.Z;
    } else {
      locations = P.Tag $ " " $  l.X $ "," $ l.Y $ "," $ l.Z $ " " $
	vr.X $ "," $ vr.Y $ "," $ vr.Z;
    }
    
    num++;
  }
	
  outstring = "NFO {StartPoses " $ num $ "}";

  if (num > 0) {
    outstring = outstring $ " {" $ locations $ "}";
  }

  LogInternal(outstring);

  SendLine(outstring);
}

//------------------------------------------------------------------------------------------------------------------//

// sends messages received from USARVehicle, these are sensor and USARVehicle status messages
function receiveMessage(string Text)
{
//  LogInternal("BotConnection: sending:"@Text);
  //LogInternal("BotConnection: GetLastError()="@GetLastError()); //receiving error 10035, ????
  //LogInternal("BotConnection: IsConnected()="@IsConnected());
  //LogInternal("BotConnection: LinkState="@LinkState);
  SendLine(Text);
}

//Send a line to the client
function SendLine(string Text, optional bool bNoCRLF)
{
  if(bDebug)
    LogInternal("    Sending: "$Text);
  if(bNoCRLF)
    SendText(Text);
  else
    SendText(Text$Chr(13)$Chr(10));
    
} // SendLine

//------------------------------------------------------------------------------------------------------------------//

// traverse all the MisPkgs of the robot and returns the index of the first camera mission package

function int findFirstCameraMisPkg() // UT3: Need to port
{
    
}

//------------------------------------------------------------------------------------------------------------------//


// BEG & END messages scrolling from here -> Not sure why

//fire right up into the loop for sending updates
auto state monitoring
{
 Begin:
 WaitingForInit:
  sleep(0.1);
  goto 'WaitingForInit';
  // Begin MCD
 WaitingForController:
  sleep(0.1);
  goto 'WaitingForController';
  // End MCD
 Running:
  sleep(0.1);
  goto 'Running';
}

defaultproperties
{
  bDebug=false;
  Begin Object Class=MessageParser Name=newMessageParser
  End Object
  messageParser=newMessageParser; //initilize messageParser object
}
