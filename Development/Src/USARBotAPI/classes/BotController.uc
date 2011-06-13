/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

/*
 * BotController: Player controller for USAR robots
 */
class BotController extends UDKBot config(USAR);

var config bool bSilentGamebot;
var BotConnection theBotConnection;
var repnotify BotMaster theBotMaster;
var repnotify int theBotConnectionID;
var class<Pawn> PawnClass;
var config float DeltaTime;

replication
{
	if (bNetOwner && bNetDirty && Role == ROLE_Authority) 
		theBotMaster, theBotConnectionID;
}

// Finds the bot connection ID if replicated
simulated event ReplicatedEvent(name VarName)
{
	if (bDebug)
		LogInternal("BotController: ReplicatedEvent");
	if (theBotConnectionID >= 0 && theBotConnection == None && theBotMaster != None)
		FindConnection();
}

// Sets the proper ID of the bot connection and optionally finds it
simulated function SetConnection(BotMaster bm, int botConID)
{
	if (bDebug)
		LogInternal("BotController: SetConnection");
	theBotMaster = bm;
	theBotConnectionID = botConID;
	if (theBotConnection == None)	
		FindConnection();
}

// Finds the matching BotConnection and assigns this object as the controller
simulated function FindConnection() 
{
	if (bDebug)
		LogInternal("BotController: FindConnection");
	theBotConnection = theBotMaster.getConnection(theBotConnectionID);

	if (theBotConnection != None)
		theBotConnection.SetController(self);
	else
		LogInternal("BotController: Unable to find matching BotConnection.");
}

// Sends a death message when the robot dies
reliable client function SendKilled(String Killer, String damageType)
{
	if (bDebug)
		LogInternal("BotController: SendKilled");
	theBotConnection.SendLine("DIE {Killer " $ Killer $ "} {DamageType " $ damageType $ "}");
}

// Clean up robot on server as well
reliable server function RemoteDestroy()
{
	if (bDebug)
		LogInternal("BotController: RemoteDestroy");
	Destroy();
}

// Clean up robot when the controller dies
simulated event Destroyed()
{
	if (bDebug)
		LogInternal("BotController: Destroyed");
	if (Pawn != None)
		Pawn.Destroy();
    super.Destroyed();
}

defaultproperties
{
    bDebug=false
	theBotConnectionID=-1
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
}
