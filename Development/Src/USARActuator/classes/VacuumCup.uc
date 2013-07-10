

class VacuumCup extends Vacuum placeable config(USAR);

//For UDK-2013-02:
//Make sure that this part is NOT mounted on the arm at an orientation of (0, 1.5708, 0): due to
//a UDK bug, the vacuum will not rotate properly if the pitch is too close to exactly pi/2

simulated function AttachItem()
{
	super.AttachItem();
	CenterItem.SetHidden(false);
}

defaultproperties
{
	
	Begin Object Class=Part Name=BodyItem
		Mesh = StaticMesh'SuctionCup.VacuumCup'
		Mass = 0.5
	End Object
	
	PartList.Add(BodyItem)
	Body=BodyItem
	
	
//	TipOffset = (x=0,y=0,z=.0)
	TipOffset = (x=0, y=0,z=0.035)
	SuctionLength = 0.02
}
