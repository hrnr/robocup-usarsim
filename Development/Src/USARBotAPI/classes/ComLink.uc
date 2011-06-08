class ComLink extends TcpLink 
    config(USAR);

var string id;
var string PartMsg;
var string MsgEnd;
var bool bInit;
var int RPort;


//Variables to process the binary message
var bool bNewMsg;
var int mLen;
var string sLen;
var int mProc;
var byte Msg[255];
var int aProc;
var string Com;
var byte C[5];


function setUp(string iden)
{
	if(!bInit)
	{
		id=iden;
		bInit=true;
		LinkMode=MODE_Binary;
	}
}

function Connect(string Ip, string sPort)
{
	RPort=int(sPort);
	if(bDebug)
		LogInternal("ComLink: Connect is resolving IP address "$Ip);
	Resolve(Ip);
}

event Resolved(IpAddr Addr)
{
	if(bDebug)
		LogInternal("ComLink: IP address resolved");
	Addr.Port=RPort;
	BindPort();
	Open(Addr);
}

event ResolveFailed()
{
  if(bDebug) LogInternal("ComLink: Could not resolve IP address");
}

event Opened()
{
	if(bDebug)
		LogInternal("ComLink: "$id$" Connected to "$IpAddrToString(RemoteAddr));
}

function bool Open(IpAddr Addr)
{
	if(bDebug)
		LogInternal("ComLink: "$id$" Connecting to "$IpAddrToString(Addr));
	return super.Open(Addr);
}

event ReceivedLine(string Line)
{
	if(bInit)
	{
		ComConnection(Owner).processMessage(Line,0,Msg,id);
	}
}

event ReceivedText( string Text )
{
	local int i;
	local string M;
	
	i=0;
	if(bDebug)
    	LogInternal("ComLink: Received Text in Server - "$Text);
		
	i=InStr(Text,MsgEnd);
	if(i==-1)				//Incomplete message
	{
		PartMsg$=Text;
	}
	else
	{
		M=PartMsg$Left(Text,i+1);
		PartMsg=Mid(Text,i+1);
		ReceivedLine(M);
	}
}

//convert the byte array to a string (SEND, CLOSE or ERR)
function string getCommand(byte B[5])
{
	if(B[0]==83 && B[1]==69 && B[2]==78 && B[3]==68 && B[4]==32)
	{
		return "SEND";
	}
	else if(B[0]==67 && B[1]==76 && B[2]==79 && B[3]==83 && B[4]==69)
	{
		return "CLOSE";
	}
	else
	{
		return "ERR";
	}
}

//If you receive a binary message
event ReceivedBinary( int Count, byte B[255] )
{
	local int ctr;
	local string m;
	local bool reachable;
	ctr=0;
	
	
	
	if(bDebug)
	{
		m="";
		while(ctr<Count)
		{
			m=m$string(B[ctr]);
			ctr++;
		}
		ctr=0;
		LogInternal("ComLink: Recived "$m);
	}
	
	while(ctr<Count)
	{
		//The command part of the message
		if(mProc<5)
		{
			C[mProc]=B[ctr];
			ctr++;
			mProc++;
		}
		//If the command part has just been processed
		if(mProc==5)
		{
			Com=getCommand(C);
			if(bDebug) LogInternal("ComLink: command received is "$Com);
		}
		
		//If the command part has been processed
		if(mProc>=5)
		{
			switch(Com)
			{
				case "SEND": 
					//Check for connectivity
					reachable=ComConnection(Owner).checkConnectivity();
					//Get the size
					if(mLen<0)
					{
						while(ctr<Count)
						{
							if(B[ctr]==32) break;
							sLen=sLen$string(int(B[ctr])-48);
							ctr++;
						}
						if(ctr<Count)
						{
							mLen=int(sLen);
							if(bDebug) LogInternal("ComLink: Message length is "$sLen$" converted to "$mLen);
							aProc=0;
							ctr++;
						}
					}
					//Get the message
					if(mLen>=0)
					{
						while(aProc<mLen && ctr<Count)
						{
							Msg[aProc]=B[ctr];
							ctr++;
							aProc++;
							//If the message buffer is full
							if(aProc==255)
							{
								//Process message
								if(reachable){
									if(bDebug) LogInternal("ComLink: message of size "$aProc$" being sent");
									ComConnection(Owner).processMessage(Com,aProc,Msg,id);
								}
								mLen=mLen-aProc;
								aProc=0;
							}
						}
						if(ctr<Count)
						{
							if(reachable){
								if(bDebug) LogInternal("ComLink: message of size "$aProc$" being sent");
								ComConnection(Owner).processMessage(Com,aProc,Msg,id);
							}
							ctr++;
							mProc=0;
							aProc=0;
							mLen=-1;
							sLen="";
							Com="None";
						}
					}
					if(!reachable){
						if(bDebug) LogInternal("ComLink: Connection being broken due to sig strength");
						ComConnection(Owner).processMessage("CLOSE",0,Msg,id);
					}
					break;
				case "CLOSE":
				//Go to the next semicolon
					while(ctr<Count)
					{
						if(B[ctr]==59) break;
						ctr++;
						mProc++;
					}
					//If this is the semi colon
					if(ctr<Count)
					{
						//Process message
						ComConnection(Owner).processMessage(Com,0,B,id);
						ctr++;
						mProc=0;
						Com="None";
					}
					break;
				case "ERR":
				//Go to the next semicolon
					while(B[ctr]!=59 && ctr<Count)
					{
						ctr++;
						mProc++;
					}
					//If this is the semi colon
					if(ctr<Count)
					{
						//Process message
						
						//ComConnection(Owner).processMessage(Com,0,B,id);
						ctr++;
						mProc=0;
						Com="None";
					}
					break;
			}
		}
	}	
		
		/*
		//If the command type is SEND the get the message into the byte array
		if(Com=="SEND" && B[ctr]!=59 && mProc>4)
		{
			Msg[aProc]=B[ctr];
			aProc=aProc+1;
		}
		
		//if the message buffer is full
		if(Com=="SEND" && aProc==255)
		{
			ComConnection(Owner).processMessage(Com,aProc,Msg,id);
			aProc=0;
		}
	
		mProc=mProc+1;
		bNewMsg=false;
		//End of message
		if(Com!="SEND" && B[ctr]==59)
		{
			//Process message
			if(bInit)
				ComConnection(Owner).processMessage(Com,0,Msg,id);
			//Reset counters
			mLen=0;
			mProc=0;
			aProc=0;
			bNewMsg=true;
			Com="NONE";
		}
		if(Com=="SEND" && B[ctr]==59 && mProc>=mLen)
		{
			//Process message
			if(bInit)
				ComConnection(Owner).processMessage(Com,aProc,Msg,id);
			//Reset counters
			mLen=0;
			mProc=0;
			aProc=0;
			bNewMsg=true;
			Com="NONE";
		}
		ctr=ctr+1;
	}
	*/
}

//Should never be called
function processMessage(string Message, string sId)
{
	if (bDebug)
		LogInternal("ComLink "$sId$" - Incorrect owner");
}

//Closed on other end
event Closed()
{
	
	//Process message
	if(bInit)
	{
		if(bDebug)
		{
			LogInternal("ComLink: Robot "$id$" closed the connection");
		}
		bInit=false;
		ComConnection(Owner).processMessage("CLOSE",0,Msg,id);
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
	mLen=-1;
	sLen="";
	mProc=0
	aProc=0
	Com=""
}
