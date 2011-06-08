class ComConnection extends Actor 
    config(USAR);

var ComLink link1,link2;
var bool bInit;
var class<ComLink> CLclass;

var FileLog  ComLog;

var config bool bLogWCS;

function setUp(string id1,string id2)
{
	if(!bInit)
	{
		//Spawn two ComLink objects
		link1=spawn(CLclass,self);
		if(link1!=None)
		{
			link1.setUp(id1);
		}
		link2=spawn(CLclass,self);
		if(link2!=None)
		{
			link2.setUp(id2);
		}
		
		if(link1!=None && link2!=None)
			bInit=true;
		else
		{
			if(bDebug)
				LogInternal("ComConnection : Cannot spawn ComLink classes");
		}
	}
}

function bool checkConnectivity(){
	return ComServer(Owner).isReachable(link1.id,link2.id);
}

function fWCSLogInternal(string x) {
    local string filename;
    filename = "WCS-ComConnection-log";

    //UsarGame = USARDeathMatch(Level.Game);

    if(ComLog == None) {
        ComLog = spawn(class'FileLog');
        if(ComLog != None) {
            ComLog.OpenLog(filename);
            ComLog.Logf(x);
        } else {
            LogInternal(x);
        }
    } else {
        ComLog.Logf(x);
    }
}

//Process the requests sent by the robot
function processMessage(string cmd, int Count, byte M[255], string id)
{	
	//Processing the command
	
	if ( bLogWCS ) {
		if(id==link1.id)
			fWCSLogInternal(WorldInfo.TimeSeconds$" "$link1.id$" "$link2.id$" "$Count$" "$cmd);
				
		else
			fWCSLogInternal(WorldInfo.TimeSeconds$" "$link2.id$" "$link1.id$" "$Count$" "$cmd);			
	}
	
	switch(cmd)
	{
		case "SEND":
			/*if(!(ComServer(Owner).isReachable(link1.id,link2.id)))
			{
				if(bDebug) LogInternal("ComConnection: Lost connectivity between "$link1.id$" and "$link2.id);
				if(id==link1.id)
				{
					//link1.SendText("Fail: Lost connectivity between "$link1.id$" and "$link2.id$";");
				}
				else
				{
					//link2.SendText("Fail: Lost connectivity between "$link1.id$" and "$link2.id$";");
				}
				link1.Close();
				link2.Close();
				link1.bInit=false;
				link2.bInit=false;
				break;
			}*/
			if(id==link1.id)
			{
				if(link2.bInit==true)
					link2.SendBinary(Count,M);
				/* 
					fLogInternal(link1.id);
					fLogInternal(link2.id$ $Count);
				*/
				//link1.SendText("OK;");
			}
			else
			{
				if(link1.bInit==true)
					link1.SendBinary(Count,M);
				/* 
					fLogInternal(link2.id);
					fLogInternal(link1.id$ $Count);
				*/	
				//link2.SendText("OK;");
			}
			break;
		case "CLOSE":
			if(link1.bInit==true)
			{
				if (bDebug) LogInternal("ComConnection: Closing connection to "$link1.id);
				link1.Close();
				link1.bInit=false;
			}
			if(link2.bInit==true)
			{
				if (bDebug) LogInternal("ComConnection: Closing connection to "$link2.id);
				link2.Close();
				link2.bInit=false;
			}
			break;
		//These should not occur
		case "REGISTER":
		case "LISTEN":
		case "OPEN":
		default:
			if(bDebug) LogInternal("ComConnection: Unknown message - "$cmd);
			if(id==link1.id)
			{
				Link1.SendText("Fail: Unknown message;");
			}
			else
			{
				Link2.SendText("Fail: Unknown message;");
			}
	}
}

defaultproperties
{
	CLclass=USARBotApi.ComLink
	bInit=false
	bDebug=false
	//bLogWCS=true // Moved to config file
}
