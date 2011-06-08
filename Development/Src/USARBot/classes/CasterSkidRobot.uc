/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class CasterSkidRobot extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=PhysicalItem Name=BodyItem
		Mesh=StaticMesh'Basic.BasicBody'
		Mass=1000
	End Object
	Body=BodyItem
	ComponentList.Add(BodyItem)

	// Caster
	Begin Object Class=PhysicalItem Name=CasterWheel
		Mesh=StaticMesh'Basic.CasterWheel'
		Offset=(x=.384, y=0,z=-.136)
		RelativeTo=BodyItem
		Mass=100
	End Object
	ComponentList.Add(CasterWheel)

	// Back Right Wheel
	Begin Object Class=PhysicalItem Name=BRWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(x=-.3,y=.576,z=-.064)
		RelativeTo=BodyItem
		Mass=100
	End Object
	ComponentList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=PhysicalItem Name=BLWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(x=-.3,y=-.576,z=-.064)
		RelativeTo=BodyItem
		Mass=100
	End Object
	ComponentList.Add(BLWheel)

	Begin Object Class=BasicWheel Name=BRWheelRoll
		Parent=BodyItem
		Child=BRWheel
		jointType=JOINTTYPE_Roll
		side=SIDE_RIGHT;
		Offset=(x=-.3,y=.576,z=-.064)
		RelativeTo=BodyItem
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=BasicWheel Name=BLWheelRoll
		Parent=BodyItem
		Child=BLWheel
		jointType=JOINTTYPE_Roll
		side=SIDE_LEFT;
		Offset=(x=-.3,y=-.576,z=-.064)
		RelativeTo=BodyItem
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(BLWheelRoll)

	Begin Object Class=BasicWheel Name=CasterWheelJoint
		Parent=BodyItem
		Child=CasterWheel
		jointType=JOINTTYPE_FREE
		side=SIDE_NONE
		Offset=(x=.384, y=0,z=-.136)
		RelativeTo=BodyItem
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(CasterWheelJoint)
}
