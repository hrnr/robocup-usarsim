/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
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

simulated function ClientTimer()
{
	local String data;
	local vector curVelocity, accel;
	local float curTime;
	
	super.ClientTimer();
	
	curVelocity = Platform.Body.PartActor.Velocity;
	curTime = WorldInfo.TimeSeconds; // obtain elapsed seconds
	if (curTime != lastTime) // prevent "DivisionByZero" error! 
	{
		accel = (curVelocity - lastVelocity) / (curTime - lastTime); // acc = dv / dt
		accel = accel << Platform.Body.PartActor.Rotation; // transform from world space to local space
	}
	else
		accel = vect(0.00, 0.00, 0.00); // Compensate for "Division By Zero"   		
	
	lastVelocity = curVelocity;
	lastTime = curTime;
	
	accel = class'UnitsConverter'.static.VelocityVectorFromUU(accel);
	data = "{Name " $ ItemName $ "} {Acceleration " $ class'UnitsConverter'.static.VectorString(accel) $ "}";
	
	MessageSendDelegate(getHead()@data);
}

defaultproperties
{
	ItemType="Accel"
}
