

class TwoLinkArm extends Actuator placeable config (USAR);

defaultproperties
{
	Begin Object Class=Part Name=Link1
		Mesh=StaticMesh'TwoLink.link'
		Mass=0.1
	End Object
	Body=Link1
	PartList.Add(Link1)
	
	Begin Object Class=Part Name=Link2
		Mesh=StaticMesh'TwoLink.link'
		Mass=0.1
		Offset=(x=2.1,y=0,z=0)
	End Object
	PartList.Add(Link2)
	
	
	Begin Object Class=RevoluteJoint Name=Link1_Link2
		Parent=Link1
		Child=Link2
		LimitLow=-2.967
		LimitHigh=2.967
		Offset=(x=2.1,y=0,z=0)
	End Object
	Joints.Add(Link1_Link2)
	
	TipOffset = (x=2.1,y=0,z=0)
}