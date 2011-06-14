/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// Simplistic Acceleration Sensor for AIBO robots
// by Marco Zaratti - marco.zaratti@gmail.com
////////////////////////////////////////////////////////////////////////////////////
// 		Based on   : Sony's AIBO's Acceleration Sensor
//		Ported by  : Kaveh team, Reza Hasanzade - Majid Yasari
//		Bug report : majid.yasari@gmail.com
//
//		It is important to mention that for the first time both current time
//		And last time values are equal, so this leads to "DivisionByZero" 
//		Runtime error, therefore, we modified this.

class Acceleration extends Sensor config (USAR);

var vector lastVelocity;
var float lastTime;

// Returns sensor data
function String GetData()
{
	local vector curVelocity, accel;
	local float curTime;
	
	curVelocity = Velocity;
	curTime = WorldInfo.TimeSeconds;
	if (curTime != lastTime)
	{
		// Transform from world space to local space. Acceleration = dv/dt
		accel = (curVelocity - lastVelocity) / (curTime - lastTime);
		accel = accel << Rotation;
	}
	else
		accel = vect(0.00, 0.00, 0.00);
	
	// Save last parameters and return data
	lastVelocity = curVelocity;
	lastTime = curTime;
	accel = class'UnitsConverter'.static.VelocityVectorFromUU(accel);
	return "{Name " $ ItemName $ "} {Acceleration " $
		class'UnitsConverter'.static.VectorString(accel) $ "}";
}

defaultproperties
{
	ItemType="Accel"
}
