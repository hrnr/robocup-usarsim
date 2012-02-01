class VacuumGripper extends Vacuum placeable config(USAR);


simulated function AttachItem()
{
	super.AttachItem();
	CenterItem.SetHidden(false);
}
defaultproperties
{
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'VacuumGripper.vacuum_gripper'
		Mass = 1.5
	End Object
	PartList.Add(BodyItem)
	Body=BodyItem
	
	SuctionFrom = (x=.2,y=0,z=0)
}
