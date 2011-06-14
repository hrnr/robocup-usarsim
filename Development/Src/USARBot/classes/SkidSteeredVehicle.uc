/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * SkidSteeredVehicle - Base class for USAR skid steered vehicles.
 */
class SkidSteeredVehicle extends WheeledVehicle config(USAR) abstract;

// Drives the vehicle given the left and right side speeds
simulated function SetDriveSpeed(float leftSpeed, float rightSpeed)
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			if (ji.JointIsA('WheelJoint'))
			{
				jt = WheelJoint(ji.Spec);
				if (jt.bIsDriven)
				{
					if (jt.Side == SIDE_LEFT)
						ji.SetVelocity(leftSpeed);
					else if (jt.Side == SIDE_RIGHT)
						ji.SetVelocity(rightSpeed);
				}
			}
		}
}

defaultproperties
{
}
