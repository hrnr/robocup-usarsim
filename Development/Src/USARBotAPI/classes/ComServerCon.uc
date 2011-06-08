class ComServerCon extends TcpLink 
    config(USAR);

var bool bInit;
var ComServer MessageHandler;
var string MsgEnd;
var string PartMsg;


event ReceivedLine( string Line )
{
	if(bInit==False)
	{
		if (bDebug) LogInternal("ComServerCon: Not initialized");
	}
	else
	{
		if(MessageHandler==None)
		{
			if (bDebug) LogInternal("ComServerCon: No message handler");
		}
		else
		{
			MessageHandler.HandleLine(Line,Self,IpAddrToString(RemoteAddr));
		}
	}
}

event ReceivedText( string Text )
{
	local int i;
	local string Msg;
	if(bInit==false)
	{
		if(bDebug) LogInternal("ComServerCon: Not Initialized");
	}
	else
	{
		i=0;
		if(bDebug)
			LogInternal("ComServerCon: Received Text in Server - "$Text);
		
		i=InStr(Text,MsgEnd);
		if(i==-1)				//Incomplete message
		{
			PartMsg$=Text;		//Concatenate
		}
		else
		{
			Msg=PartMsg$Left(Text,i+1);
			PartMsg=Mid(Text,i+1);
			if(MessageHandler==None)
			{
				if (bDebug) LogInternal("ComServerCon: No message handler");
			}
			else
			{
				MessageHandler.HandleLine(Msg,Self,IpAddrToString(RemoteAddr));
			}
		}
	}
}

defaultproperties
{
	bInit=false
	MessageHandler=None
	bDebug=false
	MsgEnd=";"
}
