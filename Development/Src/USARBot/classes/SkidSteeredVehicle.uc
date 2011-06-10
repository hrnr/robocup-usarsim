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
 * SkidSteeredVehicle - Base class for USAR skid steered vehicles.
 */
class SkidSteeredVehicle extends WheeledVehicle config(USAR) abstract;

// Speeds given to the left and right sides
var float cmdSpeedLeft;
var float cmdSpeedRight;

// Drives the vehicle given the left and right side speeds
simulated function SetDriveSpeed(float LeftSpeed, float RightSpeed)
{
	local int i;
	local vector leftTarget, rightTarget;
	local JointItem ji;
	
	// Determine targets for joints
	leftTarget.X = LeftSpeed;
	rightTarget.X = RightSpeed;
	leftTarget.Y = 0;
	rightTarget.Y = 0;
	leftTarget.Z = 0;
	rightTarget.Z = 0;
	
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			if (ji.JointIsA('WheelJoint') && WheelJoint(ji.Spec).bIsDriven)
			{
				if (ji.Spec.Side == SIDE_LEFT)
				{
					ji.Constraint.ConstraintInstance.SetAngularVelocityDrive(false, true);
					ji.Constraint.ConstraintInstance.SetAngularVelocityTarget(leftTarget);
				}
				else if (ji.Spec.Side == SIDE_RIGHT)
				{
					ji.Constraint.ConstraintInstance.SetAngularVelocityDrive(false, true);
					ji.Constraint.ConstraintInstance.SetAngularVelocityTarget(rightTarget);
				}
			}
		}
}

defaultproperties
{

}
