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

// The type of rotation this joint can complete
enum EJointType
{
	JOINTTYPE_Pitch, // Swing2
	JOINTTYPE_Yaw,   // Swing1
	JOINTTYPE_Roll,  // Twist
	JOINTTYPE_Free,  // Swing and Twist
	JOINTTYPE_Fixed,
};

// The side of the robot this joint is on (useful in many cases for symmetrical robots)
enum ESide
{
	SIDE_Left,
	SIDE_Right,
	SIDE_None
};

// Type of measurement used on the joint
enum EMeasureType
{
	EMEASURE_Pitch,
	EMEASURE_Roll,
	EMEASURE_Yaw,
	EMEASURE_Axis,
	
	EMEASURE_Pitch_RemoveYaw,
	EMEASURE_Yaw_RemoveRoll,
	EMEASURE_Yaw_RemovePitch,
	EMEASURE_Roll_RemovePitch,
	EMEASURE_Roll_RemoveYaw
};

// Specification variables
var vector Angle;
var Part Child;
var bool IsOneDof;
var EJointType JointType;
var float LimitHigh;
var float LimitLow;
// Default value only (updated value in JointItems)
var float MaxForce;
var EMeasureType MeasureType;
var vector Offset;
var Part Parent;
var Part RelativeTo;
// Overrides the default calculated axis
var vector RotateAxis;
var ESide Side;

// The default way of measuring or applying the angles might not match with the defined
// joint of the robot; use these variables to invert them
var bool InverseMeasure;
var bool InverseMeasureAngle;

defaultproperties
{
	MaxForce=50000.0
	side=SIDE_None
	RotateAxis=(X=0,Y=0,Z=0)
}
