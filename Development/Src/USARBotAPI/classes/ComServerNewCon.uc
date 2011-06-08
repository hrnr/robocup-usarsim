class ComServerNewCon extends TcpLink config(USAR);

var ComServerInterface MessageHandler;
var MessageParser messageParser;

event ReceivedText( string Text )
{
    local ParsedMessage parsedMessage;
	
	if(bDebug) LogInternal("ComServerNewCon: Received - "$Text);
	messageParser.ReceiveText(Text);
	while(true)
	{
		parsedMessage=messageParser.getNextMessage();
		if (parsedMessage==None)
			break;
		if(LinkState==STATE_Connected)
		{
		ProcessAction(parsedMessage);
		}
	}
}

//Send a line to the client
function SendLine(string Text, optional bool bNoCRLF)
{
    if(bDebug)
    	LogInternal("ComServerNewCon: Sending: "$Text);
	if(bNoCRLF)
		SendText(Text);
	else
		SendText(Text$Chr(13)$Chr(10));
}

function ProcessAction(ParsedMessage parsedMessage)
{
	local string R1,R2,L1,L2,outstring;
	local float retval;
	local vector startLoc,endLoc;
	
    if(bDebug)
		LogInternal("ComServerNewCon: commandType: "$parsedMessage.GetCommandType());

	switch(Caps(parsedMessage.GetCommandType()))
	{
		//Get number of obstacles between two robots	
		case "GETOBS":
			R1=parsedMessage.GetArgVal("From");
			R2=parsedMessage.GetArgVal("To");
			L1=parsedMessage.GetArgVal("Start");
			L2=parsedMessage.GetArgVal("End");
			
			if(R1=="" || R2=="")
			{
			    if(L1=="" || L2=="")
				{
					if(bDebug) LogInternal("ComServerNewCon: 'From'+'To' or 'Start'+'End' arguments expected in: "$parsedMessage.GetCommandType());
					retval=-1;
				}
				else
				{
					startLoc=class'Utilities'.static.ParseVector(L1);
					endLoc=class'Utilities'.static.ParseVector(L2);
					retval=MessageHandler.getNumObsBetweenLocations(startLoc,endLoc);
					outstring="NUMOBS {Start "$L1$"} {End "$L2$"} {ObstCount "$retval$"}";
				}	
			}
			else
			{
				retval=MessageHandler.getNumObs(R1,R2);
				outstring="NUMOBS {From "$R1$"} {To "$R2$"} {ObstCount "$retval$"}";
			}
			if(bDebug) LogInternal("ComServerNewCon: "$outstring);
			SendLine(outstring,false);
			break;

		case "GETPOS":
			outstring=MessageHandler.getPosAll();			
			SendLine(outstring,false);
			break;
	}
}

defaultproperties
{
	MessageHandler=None
	bDebug=false
	Begin Object Class=MessageParser Name=newMessageParser
  	End Object
  	messageParser=newMessageParser; //initilize messageParser object
}
