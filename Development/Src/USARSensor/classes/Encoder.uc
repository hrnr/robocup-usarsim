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
	var JointItem Wheel;
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
	local JointItem ji;
	local int i;
	local int index;
	
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("Encoder: Not attached to a SkidSteeredVehicle");
		SetTimer(0, false);
		return;
	}
	
	index = 0;
	for(i = 0; i < Platform.Parts.Length; i++)
		if (Platform.Parts[i].isJoint())
		{
			ji = JointItem(Platform.Parts[i]);
			if (ji.JointIsA('WheelJoint') && WheelJoint(ji.Spec).bIsDriven)
			{
				Wheels[index].Wheel = ji;
				Wheels[index].Old = ji.CurAngle;
				Wheels[index].Spin = 0;
				Wheels[index].Tick = 0;
				index++;
			}
		}
	oldTime = WorldInfo.TimeSeconds;
}

// Updates the encoder tick positions
simulated function ClientTimer()
{
	local int totalSpin;
	local float diff;
	local int i;
	local float newTime;
	local float timeDiff;
	
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - oldTime;	
	if (timeDiff < 0.000001)
		return;
	oldTime = newTime;
	for (i = 0; i < Wheels.Length; i++)
	{
		diff = Wheels[i].Wheel.CurAngle - Wheels[i].Old;
		
		// Convert back to UU for tick reasons?
		Wheels[i].Old = Wheels[i].Wheel.CurAngle;
		Wheels[i].Spin += int(diff * 32768 / PI);
		totalSpin = (1 + RandRange(-Noise, Noise)) * Wheels[i].Spin;
		Wheels[i].Tick = int(NormalAngle(totalSpin) / uuResolution);
	}
	// Fire parent method to send the message
	super.ClientTimer();
}

// Normalizes angles from -65536 to 65536
simulated function float NormalAngle(float ang)
{
	ang = ang % 65536;
	if (ang > 65536) ang -= 65536;
	if (ang < -65536) ang += 65536;
	return ang;
}

// Allows encoder to be reset
function String Set(String opcode, String args)
{
	local int i;
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

// Retrieves encoder data
simulated function String GetData()
{
	local int i;
	local String outstring;
	
	outstring = "";
	for (i = 0; i < Wheels.Length; i++)
		// Look for the wheel number in ItemName, should contain a W and # of wheel(s) to report
		if (InStr(ItemName, "W" $ i) > 0)
		{
			if (outstring != "")
				outstring = outstring $ " ";
			outstring = outstring $ "{Name W" $ i $ "} {Tick " $ Wheels[i].Tick $ "}";
		}
	return outstring;
}

function String GetConfData()
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
