/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class kuka_lwr extends Actuator placeable config (USAR);


defaultproperties
{
	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'KUKA_LWR.Arm_Base'
		Mass=0.025
		Offset=(X=0,Y=0,Z=0.000)
	End Object
	Body=Joint1
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'KUKA_LWR.Arm_Elbow'
		Mass=0.025
		Offset=(X=0.0,Y=0.00,Z=0.0)
	End Object
	PartList.Add(Joint2)
	
	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'KUKA_LWR.Arm_Elbow2'
		Mass=0.025
		Offset=(X=0.0,Y=0.0,Z=0)
	End Object
	PartList.Add(Joint3)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'KUKA_LWR.Arm_Elbow3'
		Mass=0.025
		Offset=(X=0.00,Y=0,Z=0)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'KUKA_LWR.Arm_Elbow4'
		Mass=0.025
		Offset=(X=0.0,Y=0.0,Z=0)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'KUKA_LWR.Arm_TopElbow'
		Mass=0.025
		Offset=(X=0.00,Y=0,Z=0.00)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=Part Name=Joint7
		Mesh=StaticMesh'KUKA_LWR.Arm_Head'
		Mass=0.025
		Offset=(X=0.0,Y=0.00,Z=0.00)
	End Object
	PartList.Add(Joint7)
	
	Begin Object Class=Part Name=Joint8
		Mesh=StaticMesh'KUKA_LWR.Arm_Effector'
		Mass=0.025
		Offset=(X=0,Y=0.00,Z=0.00)
	End Object
	PartList.Add(Joint8)
	
	Begin Object Class=RevoluteJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=100
		MaxForce=700
		LimitLow=-3.14159265
		LimitHigh=3.14159265
		Offset=(X=0.0,Y=0.0,Z=-0.12)
		Direction=(x=3.1415,y=0,z=0)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint1_Joint2)
	
	Begin Object Class=RevoluteJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=100
		MaxForce=700
		LimitLow=-3.14159265
		LimitHigh=3.14159265
		Offset=(X=0.0,Y=0.0,Z=-0.31)
		Direction=(x=0,y=-1.5708,z=0)
		//InverseMeasureAngle=true
	End Object
	Joints.Add(Joint2_Joint3)
	
	Begin Object Class=RevoluteJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=100
		MaxForce=700
		LimitLow=-3.14159265
		LimitHigh=3.14159265
		Offset=(X=0.0,Y=0.0,Z=-0.52)
		Direction=(x=0.0,y=0,z=3.1415)
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint3_Joint4)
	
	Begin Object Class=RevoluteJoint Name=Joint4_Joint5
		Parent=Joint4
		Child=Joint5
		Damping=100
		MaxForce=700
		LimitLow=-3.14159265
		LimitHigh=3.14159265
		Offset=(X=0.0,Y=0,Z=-0.71)
		Direction=(x=0,y=-1.5708,z=0)
		//InverseMeasureAngle=true
	End Object
	Joints.Add(Joint4_Joint5)
	
	Begin Object Class=RevoluteJoint Name=Joint5_Joint6
		Parent=Joint5
		Child=Joint6
		Damping=100
		MaxForce=700
		Offset=(X=0.00,Y=0.0,Z=-0.92)
		Direction=(x=0.00,y=3.1415,z=0)
		LimitLow=-3.14159265
		LimitHigh=3.14159265
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint5_Joint6)
	
	Begin Object Class=RevoluteJoint Name=Joint6_Joint7
		Parent=Joint6
		Child=Joint7
		Damping=100
		MaxForce=700
		Offset=(X=-0.045,Y=0.0, Z=-1.1)
		Direction=(x=0.00,y=-1.5708,z=0)
		LimitLow=-3.14159265
		LimitHigh=3.14159265
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint6_Joint7)
	
		Begin Object Class=RevoluteJoint Name=Joint7_Joint8
		Parent=Joint7
		Child=Joint8
		Damping=100
		MaxForce=700
		Offset=(X=0.00,Y=0.0,Z=-1.155)
		Direction=(x=3.1415,y=0,z=0)
		LimitLow=-3.14159265
		LimitHigh=3.14159265
//		InverseMeasureAngle=true
	End Object
	Joints.Add(Joint7_Joint8)
	
}
