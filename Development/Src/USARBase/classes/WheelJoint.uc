/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Wheel - Describes a wheel on the robot.
 */
class WheelJoint extends Joint config(USAR);

// The side of the robot this joint is on (useful in many cases for symmetrical robots)
enum ESide
{
	SIDE_Left,
	SIDE_Right,
	SIDE_None
};

// Whether the wheen can be driven
var bool bIsDriven;
// Whether the wheel can be steered
var bool bIsSteered;
// Whether the wheel can also rotate in the other direction (caster/omni wheels)
var bool bOmni;
// The side of the robot this joint inhabits
var ESide Side;

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji)
{
	local RB_ConstraintSetup setup;
	
	ji = super.Init(ji);
	setup = ji.Constraint.ConstraintSetup;
	setup.bTwistLimited = false;
	if (bOmni)
		setup.bSwingLimited = false;
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	ji.Constraint.ConstraintInstance.SetAngularVelocityDrive(bOmni, true);
	ji.SetStiffness(1.0);
	ji.SetVelocity(0.0);
	return ji;
}

// Updates angular drive parameters with the given values
function Recalc(JointItem ji)
{
	// Recalculate using damping
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(ji.MaxForce * ji.Stiffness,
		ji.Damping, ji.MaxForce * ji.Stiffness);
}

// Rotates the specified joint at the given velocity
function SetVelocity(JointItem ji, float target)
{
	local vector vel;
	
	vel.X = target;
	vel.Y = 0;
	vel.Z = 0;
	SetAngularVelocity(ji, vel);
}

// Updates the joint item's angle to match the physics system's angle
simulated function Update(JointItem ji)
{
	local rotator relRot;

	// Simple and fun
	relRot = GetRelativeRotation(ji.Child.Rotation, ji.Parent.Rotation);
	ji.CurValue = class'UnitsConverter'.static.AngleFromUU(relRot.Pitch);
}

defaultproperties
{
	bIsDriven=true
	bIsSteered=false
	bOmni=false
	Side=SIDE_None
}
