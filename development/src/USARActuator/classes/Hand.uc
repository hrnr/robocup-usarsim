/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class Hand extends Actuator placeable config (USAR);


defaultproperties
{
//base
	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'Hand.stand'
		Mass=0.025
		Offset=(X=0.0000,Y=0.000,Z=0.000)
		
	End Object
	Body=Joint1
	PartList.Add(Joint1)
	
	
	//First Finger
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'Hand.base'
		Mass=0.025
		Offset=(X=0.01337,Y=0.03651,Z=-0.05571)
		Direction=( x=0,y=0,z=0)
	End Object
	PartList.Add(Joint2)

	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'Hand.mid'
		Mass=0.025
		Offset=(X=0.01525,Y=0.03600,Z=-0.11322)
	End Object
	PartList.Add(Joint3)

	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'Hand.tip'
		Mass=0.025
		Offset=(X=0.014,Y=0.03372,Z=-0.17971)
	End Object
	PartList.Add(Joint4)
//second finger
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'Hand.BASE'
		Mass=0.025
		Offset=(X=-.04461,Y=0.006226,Z=-0.05571)
		Direction=( x=0,y=0,z=-1.57)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'Hand.MID'
		Mass=0.025
		Offset=(X=-.04449,Y=0.005569,Z=-0.11322)
		Direction=( x=0,y=0,z=1.57)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=Part Name=Joint7
		Mesh=StaticMesh'Hand.TIP'
		Mass=0.025
		Offset=(X=-.04256,Y=.0039,Z=-0.17971)
		Direction=( x=0,y=0,z=1.57)
	End Object
	PartList.Add(Joint7)
	
	//Third finger

		Begin Object Class=Part Name=Joint8
		Mesh=StaticMesh'Hand.BASE'
		Mass=0.025
		Offset=(X=.02381,Y=-.03414,Z=-0.05571)
		Direction=( x=0,y=0,z=-3.14)
	End Object
	PartList.Add(Joint8)
	
	Begin Object Class=Part Name=Joint9
		Mesh=StaticMesh'Hand.MID'
		Mass=0.025
		Offset=(X=.02106,Y=-.03499,Z=-0.11322)
		Direction=( x=0,y=0,z=-3.14)
	End Object
	PartList.Add(Joint9)
	
	Begin Object Class=Part Name=Joint10
		Mesh=StaticMesh'Hand.TIP'
		Mass=0.025
		Offset=(X=.0235,Y=-.03250,Z=-0.17971)
		Direction=( x=0,y=0,z=-3.14)
	End Object
	PartList.Add(Joint10)
	
	
	
	
	//Movement
	
	//First Finger
	//link 0
	Begin Object Class=RevoluteJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=0.01849,Y=0.03651,Z=-0.05571)
		Direction=(x=0,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint1_Joint2)
	//link 1
	Begin Object Class=RevoluteJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=100
		MaxForce=700
		LimitLow=-1.570796327//90 DEGREES	
		LimitHigh=1
	Offset=(X=.01515,Y=0.03686,Z=-0.06213)
		Direction=(x=0,y=1.570796327,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint2_Joint3)
	//link 2
	Begin Object Class=RevoluteJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=100
		MaxForce=700
		LimitLow=-1.570796327//90 DEGREES	
		LimitHigh=1.570796327
	Offset=(X=.01515,Y=0.03686,Z=-0.15591)
		Direction=(x=0,y=1.570796327,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint3_Joint4)
	
	//Second Finger
		//link 3
		Begin Object Class=RevoluteJoint Name=Joint1_Joint5
		Parent=Joint1
		Child=Joint5
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=-.04502,Y=0.001338,Z=-0.05571)
		Direction=(x=0,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint1_Joint5)
	
	// link 4
		
		Begin Object Class=RevoluteJoint Name=Joint5_Joint6
		Parent=Joint5
		Child=Joint6
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=-.04502,Y=0.001338,Z=-0.05571)
		Direction=(x=-1.570796327,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint5_Joint6)
	// link 5
	Begin Object Class=RevoluteJoint Name=Joint6_Joint7
		Parent=Joint6
		Child=Joint7
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=-.04502,Y=0.001338,Z=-0.1546)
		Direction=(x=-1.570796327,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint6_Joint7)
		
	//Third Finger
	//link 6
	Begin Object Class=RevoluteJoint Name=Joint1_Joint8
		Parent=Joint1
		Child=Joint8
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=.01844,Y=-0.03444,Z=-0.05571)
		Direction=(x=0,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint1_Joint8)
	
	//link 7
	Begin Object Class=RevoluteJoint Name=Joint8_Joint9
		Parent=Joint8
		Child=Joint9
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=.01844,Y=-.03444,Z=-0.06210)
		Direction=(x=0,y=-1.570796327,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint8_Joint9)
	
	//link 8
	Begin Object Class=RevoluteJoint Name=Joint9_Joint10
		Parent=Joint9
		Child=Joint10
		Damping=100
		MaxForce=700
		LimitLow=-3.14 //170 degrees 
		LimitHigh=3.14
	Offset=(X=.01844,Y=-.03444,Z=-0.15492)
		Direction=(x=-0,y=-1.570796327,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint9_Joint10)
	
	
}
