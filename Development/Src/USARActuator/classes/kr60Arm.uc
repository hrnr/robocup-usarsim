/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class kr60Arm extends Actuator placeable config (USAR);


defaultproperties
{
	TipOffset=(X=0.06,Y=0,Z=0)
	
	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'KR60.KR60_1'
		Mass=5.0
	End Object
	Body=Joint1
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'KR60.KR60_2'
		Mass=1
		Offset=(X=.324,Y=-.008,Z=-.688)
	End Object
	PartList.Add(Joint2)
	
	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'KR60.KR60_3'
		Mass=.5
		Offset=(X=.512,Y=.252,Z=-1.384)
	End Object
	PartList.Add(Joint3)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'KR60.KR60_4'
		Mass=0.2
		Offset=(X=.608,Y=.036,Z=-1.908)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'KR60.KR60_5'
		Mass=0.1
		Offset=(X=1.312,Y=.02,Z=-2.00)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'KR60.KR60_6'
		Mass=0.05
		Offset=(X=1.522,Y=.016,Z=-2.01)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=Part Name=Joint7
		Mesh=StaticMesh'KR60.KR60_7'
		Mass=0.025
		Offset=(X=1.642,Y=.01,Z=-2.01)
	End Object
	PartList.Add(Joint7)
	
	Begin Object Class=RevoluteJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=100
		MaxForce=600
		LimitLow=-3.14//-3.288
		LimitHigh=3.14//3.288
		Offset=(X=.112,Y=0.016,Z=-.792)
		Direction=(x=3.1415,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint1_Joint2)
	
	Begin Object Class=RevoluteJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=200
		MaxForce=1500
		LimitLow=-0.61
		LimitHigh=2.356
		Offset=(X=.520,Y=.016,Z=-.792)
		Direction=(x=-1.571,y=1.571,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint2_Joint3)
	
	Begin Object Class=RevoluteJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=100
		MaxForce=700
		LimitLow=-2.757
		LimitHigh=2.094
		Offset=(X=.520,Y=0.016,Z=-1.8)
		Direction=(x=-1.571,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint3_Joint4)
	
	Begin Object Class=RevoluteJoint Name=Joint4_Joint5
		Parent=Joint4
		Child=Joint5
		Damping=10
		MaxForce=100
		LimitLow=-3.14//-6.108
		LimitHigh=3.14//6.108
		Offset=(X=1.112,Y=0.016,Z=-1.992)
		Direction=(x=-1.571,y=0,z=-1.571)
		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint4_Joint5)
	
	Begin Object Class=RevoluteJoint Name=Joint5_Joint6
		Parent=Joint5
		Child=Joint6
		Damping=5
		MaxForce=60
		Offset=(X=1.462,Y=0.016,Z=-2.01)
		Direction=(x=1.571,y=0,z=0)
		LimitLow=-2.076
		LimitHigh=2.076
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint5_Joint6)
	
	Begin Object Class=RevoluteJoint Name=Joint6_Joint7
		Parent=Joint6
		Child=Joint7
		Damping=5
		MaxForce=25
		Offset=(X=1.462,Y=0.01,Z=-2.01)
		Direction=(x=1.571,y=0,z=-1.571)
		LimitLow=-3.14//-6.108
		LimitHigh=3.14//6.108
		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint6_Joint7)
	
}
