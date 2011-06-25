// Simplistic Accelerometer Sensor

class Accelerometer extends Sensor config (USAR);

var vector lastVelocity;
var float lastTime;

// Returns sensor data
function String GetData()
{
	local vector curVelocity, accel;
	local float curTime;
	
	curVelocity = Platform.CenterItem.StaticMeshComponent.BodyInstance.Velocity;
	curTime = WorldInfo.TimeSeconds;
	if (curTime != lastTime)
	{
		// Transform from world space to local space. Acceleration = dv/dt
		accel = (curVelocity - lastVelocity) / (curTime - lastTime);
		accel.z += WorldInfo.GetGravityZ();
		accel = accel << Rotation;
	}
	else
		accel = vect(0.00, 0.00, 0.00);
	
	// Save last parameters and return data
	lastVelocity = curVelocity;
	lastTime = curTime;
	accel = class'UnitsConverter'.static.VelocityVectorFromUU(accel);
	return "{Name " $ ItemName $ "} {ProperAcceleration " $
		class'UnitsConverter'.static.VectorString(accel) $ "}";
}

defaultproperties
{
	ItemType="AcceleroMeter"
}
