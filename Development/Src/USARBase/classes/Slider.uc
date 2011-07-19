/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Slider - Default properties for sliders used in prismatic constraints.
 */
class Slider extends RB_PrismaticActor; 

defaultproperties
{
	bNoDelete=false
	bStatic=false
	bDisableCollision=true
	
	// Default: fixed (angularly) hinge
	Begin Object Class=RB_ConstraintSetup Name=SliderSetup
		bLinearBreakable=false
		bAngularBreakable=false
		bEnableProjection=true
		bSwingLimited=true
		bTwistLimited=true
		Swing1LimitAngle=0.0
		Swing2LimitAngle=0.0
		TwistLimitAngle=0.0
	End Object
	ConstraintSetup=SliderSetup
}
