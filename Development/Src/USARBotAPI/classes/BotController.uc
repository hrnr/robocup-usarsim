/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

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

simulated event ReplicatedEvent(name VarName)
{
	if (bDebug)
		LogInternal("BotController:ReplicatedEvent");
	if (theBotConnectionID >= 0 && theBotConnection == None && theBotMaster != None)
		FindConnection();
}

simulated function SetConnection(BotMaster bm, int botConID)
{
	if (bDebug)
		LogInternal("BotController: SetConnection");
	theBotMaster = bm;
	theBotConnectionID = botConID;
	if (theBotConnection == None)	
		FindConnection();
}

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

reliable client function SendKilled(String Killer, String damageType)
{
	if (bDebug)
		LogInternal("BotController: SendKilled");
	theBotConnection.SendLine("DIE {Killer " $ Killer $ "} {DamageType " $ damageType $ "}");
}

reliable server function RemoteDestroy()
{
	if (bDebug)
		LogInternal("BotController: RemoteDestroy");
	Destroy();
}

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
    bDebug=False
	theBotConnectionID=-1
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
}
