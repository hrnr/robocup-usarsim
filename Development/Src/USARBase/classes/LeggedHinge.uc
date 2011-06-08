/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class LeggedHinge extends BasicHinge config(USAR);

defaultproperties
{
	Begin Object Class=RB_ConstraintSetup Name=HingeSetup
		bSwingLimited=true;
		bTwistLimited=true;

		LinearBreakThreshold=10000000000.0
		AngularBreakThreshold=10000000000.0
	End Object
	
	ConstraintSetup=HingeSetup
}
