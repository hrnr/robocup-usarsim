class USARTruth extends TcpLink config(USAR);

// Exactly one instance of this USARTruth class is spawned in
// BotDeathMatch.uc. The USARTruth class binds once to the port,
// and each connection is accepted and handled by the USARTruthConnection
// class.

var config int ListenPort;
var config bool Debug;
var config int MaxConnections;
var int ActiveConnections;
function PreBeginPlay()
{
  local int ival;
  local bool bval;

  Super.PreBeginPlay();

  ival = BindPort(ListenPort);
  if (Debug) {
    LogInternal("USARTruth: BindPort got " $ ival);
  }
  bval = Listen();
  if (true == bval) {
    if (Debug) {
      LogInternal("USARTruth: Listening on " $ ListenPort);
    }
  } else {
    if (Debug) {
      LogInternal("USARTruth: Can't Listen");
    }
  }
}

// The Accepted event will be passed to the USARTruthConnection class,
// per the AcceptClass in the defaultproperties. This lets us have
// multiple accepted connections.

event Accepted()
{
  if (Debug) {
    LogInternal("USARTruth: Accepted " $ self);
  }
}
event GainedChild(Actor r)
{
	ActiveConnections=ActiveConnections+1;
	
	if (ActiveConnections==MaxConnections)
		{
		if(Debug)
			LogInternal("USARTruth: Max Connections rechead, closing listener. Active Connections:"$ActiveConnections );
		Close();
		}
}
event LostChild(Actor r)
{
		
	local bool bval;
	
	
	if (ActiveConnections==MaxConnections)
		{
		if(Debug)
			LogInternal("USARTruth: listening again, Active Connections:"$ActiveConnections );
		bval =Listen();
		if (true == bval) {
			if (Debug) {
				LogInternal("USARTruth: Listening on " $ ListenPort);
			}
		} else {
			if (Debug) {
				LogInternal("USARTruth: Can't Listen");
				}
	
				}
		}
		ActiveConnections=ActiveConnections-1;
	
	
}

event Closed()
{
  if (Debug) {
    LogInternal("USARTruth: Closed " $ self);
  }
}

defaultproperties
{
  // this sets up USARTruthConnection to handle each Accepted event
  AcceptClass=Class'USARBotAPI.USARTruthConnection';
  //MaxConnections=-1; //-1 means unlimited number of connections // Moved to Config file
  //ListenPort=3989; // Moved to Config file
  //Debug=true; // Moved to Config file
}
