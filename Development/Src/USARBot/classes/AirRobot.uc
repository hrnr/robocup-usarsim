class AirRobot extends AerialVehicle
	config(USAR);

DefaultProperties
{
	isOn=0;
	
	// relax the controller goal from reaching an angle x to reaching an angle y \in x+-angleErrMargin
	 // this value has been empirically chosen after some tests in the virtual environment
	angleErrMargin = 200; // value in uu
	
	// these values are not provided in the AirRobot's specs and should be empirically derived
	pitchVelocity=7000; // value in UU/s
	rollVelocity=7000; // value in UU/s
	propellerConstantSpeed = 7;
    
	// these values come from the AirRobot's specs
	maxLateralSpeed = 2; // value in m/s
	maxLinearSpeed = 2; // value in m/s
    maxPitchAngle=25; // value in deg
    maxRollAngle=25; // value in deg	
	maxAltitudeSpeed=2; // value in m/s
    maxRotationSpeed=100; // value in deg/s

	// --- 
	// Static meshes composing the AirRobot
	// --- 
	
	// Main body:
	Begin Object Class=Part Name=MainBody
		Mesh=StaticMesh'AirRobot.body'
		Mass=0
	End Object
	Body=MainBody
	PartList.Add(MainBody)
	
	// Propellers:
	// ("magic constants" in Offsets and Directons are due to little imperfections in the main body's static mesh)

     // front right
	Begin Object Class=Part Name=FRProp
		Mesh=StaticMesh'AirRobot.propeller'
		Offset=(X=.17,Y=.175,Z=-0.01)
                Mass=0
	End Object
	PartList.Add(FRProp)

    // back left
	Begin Object Class=Part Name=BLProp
		Mesh=StaticMesh'AirRobot.propeller'
                Offset=(X=-.2167,Y=-.211,Z=-0.01)
		Mass=0
	End Object
	PartList.Add(BLProp)

    // back right
	Begin Object Class=Part Name=BRProp
		Mesh=StaticMesh'AirRobot.propeller'
		Offset=(X=-.2167,Y=.175,Z=-0.01)
		Mass=0
	End Object
	PartList.Add(BRProp)

    // front left
	Begin Object Class=Part Name=FLProp
		Mesh=StaticMesh'AirRobot.propeller'
		Offset=(X=.17,Y=-.211,Z=-0.01)
		Mass=0
	End Object
	PartList.Add(FLProp)
	
	// --- 
	// Joints between propellers and main body
	// --- 

	 // front right
	Begin Object Class=PropellerJoint Name=FRPropYaw
		Parent=MainBody
		Child=FRProp
		Side=SIDE_FrontRight
		Offset=(X=.17,Y=.175,Z=-0.01)
		Direction=(X=0,Y=0,Z=1.571)
		MaxVelocity=100
	End Object
	Joints.Add(FRPropYaw)

	 // back left
	Begin Object Class=PropellerJoint Name=BLPropYaw
		Parent=MainBody
		Child=BLProp
		Side=SIDE_BackLeft
		Offset=(X=-.2167,Y=-.211,Z=-0.01)
		Direction=(X=0,Y=0,Z=1.571)
		MaxVelocity=100
	End Object
	Joints.Add(BLPropYaw)

	// back right
	Begin Object Class=PropellerJoint Name=BRPropYaw
		Parent=MainBody
		Child=BRProp
		Side=SIDE_BackRight
		Offset=(X=-.2167,Y=.175,Z=-0.01)
		Direction=(X=0,Y=0,Z=1.571)
		MaxVelocity=100
	End Object
	Joints.Add(BRPropYaw)

	// front left
	Begin Object Class=PropellerJoint Name=FLPropYaw
		Parent=MainBody
		Child=FLProp
		Side=SIDE_FrontLeft
		Offset=(X=.17,Y=-.211,Z=-0.01)
		Direction=(X=0,Y=0,Z=1.571)
		MaxVelocity=100
	End Object
	Joints.Add(FLPropYaw)
}

