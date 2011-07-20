// IMU sensor
// it provides the following center intem's data
// x,y,z accelerations in m/sec^2
// pitch, roll and yaw angles in rad
// pitch roll and yaw accelerations in rad/sec^2
// disclaimer: this sensor still requires extensive testing to be validated

class IMU extends Sensor config (USAR);

// data at time t-1, for computing differentials
var vector lastRotation;
var vector lastAngVelocity;
var vector lastVelocity;
var float lastTime;

simulated function AttachItem()
{
	super.AttachItem();
	lastTime = WorldInfo.TimeSeconds;
	lastRotation = class'UnitsConverter'.static.AngleVectorFromUU(Platform.CenterItem.Rotation); // rotation in rad
	lastVelocity = Platform.CenterItem.StaticMeshComponent.BodyInstance.GetUnrealWorldVelocity();
}

// Returns sensor data
function String GetData()
{
	local vector curVelocity, accel, curAngVelocity, curAngAccel, curRotation, deltaRot, deltaAngVel;
	local float curTime;
	local String outstring;
	
	curTime = WorldInfo.TimeSeconds;	
	curVelocity = class'UnitsConverter'.static.VelocityVectorFromUU(Platform.CenterItem.StaticMeshComponent.BodyInstance.GetUnrealWorldVelocity()); // current velocity in m/sec
	curRotation = class'UnitsConverter'.static.AngleVectorFromUU(Platform.CenterItem.Rotation); // current rotation in rad
	accel = (curVelocity - lastVelocity) / (curTime - lastTime); // linear/lateral/altitude accelerations in m/sec^2
	// assumption that the gravity and controller's forces mutually elide
	//accel.z += WorldInfo.GetGravityZ();
	accel = accel << Rotation;
	accel.z *= -1;		
		
	deltaRot.x = class'UnitsConverter'.static.diffAngle(curRotation.x, lastRotation.x); // roll delta in rad
	deltaRot.y = class'UnitsConverter'.static.diffAngle(curRotation.y, lastRotation.y); // pitch delta in rad
	deltaRot.z = class'UnitsConverter'.static.diffAngle(curRotation.z, lastRotation.z); // yaw delta in rad
	curAngVelocity = deltaRot / (curTime - lastTime); // angular velocity in rad/sec		
		
	deltaAngVel.x = class'UnitsConverter'.static.diffAngle(curAngVelocity.x, lastAngVelocity.x); 
	deltaAngVel.y = class'UnitsConverter'.static.diffAngle(curAngVelocity.y, lastAngVelocity.y); 
	deltaAngVel.z = class'UnitsConverter'.static.diffAngle(curAngVelocity.z, lastAngVelocity.z); 
	curAngAccel = deltaAngVel / (curTime - lastTime); // angular accel in rad/sec^2		
	
	// store values for next tick
	lastTime = curTime;
	lastVelocity = curVelocity;
	lastRotation = curRotation;
	lastAngVelocity = curAngVelocity;	
	
	// note: actually angular velocities are not required
	outstring = 
	"{Name " $ ItemName $ 
	"} {XYZAcceleration " $  class'UnitsConverter'.static.VectorString(accel) $
	"} {AngularVel "  $  class'UnitsConverter'.static.VectorString(curAngVelocity) $
	"} {AngularAccel "  $ class'UnitsConverter'.static.VectorString(curAngAccel) $ 
	"} {Rotation "  $ class'UnitsConverter'.static.VectorString(curRotation) $ "}"; 
	
	return outstring;
}

defaultproperties
{
	ItemType="IMU"
}
