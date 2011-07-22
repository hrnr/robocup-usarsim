/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class BasicAckermanRobot extends AckermanSteeredVehicle config(USAR);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	GetPartByName('BREmptyMesh').SetHidden(true);
	GetPartByName('BLEmptyMesh').SetHidden(true);
}

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.BasicBody'
		Mass=10
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(FLWheel)
	
	// Back Right EmptyMesh
	Begin Object Class=Part name=BREmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(BREmptyMesh)
	
	// Left Right EmptyMesh
	Begin Object Class=Part name=BLEmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(BLEmptyMesh)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'Basic.BasicWheel'
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Mass=1
	End Object
	PartList.Add(BLWheel)

	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=BodyItem
		Child=FRWheel
		Side=SIDE_Right
		Offset=(X=.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=BodyItem
		Child=FLWheel
		Side=SIDE_Left
		Offset=(X=.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=RevoluteJoint Name=BRRearSteer
		Parent=BodyItem
		Child=BREmptyMesh
		RelativeTo=BodyItem
		Offset=(X=-.3,Y=.576,Z=.064)
		LimitLow=-.8
		LimitHigh=.8
	End Object
	Joints.Add(BRRearSteer)
	
	Begin Object Class=RevoluteJoint Name=BLRearSteer
		Parent=BodyItem
		Child=BLEmptyMesh
		RelativeTo=BodyItem
		Offset=(X=-.3,Y=-.576,Z=.064)
		LimitLow=-.8
		LimitHigh=.8
	End Object
	Joints.Add(BLRearSteer)
	
	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=BREmptyMesh
		Child=BRWheel
		Side=SIDE_Right
		Offset=(X=-.3,Y=.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=BLEmptyMesh
		Child=BLWheel
		Side=SIDE_Left
		Offset=(X=-.3,Y=-.576,Z=.064)
		RelativeTo=BodyItem
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(BLWheelRoll)

	WheelRadius=0.128
}
