/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class Hinge extends RB_HingeActor; 

defaultproperties
{
	bNoDelete=false
	bStatic=false
	bDisableCollision=true

	Begin Object Class=RB_ConstraintSetup Name=HingeSetup
		bSwingLimited=true
		bTwistLimited=false

		LinearBreakThreshold=10000000000.0
		AngularBreakThreshold=10000000000.0
	End Object
	ConstraintSetup=HingeSetup
	Begin Object Name=MyConstraintInstance
		bAngularSlerpDrive=true
	End Object
}
