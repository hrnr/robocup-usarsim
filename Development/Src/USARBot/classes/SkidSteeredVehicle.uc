/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * SkidSteeredVehicle - Base class for USAR skid steered vehicles
 */
class SkidSteeredVehicle extends WheeledVehicle config(USAR) abstract;

// Drives the vehicle given the left and right side speeds
//  DRIVE {Left float} {Right float}
function Drive(ParsedMessage message)
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	local String ls, rs;
	local float leftSpeed, rightSpeed;
	
	ls = message.GetArgVal("Left");
	rs = message.GetArgVal("Right");
	if (ls != "" && rs != "")
	{
		// Valid drive message
		leftSpeed = float(ls);
		rightSpeed = float(rs);
		for (i = 0; i < Parts.Length; i++)
			if (Parts[i].IsJoint())
			{
				ji = JointItem(Parts[i]);
				if (ji.JointIsA('WheelJoint'))
				{
					jt = WheelJoint(ji.Spec);
					// Driven wheels are moved according to their side
					if (jt.bIsDriven)
					{
						if (jt.Side == SIDE_Left)
							ji.SetVelocity(leftSpeed);
						else if (jt.Side == SIDE_Right)
							ji.SetVelocity(rightSpeed);
					}
				}
			}
	}
}

defaultproperties
{
}
