/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * LeggedVehicle - Base class for USAR legged robots.
 */
class LeggedVehicle extends USARVehicle config(USAR) abstract;

// Returns robot status (all joint angles) in radians (NOT degrees!)
simulated function String GetStatus()
{
	local int i;
	local JointItem ji;
	local String status;
	
	// Print out joint data on the status line
	status = super.GetStatus() $ " {Type LeggedVehicle}";
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			status = status $ " {" $ ji.GetJointName() $ " " $
				class'UnitsConverter'.static.Str_AngleFromUU(ji.CurAngle) $ "}";
		}
	status = status $ " {Battery " $ GetBatteryLife() $ "}";
	return status;
}

defaultproperties
{
}
