/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class BotServer extends TcpLink config(USAR);

var BotMaster Parent;
var config int ListenPort;
var config int MaxConnections;
var String gameClass;
var bool bBound;
var int ConnectionCount;

function PreBeginPlay()
{
	super.PreBeginPlay();

	Parent = BotMaster(Owner);
	BindPort(ListenPort);
	Listen();
	if (bDebug)
		LogInternal("BotServer: Bound to port " $ ListenPort);	
}

event ReceivedText(String Text)
{
    if (bDebug)
    	LogInternal("BotServer: Received text " $ Text);
}

event Accepted()
{
    if (bDebug)
    	LogInternal("BotServer: Accepted connection");
}

// Called every time a new BotConnection is spawned
event GainedChild(Actor C)
{
	super.GainedChild(C);
	ConnectionCount++;
	
	LogInternal("BotServer: Connection established");
	// If too many connections, close down listen
	if (MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		LogInternal("BotServer: Too many connections - stopping listener");
		Close();
	}
}

event LostChild( Actor C )
{
	super.LostChild(C);
	ConnectionCount--;

	LogInternal("BotServer: Connection closed");
	// if closed due to too many connections, start listening again.
	if (ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		LogInternal("BotServer: Resuming listening");
		Listen();
	}
}

defaultproperties
{
	AcceptClass=Class'USARBotAPI.BotConnection'
}
