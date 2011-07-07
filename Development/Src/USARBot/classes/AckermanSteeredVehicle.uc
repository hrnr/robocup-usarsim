/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * AckermanSteeredVehicle - Base class for USAR Ackerman steered vehicles
 */
class AckermanSteeredVehicle extends WheeledVehicle config(USAR) abstract;

// Front steer amount in radians
var float FrontSteer;
// Rear steer amount in radians
var float RearSteer;

// Drives the vehicle given the left and right side speeds
//  DRIVE {Speed float} {FrontSteer float} {RearSteer float}
function Drive(ParsedMessage message)
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	local String spd, fSteer, rSteer, nam;
	local float speed;

	// Ackerman steered vehicles must have speed and steer angles
	spd = message.GetArgVal("Speed");
	fSteer = message.GetArgVal("FrontSteer");
	rSteer = message.GetArgVal("RearSteer");
	if (spd != "" && fSteer != "" && rSteer != "")
	{
		// Valid drive message
		speed = float(spd);
		FrontSteer = float(fSteer);
		RearSteer = float(rSteer);
		for (i = 0; i < Parts.Length; i++)
			if (Parts[i].IsJoint())
			{
				ji = JointItem(Parts[i]);
				if (ji.JointIsA('WheelJoint'))
				{
					jt = WheelJoint(ji.Spec);
					// Spin all drivable wheels
					if (jt.bIsDriven)
					{
						if (Normalized)
							ji.SetVelocity(speed * jt.MaxVelocity / 100.);
						else
							ji.SetVelocity(speed);
					}
				}
				else if (ji.JointIsA('RevoluteJoint'))
				{
					// If a revolute joint has "FrontSteer" or "RearSteer" in its name, use it
					nam = String(ji.GetJointName());
					if (InStr(Caps(nam), "FRONTSTEER") >= 0)
						ji.SetTarget(FrontSteer);
					else if (InStr(Caps(nam), "REARSTEER") >= 0)
						ji.SetTarget(RearSteer);
				}
			}
	}
}

// Returns configuration data of this robot
function String GetConfData()
{
	local int i;
	local String nam;
	local JointItem ji;
	local RevoluteJoint jt;
	local float maxFront, maxRear, amount;
	
	// Establish large initial joint limits (can't steer in a circle!)
	maxFront = 6.28;
	maxRear = 6.28;
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			if (ji.JointIsA('RevoluteJoint'))
			{
				jt = RevoluteJoint(ji.Spec);
				// If a revolute joint has "FrontSteer" or "RearSteer" in its name, use it
				nam = String(ji.GetJointName());
				amount = abs(jt.LimitHigh - jt.LimitLow);
				if (InStr(Caps(nam), "FRONTSTEER") >= 0)
				{
					if (amount < maxFront) maxFront = amount;
				}
				else if (InStr(Caps(nam), "REARSTEER") >= 0)
				{
					if (amount < maxRear) maxRear = amount;
				}
			}
		}
	return super.GetConfData() $ " {MaxFrontSteer " $
		class'UnitsConverter'.static.FloatString(maxFront) $ "} {MaxRearSteer " $
		class'UnitsConverter'.static.FloatString(maxRear) $ "}";
}

// Gets robot status (adds the steer amounts)
simulated function String GetStatus()
{
	return super.GetStatus() $ " {FrontSteer " $
		class'UnitsConverter'.static.FloatString(FrontSteer) $ "} {RearSteer " $
		class'UnitsConverter'.static.FloatString(RearSteer) $ "}";
}

// Gets the robot's steering type
simulated function String GetSteeringType()
{
	return "AckermanSteered";
}

defaultproperties
{
	FrontSteer=0
	RearSteer=0
}
