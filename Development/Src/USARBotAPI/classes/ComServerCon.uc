/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * ComServerCon: Passes messages to a handler when received on a link
 */
class ComServerCon extends TcpLink config(USAR);

var bool bInit;
var ComServer MessageHandler;
var String MsgEnd;
var String PartMsg;

// Called when text is received
event ReceivedLine(String Line)
{
	if (!bInit)
	{
		if (bDebug)
			LogInternal("ComServerCon: Not initialized");
	}
	else
	{
		if (MessageHandler == None)
		{
			if (bDebug)
				LogInternal("ComServerCon: No message handler");
		}
		else
			MessageHandler.HandleLine(Line, self, IpAddrToString(RemoteAddr));
	}
}

// Called when part of a line is received
event ReceivedText(String Text)
{
	local int i;
	local String Msg;
	
	if (!bInit)
	{
		if (bDebug)
			LogInternal("ComServerCon: Not Initialized");
	}
	else
	{
		if (bDebug)
			LogInternal("ComServerCon: Received Text in Server - "$Text);
		i = InStr(Text, MsgEnd);
		// Incomplete message?
		if (i < 0)
			PartMsg $= Text;
		else
		{
			Msg = PartMsg $ Left(Text, i + 1);
			PartMsg = Mid(Text, i + 1);
			if (MessageHandler == None)
			{
				if (bDebug)
					LogInternal("ComServerCon: No message handler");
			}
			else
				MessageHandler.HandleLine(Msg, self, IpAddrToString(RemoteAddr));
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
