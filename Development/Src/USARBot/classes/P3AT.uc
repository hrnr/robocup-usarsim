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
		Mass=1
	End Object
	Body=ChassisMiddle
	PartList.Add(ChassisMiddle)
	
	// Create bottom part
	Begin Object Class=Part Name=ChassisBottom
		Mesh=StaticMesh'P3AT_static.ChassisBottom'
		Mass=10
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
		Offset=(X=.268,Y=.232,Z=.088)
		// 5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.238)
		Mass=0.05
	End Object
	PartList.Add(FRRBumper)

	// Front right Bumper
	Begin Object Class=Part Name=FRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.276,Y=.116,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FRBumper)

	// Front Bumper
	Begin Object Class=Part Name=FBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.276,Y=0,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FBumper)

	// Front left Bumper
	Begin Object Class=Part Name=FLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.276,Y=-.116,Z=.088)
		Direction=(X=0,Y=0,Z=3.14)
		Mass=0.05
	End Object
	PartList.Add(FLBumper)

	// Front left left Bumper
	Begin Object Class=Part Name=FLLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=.268,Y=-.232,Z=.088)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.042)
		Mass=0.05
	End Object
	PartList.Add(FLLBumper)

	// Back right right Bumper
	Begin Object Class=Part Name=BRRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.268,Y=.232,Z=.088)
		// -5.63 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=-0.098)
		Mass=0.05
	End Object
	PartList.Add(BRRBumper)

	// back right Bumper
	Begin Object Class=Part Name=BRBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.276,Y=.116,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BRBumper)

	// back Bumper
	Begin Object Class=Part Name=BBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.276,Y=0,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BBumper)

	// back left Bumper
	Begin Object Class=Part Name=BLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.276,Y=-.116,Z=.088)
		Mass=0.05
	End Object
	PartList.Add(BLBumper)

	// back left left Bumper
	Begin Object Class=Part Name=BLLBumper
		Mesh=StaticMesh'P3AT_static.Bumper'
		Offset=(X=-.268,Y=-.232,Z=.088)
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

	Begin Object Class=PrismaticJoint Name=FRRBumperPrismatic
		Child=FRRBumper
		Parent=ChassisBottom
		Offset=(X=.268,Y=.232,Z=.088)
		Direction=(X=0,Y=-1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(FRRBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=FRBumperPrismatic
		Child=FRBumper
		Parent=ChassisBottom
		Offset=(X=.276,Y=.116,Z=.088)
		Direction=(X=0,Y=-1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(FRBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=FBumperPrismatic
		Child=FBumper
		Parent=ChassisBottom
		Offset=(X=.276,Y=0,Z=.088)
		Direction=(X=0,Y=-1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(FBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=FLBumperPrismatic
		Child=FLBumper
		Parent=ChassisBottom
		Offset=(X=.276,Y=-.116,Z=.088)
		Direction=(X=0,Y=-1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(FLBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=FLLBumperPrismatic
		Child=FLLBumper
		Parent=ChassisBottom
		Offset=(X=.268,Y=-.232,Z=.088)
		Direction=(X=0,Y=-1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(FLLBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=BRRBumperPrismatic
		Child=BRRBumper
		Parent=ChassisBottom
		Offset=(X=-.288,Y=.232,Z=.088)
		Direction=(X=0,Y=1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(BRRBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=BRBumperPrismatic
		Child=BRBumper
		Parent=ChassisBottom
		Offset=(X=-.296,Y=.116,Z=.088)
		Direction=(X=0,Y=1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(BRBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=BBumperPrismatic
		Child=BBumper
		Parent=ChassisBottom
		Offset=(X=-.296,Y=0,Z=.088)
		Direction=(X=0,Y=1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(BBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=BLBumperPrismatic
		Child=BLBumper
		Parent=ChassisBottom
		Offset=(X=-.296,Y=-.116,Z=.088)
		Direction=(X=0,Y=1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(BLBumperPrismatic)

	Begin Object Class=PrismaticJoint Name=BLLBumperPrismatic
		Child=BLLBumper
		Parent=ChassisBottom
		Offset=(X=-.288,Y=-.232,Z=.088)
		Direction=(X=0,Y=1.571,Z=0)
		LimitHigh=0.02
		MaxForce=0.5
	End Object
	Joints.Add(BLLBumperPrismatic)
	
	WheelRadius=0.098
}