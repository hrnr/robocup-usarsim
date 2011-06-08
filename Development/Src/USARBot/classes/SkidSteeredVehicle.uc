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
 * Base class for USAR skid steered vehicles.
 */
class SkidSteeredVehicle extends WheeledVehicle config(USAR) abstract;

// Speeds given to the left and right sides
var float cmdSpeedLeft;
var float cmdSpeedRight;

// Drives the vehicle given the left and right side speeds
simulated function SetDriveSpeed(float LeftSpeed, float RightSpeed)
{
	local int i;
	local Vector leftTarget, rightTarget;
	local BasicWheel wheel;
	
	leftTarget.X = LeftSpeed;
	rightTarget.X = RightSpeed;
	leftTarget.Y = 0;
	rightTarget.Y = 0;
	leftTarget.Z = 0;
	rightTarget.Z = 0;
	for (i = 0; i < Joints.Length; i++)
		if (Joints[i].isA('BasicWheel'))
		{
			wheel = BasicWheel(Joints[i]);
			if (wheel.bIsDriven)
			{
				if (wheel.Side == SIDE_LEFT)
				{
					wheel.Constraint.ConstraintInstance.SetAngularVelocityDrive(false, true);
					wheel.Constraint.ConstraintInstance.SetAngularVelocityTarget(leftTarget);
				}
				else if (wheel.Side == SIDE_RIGHT)
				{
					wheel.Constraint.ConstraintInstance.SetAngularVelocityDrive(false, true);
					wheel.Constraint.ConstraintInstance.SetAngularVelocityTarget(rightTarget);
				}
			}
		}
}

// Temporarily removed until we find a way to set the AngularDriveForceLimit. Currently we can't change it directly. 
/*
function SetMaxTorque(float maxTorque)
{
	local int i;
	for (i = 0; i < Joints.Length; i++)
		if (Joints[i].Side != SIDE_NONE)
			Joints[i].Constraint.ConstraintInstance.AngularDriveForceLimit = maxTorque;
}
*/

defaultproperties
{

}
