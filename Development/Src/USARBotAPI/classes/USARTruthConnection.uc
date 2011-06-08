class USARTruthConnection extends TcpLink config(USAR);

var config bool Debug;

event Accepted()
{
  if (Debug) {
    LogInternal("USARTruthConnection: Accepted " $ self);
  }
}

event ReceivedText(string Text)
{
  local Actor theActor;
  local Pawn thePawn;
  local WCObject theWCObject;
	
  if (Debug) {
    LogInternal("USARTruthConnection: ReceivedText " $ Text);
  }

  if (Mid(Text,0,7) == "{Actor}") {
    foreach AllActors(class'Actor', theActor) {
      SendText("{Name " $ theActor.Name $ "} {Class " $ theActor.Class $ "} {Time " $ WorldInfo.TimeSeconds $ "} {Location " $ class'UnitsConverter'.static.LengthVectorFromUU(theActor.Location) $ "} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(theActor.Rotation) $ "}" $ Chr(13) $ Chr(10));
    }
  } else if (Mid(Text,0,10) == "{WCObject}") {
    foreach AllActors(class'WCObject', theWCObject) {
      SendText("{Name " $ theWCObject.Name $ "} {Class " $ theWCObject.Class $ "} {Time " $ WorldInfo.TimeSeconds $ "} {Location " $ class'UnitsConverter'.static.LengthVectorFromUU(theWCObject.Location) $ "} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(theWCObject.Rotation) $ "}" $ Chr(13) $ Chr(10));
    }
  } else {
    foreach AllActors(class'Pawn', thePawn) {
      SendText("{Name " $ thePawn.Name $ "} {Class " $ thePawn.Class $ "} {Time " $ WorldInfo.TimeSeconds $ "} {Location " $ class'UnitsConverter'.static.LengthVectorFromUU(thePawn.Location) $ "} {Rotation " $ class'UnitsConverter'.static.AngleVectorFromUU(thePawn.Rotation) $ "}" $ Chr(13) $ Chr(10));
    }
  }

  SendText("{End}" $ Chr(13) $ Chr(10));
}

event Closed()
{
  if (Debug) {
    LogInternal("USARTruthConnection: Closed " $ self);
  }
  Destroy();
}

defaultproperties
{
  //Debug=true; // Moved to config file
}
