/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class Fanuc_M16iB20Arm extends Actuator placeable config (USAR);

simulated function array<float> getRotation(array<float> pos)
{
	// Joint 3's real value must compensate for 2's position
	pos[2] -= pos[1];
	return pos;
}

simulated function array<float> updateRotation(array<float> Target, int Link, float Value)
{

	Target = super.updateRotation(Target, Link, Value);
	
	Target[2] = CmdPos[1] + CmdPos[2];
	return Target;
}

defaultproperties
{
	Begin Object Class=Part Name=Base
		Mesh=StaticMesh'Fanuc.Base'
		Mass=5.0
	End Object
	Body=Base
	PartList.Add(Base)
	
	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'Fanuc.Joint1'
		Mass=1.0
		Offset=(X=.052,Y=0,Z=-.384)
	End Object
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'Fanuc.Joint2'
		Mass=0.5
		Offset=(X=.204,Y=-.112,Z=-.384)
	End Object
	PartList.Add(Joint2)
	
	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'Fanuc.Joint3'
		Mass=0.2
		Offset=(X=.2,Y=-.112,Z=-1.156)
	End Object
	PartList.Add(Joint3)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'Fanuc.Joint4'
		Mass=0.1
		Offset=(X=.384,Y=0,Z=-1.256)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'Fanuc.Joint5'
		Mass=0.05
		Offset=(X=.944,Y=0,Z=-1.256)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'Fanuc.Joint6'
		Mass=0.01
		Offset=(X=1.036,Y=0,Z=-1.256)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=RevoluteJoint Name=Base_Joint1
		Parent=Base
		Child=Joint1
		Damping=20
		MaxForce=100
		LimitLow=-2.967
		LimitHigh=2.967
		Offset=(X=.052,Y=0,Z=-.384)
		Direction=(X=3.142,Y=0,Z=0)
	End Object
	Joints.Add(Base_Joint1)
	
	Begin Object Class=RevoluteJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=20
		MaxForce=100
		LimitLow=-1.571
		LimitHigh=2.793
		Offset=(X=.204,Y=-.112,Z=-.384)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint1_Joint2)
	
	Begin Object Class=RevoluteJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=10
		MaxForce=50
		LimitLow=-2.967
		LimitHigh=4.538
		Offset=(X=.2,Y=-.112,Z=-1.156)
		Direction=(X=-1.571,Y=0,Z=0)
		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint2_Joint3)
	
	Begin Object Class=RevoluteJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=5
		MaxForce=50
		LimitLow=-3.491
		LimitHigh=3.491
		Offset=(X=.384,Y=0,Z=-1.256)
		Direction=(X=0,Y=-1.571,Z=0)
	End Object
	Joints.Add(Joint3_Joint4)
	
	Begin Object Class=RevoluteJoint Name=Joint4_Joint5
		Parent=Joint4
		Child=Joint5
		Damping=5
		MaxForce=25
		LimitLow=-3.491
		LimitHigh=3.491
		Offset=(X=.944,Y=0,Z=-1.256)
		Direction=(X=-1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint4_Joint5)
	
	Begin Object Class=RevoluteJoint Name=Joint5_Joint6
		Parent=Joint5
		Child=Joint6
		Damping=5
		MaxForce=10
		Offset=(X=1.036,Y=0,Z=-1.256)
		Direction=(X=0,Y=1.571,Z=0)
		LimitLow=-7.854
		LimitHigh=7.854
	End Object
	Joints.Add(Joint5_Joint6)
}
