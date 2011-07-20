/*
 * Propeller - Describes a propeller on an aerial robot.
 */
class PropellerJoint extends Joint config(USAR);

// The side of the robot this joint is on (useful in many cases for symmetrical robots)
enum ESide
{
	SIDE_FrontLeft,
	SIDE_FrontRight,
	SIDE_BackLeft,
	SIDE_BackRight,
	// Default
	SIDE_None
};

// Whether the wheel can be driven
//var bool bIsDriven;
// Whether the wheel can also rotate in the other direction (caster/omni wheels)
//var bool bOmni;
// The maximum speed of the wheel in rads/s
var float MaxVelocity;
// The side of the robot this joint inhabits
var ESide Side;

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji)
{
	local RB_ConstraintSetup setup;
	
	ji = super.Init(ji);
	setup = ji.Constraint.ConstraintSetup;
	setup.bTwistLimited = false;
	setup.bSwingLimited = true; //was false
	setup.Swing1LimitAngle=0;
	setup.Swing2LimitAngle=0;
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	ji.Constraint.ConstraintInstance.SetAngularVelocityDrive(true, true);
        ji.Constraint.SetDisableCollision(true);
	ji.SetStiffness(1.0);
	ji.SetVelocity(0.0);
	// Fix initial-value problem that has some wheels rotated 180 degrees
	Update(ji);
	ji.CurValue = 0.0;
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

	if (target > MaxVelocity) target = MaxVelocity;
	if (target < -MaxVelocity) target = -MaxVelocity;
	vel.X = target;
	vel.Y = 0;
	vel.Z = 0;
	SetAngularVelocity(ji, vel);
}

// Updates the joint item's angle to match the physics system's angle
simulated function Update(JointItem ji)
{
	local rotator relRot;
	local float newVal, retVal, diff, cval1, cval2;

	// Provide full rotation capabilities (beyond the -pi to pi range)
	relRot = GetRelativeRotation(ji.Child.Rotation, ji.Parent.Rotation);
	relRot = class'Utilities'.static.rTurn(
		-1 * class'UnitsConverter'.static.AngleVectorToUU(ji.Spec.Direction), relRot);
	newVal = class'UnitsConverter'.static.AngleFromUU(relRot.Yaw);
	// Assume that the rotation was small enough to not make it all the way around (due to the
	// very high update rate of 50 Hz); then if the angle wrapped around from -pi to pi, then
	// the abs difference will be huge (-2pi or 2pi) but the difference with the negative angle
	// added to 2pi will be smaller
	diff = newVal - ji.OldValue;
	cval1 = diff - 2 * PI;
	cval2 = diff + 2 * PI;
	// Compute which has the least absolute value (3-way minimum), the sign will be right
	retVal = diff;
	if (abs(cval1) < abs(retVal)) retVal = cval1;
	if (abs(cval2) < abs(retVal)) retVal = cval2;
	ji.CurValue += retVal;
	ji.OldValue = newVal;
}

defaultproperties
{
	//bIsDriven=true
	//bOmni=false
	MaxVelocity=6.283
	Side=SIDE_None
}
