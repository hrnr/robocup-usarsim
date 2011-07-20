class AerialVehicle extends USARVehicle config(USAR);

// vehicle parameters
var float pitchVelocity;
var float rollVelocity;
var float maxLateralSpeed;
var float maxAltitudeSpeed;
var float maxLinearSpeed;
var float maxRotationSpeed;
var float maxPitchAngle;
var float maxRollAngle;
var float propellerConstantSpeed;

// relax the controller goal from reaching an angle x to reaching an angle y \in x+-angleErrMargin
// now it's used as a threshold for triggering angles variations
var int angleErrMargin;

// velocities and angles received from the controller
var float cmdLateralVelocity;
var float cmdAltitudeVelocity;
var float cmdLinearVelocity;
var float cmdRotVelocity;
var float cmdPitchAngle;
var float cmdRollAngle;
var float speed1; // used for propellers spin
var float speed2; // used for propellers spin

// boolean used to automatically spin the propellers
var int isOn;

// variables to support the simplicistic pitch/roll controller 
// (1 apply positive rotaion, -1 aplly negative rotation, 0 no rotation to be applied)
var int pitchDir;
var int rollDir;
var int yawDir;

// stable rotation, it's used by the pitch/roll controller for taking a snapshot of the reached rotation and keeping it as soon as the controller need to change it
var rotator SROT;

simulated
function PostBeginPlay()
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	local String ls, rs, nm;
	local float left, leftSpeed, right, rightSpeed;
	super.PostBeginPlay();
	//CenterItem.WorldInfo.WorldGravityZ=0;
	
	for (i = 0; i < Parts.Length; i++){ 
		Parts[i].StaticMeshComponent.BodyInstance.CustomGravityFactor=0;
		Parts[i].StaticMeshComponent.bIgnoreForceField=true;
		Parts[i].StaticMeshComponent.bIgnoreRadialForce=true;
	}

	// initialize the rotation controllers to OFF
	pitchDir=0;
	rollDir=0;
	yawDir=0;
}

// sets the AV's lateral speed (along the y axis), speed is a value in m/s
reliable server
function setLateralVelocity(float speed, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (speed > 100) speed = maxLateralSpeed;
		else if (speed < -100) speed = -maxLateralSpeed;
		else speed = (speed*0.01)*maxLateralSpeed;
	}
	cmdLateralVelocity = class'UnitsConverter'.static.LengthToUU(speed); // every tick cmdLateralVelocity is read and applied to the AV
	
	// Here holds the assumption that the roll angle does not depend on the lateralVelocity magnitude 
	// (after real experiments we'll consider the option of using some relation between the two)
	if(speed > 0) setRollAngle(maxRollAngle,norm);
	else if(speed < 0) setRollAngle(-maxRollAngle,norm);
	else setRollAngle(0,norm);
}

// sets the AV's vertical speed (along the z axis), speed is a value in m/s
reliable server
function setAltitudeVelocity(float speed, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (speed > 100) speed = maxAltitudeSpeed;
		else if (speed < -100) speed = -maxAltitudeSpeed;
		else speed = (speed*0.01)*maxAltitudeSpeed;
		}
	cmdAltitudeVelocity = class'UnitsConverter'.static.LengthToUU(speed); // every tick cmdAltitudeVelocity is read and applied to the AV
}

// sets the AV's linear speed (along the x axis), speed is a value in m/s
reliable server
function setLinearVelocity(float speed, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (speed > 100) speed = maxLinearSpeed;
		else if (speed < -100) speed = -maxLinearSpeed;
		else speed = (speed*0.01)*maxLinearSpeed;
	}
	cmdLinearVelocity = class'UnitsConverter'.static.LengthToUU(speed); // every tick cmdLinearVelocity is read and applied to the AV

	// Here holds the assumption that the pitch angle does not depend on the linearVelocity magnitude 
	// (after real experiments we'll consider the option of using some relation between the two)	
	if(speed > 0) setPitchAngle(-maxPitchAngle,norm);
	else if(speed < 0) setPitchAngle(maxPitchAngle,norm);
	else setPitchAngle(0,norm);
}

// sets the AV's rotational speed (around the z axis), speed is a value in deg/s
reliable server
function setRotationVelocity(float speed, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (speed > 100) speed = maxRotationSpeed;
		else if (speed < -100) speed = -maxRotationSpeed;
		else speed = (speed*0.01)*maxRotationSpeed;
	}

  // conversions: deg -> rad -> uu
  cmdRotVelocity = class'UnitsConverter'.static.AngleToUU(class'UnitsConverter'.static.AngleFromDeg(speed)); // every tick cmdRotVelocity is read and applied to the AV
}

// sets the AV's pitch angle (around the y axis), desiredPitch is a value in deg (with a positive angle the robot looks up)
reliable server
function setPitchAngle(float desiredPitch, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (desiredPitch > 100) desiredPitch = maxPitchAngle;
		else if (desiredPitch < -100) desiredPitch = -maxPitchAngle;
		else desiredPitch = (desiredPitch*0.01)*maxPitchAngle;
	}
	
	// conversions: deg -> rad -> uu
	cmdPitchAngle = class'UnitsConverter'.static.AngleToUU(class'UnitsConverter'.static.AngleFromDeg(desiredPitch)); // every tick cmdPitchAngle is read and applied to the AV
  }

// sets the AV's roll angle (around the z axis), desiredRoll is a value in deg (with a positive angle the robot bends the head to the left)
reliable server
function setRollAngle(float desiredRoll, bool norm)
{
	// if the value is normalize in [0,100]
	if (norm) {
		if (desiredRoll > 100) desiredRoll = maxRollAngle;
		else if (desiredRoll < -100) desiredRoll = -maxRollAngle;
		else desiredRoll = (desiredRoll*0.01)*maxRollAngle;
	}
	
	// conversions: deg -> rad -> uu
	cmdRollAngle = class'UnitsConverter'.static.AngleToUU(class'UnitsConverter'.static.AngleFromDeg(desiredRoll)); // every tick cmdRollAngle is read and applied to the AV
  
}

// This function is called each time a DRIVE directive is received
// It sets the desired velocities and angles for the AV callings the functions defined above (with the exception of the propellers' spin velocities)
// The {Field Value} pairs that are supported are the follwing (examples):
// {AltitudeVelocity 1000}, {LinearVelocity 0}, {LateralVelocity 0}, {RotationalVelocity 56}, {PitchAngle 15}, {RollAngle -20}, {Spin1 10} {Spin2 5} {Normalized false}
// NOTE: Since linear/lateral velocities inject pitch/roll variations, it is not recommended to use a linear/lateral velocity and a pitch/roll angle command in the same DRIVE directive
// Examples:
// DRIVE {AltitudeVelocity 1000} {LinearVelocity 0} {LateralVelocity 0} {RotationalVelocity 56} {Normalized false}
// DRIVE {AltitudeVelocity 1000} {RotationalVelocity 56} {PitchAngle 15} {RollAngle -20} {Normalized false}
function Drive(ParsedMessage message)
{
	local int i;
	local String z_vel, x_vel, y_vel, pitch_angle,roll_angle,yaw_vel, nm, spin1,spin2;
	local bool norm;
	local JointItem ji;
	local PropellerJoint jt;

    norm = false;
	// read the values from the received DRIVE directive
	spin1 = message.GetArgVal("Spin1");
	spin2 = message.GetArgVal("Spin2");
	z_vel = message.GetArgVal("AltitudeVelocity");
	x_vel = message.GetArgVal("LinearVelocity");
	y_vel = message.GetArgVal("LateralVelocity");
	pitch_angle = message.GetArgVal("PitchAngle");
	roll_angle = message.GetArgVal("RollAngle");
	yaw_vel= message.GetArgVal("RotationalVelocity");
	nm = message.GetArgVal("Normalized");
	if (nm != "") norm = (nm == "true");
	
	// for each specified value call the corresponding set function
	if (z_vel != "") setAltitudeVelocity(float(z_vel),norm);
	if (x_vel != "") setLinearVelocity(float(x_vel),norm);
	if (y_vel != "") setLateralVelocity(float(y_vel),norm);
	if (pitch_angle != "") setPitchAngle(float(pitch_angle),norm);
	if (roll_angle != "") setRollAngle(float(roll_angle),norm);
	if (yaw_vel != "") setRotationVelocity(float(yaw_vel),norm);
	
	// spin velocities are applied directly in this function
	if (spin1 != "") speed1 = float(spin1);
	if (spin2 != "") speed2 = float(spin2);
		
	// if a DRIVE directive is received and the propellers are off then turn them on	
	if(isOn == 0){
		speed1=propellerConstantSpeed;
		speed2=propellerConstantSpeed;
		isOn=1;
	}
	
	// apply a rotational speed to each pair (FL+Br and FR+BL) of the four propellers
	for (i = 0; i < Parts.Length; i++)
	if (Parts[i].IsJoint()){
		ji = JointItem(Parts[i]);
		if (ji.JointIsA('PropellerJoint'))
		{
			jt = PropellerJoint(ji.Spec);
			if (jt.Side == SIDE_FrontLeft || jt.Side == SIDE_BackRight)  ji.SetVelocity(speed1);
			else if (jt.Side == SIDE_FrontRight || jt.Side == SIDE_BackLeft) ji.SetVelocity(-speed2);
		}
	}
}


event Tick(float DeltaTime)
{
	local Rotator newrot;
	local vector rotVelocities;
	local vector linVelocities;
	local Rotator curRotation;
	local Rotator linVelTrans;
	local int i;
	local JointItem ji;
	local PropellerJoint jt;
	local String ls, rs, nm;
	local float left, leftSpeed, right, rightSpeed;
	local bool norm;
	
	Super.Tick(DeltaTime);
	
	curRotation=CenterItem.StaticMeshComponent.getRotation(); // snapshot the current rotation in uu	
	
	// --- 
	// pitch/roll/yaw velocity simple controller
	// ---
	
	// this part determines when to turn on/off the angles variations
	if(pitchDir == 0 && cmdPitchAngle > SROT.pitch + angleErrMargin) pitchDir = 1;
	else if(pitchDir == 0 && cmdPitchAngle < SROT.pitch -angleErrMargin) pitchDir = -1;
	else if((pitchDir == 1 && cmdPitchAngle <= curRotation.pitch)||(pitchDir == -1 && cmdPitchAngle >= curRotation.pitch)){
		pitchDir = 0;
		// when turning off, snapshot the reached pitch and store it in SROT
		SROT.pitch = curRotation.pitch;
		cmdPitchAngle = SROT.pitch;
	}

	if(rollDir == 0 && cmdRollAngle > SROT.roll + angleErrMargin) rollDir = 1;
	else if(rollDir == 0 && cmdRollAngle < SROT.roll - angleErrMargin) rollDir = -1;
	else if((rollDir == 1 && cmdRollAngle <= curRotation.roll)||(rollDir == -1 && cmdRollAngle >= curRotation.roll)){
		rollDir = 0;
		// when turning off, snapshot the reached roll and store it in SROT
		SROT.roll = curRotation.roll;
		cmdRollAngle = SROT.roll;
	}
	
	if(yawDir == 0 && cmdRotVelocity > 0) yawDir = 1; 
	else if(yawDir == 0 && cmdRotVelocity < 0) yawDir = -1; 
	else if(yawDir!=0 && cmdRotVelocity==0){
		yawDir = 0;
		// when turning off, snapshot the reached yaw and store it in SROT
		SROT.yaw = curRotation.yaw;
	}
	
	// this part computes the new rotation to be applied
	newrot = curRotation;
	if(yawDir == 1) newrot.yaw += cmdRotVelocity*deltaTime;
	else if(yawDir == -1) newrot.yaw += cmdRotVelocity*deltaTime;
	else newrot.yaw = SROT.yaw;
	
	if(pitchDir == 1) newrot.pitch += pitchVelocity*deltaTime;
	else if(pitchDir == -1) newrot.pitch -= pitchVelocity*deltaTime;
	else newrot.pitch = SROT.pitch;
	
	if(rollDir == 1) newrot.roll += rollVelocity*deltaTime;
	else if(rollDir == -1)
	newrot.roll -= rollVelocity*deltaTime;
	else newrot.roll = SROT.roll;
	
	// if the robot has to change its rotation try to have a smmoth one
	if(rollDir!=0 || pitchDir!=0 || yawDir!=0) CenterItem.StaticMeshComponent.SetRBRotation(RInterpTo(curRotation,newrot,DeltaTime,90000,true));
	// if not just impose the reached rotation
	else CenterItem.StaticMeshComponent.SetRBRotation(SROT);
	
	// --- 
	// apply linear/lateral/altitude velocities
	// ---
	
	linVelocities.x=cmdLinearVelocity;
	linVelocities.y=cmdLateralVelocity;
	linVelocities.z=cmdAltitudeVelocity;
	linVelTrans.yaw = curRotation.yaw; // velocities should be in local space (considering just the robot's current yaw)
	CenterItem.StaticMeshComponent.SetRBLinearVelocity(linVelocities>>linVelTrans);

	// with Parts mounted on the robot, applying a velocity to the center of mass of CenterItem can introduce a momentum, since the real center of mass
	// of the entire vehicle is <> to CenterItem's one.
	// A tricky way to solve the problem is to apply the same linear velocity to all the parts:
	//for (i = 0; i < Parts.Length; i++) if (!Parts[i].IsJoint()) Parts[i].StaticMeshComponent.SetRBLinearVelocity(linVelocities);	
	// however, since the pitch/roll/yaw controller is quite aggressive (it overrides the rotation at every tick), this effect is inhibited
	
	CenterItem.StaticMeshComponent.WakeRigidBody();
}

