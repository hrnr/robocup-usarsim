class AirRobotCameraAct extends Actuator placeable config (USAR);

// tiltable component (mission package / actuator) that connects the camera to the main body of the AirRobot

defaultproperties
{
	Begin Object Class=Part Name=BaseItem
		Mesh=StaticMesh'AirRobot.PackageBase'
		Collision=false
		Mass=0
	End Object
	Body=BaseItem
	PartList.Add(BaseItem)

	Begin Object Class=Part Name=BottomItem
		Mesh=StaticMesh'AirRobot.PackageBase'
		Direction=(X=0,Y=0,Z=0)
		Mass=0
		RelativeTo=BaseItem
	End Object
	PartList.Add(TopItem)

	Begin Object Class=RevoluteJoint Name=RotateJoint
		Parent=BaseItem
		Child=BottomItem
		Direction=(X=1.571,Y=1.571,Z=0)
		MaxForce=1000
		LimitLow=-3.228
		LimitHigh=3.228
	End Object
	Joints.Add(RotateJoint)
}