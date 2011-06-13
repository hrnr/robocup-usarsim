/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Wheel - Describes a wheel on the robot.
 */
class WheelJoint extends Joint config(USAR);

var bool bIsDriven;
var bool bIsSteered;

defaultproperties
{
	bIsDriven=true
	bIsSteered=false
}
