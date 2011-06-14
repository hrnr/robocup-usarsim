/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * RevoluteJoint - used for revolving limited-range joints on mission packages and legs
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

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji) {
	local vector savedLocation;
	local rotator savedRotation, angle;
	local int trueZero, hi, lo;
	local float tl;
	
	// Parent initialization
	ji = super.Init(ji);
	// NOTE: Constraint limits are always symmetrical, but joints can be asymmetrical
	// Make the limits symmetrical; map set angles to the actual constraint limits
	hi = class'UnitsConverter'.static.AngleToUU(LimitHigh);
	lo = class'UnitsConverter'.static.AngleToUU(LimitLow);
	trueZero = int((-hi - lo) / 2.0);
	ji.TrueZero = trueZero;
	// Setup joint limits of movement
	// Evidently TwistLimitAngle is in DEGREES!?!?
	tl = class'UnitsConverter'.static.AngleFromUU(hi + trueZero);
	ji.Constraint.ConstraintSetup.TwistLimitAngle = class'UnitsConverter'.static.AngleToDeg(tl);
	// Perform fix to handle asymmetrical joints
	angle = rot(0, 0, 0);
	angle.Pitch = trueZero;
	TempRotatePart(ji, ji.Child, angle, savedLocation, savedRotation);
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	RestoreRotatePart(ji.Child, savedLocation, savedRotation);
	// Enable angular drive position and set the initial drive parameters
	ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, true);
	ji.SetStiffness(1.0);
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
	
	// Update the values to match new target
	angle = rot(0, 0, 0);
	angle.roll = int(value + ji.TrueZero);
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

	jt = RevoluteJoint(ji.Spec);
	// Measure direction depends on spec
	if (jt.InverseMeasure)
		relRot = GetRelativeRotation(ji.Parent.Rotation, ji.Child.Rotation);
	else
		relRot = GetRelativeRotation(ji.Child.Rotation, ji.Parent.Rotation);
	angle = class'UnitsConverter'.static.AngleFromUU(relRot.Pitch);
	// Update angle representation
	if (jt.InverseMeasureAngle)
		angle = -angle;
	ji.CurValue = angle;
}

defaultproperties
{
	MaxForce=50000.0
}
