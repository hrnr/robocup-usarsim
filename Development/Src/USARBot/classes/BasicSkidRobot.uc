/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class BasicSkidRobot extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.BasicBody'
		Mass=1.0
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Mass=0.1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Mass=0.1
	End Object
	PartList.Add(FLWheel)

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

	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=BodyItem
		Child=FRWheel
		JointType=JointType_Roll
		Side=Side_RIGHT
		Offset=(X=.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=BodyItem
		Child=FLWheel
		JointType=JointType_Roll
		Side=Side_LEFT
		Offset=(X=.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=BodyItem
		Child=BRWheel
		JointType=JointType_Roll
		Side=Side_RIGHT
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=BodyItem
		Child=BLWheel
		JointType=JointType_Roll
		Side=Side_LEFT
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(BLWheelRoll)
}
