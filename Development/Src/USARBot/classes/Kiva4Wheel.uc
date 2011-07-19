/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Kiva4Wheel - A Kiva implemented using 2 drive wheels and 2 caster wheels
 */
class Kiva4Wheel extends SkidSteeredVehicle config(USAR);

defaultproperties
{
	// Create body part
	Begin Object Class=Part Name=Chassis
		Mesh=StaticMesh'Kiva_static.Chassis'
		Mass=12
	End Object
	Body=Chassis
	PartList.Add(Chassis)

	// Front caster wheel
	Begin Object Class=Part Name=FCasterWheel
		Mesh=StaticMesh'Kiva_static.CasterWheel'
		Offset=(X=.432,Y=0,Z=.24)
		Mass=1
	End Object
	PartList.Add(FCasterWheel)

	// Back caster wheel
	Begin Object Class=Part Name=BCasterWheel
		Mesh=StaticMesh'Kiva_static.CasterWheel'
		Offset=(X=-.432,Y=0,Z=.24)
		Mass=1
	End Object
	PartList.Add(BCasterWheel)

	// Right Driven Wheel
	Begin Object Class=Part Name=RWheel
		Mesh=StaticMesh'Kiva_static.Wheel'
		Offset=(X=0,Y=.324,Z=.194)
		Direction=(X=1.571,Y=0,Z=0)
		Mass=1
	End Object
	PartList.Add(RWheel)

	// Left Driven Wheel
	Begin Object Class=Part Name=LWheel
		Mesh=StaticMesh'Kiva_static.Wheel'
		Offset=(X=0,Y=-.324,Z=.194)
		Direction=(X=1.571,Y=0,Z=0)
		Mass=1
	End Object
	PartList.Add(LWheel)

	// Front Caster Wheel joint
	Begin Object Class=WheelJoint Name=FCasterJoint
		Parent=Chassis
		Child=FCasterWheel
		Side=SIDE_None
		bOmni=true
		bIsDriven=false
		Offset=(X=.432,Y=0,Z=.24)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(FCasterJoint)

	// Back Caster Wheel joint
	Begin Object Class=WheelJoint Name=BCasterJoint
		Parent=Chassis
		Child=BCasterWheel
		Side=SIDE_None
		bOmni=true
		bIsDriven=false
		Offset=(X=-.432,Y=0,Z=.24)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(BCasterJoint)

	// Right driven wheel joint
	Begin Object Class=WheelJoint Name=RWheelJoint
		Parent=Chassis
		Child=RWheel
		Side=SIDE_Right
		Offset=(X=0,Y=.324,Z=.194)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(RWheelJoint)

	// Left driven wheel joint
	Begin Object Class=WheelJoint Name=LWheelJoint
		Parent=Chassis
		Child=LWheel
		Side=SIDE_Left
		Offset=(X=0,Y=-.324,Z=.194)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(LWheelJoint)
	
	WheelRadius=.098
}