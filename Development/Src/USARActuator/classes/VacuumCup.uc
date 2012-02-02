

class VacuumCup extends Vacuum placeable config(USAR);

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
	
	SuctionFrom = (x=0.04, y=0,z=0)
}