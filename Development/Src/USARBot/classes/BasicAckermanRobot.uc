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
	GetPartByName('FREmptyMesh').SetHidden(true);
	GetPartByName('FLEmptyMesh').SetHidden(true);
}

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'AckermanExample.Body'
		Mass=50
		Direction=(X=0,Y=0,Z=1.571)
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'AckermanExample.BigWheel'
		Offset=(X=.54,Y=.204,Z=.456)
		Direction=(X=0,Y=0,Z=1.571)
		Mass=1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'AckermanExample.BigWheel'
		Offset=(X=.54,Y=-.204,Z=.456)
		Direction=(X=0,Y=0,Z=1.571)
		Mass=1
	End Object
	PartList.Add(FLWheel)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'AckermanExample.SmallWheel'
		Offset=(X=-.416,Y=.248,Z=.512)
		Direction=(X=0,Y=0,Z=1.571)
		Mass=1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'AckermanExample.SmallWheel'
		Offset=(X=-.416,Y=-.248,Z=.512)
		Direction=(X=0,Y=0,Z=1.571)
		Mass=1
	End Object
	PartList.Add(BLWheel)
	
	Begin Object Class=Part Name=FREmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Offset=(X=.54,Y=.104,Z=.456)
		Mass=2
	End Object
	PartList.Add(FREmptyMesh)
	
	Begin Object Class=Part Name=FLEmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Offset=(X=.54,Y=-.104,Z=.456)
		Mass=2
	End Object
	PartList.Add(FLEmptyMesh)
	
	Begin Object Class=RevoluteJoint Name=FRFrontSteer
		Parent=BodyItem
		Child=FREmptyMesh
		Damping=50
		Offset=(X=.54,Y=.204,Z=.456)
		LimitLow=-0.5
		LimitHigh=0.5
	End Object
	Joints.Add(FRFrontSteer)
	
	Begin Object Class=RevoluteJoint Name=FLFrontSteer
		Parent=BodyItem
		Child=FLEmptyMesh
		Damping=50
		Offset=(X=.54,Y=-.204,Z=.456)
		LimitLow=-0.5
		LimitHigh=0.5
	End Object
	Joints.Add(FLFrontSteer)

	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=FREmptyMesh
		Child=FRWheel
		Side=SIDE_Right
		Offset=(X=.54,Y=.204,Z=.456)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=FLEmptyMesh
		Child=FLWheel
		Side=SIDE_Left
		Offset=(X=.54,Y=-.204,Z=.456)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=BodyItem
		Child=BRWheel
		Side=SIDE_Right
		Offset=(X=-.416,Y=.248,Z=.512)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=BodyItem
		Child=BLWheel
		Side=SIDE_Left
		Offset=(X=-.416,Y=-.248,Z=.512)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.4
	End Object
	Joints.Add(BLWheelRoll)

	WheelRadius=0.128
}
