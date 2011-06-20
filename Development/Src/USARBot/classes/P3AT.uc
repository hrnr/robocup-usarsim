/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * P3AT - example skid steered vehicle with correctly mapped materials and collision
 */
class P3AT extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=ChassisMiddle
		Mesh=StaticMesh'P3AT_static.ChassisMiddle'
		Mass=1.0
	End Object
	Body=ChassisMiddle
	PartList.Add(ChassisMiddle)
	
	// Create bottom part
	Begin Object Class=Part Name=ChassisBottom
		Mesh=StaticMesh'P3AT_static.ChassisBottom'
		Mass=0.5
		Offset=(X=.012,Y=0,Z=.068)
	End Object
	PartList.Add(ChassisBottom)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'P3AT_static.Wheel'
		Offset=(X=.124,Y=.18,Z=.048)
		Mass=0.1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'P3AT_static.Wheel'
		Offset=(X=.124,Y=-.18,Z=.048)
		Mass=0.1
	End Object
	PartList.Add(FLWheel)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'P3AT_static.Wheel'
		Offset=(X=-.124,Y=.18,Z=.048)
		Mass=0.1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'P3AT_static.Wheel'
		Offset=(X=-.124,Y=-.18,Z=.048)
		Mass=0.1
	End Object
	PartList.Add(BLWheel)

	// Front right right Bumper
	Begin Object Class=Part Name=FRRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.288,Y=.232,Z=.088)
		// 5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.238)
		Mass=0.05
	End Object
	PartList.Add(FRRBumper)

	// Front right Bumper
	Begin Object Class=Part Name=FRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.296,Y=.116,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FRBumper)

	// Front Bumper
	Begin Object Class=Part Name=FBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.296,Y=0,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FBumper)

	// Front left Bumper
	Begin Object Class=Part Name=FLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.296,Y=-.116,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FLBumper)

	// Front left left Bumper
	Begin Object Class=Part Name=FLLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.288,Y=-.232,Z=.088)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.042)
		Mass=0.05
	End Object
	PartList.Add(FLLBumper)

	// Back right right Bumper
	Begin Object Class=Part Name=BRRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.288,Y=.232,Z=.088)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=-0.098)
		Mass=0.05
	End Object
	PartList.Add(BRRBumper)

	// back right Bumper
	Begin Object Class=Part Name=BRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.296,Y=.116,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BRBumper)

	// back Bumper
	Begin Object Class=Part Name=BBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.296,Y=0,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BBumper)

	// back left Bumper
	Begin Object Class=Part Name=BLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.296,Y=-.116,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BLBumper)

	// back left left Bumper
	Begin Object Class=Part Name=BLLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.288,Y=-.232,Z=.088)
		// 5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=0.098)
		Mass=0.05
	End Object
	PartList.Add(BLLBumper)

	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=ChassisMiddle
		Child=FRWheel
		Side=SIDE_Right
		Offset=(X=.124,Y=.18,Z=.048)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.3
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=ChassisMiddle
		Child=FLWheel
		Side=SIDE_Left
		Offset=(X=.124,Y=-.18,Z=.048)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.3
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=ChassisMiddle
		Child=BRWheel
		Side=SIDE_Right
		Offset=(X=-.124,Y=.18,Z=.048)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.3
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=ChassisMiddle
		Child=BLWheel
		Side=SIDE_Left
		Offset=(X=-.124,Y=-.18,Z=.048)
		Direction=(X=1.571,Y=0,Z=0)
		MaxVelocity=1.3
	End Object
	Joints.Add(BLWheelRoll)

	Begin Object Class=FixedJoint Name=ChassisFixed
		Child=ChassisBottom
		Parent=ChassisMiddle
		Offset=(X=.012,Y=0,Z=.068)
	End Object
	Joints.Add(ChassisFixed)

	Begin Object Class=FixedJoint Name=FRRBumperFixed
		Child=ChassisBottom
		Parent=FRRBumper
		Offset=(X=.288,Y=.232,Z=.088)
	End Object
	Joints.Add(FRRBumperFixed)

	Begin Object Class=FixedJoint Name=FRBumperFixed
		Child=ChassisBottom
		Parent=FRBumper
		Offset=(X=.296,Y=.116,Z=.088)
	End Object
	Joints.Add(FRBumperFixed)

	Begin Object Class=FixedJoint Name=FBumperFixed
		Child=ChassisBottom
		Parent=FBumper
		Offset=(X=.296,Y=0,Z=.088)
	End Object
	Joints.Add(FBumperFixed)

	Begin Object Class=FixedJoint Name=FLBumperFixed
		Child=ChassisBottom
		Parent=FLBumper
		Offset=(X=.296,Y=-.116,Z=.088)
	End Object
	Joints.Add(FLBumperFixed)

	Begin Object Class=FixedJoint Name=FLLBumperFixed
		Child=ChassisBottom
		Parent=FLLBumper
		Offset=(X=.288,Y=-.232,Z=.088)
	End Object
	Joints.Add(FLLBumperFixed)

	Begin Object Class=FixedJoint Name=BRRBumperFixed
		Child=ChassisBottom
		Parent=BRRBumper
		Offset=(X=-.288,Y=.232,Z=.088)
	End Object
	Joints.Add(BRRBumperFixed)

	Begin Object Class=FixedJoint Name=BRBumperFixed
		Child=ChassisBottom
		Parent=BRBumper
		Offset=(X=-.296,Y=.116,Z=.088)
	End Object
	Joints.Add(BRBumperFixed)

	Begin Object Class=FixedJoint Name=BBumperFixed
		Child=ChassisBottom
		Parent=BBumper
		Offset=(X=-.296,Y=0,Z=.088)
	End Object
	Joints.Add(BBumperFixed)

	Begin Object Class=FixedJoint Name=BLBumperFixed
		Child=ChassisBottom
		Parent=BLBumper
		Offset=(X=-.296,Y=-.116,Z=.088)
	End Object
	Joints.Add(BLBumperFixed)

	Begin Object Class=FixedJoint Name=BLLBumperFixed
		Child=ChassisBottom
		Parent=BLLBumper
		Offset=(X=-.288,Y=-.232,Z=.088)
	End Object
	Joints.Add(BLLBumperFixed)

	WheelRadius=0.098
}