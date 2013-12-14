// Represents a single parsed messages received over TcpLink connections
class ParsedMessage extends Object;

var string cmdType;
var int attrNum;
var array<string> ReceivedArgs;
var array<string> ReceivedVals;
var bool bDebug;

defaultproperties
{
  cmdType="";
  attrNum=0;
  bDebug=true;
}

// parses a 'message' to its command type, arguments and the argument values
function bool ParseMessage(string message)
{
  local int i,j;
  local string block;
 
  if(bDebug) LogInternal("ParsedMessage: parsing '"$message$"'");
 
  message=class'Utilities'.static.trim(message);
  i=InStr(message,"{");
  if (i==-1)
	i=Len(message);
  cmdType=class'Utilities'.static.trim(left(message,i));
  if(bDebug) LogInternal("ParsedMessage: command type '"$cmdType$"'");
	
  while (true)
  {
    i=InStr(message,"{");
	j=InStr(message,"}");
	if (i==-1 || j==-1)
	{
	   break;
	}
	block=class'Utilities'.static.trim(Mid(message,i+1,j-(i+1)));
	if(bDebug) LogInternal("ParsedMessage: parsing block '"$block$"'");
	
	i=InStr(block," ");
	ReceivedArgs[attrNum]=class'Utilities'.static.trim(Left(block,i));
	ReceivedVals[attrNum]=class'Utilities'.static.trim(Mid(block,i));
	if(bDebug) LogInternal("ParsedMessage: found arg '"$ReceivedArgs[attrNum]$"' value '"$ReceivedVals[attrNum]$"'");
	attrNum+=1;
	
	message=mid(message,j+1);
  }

  return true;
}

// returns the command type
function string GetCommandType()
{
  return cmdType;
}

// returns the value of an argument
function string GetArgVal(string argName)
{
  local int i;
  while (i < attrNum && ReceivedArgs[i] != "")
  {
 	if (ReceivedArgs[i] ~= argName)
	return ReceivedVals[i];
 	i++;
  }
  return "";
}

// returns all arguments
function array<string> GetArguments()
{
  return ReceivedArgs;
}

// returns all valeus
function array<string> GetValues()
{
  return ReceivedVals;
}

function printParsedMessage()
{
  local string message;
  local array<string> arguments;
  local string arg;
  
  message=GetCommandType();
  arguments=GetArguments();
  foreach arguments(arg)
  {
	  message@="{"$arg$" "$GetArgVal(arg)$"}";
  }
  LogInternal("ParsedMessage: '"$message$"'");
}
