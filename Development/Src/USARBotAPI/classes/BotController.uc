class BotController extends UDKBot //Eric Changed: originaly it was just Bot but UT3 calls it UTBot 
	config(USAR);

//var config bool bDebug; //Now included in Actor
var config bool bSilentGamebot;

//The socket to the agent
// var BotConnection myConnection; // Replaced in MCD

// Begin MCD
//The necessary variables to define the socket to the agent
var BotConnection theBotConnection;
var repnotify BotMaster theBotMaster;
var repnotify int theBotConnectionID;
// End MCD

var class<Pawn> PawnClass;
//var Pawn Actor;

var config float DeltaTime;

// Begin MCD
replication
{
	if (bNetOwner && bNetDirty && Role == ROLE_Authority) 
		theBotMaster, theBotConnectionID;
}

simulated
event ReplicatedEvent(name VarName)
{
	LogInternal( "BotController:ReplicatedEvent");
	if (theBotConnectionID >= 0 && theBotConnection == none && theBotMaster != none)
		FindConnection();
}

simulated
function SetConnection(BotMaster bm, int botConID)
{
	LogInternal( "BotController:SetConnection");
	theBotMaster = bm;
	theBotConnectionID = botConID;

	if (theBotConnection == none)	
		FindConnection();
}

simulated 
function FindConnection() 
{
	LogInternal( "BotController:FindConnection");
	theBotConnection = theBotMaster.getConnection(theBotConnectionID);

	if (theBotConnection != none) {
		theBotConnection.SetController(self);
	} else {
		LogInternal("Unable to find matching BotConnection.");
	}
}

reliable client
function SendKilled(String Killer, String damageType)
{
	LogInternal( "BotController:SendKilled");
	theBotConnection.SendLine("DIE {Killer "$Killer$"} {DamageType "$damageType$"}");
}
// End MCD

// Begin MCD
reliable server
function RemoteDestroy()
{
	LogInternal( "BotController:RemoteDestroy");
	Destroy();
}

simulated
event Destroyed()
{
	LogInternal( "BotController:simulated Destroyed");

	if(Pawn != None)
		Pawn.Destroy();
    
    Super.Destroyed();
}
// End MCD

/* Replaced by MCD version
function Destroyed()
{
	LogInternal( "BotController:Destroyed");
    if(Pawn != None) {
	Pawn.Destroy();
    }
    Super.Destroyed();
}
*/

defaultproperties
{
    bDebug=False
    //DeltaTime=0.100000 // Moved to config file
    //bSilentGamebot=True // Moved to config file

	// Begin MCD
	theBotConnectionID=-1
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
	// End MCD
}
