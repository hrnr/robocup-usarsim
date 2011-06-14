/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WheelSensor - defines methods for finding wheels and storing old positions
 */
class WheelSensor extends Sensor config (USAR);

// Stores the wheel joint and the amount it has spun since reset
struct EncodedWheel
{
	var float Old;
	var float Spun;
	var JointItem Wheel;
};

var array<EncodedWheel> Wheels;

simulated function AttachItem()
{
	super.AttachItem();
	FindTires();
}

// Locates wheels to monitor for changes
simulated function FindTires()
{
	local JointItem ji;
	local int i;
	local int index;
	
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("WheelSensor: Not attached to a SkidSteeredVehicle");
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
				Wheels.Length = index + 1;
				Wheels[index].Old = ji.CurValue;
				Wheels[index].Spun = 0.0;
				Wheels[index].Wheel = ji;
				index++;
			}
		}
}

// Allows encoder to be reset
function String Set(String opcode, String args)
{
	local int i;
	
	if (Caps(opcode) == "RESET")
	{
		for (i = 0; i < Wheels.Length; i++)
			Wheels[i].Spun = 0.0;
		return "OK";
	}
	return "Failed";
}

// Retrieves wheel data and updates the amount spun
simulated function UpdateSpin()
{
	local int i;
	local float value;
	
	for (i = 0; i < Wheels.Length; i++)
	{
		// Accumulate ticks since last reset
		value = Wheels[i].Wheel.CurValue;
		Wheels[i].Spun += value - Wheels[i].Old;
		Wheels[i].Old = value;
	}
}

defaultproperties
{
	ItemType="WheelSensor"
}
