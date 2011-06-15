/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class CasterSkidRobot extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.BasicBody'
		Mass=1.0
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Caster
	Begin Object Class=Part Name=CasterWheel
		Mesh=StaticMesh'Basic.CasterWheel'
		Offset=(X=.384,Y=0,Z=.136)
		RelativeTo=BodyItem
		Mass=0.07
	End Object
	PartList.Add(CasterWheel)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Mass=0.1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Mass=0.1
	End Object
	PartList.Add(BLWheel)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=BodyItem
		Child=BRWheel
		Side=SIDE_Right
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=BodyItem
		Child=BLWheel
		Side=SIDE_Left
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(BLWheelRoll)

	Begin Object Class=WheelJoint Name=CasterWheelJoint
		Parent=BodyItem
		Child=CasterWheel
		Side=SIDE_None
		bIsDriven=false
		bOmni=true
		Offset=(X=.384,Y=0,Z=.136)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(CasterWheelJoint)
}
