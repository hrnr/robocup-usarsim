

class VacuumCup extends Vacuum placeable config(USAR);

simulated function AttachItem()
{
	super.AttachItem();
	CenterItem.SetHidden(false);
}

defaultproperties
{
	
	Begin Object Class=Part Name=BodyItem
		Mesh = StaticMesh'SuctionCup.VacuumCupFeb2013'
		Mass = 0.5
	End Object
	
	PartList.Add(BodyItem)
	Body=BodyItem
	
	TipOffset = (x=0,y=0,z=-0.085)
//	TipOffset = (x=0, y=0,z=-0.085)
}
