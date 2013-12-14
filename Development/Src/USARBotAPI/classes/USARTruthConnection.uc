/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARTruthConnection: send true world data to connected client
 */
class USARTruthConnection extends TcpLink config(USAR);

var MessageParser parser;

event Accepted()
{
	if (bDebug)
		LogInternal("USARTruthConnection: Accepted " $ self);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	parser = new class'MessageParser';
}

event ReceivedText(String Text)
{
	local Actor theActor;
	local ParsedMessage parsedMessage;
	local class<Actor> searchClass;
	local String searchName;
	local String className;
	local String actorName;
	local Vector actorLocation;
	local Rotator actorRotation;
	
	if (bDebug)
		LogInternal("USARTruthConnection: Received " $ Text);
	
	parser.ReceiveText(Text);
	parsedMessage = parser.getNextMessage();
	className = parsedMessage.getArgVal("class");
	searchName = parsedMessage.getArgVal("name");
	if (bDebug)
		LogInternal("USARTruth looking for class " $ className $ " and name " $searchName);
	if(className != "")
	{
		searchClass = class<Actor>(DynamicLoadObject(className, class'Class'));
		if(searchClass == None)
		{
			if (bDebug)
				LogInternal("Did not find class " $ className $ ", guessing USARPhysObj." $ className);
			className = "USARPhysObj." $ className;
			searchClass = class<Actor>(DynamicLoadObject(className, class'Class'));
		}
	}
	else
	{
		searchClass = class'Pawn';
	}
	if(searchClass != None)
	{
		foreach AllActors(searchClass, theActor)
		{
			//custom actor name behavior
			if(theActor.isA('WCObject'))
			{
				actorName = WCObject(theActor).ObjectName;
			}
			else if(theActor.isA('Item'))
			{
				actorName = Item(theActor).ItemName;
			}
			else
			{
				actorName = String(theActor.Name);
			}
			//custom actor position behavior
			if(theActor.isA('USARVehicle'))
			{
				actorLocation = USARVehicle(theActor).CenterItem.Location;
				actorRotation = USARVehicle(theActor).CenterItem.Rotation;
			}
			else
			{
				actorLocation = theActor.Location;
				actorRotation = theActor.Rotation;
			}
			if(searchName == "" || searchName == actorName)
			{
				SendText("{Name " $ actorName $ "} {Class " $ theActor.Class $ "} {Time " $
					WorldInfo.TimeSeconds $ "} {Location " $
					class'UnitsConverter'.static.LengthVectorFromUU(actorLocation) $
					"} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(actorRotation) $
					"}" $ Chr(13) $ Chr(10));
			}
		}
	}
	SendText("{End}" $ Chr(13) $ Chr(10));
}

event Closed()
{
	if (bDebug)
		LogInternal("USARTruthConnection: Closed " $ self);
	Destroy();
}

defaultproperties
{
}
