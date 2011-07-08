/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class ForkLift extends Actuator placeable config (USAR);

defaultproperties
{
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.EmptyMesh'
		Collision=false
		Mass=5
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)
	
	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'Forklift_static.joint1'
		Mass=2
		Offset=(X=-.004,Y=0,Z=-.144)
	End Object
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint2
		Mesh=StaticMesh'Forklift_static.Joint2'
		Mass=1
		Offset=(X=.002,Y=0,Z=-.236)
	End Object
	PartList.Add(Joint2)
	
	Begin Object Class=Part Name=Joint3
		Mesh=StaticMesh'Forklift_static.Joint3'
		Mass=.5
		Offset=(X=.012,Y=0,Z=0)
	End Object
	PartList.Add(Joint3)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'Forklift_static.Joint4'
		Mass=.25
		Offset=(X=.024,Y=0,Z=-.092)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=EmptyJoint
		Mesh=StaticMesh'Basic.EmptyMesh'
		Offset=(X=.104,Y=0,Z=0)
		Mass=0.001
	End Object
	PartList.Add(EmptyJoint)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'Forklift_static.Joint5'
		Mass=.0125
		RelativeTo=EmptyJoint
		Offset=(X=0,Y=-.032,Z=0)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'Forklift_static.Joint5'
		Mass=.0125
		RelativeTo=EmptyJoint
		Offset=(X=0,Y=.032,Z=0)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=RevoluteJoint Name=Body_Joint1
		Parent=BodyItem
		Child=Joint1
		Damping=5
		MaxForce=50
		LimitLow=-0.1
		LimitHigh=0.1
		Offset=(X=-.008,Y=0,Z=-.088)
		Direction=(X=-1.571,Y=0,Z=0)
	End Object
	Joints.Add(Body_Joint1)
	
	Begin Object Class=PrismaticJoint Name=Joint1_Joint2
		Parent=Joint1
		Child=Joint2
		Damping=5
		MaxForce=50
		LimitLow=0
		LimitHigh=1
		Offset=(X=.002,Y=0,Z=-.236)
		Direction=(X=3.141,Y=0,Z=0)
	End Object
	Joints.Add(Joint1_Joint2)
	
	Begin Object Class=PrismaticJoint Name=Joint2_Joint3
		Parent=Joint2
		Child=Joint3
		Damping=5
		MaxForce=50
		LimitLow=-.9
		LimitHigh=5
		Offset=(X=.012,Y=0,Z=0)
		Direction=(X=3.141,Y=0,Z=0)
	End Object
	Joints.Add(Joint2_Joint3)
	
	Begin Object Class=PrismaticJoint Name=Joint3_Joint4
		Parent=Joint3
		Child=Joint4
		Damping=5
		MaxForce=50
		LimitLow=-1
		LimitHigh=1
		Offset=(X=.024,Y=0,Z=-.092)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint3_Joint4)
	
	Begin Object Class=PrismaticJoint Name=Joint4_Empty
		Parent=Joint4
		Child=EmptyJoint
		Damping=5
		MaxForce=50
		LimitLow=-.5
		LimitHigh=.5
		Offset=(X=.104,Y=0,Z=0)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(Joint4_Empty)
	
	Begin Object Class=FixedJoint Name=Empty_Joint5
		Parent=EmptyJoint
		Child=Joint5
		RelativeTo=EmptyJoint
	End Object
	Joints.Add(Empty_Joint5)
	
	Begin Object Class=FixedJoint Name=Empty_Joint6
		Parent=EmptyJoint
		Child=Joint6
		RelativeTo=EmptyJoint
	End Object
	Joints.Add(Empty_Joint6)
}
