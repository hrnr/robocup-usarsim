/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class kr6Arm extends Actuator placeable config (USAR);


defaultproperties
{

	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'KR6.KR6_1'
		Mass=5.0
		Offset=(X=.06,Y=.108,Z=-.236)
	End Object
	Body=Joint1
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'KR6.KR6_2'
		Mass=1.0
		Offset=(X=.328,Y=.132,Z=-.764)
	End Object
	PartList.Add(Joint2)
	
	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'KR6.KR6_3'
		Mass=0.5
		Offset=(X=.508,Y=.312,Z=-1.288)
	End Object
	PartList.Add(Joint3)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'KR6.KR6_4'
		Mass=0.2
		Offset=(X=.736,Y=.124,Z=-1.652)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'KR6.KR6_5'
		Mass=0.1
		Offset=(X=1.348,Y=.1,Z=-1.60)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'KR6.KR6_6'
		Mass=0.05
		Offset=(X=1.456,Y=.072,Z=-1.6)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=Part Name=Joint7
		Mesh=StaticMesh'KR6.KR6_7'
		Mass=0.01
		Offset=(X=1.562,Y=.092,Z=-1.6)
	End Object
	PartList.Add(Joint7)
	
	Begin Object Class=RevoluteJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=200
		MaxForce=1200
		LimitLow=-2.967
		LimitHigh=2.967
		Offset=(X=.2,Y=.092,Z=-.256)
		Direction=(X=0,Y=0,Z=0)
	End Object
	Joints.Add(Joint1_Joint2)
	
	Begin Object Class=RevoluteJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=200
		MaxForce=1200
		LimitLow=-1.571
		LimitHigh=2.793
		Offset=(X=.508,Y=.408,Z=-.884)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint2_Joint3)
	
	Begin Object Class=RevoluteJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=100
		MaxForce=800
		LimitLow=-2.967
		LimitHigh=4.538
		Offset=(X=.512,Y=.108,Z=-1.632)
		Direction=(X=-1.571,Y=0,Z=0)
		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint3_Joint4)
	
	Begin Object Class=RevoluteJoint Name=Joint4_Joint5
		Parent=Joint4
		Child=Joint5
		Damping=10
		MaxForce=100
		LimitLow=-3.491
		LimitHigh=3.491
		Offset=(X=1.236,Y=0.096,Z=-1.6)
		Direction=(X=0,Y=-1.571,Z=0)
	End Object
	Joints.Add(Joint4_Joint5)
	
	Begin Object Class=RevoluteJoint Name=Joint5_Joint6
		Parent=Joint5
		Child=Joint6
		Damping=5
		MaxForce=75
		LimitLow=-3.491
		LimitHigh=3.491
		Offset=(X=1.448,Y=0.08,Z=-1.6)
		Direction=(X=-1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint5_Joint6)
	
	Begin Object Class=RevoluteJoint Name=Joint6_Joint7
		Parent=Joint6
		Child=Joint7
		Damping=5
		MaxForce=50
		Offset=(X=1.544,Y=0.092,Z=-1.6)
		Direction=(X=0,Y=1.571,Z=0)
		LimitLow=-7.854
		LimitHigh=7.854
	End Object
	Joints.Add(Joint6_Joint7)
	
}
