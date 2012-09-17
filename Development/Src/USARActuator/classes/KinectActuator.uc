class KinectActuator extends Actuator placeable config (USAR);

defaultproperties
{
	Begin Object Class=Part Name=KBase
		Mesh=StaticMesh'Kinect.KinectBase'
		Mass=5.0
        Collision=true
	End Object
	Body=KBase
	PartList.Add(KBase)
	
	Begin Object Class=Part Name=KHead
		Mesh=StaticMesh'Kinect.KinectHead'
		Mass=1.0
		Collision=true
		Offset=(x=0,y=0,z=-0.02)
	End Object
	PartList.Add(KHead)
	
	
	Begin Object Class=RevoluteJoint Name=KBase_KHead
		Parent=KBase
		Child=KHead
		Damping=100
		MaxForce=600
		LimitLow=-0.2618
		LimitHigh=0.2618
		Offset=(x=0,y=0,z=-0.02)
		Direction=(x=-1.570795,y=0,z=0)
	End Object
	Joints.Add(KBase_KHead)	
}