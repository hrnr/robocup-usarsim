/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class P3AT extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=ChassisMiddle
		Mesh=StaticMesh'P3AT.ChassisMiddle'
		Mass=1.0
		Offset=(X=.048,Y=-.004,Z=-.032)
	End Object
	Body=ChassisMiddle
	PartList.Add(ChassisMiddle)
	
	// Create bottom part
	Begin Object Class=Part Name=ChassisBottom
		Mesh=StaticMesh'P3AT.ChassisBottom'
		Mass=0.5
		Offset=(X=.012,Y=.008,Z=.076)
	End Object
	PartList.Add(ChassisBottom)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(X=.126,Y=.212,Z=.054)
		// 180 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.142)
		Mass=0.1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(X=.126,Y=-.212,Z=.054)
		Mass=0.1
	End Object
	PartList.Add(FLWheel)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(X=-.126,Y=.212,Z=.054)
		// 180 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.142)
		Mass=0.1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(X=-.126,Y=-.212,Z=.054)
		Mass=0.1
	End Object
	PartList.Add(BLWheel)

	// Front right right Bumper
	Begin Object Class=Part Name=FRRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=.292,Y=.22,Z=.092)
		// 5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=0.098)
		Mass=0.05
	End Object
	PartList.Add(FRRBumper)

	// Front right Bumper
	Begin Object Class=Part Name=FRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=.296,Y=.112,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(FRBumper)

	// Front Bumper
	Begin Object Class=Part Name=FBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=.296,Y=0,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(FBumper)

	// Front left Bumper
	Begin Object Class=Part Name=FLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=.296,Y=-.112,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(FLBumper)

	// Front left left Bumper
	Begin Object Class=Part Name=FLLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=.292,Y=-.22,Z=.092)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=-0.098)
		Mass=0.05
	End Object
	PartList.Add(FLLBumper)

	// Back right right Bumper
	Begin Object Class=Part Name=BRRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=-.292,Y=.22,Z=.092)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=-0.098)
		Mass=0.05
	End Object
	PartList.Add(BRRBumper)

	// back right Bumper
	Begin Object Class=Part Name=BRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=-.296,Y=.112,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(BRBumper)

	// back Bumper
	Begin Object Class=Part Name=BBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=-.296,Y=0,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(BBumper)

	// back left Bumper
	Begin Object Class=Part Name=BLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=-.296,Y=-.112,Z=.092)
		Mass=0.05
	End Object
	PartList.Add(BLBumper)

	// back left left Bumper
	Begin Object Class=Part Name=BLLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(X=-.292,Y=-.22,Z=.092)
		// 5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=0.098)
		Mass=0.05
	End Object
	PartList.Add(BLLBumper)

	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=ChassisMiddle
		Child=FRWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_Right
		Offset=(X=.126,Y=.212,Z=.054)
		// 90 degree rotation about Z axis
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=ChassisMiddle
		Child=FLWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_Left
		Offset=(X=.126,Y=-.212,Z=.054)
		// 90 degree rotation about Z axis
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=ChassisMiddle
		Child=BRWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_Right
		Offset=(X=-.126,Y=.212,Z=.054)
		// 90 degree rotation about Z axis
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=ChassisMiddle
		Child=BLWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_Left
		Offset=(X=-.126,Y=-.212,Z=.054)
		// 90 degree rotation about Z axis
		RotateAxis=(X=0,Y=0,Z=1.571)
	End Object
	Joints.Add(BLWheelRoll)

	Begin Object Class=Joint Name=ChassisFixed
		Child=ChassisBottom
		Parent=ChassisMiddle
		JointType=JOINTTYPE_Fixed
		Offset=(X=.012,Y=.008,Z=.076)
	End Object
	Joints.Add(ChassisFixed)

	Begin Object Class=Joint Name=FRRBumperFixed
		Child=ChassisBottom
		Parent=FRRBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=.292,Y=.22,Z=.092)
	End Object
	Joints.Add(FRRBumperFixed)

	Begin Object Class=Joint Name=FRBumperFixed
		Child=ChassisBottom
		Parent=FRBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=.296,Y=.112,Z=.092)
	End Object
	Joints.Add(FRBumperFixed)

	Begin Object Class=Joint Name=FBumperFixed
		Child=ChassisBottom
		Parent=FBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=.296,Y=0,Z=.092)
	End Object
	Joints.Add(FBumperFixed)

	Begin Object Class=Joint Name=FLBumperFixed
		Child=ChassisBottom
		Parent=FLBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=.296,Y=-.112,Z=.092)
	End Object
	Joints.Add(FLBumperFixed)

	Begin Object Class=Joint Name=FLLBumperFixed
		Child=ChassisBottom
		Parent=FLLBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=.292,Y=-.22,Z=.092)
	End Object
	Joints.Add(FLLBumperFixed)

	Begin Object Class=Joint Name=BRRBumperFixed
		Child=ChassisBottom
		Parent=BRRBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=-.292,Y=.22,Z=.092)
	End Object
	Joints.Add(BRRBumperFixed)

	Begin Object Class=Joint Name=BRBumperFixed
		Child=ChassisBottom
		Parent=BRBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=-.296,Y=.112,Z=.092)
	End Object
	Joints.Add(BRBumperFixed)

	Begin Object Class=Joint Name=BBumperFixed
		Child=ChassisBottom
		Parent=BBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=-.296,Y=0,Z=.092)
	End Object
	Joints.Add(BBumperFixed)

	Begin Object Class=Joint Name=BLBumperFixed
		Child=ChassisBottom
		Parent=BLBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=-.296,Y=-.112,Z=.092)
	End Object
	Joints.Add(BLBumperFixed)

	Begin Object Class=Joint Name=BLLBumperFixed
		Child=ChassisBottom
		Parent=BLLBumper
		JointType=JOINTTYPE_Fixed
		Offset=(X=-.292,Y=-.22,Z=.092)
	End Object
	Joints.Add(BLLBumperFixed)
}