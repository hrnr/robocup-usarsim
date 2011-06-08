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
 * This class simulates the encoder sensor.
 * 
 * The added config params are:
 *  Resolution:   The resoulution of the encoder defined in UU.
 *  Noise:		The Noise added to the encoder value.
 * 
 * The returned value is:
 *  Tick: The data range is (-65535/uuResolution)~(65535/uuResolution).
 *   Positive value means clockwise direction. It's the controller's
 *   resposible to count how many circles the part has rotated.
 * 	
 * Author: Behzad Tabibian
*/

class Encoder extends Sensor config (USAR);

struct EncodedWheel
{
	var float Old;
	var int Spin;
	var int Tick;
	var BasicWheel Wheel;
};

var float oldTime;
var config float Resolution;
var int uuResolution;
var array<EncodedWheel> Wheels;

simulated function AttachItem()
{
	super.AttachItem();
	FindTires();
}

simulated function ConvertParam()
{
	super.ConvertParam();
	uuResolution = class'UnitsConverter'.static.AngleToUU(Resolution);
}

simulated function FindTires()
{
	local BasicWheel wheel;
	local int i;
	local int index;
	
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("Encoder: Not attached to a SkidSteeredVehicle!");
		SetTimer(0, false);
		return;
	}
	
	index = 0;
	for(i = 0; i < Platform.Joints.Length; i++)
		if (Platform.Joints[i].isA('BasicWheel'))
		{
			wheel = BasicWheel(Platform.Joints[i]);
			Wheels[index].Wheel = wheel;
			Wheels[index].Old = wheel.CurAngle;
			Wheels[index].Spin = 0;
			Wheels[index].Tick = 0;
			index++;
		}
	oldTime = WorldInfo.TimeSeconds;
}

simulated function ClientTimer()
{
	local int totalSpin; // will contain the spin speed of the wheels in rad/sec
	local String encData;
	local float diff;
	local int i;
	local float newTime;
	local float timeDiff;
	
	super.ClientTimer();
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - oldTime;	
	if (timeDiff < 0.000001)
		return;
		
	oldTime = newTime;
	for (i = 0; i < Wheels.Length; i++)
	{
		diff = Wheels[i].Wheel.CurAngle - Wheels[i].Old;
		
		Wheels[i].Old = Wheels[i].Wheel.CurAngle;
		Wheels[i].Spin += int((degToRad * diff) * 32768 / PI);
		
		totalSpin = (1 + RandRange(-Noise, Noise)) * Wheels[i].Spin;
		Wheels[i].Tick = int(normalAngle(totalSpin) / uuResolution);
		
		// Here I will look for the wheel number used in ItemName
		if (InStr(ItemName, "W" $ i) > 0)
		{
			encData = "{Name " $ ItemName $ "} {Tick " $ Wheels[i].Tick $ "}";
			MessageSendDelegate(getHead() @ encData);
		}
	}
}

// Normalizes angles from -65536 to 65536
simulated function float normalAngle(float ang)
{
	if (ang > 65536) ang -= 65536;
	if (ang < -65536) ang += 65536;
	return ang;
}

function String Set(String opcode, String args)
{
	local int i, j;
	if (Caps(opcode) == "RESET")
	{
		for (i = 0; i < Wheels.Length; i++)
		{
			Wheels[i].Tick = 0;
			Wheels[i].Spin = 0;
		}
		return "OK";
	}
	return "Failed";
}

function String GetData()
{
	local int i;
	
	for (i = 0; i < Wheels.Length; i++)
		// Look for the wheel number in ItemName, ItemName should contain a W and # of wheel to report
		if (InStr(ItemName, "W" $ i) > 0)
			return "{Name " $ ItemName $ "} {Tick " $ Wheels[i].Tick $ "}";
}

simulated function String GetConfData()
{
    local String outstring;
	outstring = super.GetConfData();
	outstring @= "{Resolution " $ class 'UnitsConverter'.static.FloatString(Resolution) $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Encoder"
	DrawScale=0.0047620004
	DrawScale3D=(X=0.001)
}
