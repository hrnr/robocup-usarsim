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

// Drives the vehicle given the left and right side speeds
//  DRIVE {Speed float} {FrontSteer float} {RearSteer float}
function Drive(ParsedMessage message)
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	local String spd, fSteer, rSteer, nam;
	local float speed, frontSteer, rearSteer;

	// Ackerman steered vehicles must have speed and steer angles
	spd = message.GetArgVal("Speed");
	fSteer = message.GetArgVal("FrontSteer");
	rSteer = message.GetArgVal("RearSteer");
	if (spd != "" && fSteer != "" && rSteer != "")
	{
		// Valid drive message
		speed = float(spd);
		frontSteer = float(fSteer);
		rearSteer = float(rSteer);
		for (i = 0; i < Parts.Length; i++)
			if (Parts[i].IsJoint())
			{
				ji = JointItem(Parts[i]);
				if (ji.JointIsA('WheelJoint'))
				{
					jt = WheelJoint(ji.Spec);
					// Spin all drivable wheels
					if (jt.bIsDriven)
						ji.SetVelocity(speed);
				}
				else if (ji.JointIsA('RevoluteJoint'))
				{
					// If a revolute joint has "FrontSteer" or "RearSteer" in its name, use it
					nam = String(ji.GetJointName());
					if (InStr(Caps(nam), "FRONTSTEER") >= 0)
						ji.SetTarget(frontSteer);
					else if (InStr(Caps(nam), "REARSTEER") >= 0)
						ji.SetTarget(rearSteer);
				}
			}
	}
}

defaultproperties
{
}
