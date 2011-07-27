/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * GripperEffector - Used for binary control of gripper, but contains functionality to control as actuator as well
 */
class GripperEffector extends Gripper placeable config (USAR);

var JointItem LFJoint;
var JointItem RFJoint;

simulated function AttachItem()
{
	local int i;
	local JointItem ji;

	super.AttachItem();
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			`log(String(ji.GetJointName()));
			if (ji.GetJointName() == 'LeftForkJoint')
				LFJoint = ji;
			else if (ji.GetJointName() == 'RightForkJoint')
				RFJoint = ji;
		}
}

// Operates the effector
function Operate(bool on)
{
	if (on)
	{
		LFJoint.SetTarget(0.3);
		RFJoint.SetTarget(-0.3);
	}
	else
	{
		LFJoint.SetTarget(0);
		RFJoint.SetTarget(0);
	}
}

defaultproperties 
{
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Gripper.GripperBody'
		Mass=1.0
	End Object
	PartList.Add(BodyItem)
	Body=BodyItem
	
	Begin Object Class=Part Name=RightFork
		Mesh=StaticMesh'Gripper.GripperArm'
		Mass=0.5
		Offset=(X=.14,Y=.06,Z=.012)
	End Object
	PartList.Add(RightFork)
	
	Begin Object Class=Part Name=LeftFork
		Mesh=StaticMesh'Gripper.GripperArm'
		Mass=0.5
		Offset=(X=.14,Y=-.06,Z=.012)
	End Object
	PartList.Add(LeftFork)
	
	Begin Object Class=RevoluteJoint Name=RightForkJoint
		Parent=BodyItem
		Child=RightFork
		LimitLow=-.5
		LimitHigh=.5
		MaxForce=1000
		Damping=200
		Offset=(X=.02,Y=.06,Z=0)
	End Object
	Joints.Add(RightForkJoint)
	
	Begin Object Class=RevoluteJoint Name=LeftForkJoint
		Parent=BodyItem
		Child=LeftFork
		LimitLow=-.5
		LimitHigh=.5
		MaxForce=1000
		Damping=200
		Offset=(X=.02,Y=-.06,Z=0)
	End Object
	Joints.Add(LeftForkJoint)
	
}