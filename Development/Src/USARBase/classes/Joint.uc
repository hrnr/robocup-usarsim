/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class Joint extends Object config(USAR);

enum EJointType
{
	JOINTTYPE_Pitch, // Swing2
	JOINTTYPE_Yaw,   // Swing1
	JOINTTYPE_Roll,  // Twist
	JOINTTYPE_Free,  // Swing and Twist
	JOINTTYPE_Fixed,
};

enum ESide
{
	SIDE_LEFT,
	SIDE_RIGHT,
	SIDE_NONE,
};

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

var EMeasureType MeasureType;
var EJointType JointType;
var bool IsOneDof;
var PhysicalItem Parent;
var PhysicalItem Child;
var PhysicalItem RelativeTo;
var vector Offset; // In meters
var vector Angle;  // In degrees
var float MaxForce;
var float LimitHigh;
var float LimitLow;

// The default way of measuring or applying the angles might not match with the defined
// joint of the robot. Use these variables to inverse them.
var bool InverseMeasure;
var bool InverseMeasureAngle;

// These options override the default calculated axis
var vector RotateAxis;

// Instance data
var float Stiffness;
var int TrueZero;
var BasicHinge Constraint;
var int CurAngularTarget;
var float CurAngle;
var ESide side;

defaultproperties
{
	MaxForce=50000;
	side=SIDE_NONE;
	RotateAxis=(X=0, Y=0, Z=0);
}
