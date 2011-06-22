/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * BotMaster: TCP server for incoming USAR connection requests
 */
class BotMaster extends Inventory config(USAR);

var class<BotServer>	BotServerClass;
var class<ComServer>	ComServerClass;
var class<ComServerInterface>	ComServerInterfaceClass;

var BotServer 	    	theBotServer;
var ComServer			theComServer;
var ComServerInterface	theComServerInterface;

var BotDeathMatch       theGameInfo;
var string              theGameInfoClass;
var int                 theGameTimeLimit;

var BotConnection       waitConnections[64];

replication 
{
	// Sends waitConnections list to server
	if (Role < ROLE_Authority)
		waitConnections;

	// Send game information to clients
	if (Role == ROLE_Authority)
		theGameInfoClass, theGameTimeLimit;
}

function SetGameInfo(BotDeathMatch gi)
{
	theGameInfo = gi;
	theGameInfoClass = string(gi.Class);
	theGameTimeLimit = gi.TimeLimit;
}

simulated function int GetTimeLimit()
{
	return theGameTimeLimit;
}

simulated function String GetGameInfoClass()
{
	return theGameInfoClass;
}

reliable client function Initialize()
{
	// Start the TCP services
    theBotServer = spawn(BotServerClass, self);
	theComServer = spawn(ComServerClass, self);
	theComServerInterface = spawn(ComServerInterfaceClass, self);
}

function AddBotController(BotConnection botCon, String botName, vector startLocation,
	rotator startRotation, String className)
{
	local int i;
	
	// Find first open slot in array
	for (i = 0; i < ArrayCount(waitConnections); i++)
		if (waitConnections[i] == None)
		{
			// Assign caller BotConnection to open slot and replicate AddBot function on server
			waitConnections[i] = botCon;
			AddBotController_internal(i, botName, startLocation, startRotation, className);
			return;
		}
	LogInternal("Too many unbound robots, failed to create " $ className);
}

function DeleteBotController(BotController botCon)
{
	DeleteBotController_internal(botCon);
}

reliable server protected function DeleteBotController_internal(BotController theBot)
{
	theGameInfo.DeleteBotController(theBot);
}

reliable server protected function bool AddBotController_internal(int botConID, String botName,
	vector startLocation, rotator startRotation, String className)
{
	local BotController theBot;
	
	theBot = theGameInfo.AddBotController(Owner, botName, startLocation, startRotation, className);
	if (theBot.PawnClass != None)
	{
		theBot.SetConnection(self, botConID);
		LogInternal("Created " $ className $ ", assigned to " $ theBot);
	}
	return theBot.PawnClass != None;
}

simulated function BotConnection getConnection(int botConnectionID)
{
	local BotConnection botCon;

	botCon = waitConnections[botConnectionID];
	waitConnections[botConnectionID] = none;
	return botCon;
}

defaultproperties
{
	BotServerClass=USARBotAPI.BotServer
    ComServerClass=USARBotAPI.ComServer
    ComServerInterfaceClass=USARBotAPI.ComServerInterface
}