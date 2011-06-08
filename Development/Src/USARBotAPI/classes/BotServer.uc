class BotServer extends TcpLink
	config(USAR);

// Begin MCD
var BotMaster Parent;
// End MCD

var config int ListenPort;
var config int MaxConnections;

var string gameClass;
var bool bBound;
var int ConnectionCount;

// Begin MCD
function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	Parent = BotMaster(Owner);

	BindPort( ListenPort );
	Listen();

	if (bDebug)
		LogInternal("BotServer: Bound to port "$ListenPort);	
}
// End MCD

//should never happen - accepted connections should be forwarded to a botconnection
event ReceivedText( string Text )
{
    if(bDebug)
    	LogInternal("ReceivedTest in Server - "$Text);
}

/* Replaced by MCD version
function PreBeginPlay()
{
	Super.PreBeginPlay();
    
    if(!bBound)
    {
		BindPort( ListenPort );
        
		if(bDebug)
    		LogInternal("BotServer bound to port "$ListenPort);
        
		Listen();
        bBound = true;
    }
}*/

//should never happen - accepted connections should be forwarded to a botconnection
event Accepted()
{
    if(bDebug)
    	LogInternal("Accepted connection in BotServer");
}

//called everytime a new botconnection is spawned
event GainedChild( Actor C )
{
	Super.GainedChild(C);
	ConnectionCount++;

	LogInternal( "BotServer:GainedChild called" );
    //BotConnection(C).Parent = self;
	// if too many connections, close down listen.
	if(MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		if(bDebug)
    		LogInternal("BotServer: Too many connections - closing down Listen.");
		Close();
	}
}

event LostChild( Actor C )
{
	Super.LostChild(C);
	ConnectionCount--;

	LogInternal( "BotServer:LostChild called" );

	// if closed due to too many connections, start listening again.
	if(ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		if(bDebug)
    		LogInternal("BotServer: Listening again - connections have been closed.");
		Listen();
	}
}

defaultproperties
{
    // ListenPort=3000 // Moved to config file
     //MaxConnections=64 // Moved to config file
     AcceptClass=Class'USARBotAPI.BotConnection'
}
