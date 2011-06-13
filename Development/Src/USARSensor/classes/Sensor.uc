/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Sensor - parents all sensors on the robot
 */
class Sensor extends Item config(USAR) abstract;

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

// Called when sensor is attached to a vehicle
simulated function AttachItem()
{
	MessageSendDelegate = Platform.ReceiveMessageFromSensor;
}

// Sends out sensor data per tick
simulated function ClientTimer()
{
	MessageSendDelegate(GetHead() @ GetData());
}

// Gets the sensor data
function String GetData()
{
}

// Gets the geometry data
function String GetGeoData()
{
	local String outstring;
	
	// Name and location
	outstring = "{Name " $ ItemName $ "} {Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Location - Platform.CenterItem.Location);
	
	// Direction
	outstring = outstring $ "} {Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation - Platform.CenterItem.Rotation);
	
	// Mount point
	outstring = outstring $ "} {Mount " $ ItemMount $ "}";
	return outstring;
}

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

// Called by the vehicle timer function
simulated function Timer()
{
	super.Timer();
	
	// Continue if battery remains alive
	if (IsClient && IsOwner && Platform.GetBatteryLife() > 0)
		ClientTimer();
}

defaultproperties
{
	ItemType="Sensor"
	Mean=0.0
	Sigma=0.05
	Physics=PHYS_None
}
