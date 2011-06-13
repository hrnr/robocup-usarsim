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

event Accepted()
{
	if (bDebug)
		LogInternal("USARTruthConnection: Accepted " $ self);
}

event ReceivedText(String Text)
{
	local Actor theActor;
	local Pawn thePawn;
	local WCObject theWCObject;

	if (bDebug)
		LogInternal("USARTruthConnection: Received " $ Text);
	if (Mid(Text, 0, 7) == "{Actor}")
	{
		foreach AllActors(class'Actor', theActor)
		{
			SendText("{Name " $ theActor.Name $ "} {Class " $ theActor.Class $ "} {Time " $
				WorldInfo.TimeSeconds $ "} {Location " $
				class'UnitsConverter'.static.LengthVectorFromUU(theActor.Location) $
				"} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(theActor.Rotation) $
				"}" $ Chr(13) $ Chr(10));
		}
	}
	else if (Mid(Text, 0, 10) == "{WCObject}")
	{
		foreach AllActors(class'WCObject', theWCObject)
		{
			SendText("{Name " $ theWCObject.Name $ "} {Class " $ theWCObject.Class $ "} {Time " $
				WorldInfo.TimeSeconds $ "} {Location " $
				class'UnitsConverter'.static.LengthVectorFromUU(theWCObject.Location) $
				"} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(theWCObject.Rotation) $
				"}" $ Chr(13) $ Chr(10));
		}
	}
	else
	{
		foreach AllActors(class'Pawn', thePawn)
		{
			SendText("{Name " $ thePawn.Name $ "} {Class " $ thePawn.Class $ "} {Time " $
				WorldInfo.TimeSeconds $ "} {Location " $
				class'UnitsConverter'.static.LengthVectorFromUU(thePawn.Location) $
				"} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(thePawn.Rotation) $
				"}" $ Chr(13) $ Chr(10));
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
