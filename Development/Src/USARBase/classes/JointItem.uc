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
 * JointItem - the Item subclass added to the array to hold instance properties of a Joint.
 * Fixes bug where shared Joint instances caused multiple robots of the same type to crash.
 */
class JointItem extends Item config(USAR);

// The child item controlled by this joint
var PhysicalItem Child;
// The constraint handling this joint
var Hinge Constraint;
// The angle this joint is currently pointing
var float CurAngle;
// The target where this joint must eventually point
var int CurAngularTarget;
// The maximum force this joint can exert
var float MaxForce;
// The parent item controlled by this joint
var PhysicalItem Parent;
// The specifier which declared this joint
var Joint Spec;
// Joint stiffness
var float Stiffness;
// NOTE: Constraint limits are always symmetrical, but joints can be asymmetrical
// Make the limits symmetrical; map set angles to the actual constraint limits
var int TrueZero;

// Clean up the constraints when this joint dies
simulated event Destroyed()
{
	Constraint.Destroy();
}

// Gets the name of the parent joint
simulated function name GetJointName()
{
	return Spec.Name;
}

// Convenience function to check whether this Item is actually a joint
simulated function bool IsJoint()
{
	return true;
}

// Checks to see if the contained joint is of the specified type
simulated function bool JointIsA(name theType)
{
	return Spec.isA(theType);
}

defaultproperties
{
	// Collision properties
	BlockRigidBody=false
	bBlockActors=false
	bCollideActors=false
	bCollideWorld=false
	bPathColliding=false
	bProjTarget=false
	bCollideWhenPlacing=false
	
	MaxForce=50000.0
	Physics=PHYS_None
}