/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class BotDeathMatch extends UDKGame config(USAR);
    
var array<BotController> 	botList;
var BotMaster               theBotMaster;
var class<BotMaster>        BotMasterClass;
var class<BotController>    BotControllerClass;
var int                     NumRemoteBots;
// This determines whether or not we check and log any time a robot bumps into a victim
var config bool             bLogVictimRobotCol;
var config float            PhysicsResolution;
var class<USARTruth> USARTruthClass;
var USARTruth theUSARTruth;

event PostBeginPlay()
{
	if (bDebug)
		LogInternal("BotDeathmatch: PostBeginPlay");
	// The server is given a master object
	CreateBotMaster(self);
	super.PostBeginPlay();
	WorldInfo.PhysicsProperties.PrimaryScene.bFixedTimeStep = true;
	WorldInfo.PhysicsProperties.PrimaryScene.TimeStep = PhysicsResolution;
	WorldInfo.MaxPhysicsSubsteps = 100;
	WorldInfo.PhysicsProperties.PrimaryScene.MaxSubSteps = 100;
}

event PostLogin(PlayerController NewPlayer)
{
	if (bDebug)
		LogInternal("BotDeathmatch: PostLogin");
	// Each client is given a master object
	CreateBotMaster(NewPlayer);
	super.PostLogin(NewPlayer);
}

function CreateBotMaster(Actor theOwner)
{   
	if (bDebug)
		LogInternal("BotDeathmatch: CreateBotMaster");
	theBotMaster = Spawn(BotMasterClass, theOwner);
	if (theBotMaster != None)
	{		
		theBotMaster.SetGameInfo(self);
		theBotMaster.Initialize();
	} else
		LogInternal("BotDeathmatch: Failed to create BotMaster for " $ theOwner);
}

function PreBeginPlay()
{
	super.PreBeginPlay();
	
	if (bDebug)
		LogInternal("BotDeathmatch: PreBeginPlay");
	theUSARTruth = spawn(USARTruthClass, self);
	if (theUSARTruth == None)
		LogInternal("BotDeathmatch: Could not spawn USARTruth instance");
}

function DeleteBotController(BotController OldBot)
{
	local int i;

	for (i = 0; i < botList.length; i++)
		if (botList[i] == OldBot)
		{
			if (bDebug)
				LogInternal("BotDeathmatch: Removing bot " $ OldBot.name);
			botList.Remove(i,1);
			break;
		}
}

function BotController AddBotController(Actor theOwner, String botName, int teamNum,
	vector startLocation, rotator startRotation, String className)
{
	local BotController NewBot;
	
	if (bDebug)
		LogInternal("BotDeathmatch: AddBotController");
	NewBot = Spawn(BotControllerClass, theOwner, , startLocation, startRotation);
	NewBot.bIsPlayer = true;
	NewBot.SetHidden(false);
	if (NewBot != None)
	{
		NumRemoteBots++;
		NumPlayers++;
		/*
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
		if (botName == "")
			newBot.PlayerReplicationInfo.PlayerName = "Unnamed_Bot_" $ NumRemoteBots;
		else
			newBot.PlayerReplicationInfo.PlayerName = botName;
		*/
		if (className != "")
			NewBot.PawnClass = class<Pawn>(DynamicLoadObject(className, class'Class'));
		else if (NewBot.PawnClass == None)
		{
			LogInternal("BotDeathmatch: New robot has no actor class");
			NewBot.PawnClass = class<Pawn>(DynamicLoadObject("Engine.Pawn", class'Class'));
		}
		SpawnPlayer(NewBot, startLocation, startRotation);
		botList.AddItem(NewBot);
	}
	else
		LogInternal("BotDeathmatch: BotController failed to spawn");
	return NewBot;
}

function SpawnPlayer(BotController newBot, optional vector startLocation, optional rotator startRotation)
{
	if (NewBot == None) {
		LogInternal("BotDeathmatch: Robot was None");
		return;
	}
	if (NewBot.Pawn != None) {
		LogInternal("BotDeathmatch: Robot already had pawn");
		return;
	}
	FindPlayerStart(NewBot);
	NewBot.Pawn = Spawn(NewBot.PawnClass,NewBot,,startLocation,startRotation);
	if (NewBot.Pawn == None)
	{
		LogInternal("Failed to spawn player of type " $ NewBot.PawnClass);
		return;
	} else
		LogInternal("Spawned player of type " $ NewBot.PawnClass $ ": " $
			String(NewBot.Pawn.Name));
	NewBot.PawnClass = NewBot.Pawn.Class;
	NewBot.Squad = spawn(class'UTSquadAI');
	if (NewBot.Squad == None)
		LogInternal("BotDeathmatch: Robot has no squad");
	NewBot.Pawn.PlayTeleportEffect(true, true);
}

function RestartPlayer(Controller aPlayer)
{
	if (bDebug)
		LogInternal("BotDeathmatch: RestartPlayer");

	if (aPlayer.IsA('USARBot'))
	{
		if (aPlayer.IsInState('Dying'))
			SpawnPlayer(BotController(aPlayer));	
	} 
	else if (aPlayer.bIsPlayer)
	{
		super.RestartPlayer(aPlayer);
		aPlayer.ConsoleCommand("Ghost");
		aPlayer.SetHidden(true);
	}
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn,
	class<DamageType> damageType)
{
	if (bDebug)
		LogInternal("BotDeathmatch: Killed");

	if (!Killed.IsA('RemoteBot'))
		super.Killed(Killer, Killed, KilledPawn, damageType);
	else if (Killed != None)
		BotController(Killed).SendKilled(String(Killer), String(damageType));
}

// get the controller of the bot 'name' after calling use BotController.Pawn to access the bot
function BotController GetRobot(String botname) 
{
	local int len, i;
	len = botList.length;
	for (i = 0; i < len; i++)
	{
		if (Caps(botname) == Caps(botList[i].PlayerReplicationInfo.PlayerName))
			return botList[i];
	}
	return None;
}

// Note: Skip UTGame GenericPlayerInitialization, it overrides the HUDType.
function GenericPlayerInitialization(Controller C)
{
	super(UDKGame).GenericPlayerInitialization(C);
}

defaultproperties
{
	bDebug=false
	PlayerControllerClass=class'UTPlayerController'
	DefaultPawnClass=class'UTPawn'
	BotControllerClass=class'USARBotAPI.BotController'
	BotMasterClass=class'USARBotAPI.BotMaster'
	HUDType=class'USARBotAPI.Multiview'
	NumRemoteBots=0
	bPauseable=true
	bDelayedStart=false
	USARTruthClass=class'USARBotAPI.USARTruth'
}
