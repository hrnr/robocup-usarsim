// Parses messages received over TcpLink connections in the format:
//     commandtype {argument1 value1 } { argument2 value2 }
// and ending with any combination of 'new line' or 'carriage return' of atleast length 1
// see the regression test function below for examples of use
class MessageParser extends Object;

var string receivedData;
var StackQueue queue;
var bool bDebug;

var ConveyorVolume t;

defaultproperties
{
  receivedData="";

  Begin Object Class=StackQueue Name=newQueue
  End Object
  queue=newQueue //initilize queue object

  bDebug=false;
}

// receives 'text' which is parses into messages
// note that 'text' can contain many and or parts of a message
function ReceiveText(string text)
{
  local ParsedMessage parsedMessage;
  local int i,j;

  if (bDebug) LogInternal("MessageParser: receiving '"$text$"'");
  receivedData$=text;
  while (true)
  {
    while (Left(receivedData,1)==Chr(10) || Left(receivedData,1)==Chr(13))
		receivedData=Mid(receivedData,1);
	if (bDebug) LogInternal("MessageParser: searching end of message in: "$receivedData);
    i=InStr(receivedData, Chr(10)); // search for end of first message
	j=InStr(receivedData, Chr(13)); // search for end of first message
	if (i==-1 || i>j)
	  i=j;
    if (i==-1)
	  break; // exit loop when no end is found and try again after receiving more text
    parsedMessage= new class'ParsedMessage';
    if (parsedMessage.ParseMessage(Left(receivedData,i)))
    {
      addNewMessage(parsedMessage);
    }
    receivedData=Mid(receivedData,i+1); // remainder of data
  }
}

// gets the next parsed message when available
// when none is available it returns None 
function ParsedMessage getNextMessage()
{
  local ParsedMessage parsedMessage;
  parsedMessage=ParsedMessage(queue.pop_oldest());
  if (bDebug)
  {
    if (parsedMessage==None)
      LogInternal("MessageParser: no message available");
    else
      LogInternal("MessageParser: returning a message");
  }	
  return parsedMessage;
}

function printMessageParser()
{
  local ParsedMessage parsedMessage;
  local int i;
  for(i=queue.start();i<queue.end();i++)
  {
    parsedMessage=ParsedMessage(queue.get(i));
    parsedMessage.printParsedMessage();
  }
}

private function addNewMessage(ParsedMessage parsedMessage)
{
  if(bDebug) LogInternal("MessageParser: new message added to queue");
  queue.push(parsedMessage);
}

// runs some regression tests
// returns true on success and false on error
function bool test()
{
  local MessageParser messageParser;
  local ParsedMessage parsedMessage;
  local int count;
  
  if (bDebug) LogInternal("MessageParser Test: running regression tests");
  // receive data
  messageParser=new class'MessageParser';
  messageParser.ReceiveText("TestCommand {test1 1} {test2 2}"$Chr(10));
  messageParser.ReceiveText("Com1{BasMan Rulez} {Hello"); // split
  messageParser.ReceiveText(" 2}"$Chr(13)$Chr(13)$Chr(13));
  messageParser.ReceiveText("Com2     {  WithWhitespaces      88     } {        More  whitespaces }    "$Chr(10)$Chr(13)$Chr(10)$Chr(13));
  if (bDebug) LogInternal("MessageParser Test: current set of queued messages:");
  if (bDebug) messageParser.printMessageParser();
  
  // get all messages
  count=0;
  while(true)
  {
    parsedMessage=messageParser.getNextMessage();
	if (parsedMessage==None)
	  break;
    if (bDebug) LogInternal("MessageParser Test: testing message:");
	if (bDebug) parsedMessage.printParsedMessage();

	count++;
	switch (count)
	{
	  case 1:
		if (parsedMessage.GetCommandType()!="TestCommand") 
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected 'TestCommand':");
		  return false;
		}
		if (parsedMessage.GetArgVal("test1")!="1")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected '1':");
		  return false;
		}
		if (parsedMessage.GetArgVal("test2")!="2")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected '2':");
		  return false;
		}
	    if (bDebug) LogInternal("MessageParser Test: test 1 succeeded");break;
	  case 2:
	    if (parsedMessage.GetCommandType()!="Com1")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected 'Com1':");
		  return false;
		}
		if (parsedMessage.GetArgVal("BasMan")!="Rulez")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected 'Rulez':");
		  return false;
		}
		if (parsedMessage.GetArgVal("Hello")!="2")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected '2':");
		  return false;
		}
	    if (bDebug) LogInternal("MessageParser Test: test 2 succeeded");break;
	  case 3:
	    if (parsedMessage.GetCommandType()!="Com2")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected 'Com2':");
		  return false;
		}
		if (parsedMessage.GetArgVal("WithWhitespaces")!="88")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected '88':");
		  return false;
		}
		if (parsedMessage.GetArgVal("More")!="whitespaces")
		{ 
		  if (bDebug) LogInternal("MessageParser Test: ERROR expected 'whitespaces':");
		  return false;
		}
	    if (bDebug) LogInternal("MessageParser Test: test 3 succeeded");break;
	}
  }
  if (bDebug) LogInternal("MessageParser Test: all tests succeeded");
  return true;
}
