/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

/*
 * ComLink: represents communication link between robot and controller
 */
class ComLink extends TcpLink config(USAR);

var String id;
var String PartMsg;
var String MsgEnd;
var bool bInit;
var int RPort;
// Variables to process the binary message
var bool bNewMsg;
var int mLen;
var String sLen;
var int mProc;
var byte Msg[255];
var int aProc;
var String Com;
var byte C[5];

function setUp(String iden)
{
	if (!bInit)
	{
		id = iden;
		bInit = true;
		LinkMode = MODE_Binary;
	}
}

function Connect(String ip, String sPort)
{
	RPort = int(sPort);
	if (bDebug)
		LogInternal("ComLink: Resolving IP address " $ ip);
	Resolve(ip);
}

event Resolved(IpAddr addr)
{
	if (bDebug)
		LogInternal("ComLink: IP address resolved");
	addr.Port = RPort;
	BindPort();
	Open(addr);
}

event ResolveFailed()
{
	if (bDebug)
		LogInternal("ComLink: Could not resolve IP address");
}

event Opened()
{
	if (bDebug)
		LogInternal("ComLink: " $ id $ " connected to " $ IpAddrToString(RemoteAddr));
}

function bool Open(IpAddr addr)
{
	if (bDebug)
		LogInternal("ComLink: " $ id $ " Connecting to " $ IpAddrToString(addr));
	return super.Open(Addr);
}

event ReceivedLine(String line)
{
	if (bInit)
		ComConnection(Owner).processMessage(line, 0, Msg, id);
}

event ReceivedText(String text)
{
	local int i;
	local String M;
	
	i = 0;
	if (bDebug)
    	LogInternal("ComLink: Received " $ text);
		
	i = InStr(text, MsgEnd);
	if (i < 0)
		PartMsg $= text;
	else
	{
		M = PartMsg $ Left(text, i+1);
		PartMsg = Mid(text, i+1);
		ReceivedLine(M);
	}
}

//convert the byte array to a string (SEND, CLOSE or ERR)
function String getCommand(byte B[5])
{
	if (B[0]==83 && B[1]==69 && B[2]==78 && B[3]==68 && B[4]==32)
	{
		return "SEND";
	}
	else if (B[0]==67 && B[1]==76 && B[2]==79 && B[3]==83 && B[4]==69)
	{
		return "CLOSE";
	}
	else
	{
		return "ERR";
	}
}

//If you receive a binary message
event ReceivedBinary(int Count, byte B[255])
{
	local int ctr;
	local String m;
	local bool reachable;
	
	ctr = 0;
	if (bDebug)
	{
		m = "";
		while (ctr < Count)
		{
			m $= String(B[ctr]);
			ctr++;
		}
		ctr = 0;
		LogInternal("ComLink: Recieved " $ m);
	}
	
	while (ctr < Count)
	{
		// The command part of the message
		if (mProc < 5)
		{
			C[mProc] = B[ctr];
			ctr++;
			mProc++;
		}
		// If the command part has just been processed
		if (mProc == 5)
		{
			Com = getCommand(C);
			if (bDebug)
				LogInternal("ComLink: command received is " $ Com);
		}
		// If the command part has been processed
		if (mProc >= 5)
			switch (Com)
			{
				case "SEND": 
					// Check for connectivity
					reachable = ComConnection(Owner).checkConnectivity();
					if (mLen < 0)
					{
						while (ctr < Count)
						{
							if (B[ctr] == 32) break;
							sLen $= String(int(B[ctr]) - 48);
							ctr++;
						}
						if (ctr < Count)
						{
							mLen = int(sLen);
							if (bDebug)
								LogInternal("ComLink: Message length is " $ mLen);
							aProc = 0;
							ctr++;
						}
					}
					// Get the message
					if (mLen >= 0)
					{
						while (aProc < mLen && ctr < Count)
						{
							Msg[aProc] = B[ctr];
							ctr++;
							aProc++;
							// Send message if possible
							if (aProc == 255)
							{
								// Process message
								if (reachable)
								{
									if (bDebug)
										LogInternal("ComLink: Sending message of size " $ aProc);
									ComConnection(Owner).processMessage(Com, aProc, Msg, id);
								}
								mLen = mLen - aProc;
								aProc = 0;
							}
						}
						if (ctr < Count)
						{
							// Send message if possible
							if (reachable)
							{
								if (bDebug)
									LogInternal("ComLink: Sending message of size " $ aProc);
								ComConnection(Owner).processMessage(Com, aProc, Msg, id);
							}
							ctr++;
							mProc = 0;
							aProc = 0;
							mLen = -1;
							sLen = "";
							Com = "None";
						}
					}
					// Notify if connection is closed
					if (!reachable)
					{
						if (bDebug)
							LogInternal("ComLink: Low signal strength, closing connection");
						ComConnection(Owner).processMessage("CLOSE", 0, Msg, id);
					}
					break;
				case "CLOSE":
					// Go to the next semicolon
					while (B[ctr] != 59 && ctr < Count)
					{
						ctr++;
						mProc++;
					}
					if (ctr < Count)
					{
						// Send last message
						ComConnection(Owner).processMessage(Com, 0, B, id);
						ctr++;
						mProc = 0;
						Com = "None";
					}
					break;
				case "ERR":
					// Go to the next semicolon
					while (B[ctr] != 59 && ctr < Count)
					{
						ctr++;
						mProc++;
					}
					if (ctr < Count)
					{
						// Clean up
						ctr++;
						mProc = 0;
						Com = "None";
					}
					break;
			}
	}
}

// Should never be called
function processMessage(String message, String sId)
{
	if (bDebug)
		LogInternal("ComLink: Incorrect owner " $ sId);
}

// Closed on other end
event Closed()
{
	if (bInit)
	{
		if (bDebug)
			LogInternal("ComLink: Robot " $ id $ " closed the connection");
		bInit = false;
		ComConnection(Owner).processMessage("CLOSE", 0, Msg, id);
	}
}

defaultproperties
{
	id=""
	bInit=false
	PartMsg=""
	MsgEnd=";"
	bDebug=false
	RPort=0
	bNewMsg=true
	mLen=-1
	sLen=""
	mProc=0
	aProc=0
	Com=""
}
