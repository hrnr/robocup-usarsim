/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * RevoluteJoint - used for revolving limited-range joints on actuators and legs
 */
class RevoluteJoint extends Joint config(USAR);

// Upper limit of joint's angle
var float LimitHigh;
// Lower limit of joint's angle
var float LimitLow;
// The default way of measuring or applying the angles might not match with the defined
// joint of the robot; use these variables to invert it
// Inverts the parent and the child
var bool InverseMeasure;
// Inverts the measured angle's sign
var bool InverseMeasureAngle;

// Gets the maximum value of this joint (only applies for some joint types)
simulated function float GetMin()
{
	return LimitLow;
}

// Gets the minimum value of this joint (only applies for some joint types)
simulated function float GetMax()
{
	return LimitHigh;
}

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji)
{
	local vector savedLocation;
	local rotator savedRotation, angle;
	local int trueZero, hi, lo, limit;
	local float twistLimit;
	
	// Parent initialization
	ji = super.Init(ji);
	// NOTE: Constraint limits are always symmetrical, but joints can be asymmetrical
	// Make the limits symmetrical; map set angles to the actual constraint limits
	hi = class'UnitsConverter'.static.AngleToUU(LimitHigh);
	lo = class'UnitsConverter'.static.AngleToUU(LimitLow);
	trueZero = int((-hi - lo) / 2.0);
	ji.TrueZero = trueZero;
	// Setup joint limits of movement (it can't be more than 180 or the joint will crash)
	// Evidently TwistLimitAngle is in DEGREES!?!?
	twistLimit = class'UnitsConverter'.static.AngleFromUU(hi + trueZero);
	limit = class'UnitsConverter'.static.AngleToDeg(twistLimit);
	if (limit > 180) limit = 180;
	ji.Constraint.ConstraintSetup.TwistLimitAngle = limit;
	// Perform fix to handle asymmetrical joints
	angle = QuatToRotator(QuatFromAxisAndAngle(Vector(ji.Constraint.Rotation), 
		class'UnitsConverter'.static.AngleFromUU(-trueZero)));
	// Only TempRotate if required
	if (trueZero != 0)
		TempRotatePart(ji, ji.Child, angle, savedLocation, savedRotation);
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	if (trueZero != 0)
		RestoreRotatePart(ji.Child, savedLocation, savedRotation);
	// Enable angular drive position and set the initial drive parameters
	ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, true);
	ji.SetStiffness(ji.Spec.Stiffness);
	ji.SetTarget(0.0);
	return ji;
}

// Updates angular drive parameters with the given values
function Recalc(JointItem ji)
{
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(ji.MaxForce * ji.Stiffness,
		ji.Damping, ji.MaxForce * ji.Stiffness);
}

// Restores the part's rotation and location to the specified values to deal with symmetry
// See TempRotatePart
simulated function RestoreRotatePart(Actor p, vector savedPosition, rotator savedRotation)
{
	p.SetRotation(savedRotation);
	p.SetLocation(savedPosition);
}

// Rotates the specified joint to the given target angle
function SetTarget(JointItem ji, float value)
{
	local rotator angle;
	local RevoluteJoint jt;
	
	// Perform bounds checking on joint angle
	jt = RevoluteJoint(ji.Spec);
	if (value > jt.LimitHigh) value = jt.LimitHigh;
	if (value < jt.LimitLow) value = jt.LimitLow;
	// Update the values to match new target
	angle = rot(0, 0, 0);
	angle.roll = int(class'UnitsConverter'.static.AngleToUU(value) + ji.TrueZero);
	SetAngularTarget(ji, angle);
}

// TempRotatePart and RestoreRotatePart are used to deal with the problem that the constraint
// angle limits are specified symmetrically. The part is temporary rotated so the high and
// low limits become symmetrical if there were not already when initializing the constraint
simulated function TempRotatePart(JointItem ji, Actor p, rotator angle,
	out vector savedPosition, out rotator savedRotation)
{
	local vector pos;
	
	// Save old position and location
	savedPosition = p.Location;
	savedRotation = p.Rotation;
	// Transform position and direction temporarily
	pos = TransformVectorByRotation(angle, p.Location - ji.Location);
	p.SetRotation(p.Rotation + angle);
	p.SetLocation(pos + ji.Location);
}

// Updates the joint item's angle to match the physics system's angle
simulated function Update(JointItem ji)
{
	local RevoluteJoint jt;
	local rotator relRot;
	local float angle;
	local Rotator r1, r2;

	jt = RevoluteJoint(ji.Spec);
	
	// Transform rotation of the parts by the constraint rotation
	// Then take the relative rotation between these two parts
	// The angle of the Revolute joint is then the roll component
	// TODO: Take the base rotations of the parts into account
	//       Right now it assumes the contraint is initialized with
	//       the same rotations for both parts
	r1 = class'Utilities'.static.rTurn(ji.Parent.Rotation, -1*ji.Constraint.Rotation);
	r2 = class'Utilities'.static.rTurn(ji.Child.Rotation, -1*ji.Constraint.Rotation);
	if (jt.InverseMeasure)
		relRot = GetRelativeRotation(r1, r2);
	else
		relRot = GetRelativeRotation(r2, r1);
	angle = class'UnitsConverter'.static.AngleFromUU(relRot.Roll);

	// Update angle representation
	if (jt.InverseMeasureAngle)
		angle = -angle;
	ji.CurValue = angle;
}

defaultproperties
{
	MaxForce=50000.0
	LimitHigh=0.0
	LimitLow=0.0
}
