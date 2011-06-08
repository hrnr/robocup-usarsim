/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class P3AT extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=PhysicalItem Name=ChassisMiddle
		Mesh=StaticMesh'P3AT.ChassisMiddle'
		Mass=1000
		Offset=(x=.048,y=-.004,z=.032)
	End Object
	Body=ChassisMiddle
	ComponentList.Add(ChassisMiddle)
	
	// Create bottom part
	Begin Object Class=PhysicalItem Name=ChassisBottom
		Mesh=StaticMesh'P3AT.ChassisBottom'
		Mass=1000
		Offset=(x=.012,y=.008,z=-.076)
	End Object
	ComponentList.Add(ChassisBottom)

	// Front Right Wheel
	Begin Object Class=PhysicalItem Name=FRWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(x=.126,y=.212,z=-.054)
		Direction=(X=0,Y=180,Z=0)
		Mass=100
	End Object
	ComponentList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=PhysicalItem Name=FLWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(x=.126,y=-.212,z=-.054)
		Mass=100
	End Object
	ComponentList.Add(FLWheel)

	// Back Right Wheel
	Begin Object Class=PhysicalItem Name=BRWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(x=-.126,y=.212,z=-.054)
		Direction=(X=0,Y=180,Z=0)
		Mass=100
	End Object
	ComponentList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=PhysicalItem Name=BLWheel
		Mesh=StaticMesh'P3AT.Wheel'
		Offset=(x=-.126,y=-.212,z=-.054)
		Mass=100
	End Object
	ComponentList.Add(BLWheel)

	// Front right right Bumper
	Begin Object Class=PhysicalItem Name=FRRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=.292,y=.22,z=-.092)
		Direction=(X=0,Y=5.63,Z=0)
		Mass=20
	End Object
	ComponentList.Add(FRRBumper)

	// Front right Bumper
	Begin Object Class=PhysicalItem Name=FRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=.296,y=.112,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(FRBumper)

	// Front Bumper
	Begin Object Class=PhysicalItem Name=FBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=.296,y=0,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(FBumper)

	// Front left Bumper
	Begin Object Class=PhysicalItem Name=FLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=.296,y=-.112,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(FLBumper)

	// Front left left Bumper
	Begin Object Class=PhysicalItem Name=FLLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=.292,y=-.22,z=-.092)
		Direction=(X=0,Y=-5.63,Z=0)
		Mass=20
	End Object
	ComponentList.Add(FLLBumper)

	// Back right right Bumper
	Begin Object Class=PhysicalItem Name=BRRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=-.292,y=.22,z=-.092)
		Direction=(X=0,Y=-5.63,Z=0)
		Mass=20
	End Object
	ComponentList.Add(BRRBumper)

	// back right Bumper
	Begin Object Class=PhysicalItem Name=BRBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=-.296,y=.112,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(BRBumper)

	// back Bumper
	Begin Object Class=PhysicalItem Name=BBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=-.296,y=0,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(BBumper)

	// back left Bumper
	Begin Object Class=PhysicalItem Name=BLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=-.296,y=-.112,z=-.092)
		Mass=20
	End Object
	ComponentList.Add(BLBumper)

	// back left left Bumper
	Begin Object Class=PhysicalItem Name=BLLBumper
		Mesh=StaticMesh'P3AT.Bumper'
		Offset=(x=-.292,y=-.22,z=-.092)
		Direction=(X=0,Y=5.63,Z=0)
		Mass=20
	End Object
	ComponentList.Add(BLLBumper)

	Begin Object Class=BasicWheel Name=FRWheelRoll
		Parent=ChassisMiddle
		Child=FRWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_RIGHT
		Offset=(x=.126,y=.212,z=-.054)
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=BasicWheel Name=FLWheelRoll
		Parent=ChassisMiddle
		Child=FLWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_LEFT
		Offset=(x=.126,y=-.212,z=-.054)
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=BasicWheel Name=BRWheelRoll
		Parent=ChassisMiddle
		Child=BRWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_RIGHT
		Offset=(x=-.126,y=.212,z=-.054)
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=BasicWheel Name=BLWheelRoll
		Parent=ChassisMiddle
		Child=BLWheel
		JointType=JOINTTYPE_Roll
		Side=SIDE_LEFT
		Offset=(x=-.126,y=-.212,z=-.054)
		RotateAxis=(x=0,y=90,z=0)
	End Object
	Joints.Add(BLWheelRoll)

	Begin Object Class=Joint Name=ChassisFixed
		Child=ChassisBottom
		Parent=ChassisMiddle
		JointType=JOINTTYPE_FIXED
		Offset=(x=.012,y=.008,z=-.076)
	End Object
	Joints.Add(ChassisFixed)

	Begin Object Class=Joint Name=FRRBumperFixed
		Child=ChassisBottom
		Parent=FRRBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=.292,y=.22,z=-.092)
	End Object
	Joints.Add(FRRBumperFixed)

	Begin Object Class=Joint Name=FRBumperFixed
		Child=ChassisBottom
		Parent=FRBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=.296,y=.112,z=-.092)
	End Object
	Joints.Add(FRBumperFixed)

	Begin Object Class=Joint Name=FBumperFixed
		Child=ChassisBottom
		Parent=FBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=.296,y=0,z=-.092)
	End Object
	Joints.Add(FBumperFixed)

	Begin Object Class=Joint Name=FLBumperFixed
		Child=ChassisBottom
		Parent=FLBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=.296,y=-.112,z=-.092)
	End Object
	Joints.Add(FLBumperFixed)

	Begin Object Class=Joint Name=FLLBumperFixed
		Child=ChassisBottom
		Parent=FLLBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=.292,y=-.22,z=-.092)
	End Object
	Joints.Add(FLLBumperFixed)

	Begin Object Class=Joint Name=BRRBumperFixed
		Child=ChassisBottom
		Parent=BRRBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=-.292,y=.22,z=-.092)
	End Object
	Joints.Add(BRRBumperFixed)

	Begin Object Class=Joint Name=BRBumperFixed
		Child=ChassisBottom
		Parent=BRBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=-.296,y=.112,z=-.092)
	End Object
	Joints.Add(BRBumperFixed)

	Begin Object Class=Joint Name=BBumperFixed
		Child=ChassisBottom
		Parent=BBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=-.296,y=0,z=-.092)
	End Object
	Joints.Add(BBumperFixed)

	Begin Object Class=Joint Name=BLBumperFixed
		Child=ChassisBottom
		Parent=BLBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=-.296,y=-.112,z=-.092)
	End Object
	Joints.Add(BLBumperFixed)

	Begin Object Class=Joint Name=BLLBumperFixed
		Child=ChassisBottom
		Parent=BLLBumper
		JointType=JOINTTYPE_FIXED
		Offset=(x=-.292,y=-.22,z=-.092)
	End Object
	Joints.Add(BLLBumperFixed)

}