/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * FixedJoint - immovable joint used for linking parts
 */
class FixedJoint extends Joint config(USAR);

// Creates and returns a fixed joint between the parent and child
simulated static function Hinge CreateFixJoint(Actor par, Actor chi)
{
	local RB_ConstraintSetup setup;
	local Hinge cons;
	
	cons = par.Spawn(class'Hinge', par, '', par.Location, par.Rotation);
	setup = cons.ConstraintSetup;
	// Cannot set these in default properties, do it here
	setup.LinearXSetup.LimitSize = 0.0;
	setup.LinearYSetup.LimitSize = 0.0;
	setup.LinearZSetup.LimitSize = 0.0;
	// Init constraint and return it
	cons.InitConstraint(par, chi, , , 6000.0);
	cons.ConstraintInstance.SetAngularPositionDrive(false, false);
	cons.ConstraintInstance.SetLinearPositionDrive(false, false, false);
	cons.ConstraintInstance.InitConstraint(par.CollisionComponent, chi.CollisionComponent,
		cons.ConstraintSetup, 1, par, par.CollisionComponent, false);
	return cons;
}

// Configure the JointItem for this joint as an angular joint that can't be moved
reliable server function JointItem Init(JointItem ji)
{
	local RB_ConstraintSetup setup;
	
	ji = super.Init(ji);
	setup = ji.Constraint.ConstraintSetup;
	setup.LinearXSetup.LimitSize = 0.0;
	setup.LinearYSetup.LimitSize = 0.0;
	setup.LinearZSetup.LimitSize = 0.0;
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
	ji.SetStiffness(ji.Spec.Stiffness);
	return ji;
}

// Updates angular drive parameters with the given values
function Recalc(JointItem ji)
{
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(ji.MaxForce * ji.Stiffness,
		ji.Damping, ji.MaxForce * ji.Stiffness);
}

defaultproperties
{
}
