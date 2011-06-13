/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARTruth: One instance is spawned in BotDeathMatch to bind and handle incoming requests for
 * true world data.
 */
class USARTruth extends TcpLink config(USAR);

var config int ListenPort;
var config int MaxConnections;
var int ActiveConnections;

// Starts listening before play begins
function PreBeginPlay()
{
	super.PreBeginPlay();
	BindPort(ListenPort);
	if (Listen())
	{
		if (bDebug)
			LogInternal("USARTruth: Listening on port " $ ListenPort);
	}
	else
	{
		if (bDebug)
			LogInternal("USARTruth: Failed to open listener");
	}
}

// Passed from USARTruthConnection per accepted connection
event Accepted()
{
	if (bDebug)
		LogInternal("USARTruth: Accepted " $ self);
}

// Closes off any sockets in excess of the limit
event GainedChild(Actor r)
{
	ActiveConnections++;
	
	if (ActiveConnections == MaxConnections)
	{
		if (bDebug)
			LogInternal("USARTruth: Connection limit reached");
		Close();
	}
}

// Clears off old connections and starts listening
event LostChild(Actor r)
{
	if (ActiveConnections >= MaxConnections)
	{
		if (bDebug)
			LogInternal("USARTruth: Connection limit no longer reached");
		if (!Listen())
		{
			if (bDebug)
				LogInternal("USARTruth: Failed to open listener");
		}
	}
	ActiveConnections--;
}

// Log when the socket is closed
event Closed()
{
	if (bDebug)
		LogInternal("USARTruth: Closed " $ self);
}

defaultproperties
{
	AcceptClass=Class'USARBotAPI.USARTruthConnection';
}