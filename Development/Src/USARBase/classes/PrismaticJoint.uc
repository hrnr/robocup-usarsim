/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * PrismaticJoint - used for sliding limited-range joints on actuators
 */
class PrismaticJoint extends Joint config(USAR);

// Upper limit of joint's travel
var float LimitHigh;
// Lower limit of joint's travel
var float LimitLow;

// Gets the maximum value of this joint (only applies for some joint types)
simulated function float GetMax()
{
	return LimitHigh;
}

// Gets the minimum value of this joint (only applies for some joint types)
simulated function float GetMin()
{
	return LimitLow;
}

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji)
{
	local vector savedLocation, amount;
	local float trueZero, hi, lo;
	local RB_ConstraintSetup setup;
	
	// Parent initialization
	ji = super.Init(ji);
	setup = ji.Constraint.ConstraintSetup;
	// NOTE: Constraint limits are always symmetrical, but joints can be asymmetrical
	// Make the limits symmetrical; map set angles to the actual constraint limits
	hi = class'UnitsConverter'.static.LengthToUU(LimitHigh);
	lo = class'UnitsConverter'.static.LengthToUU(LimitLow);
	trueZero = (-hi - lo) / 2.0;
	ji.TrueZero = trueZero;
	// Setup joint limits of movement
	setup.LinearXSetup.LimitSize = hi + trueZero;
	// Perform fix to handle asymmetrical joints
	amount = vect(0, 0, 0);
	amount.Z = trueZero;
	amount = amount << class'UnitsConverter'.static.AngleVectorToUU(ji.Spec.Direction);
	if (trueZero != 0.0)
		TempMovePart(ji, ji.Child, amount, savedLocation);
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	if (trueZero != 0.0)
		RestoreMovePart(ji.Child, savedLocation);
	// Enable linear drive position and set the initial drive parameters
	ji.Constraint.ConstraintInstance.SetLinearPositionDrive(true, false, false);
	ji.SetStiffness(ji.Spec.Stiffness);
	ji.SetTarget(0.0);
	// Now store the initial offset for the value checker later
	ji.OldValue = 0.0;
	Update(ji);
	ji.OldValue = ji.CurValue;
	ji.CurValue = 0.0;
	return ji;
}

// Updates linear drive parameters with the given values
function Recalc(JointItem ji)
{
	ji.Constraint.ConstraintInstance.SetLinearDriveParams(ji.MaxForce * ji.Stiffness,
		ji.Damping, ji.MaxForce * ji.Stiffness);
}

// Restores the part's rotation and location to the specified values to deal with symmetry
// See TempMovePart
simulated function RestoreMovePart(Actor p, vector savedPosition)
{
	p.SetLocation(savedPosition);
}

// Moves the specified joint to the given target position
function SetTarget(JointItem ji, float value)
{
	local vector pos;
	
	// Update the values to match new target
	pos = vect(0, 0, 0);
	pos.X = class'UnitsConverter'.static.LengthToUU(value) + ji.TrueZero;
	SetLinearTarget(ji, pos);
}

// Create the slider actor for the given joint item
function RB_ConstraintActor SpawnHinge(JointItem ji)
{
	return ji.Spawn(class'Slider', ji, '', ji.Location, ji.Rotation);
}

// TempMovePart and RestoreMovePart are used to deal with the problem that the constraint 
// value limits are specified symmetrically. The part is temporarily moved so the high and
// low limits become symmetrical if there were not already when initializing the constraint
simulated function TempMovePart(JointItem ji, Actor p, vector amount, out vector savedPosition)
{
	// Save old position and location
	savedPosition = p.Location;
	// Transform position temporarily
	p.SetLocation(savedPosition + amount);
}

// Updates the joint item's value to match the physics system's location
simulated function Update(JointItem ji)
{
	local vector diff;
	
	// Rotate back
	diff = (ji.Parent.Location - ji.Child.Location) >> ji.Parent.Rotation;
	diff = diff << class'UnitsConverter'.static.AngleVectorToUU(ji.Spec.Direction);
	ji.CurValue = class'UnitsConverter'.static.LengthFromUU(diff.Z) - ji.OldValue;
}

defaultproperties
{
	MaxForce=50000.0
}
