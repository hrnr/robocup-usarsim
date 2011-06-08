class BotDeathMatch extends UDKGame config(USAR);
    
// UT3: Removed for initial port
//var class<VizServer>	VizServerClass;
//var VizServer           theVizServer;
//var class<RemoteBotInfo> RemoteBotConfigClass;
//var RemoteBotInfo       RemoteBotConfig;

//var array<Item> Machines;
var array<BotController> 	botList;
var BotMaster               theBotMaster;
var class<BotMaster>        BotMasterClass;
var class<BotController>    BotControllerClass;
var int                     NumRemoteBots;
var config bool             bLogVictimRobotCol; // This determines whether or not we check and log any time a robot bumps into 
//   or touches a victim  
//   Stevens change 

var class<USARTruth> USARTruthClass;
var USARTruth theUSARTruth;

// Begin MCD
event PostBeginPlay()
{
  LogInternal( "BotDeathmatch:PostBeginPlay called" );
  // The server is given a master object
  CreateBotMaster(self);

  super.PostBeginPlay();

  
	//WorldInfo.RBPhysicsGravityScaling = 5.0; // (gravity -520)
	WorldInfo.PhysicsProperties.PrimaryScene.bFixedTimeStep = true;
	WorldInfo.PhysicsProperties.PrimaryScene.TimeStep = 0.005;
	WorldInfo.MaxPhysicsSubsteps = 100;
	WorldInfo.PhysicsProperties.PrimaryScene.MaxSubSteps = 100;

/*
	WorldInfo.PhysicsProperties.PrimaryScene.bFixedTimeStep = true;
	WorldInfo.PhysicsProperties.PrimaryScene.TimeStep = 0.02;
	WorldInfo.MaxPhysicsSubsteps = 1000;
	WorldInfo.PhysicsProperties.PrimaryScene.MaxSubSteps = 1000;
*/
}

event PostLogin(PlayerController NewPlayer)
{
  LogInternal( "BotDeathmatch:PostLogin called" );
  // Each client is given a master object
  CreateBotMaster(NewPlayer);

  super.PostLogin(NewPlayer);
}

function CreateBotMaster(Actor theOwner)
{   
  LogInternal( "BotDeathmatch:CreateBotMaster called" );
  theBotMaster = Spawn( BotMasterClass, theOwner );
  if (theBotMaster != None)
    {		
      theBotMaster.SetGameInfo(self);
      theBotMaster.Initialize();
    } else {
    LogInternal("Failed to create BotMaster for " @ theOwner);
  }
}
// End MCD

function PreBeginPlay()
{
  Super.PreBeginPlay();
  LogInternal( "BotDeathmatch:PreBeginPlay called" );

  if (true) {
    theUSARTruth = spawn(USARTruthClass, self);
    if (theUSARTruth == None) {
      LogInternal("Can't spawn USARTruth");
    } else {
      LogInternal("Spawned USARTruth");
    }
  }

  // moved into BotMaster
  /*
    if (!bServerLoaded) {
      // UT3: Removed for initial port
      //theVizServer = spawn(VizServerClass, self);
      //theVizServer.gameClass = "BotDeathMatch";
	    
      theBotServer = spawn(BotServerClass);
      theBotServer.gameClass = "BotDeathMatch";
		
      theComServer = spawn(ComServerClass,self);
      theComServer.gameClass = "BotDeathMatch";
		
      theComServerInterface = spawn(ComServerInterfaceClass,self);
      theComServer.gameClass = "BotDeathMatch";
		
      bServerLoaded = true;
    }
    // UT3: Removed for initial port
    //RemoteBotConfig = spawn(RemoteBotConfigClass);
  }
  */
}

function DeleteBotController(BotController OldBot )
{
  local int i;
	
  for (i=0;i<botList.length;i++) {
    if (botList[i]==OldBot) {
      LogInternal( "BotDeathmatch:DeleteBotController removing bot: " $ OldBot.name );
      botList.Remove(i,1);
      break;
    }
  }	
}

function BotController AddBotController(Actor theOwner, string botName, int teamNum, vector startLocation, rotator startRotation, string className)
{
  local BotController NewBot;
  local int Index;
  //local NavigationPoint startSpot;

  //startSpot = FindPlayerStart(NewBot);
  LogInternal( "BotDeathmatch:AddBotController called" );
	
  NewBot = Spawn(BotControllerClass, theOwner, , startLocation, startRotation);
	
  NewBot.bIsPlayer = true;
  NewBot.SetHidden(false);
  if ( NewBot != None ) {
    // Removed for MCD
    //NewBot.myConnection = theConnection;
    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumRemoteBots++;
    NumPlayers++;
    if(botName == "") {
      newBot.PlayerReplicationInfo.PlayerName = "Unnamed_Bot_" $ NumRemoteBots;
    } else {
      newBot.PlayerReplicationInfo.PlayerName = botName;
    }

    if(className != "") {
      NewBot.PawnClass=class<Pawn>(DynamicLoadObject(className, class'Class'));
    } else if(NewBot.PawnClass == None) {
      LogInternal("NewBot.ActorClass is None");
      NewBot.PawnClass = class<Pawn>(DynamicLoadObject("Engine.Pawn", class'Class'));
    }
    LogInternal("NewBot"@NewBot.PawnClass);
    SpawnPlayer(NewBot, startLocation, startRotation);
    Index = botList.length;
    botList.Insert(Index,1);
    botList[Index]=NewBot;
  } else {
    LogInternal("NewBot was none");
  }

  return NewBot;
}

function SpawnPlayer(BotController newBot, optional vector startLocation, optional rotator startRotation) {
  local NavigationPoint startSpot;
  //local array<SequenceEvent> eventList;

  LogInternal( "BotDeathmatch:SpawnPlayer called" );
  if(NewBot == None) {
    LogInternal("NewBot was none");
    return;
  }
  if(NewBot.Pawn != None) {
    LogInternal("Already had pawn");
    return;
  }

  startSpot = FindPlayerStart(NewBot);

  if(startLocation == vect(0,0,0)) {
    //NewBot.Actor = Spawn(GetDefaultPlayerClass(NewBot),,,StartSpot.Location,StartSpot.Rotation);
    NewBot.Pawn = Spawn(NewBot.PawnClass,NewBot,,startLocation,startRotation);
  } else {
    NewBot.Pawn = Spawn(NewBot.PawnClass,NewBot,,startLocation,startRotation);
  }
  LogInternal("PawnClass: "$NewBot.PawnClass);

  if ( NewBot.Pawn == None )
    {
      LogInternal("Couldn't spawn player of type "$NewBot.PawnClass$" at "$StartSpot);
      return;
    } else {
    LogInternal("Spawned player of type "$NewBot.PawnClass$" at "$StartSpot);
  }

  //NewBot.Actor.SetAnchor(startSpot);
  //NewBot.Actor.LastStartSpot = PlayerStart(startSpot);
  //NewBot.Actor.LastStartTime = WorldInfo.TimeSeconds;
  //NewBot.PreviousPawnClass = NewBot.Actor.Class;

  //NewBot.Possess(NewBot.Actor,True);
  NewBot.PawnClass = NewBot.Pawn.Class;

  NewBot.Squad = spawn(class'UTSquadAI');
  //UTDMRoster(UTDeathMatch(WorldInfo.Game).GetBotTeam).DMSquadClass);
  if(NewBot.Squad == None) LogInternal("NewBot.Squad == None");

  NewBot.Pawn.PlayTeleportEffect(true, true);
  //	NewBot.ClientSetRotation(NewBot.Actor.Rotation);
  //AddDefaultInventory(NewBot.Actor);
  //eventList=Startspot.
  //Startspot.TriggerEventClass(
  //TriggerEvent( StartSpot.Event, StartSpot, NewBot.Actor );
  //BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);
  NewBot.GotoState('StartUp', 'Begin');
}

function AddDefaultInventory( pawn PlayerPawn )
{
	PlayerPawn.CreateInventory(class'UTWeap_PhysicsGun',true);

	PlayerPawn.AddDefaultInventory();
}

/* MCD TODO: This function needs to be replicated, but *how* depends on where it is used
   function string GetGameStatus()
   {
   local string outStr;
   local Pawn P;
	
   LogInternal( "BotDeathmatch:GetGameStatus called" );
			
   outStr = ("GAM {PlayerScores");
   for ( P=WorldInfo.PawnList; P!=None; P=P.NextPawn )
   {
   //if( !P.PlayerReplicationInfo.bIsSpectator )
   //outStr $=" {"$P$" "$P.PlayerReplicationInfo.Score$"}");
   }
   outStr $=" }";				
					
   return outStr;
   }
*/

function RestartPlayer( Controller aPlayer )
{
  LogInternal( "BotDeathmatch:RestartPlayer called" );

  if(aPlayer.IsA('USARBot')) {
    if(aPlayer.IsInState('Dying')) {
      LogInternal("BOTRESTARTPLAYER"@aPlayer);
      SpawnPlayer(BotController(aPlayer));	
    }
  } 
  // MCD: Removed to keep players from having UT characters
  // Do spawn, but as ghost.
  else if (aPlayer.bIsPlayer){
  	LogInternal("RESTARTPLAYER"@aPlayer);
  	Super.RestartPlayer(aPlayer);
	aPlayer.ConsoleCommand("Ghost");
	aPlayer.SetHidden(true);
  }
}

// MCD: Changed to properly replicate over network
function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
  // Pras: Why were we scoring points for killing people?
  //Killer.PlayerReplicationInfo.Score += 1.0;
  LogInternal( "BotDeathmatch:Killed called" );

  if(!Killed.IsA('RemoteBot')) {
    Super.Killed(Killer, Killed, KilledPawn, damageType);
  } else if(Killed != None) {
    BotController(Killed).SendKilled(string(Killer), string(damageType));
  }
}

// get the controller of the bot 'name'
// after calling use BotController.Pawn to access the bot
function BotController GetRobot(string botname) 
{
  local int len,i;
  len=botList.length;
  for (i=0;i<len;i++)
    {
      if (botname==botList[i].PlayerReplicationInfo.PlayerName)
	return botList[i];
    }
  return None;
}

function GenericPlayerInitialization(Controller C)
{
	// Note: Skip UTGame GenericPlayerInitialization, it overrides the HUDType.
	Super(UDKGame).GenericPlayerInitialization(C);
}

defaultproperties
{
  PlayerControllerClass=class'UTPlayerController'
  DefaultPawnClass=class'UTPawn'
  BotControllerClass=USARBotAPI.BotController;
  BotMasterClass=USARBotAPI.BotMaster;
  HUDType=class'USARBotAPI.Multiview';
  //DefaultInventory=();
  NumRemoteBots=0;
  //NetWait=0; // Moved to config file
  //CountDown=0;
  //DefaultEnemyRosterClass="XGame.xDMRoster"; // Not needed?
  bPauseable=True;
  bDelayedStart=false;
  //MaxPlayers=16; // Moved to config file
  //GameName="USARSim Deathmatch"; // Moved to config file
  
  USARTruthClass=USARBotAPI.USARTruth;
}
