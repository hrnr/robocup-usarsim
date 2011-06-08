/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * Sensor - parents all sensors on the robot
 */
class Sensor extends Item abstract;

// Whether the sensor is invisible
var config bool HiddenSensor;
// Configuration for noise
var config float Noise;
// UT3 port - not used?
var InterpCurveFloat OutputCurve;
// Typo ported from UT3 (sensorData)
var String SenorData;
// Variables to be used in the gaussian random number generator
var float Mean;
var float Sigma;
// Whether the sensor data will be sent out in group style or not. Right now, all the sensors of the same
// type are treated as a group
var config bool bUseGroup; 
var config bool bWithTimeStamp;
// Battery of USARVehicle to which the sensor is connected (name for compatibility)
var Battery battery;

// Called when sensor is attached to a vehicle
simulated function AttachItem()
{
	MessageSendDelegate = Platform.ReceiveMessageFromSensor;
}

// Called by the vehicle timer function
simulated function Timer()
{
	super.Timer();
	
	// Continue if battery remains alive
	if (IsClient && IsOwner && (battery==None || !battery.isDead()))
		ClientTimer();
}

simulated function ClientTimer();

// Gets the header of the sensor data
simulated function String GetHead()
{
	local String outstring;

	// Add timestamp if necessary
	outstring = "SEN";
	if (bWithTimeStamp)
		outstring @= " {Time " $ WorldInfo.TimeSeconds $ "}";
	
	// Add sensor type
	outstring @= " {Type " $ ItemType $ "}";
	return outstring;
}

// Gets the geometry data
simulated function String GetGeoData()
{
	local String outstring;
	
	// Name and location
	outstring = "{Name " $ ItemName $ " Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Location - Base.Location);
	
	// Orientation
	outstring @= " Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation - Base.Rotation);
	
	// Mounting type
	outstring @= " Mount " $ ItemMount $ "}";
	return outstring;
}

// Connects sensor to the battery of a USARVehicle
simulated function ConnectToBattery(Battery VehicleBattery)
{
	battery = VehicleBattery;
}

defaultproperties
{
	ItemType="Sensor";
	Mean=0.0;
	Sigma=0.05;
}
