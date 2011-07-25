/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class ForkLiftArm extends Actuator placeable config (USAR);

simulated function AttachItem()
{
	super.AttachItem();
	GetPartByName('BaseEmptyMesh').SetHidden(true);
}

defaultproperties
{

	Begin Object Class=Part Name=BaseEmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Mass=1
		Offset=(X=-.06,Y=0,Z=-.144)
	End Object
	PartList.Add(BaseEmptyMesh)
	Body=BaseEmptyMesh

	Begin Object Class=Part Name=Joint1
		Mesh=StaticMesh'Forklift_static.joint1'
		Mass=2
		Offset=(X=-.02,Y=0,Z=-.144)
	End Object
	PartList.Add(Joint1)
	
	Begin Object Class=Part Name=Joint4
		Mesh=StaticMesh'Forklift_static.Joint4'
		Mass=1
		Offset=(X=.018,Y=0,Z=-.092)
	End Object
	PartList.Add(Joint4)
	
	Begin Object Class=Part Name=Joint5
		Mesh=StaticMesh'Forklift_static.Joint5'
		Mass=.0125
		RelativeTo=Joint4
		Offset=(X=.08,Y=-.032,Z=.05)
	End Object
	PartList.Add(Joint5)
	
	Begin Object Class=Part Name=Joint6
		Mesh=StaticMesh'Forklift_static.Joint5'
		Mass=.0125
		RelativeTo=Joint4
		Offset=(X=.08,Y=.032,Z=.05)
	End Object
	PartList.Add(Joint6)
	
	Begin Object Class=RevoluteJoint Name=Empty_Joint1
		Parent=BaseEmptyMesh
		Child=Joint1
		Damping=5
		MaxForce=50
		LimitLow=-.2
		LimitHigh=.2
		Offset=(X=-.06,Y=0,Z=-.144)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(Empty_Joint1)
	
	Begin Object Class=PrismaticJoint Name=Joint1_Joint4
		Parent=Joint1
		Child=Joint4
		Damping=5
		MaxForce=50
		LimitLow=-.3
		LimitHigh=.3				// Don't change this! It used to be at 1 and for some reason caused shaking. 
		Offset=(X=.018,Y=0,Z=-.092)
		Direction=(X=3.141,Y=0,Z=0)
	End Object
	Joints.Add(Joint1_Joint4)
	
	Begin Object Class=FixedJoint Name=Joint4_Joint5
		Parent=Joint4
		Child=Joint5
		RelativeTo=Joint4
	End Object
	Joints.Add(Joint4_Joint5)
	
	Begin Object Class=FixedJoint Name=Joint4_Joint6
		Parent=Joint4
		Child=Joint6
		RelativeTo=Joint4
	End Object
	Joints.Add(Joint4_Joint6)
	
}
