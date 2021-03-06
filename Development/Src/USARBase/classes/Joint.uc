/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Joint - holds non-instance information about a robot joint
 * Runtime data goes in a JointItem instead
 */
class Joint extends Object config(USAR);

// The joint's direction; this should override the former RotateAxis functionality
var vector Direction;
// The child part (moveable relative to the parent)
var Part Child;
// Damping value to apply to joint
var float Damping;
// Default value only (updated value in JointItems) of maximum force (torque)
var float MaxForce;
// Part offset from the robot origin, or relative to
var vector Offset;
// The parent part (fixed relative to the child)
var Part Parent;
// Transforms the joint's location to be relative to this part; cannot be relative to a joint
var Part RelativeTo;
// Default value only (updated value in JointItems) of maximum force (torque)
var float Stiffness;

// Gets the maximum value of this joint (only applies for some joint types)
simulated function float GetMax()
{
	return 0.0;
}

// Gets the minimum value of this joint (only applies for some joint types)
simulated function float GetMin()
{
	return 0.0;
}

// Finds the rotation of MyRotation relative to BaseRotation (convenience)
simulated function rotator GetRelativeRotation(rotator MyRotation, rotator BaseRotation)
{
	local vector X, Y, Z;
	
	GetAxes(MyRotation, X, Y, Z);
	return OrthoRotation(X << BaseRotation, Y << BaseRotation, Z << BaseRotation);
}

// Configure the JointItem for this joint
reliable server function JointItem Init(JointItem ji)
{
	ji.Constraint = SpawnHinge(ji);
	// Don't disable collision again, it was already disabled in default properties...
	ji.CurValue = 0.0;
	ji.MaxForce = MaxForce;
	ji.Spec = self;
	ji.Stiffness = Stiffness;
	ji.Damping = Damping;
	// Cannot set these in default properties, do it here
	ji.Constraint.ConstraintSetup.LinearXSetup.LimitSize = 0.0;
	ji.Constraint.ConstraintSetup.LinearYSetup.LimitSize = 0.0;
	ji.Constraint.ConstraintSetup.LinearZSetup.LimitSize = 0.0;
	return ji;
}

// Set the angular target of a constraint using a rotator (convenience)
simulated function SetAngularTarget(JointItem ji, rotator rot)
{
	local Quat q;
	q = QuatFromRotator(rot);
	ji.Constraint.ConstraintInstance.SetAngularPositionTarget(q);
}

// Set the angular velocity of a constraint using a speed (convenience)
simulated function SetAngularVelocity(JointItem ji, vector velocity)
{
	ji.Constraint.ConstraintInstance.SetAngularVelocityTarget(velocity);
}

// Set the position target of a constraint using a vector (convenience)
simulated function SetLinearTarget(JointItem ji, vector vec) 
{
	ji.Constraint.ConstraintInstance.SetLinearPositionTarget(vec);
}

// Set the velocity target of a constraint using a vector (convenience)
simulated function SetLinearVelocity(JointItem ji, vector vec) 
{
	ji.Constraint.ConstraintInstance.SetLinearVelocityTarget(vec);
}

// Overridden by subclasses to update joint drive parameters
function Recalc(JointItem ji)
{
}

// Overridden by subclasses to move joint to target
function SetTarget(JointItem ji, float target)
{
}

// Overridden by subclasses to move joint at velocity
function SetVelocity(JointItem ji, float velocity)
{
}

// Create the hinge actor for the given joint item
function RB_ConstraintActor SpawnHinge(JointItem ji)
{
	return ji.Spawn(class'Hinge', ji, '', ji.Location, ji.Rotation);
}

// Updates the joint's CurValue to match its physics
simulated function Update(JointItem ji)
{
//	local vector x,y,z;
//	local vector jtOffset;
//	local Rotator jtRotate;
	/*
	//using the child rotation as a base, set the original rotation of each joint and get the transformed world axes
		jtRotate = class'Utilities'.static.rTurn(ji.Child.Rotation, class'UnitsConverter'.static.AngleVectorToUU(Direction));
		GetAxes(jtRotate, x, y, z);
		jtOffset = class'UnitsConverter'.static.MeterVectorToUU(Offset - Child.Offset);
		jtOffset = ji.Child.Location+ (jtOffset<<(-1*ji.Child.Rotation));
		ji.DrawDebugLine(jtOffset, jtOffset + x*200, 255, 0, 0, true);
		ji.DrawDebugLine(jtOffset, jtOffset + y*200, 0, 255, 0, true);
		ji.DrawDebugLine(jtOffset, jtOffset + z*200, 0, 0, 255, true);
	*/
}

defaultproperties
{
	// Much too small for most applications! Here for compatibility only!
	Damping=0.25
	MaxForce=50000.0
	Stiffness=1.0
}
