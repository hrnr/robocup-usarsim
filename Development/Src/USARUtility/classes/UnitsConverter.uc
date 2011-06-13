/*****************************************************************************
	DISCLAIMER:
	This software was produced in part by the National Institute of Standards
	and Technology (NIST), an agency of the U.S. government, and by statute is
	not subject to copyright in the United States.	Recipients of this software
	assume all responsibility associated with its operation, modification,
	maintenance, and subsequent redistribution.

	See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * UnitsConverter: utility class which converts angles and lengths to and from Unreal units
 */
class UnitsConverter extends Object config(USAR);

/*
 * The UU coordinate system axes are oriented left-handed, with
 * rotations about the X and Y axes in the right-handed sense, rotations
 * about the Z axis in the left-handed sense. 

 * Converting between pure LH- and RH coordinate systems is done by
 * negating Z values and negating rotations about X and Y. Converting
 * between UU's hybrid coordinate systems is accomplished by simply
 * negating Z values.
 */

// Meters <-> UU
var config float C_MeterToUU;

// Angles <-> UU
var config float C_AngleToDegree;
var config float C_AngleToURot;

// Decibels <-> UU
var config float C_DecibelsToUU;

// Kilograms <-> UU
var config float C_MassToUU;

// Right hand or left hand coordinate system
var config bool RightHand;

// Precision of numbers when converting to string by default
var config int NumberPrecision;

// Converts a floating point value to a string with the specified precision
static final function String FloatString(float Value, optional int Precision)
{
	local int IntPart;
	local float FloatPart;
	local String IntString, FloatString;

	// Set number precision
	if (Precision == 0)
		Precision = Default.NumberPrecision; // 4
	else
		Precision = Max(Precision, 1);

	// Negative number handling
	if (Value < 0) {
		IntString = "-";
		Value *= -1;
	}

	// Find integral and fractional parts
	IntPart = int(Value);
	FloatPart = Value - IntPart;
	IntString = IntString $ String(IntPart);
	FloatString = String(int(FloatPart * (10 ** Precision)));
	
	// Prepend zeroes to match
	while (Len(FloatString) < Precision)
		FloatString = "0" $ FloatString;
	
	return IntString $ "." $ FloatString;
}

// Converts a 3D vector to a string
static final function String VectorString(vector vec, optional int Precision)
{
	return FloatString(vec.X, Precision) $ "," $ FloatString(vec.Y, Precision) $ "," $
		FloatString(vec.Z, Precision);
}

// Converts a 3D rotator to a string
static final function String RotatorString(rotator vec, optional int Precision) {
	return FloatString(vec.Roll, Precision) $ "," $ FloatString(vec.Pitch, Precision) $ "," $
		FloatString(vec.Yaw, Precision);
}

// String version of LengthFromUU
static final function String Str_LengthFromUU(float uu,	optional int Precision)
{
	return FloatString(LengthFromUU(uu), Precision);
}

// String version of SpeedFromUU
static final function String Str_SpeedFromUU(float uu, optional int Precision)
{
	return FloatString(SpeedFromUU(uu), Precision);
}

// String version of AngleVectorFromUU
static final function String Str_AngleVectorFromUU(rotator rot, optional int Precision)
{
	return VectorString(AngleVectorFromUU(rot), Precision);
}

// String version of AngleFromUU
static final function String Str_AngleFromUU(int uu, optional int Precision)
{
	return FloatString(AngleFromUU(uu), Precision);
}

// String version of AngleFromDeg
static final function String Str_AngleFromDeg(int deg, optional int Precision)
{
	return FloatString(AngleFromDeg(deg), Precision);
}

// String version of SoundLevelFromUU
static final function String Str_SoundLevelFromUU(float uu, optional int Precision)
{
	return FloatString(SoundLevelFromUU(uu), Precision);
}

// String version of SpinSpeedFromUU
static final function String Str_SpinSpeedFromUU(int uu, optional int Precision)
{
	return FloatString(SpinSpeedFromUU(uu), Precision);
}

// String version of DeprecatedRotatorFromUU
static final function String Str_DeprecatedRotatorFromUU(rotator rot, optional int Precision)
{
	return VectorString(DeprecatedRotatorFromUU(rot), Precision);
}

// String version of LengthVectorFromUU
static final function String Str_LengthVectorFromUU(vector vec, optional int Precision) {
	return VectorString(LengthVectorFromUU(vec), Precision);
}

// String version of VelocityVectorFromUU
static final function String Str_VelocityVectorFromUU(vector vec, optional int Precision) {
	return VectorString(VelocityVectorFromUU(vec), Precision);
}

// Converts mass from UU to SI (g)
static final function float MassFromUU(float uu)
{
	return uu / default.C_MassToUU;
}

// Converts mass from SI (g) to UU
static final function float MassToUU(float g)
{
	return g * default.C_MassToUU;
}

// Converts length from UU to SI (m)
static final function float LengthFromUU(float uu)
{
	return uu / default.C_MeterToUU;
}

// Converts length from SI (m) to UU
static final function float LengthToUU(float m)
{
	return m * default.C_MeterToUU;
}

// Converts velocity from UU to SI (m/s)
static final function float SpeedFromUU(float uu)
{
	return uu / default.C_MeterToUU;
}

// Converts velocity from SI (m/s) to UU
static final function float SpeedToUU(float m)
{
	return m * default.C_MeterToUU;
}

// Converts angle from UU to SI (rad)
static final function float AngleFromUU(int uu)
{
	return uu / default.C_AngleToURot;
}

// Converts angle from SI (rad) to UU
static final function int AngleToUU(float rad)
{
	return int(rad * default.C_AngleToURot);
}

// Converts angle from UU to degrees
static final function float AngleFromDeg(int deg)
{
	return deg / default.C_AngleToDegree;
}

// Converts angle from degrees to UU
static final function int AngleToDeg(float rad)
{
	return int(rad * default.C_AngleToDegree);
}

// Converts sound level from UU to SI (dB)
static final function int SoundLevelFromUU(float uu)
{
	return int(uu / default.C_DecibelsToUU);
}

// Converts sound level from SI (dB) to UU
static final function float SoundLevelToUU(int level)
{
	return level * default.C_DecibelsToUU;
}

// Converts angular velocity from UU to SI (rad/s)
static final function float SpinSpeedFromUU(int uu)
{
	return uu / default.C_AngleToURot;
}

// Converts angular velocity from SI (rad/s) to UU
static final function int SpinSpeedToUU(float rad)
{
	return int(rad * default.C_AngleToURot);
}

// Converts an angle vector to an Unreal rotator
static final function rotator DeprecatedRotatorToUU(vector vec)
{
	local vector v;
	local rotator rot;
	v = DeprecatedRotatorVectorToUU(vec);
	rot.Roll = v.X;
	rot.Pitch = v.Y;
	rot.Yaw = v.Z;
	return rot;
}

// Converts an Unreal rotator to an angle vector
static final function vector DeprecatedRotatorFromUU(rotator rot)
{
	local vector vec;
	
	// Convert components
	vec.x = rot.Roll / default.C_AngleToURot;
	vec.y = rot.Pitch / default.C_AngleToURot;
	vec.z = rot.Yaw / default.C_AngleToURot;
	return vec;
}

// Converts an angle vector to an Unreal vector (not a rotator)
static final function vector DeprecatedRotatorVectorToUU(vector vec)
{
	local vector v;
	
	// Convert components
	v.X = vec.X * default.C_AngleToURot;
	v.Y = vec.Y * default.C_AngleToURot;
	v.Z = vec.Z * default.C_AngleToURot;
	return v;
}

// Converts an Unreal angle vector to a radian angle vector
static final function vector DeprecatedRotatorVectorFromUU(vector vec)
{
	local vector v;
	
	// Convert components
	v.X = vec.X / default.C_AngleToURot;
	v.Y = vec.Y / default.C_AngleToURot;
	v.Z = vec.Z / default.C_AngleToURot;
	return v;
}

// Converts an Unreal length vector to a meter vector
static final function vector LengthVectorFromUU(vector vec)
{
	local vector res;
	
	// Convert components
	res.X = vec.X / default.C_MeterToUU;
	res.Y = vec.Y / default.C_MeterToUU;
	res.Z = vec.Z / default.C_MeterToUU;
	
	// Account for right-hand system
	if (default.RightHand)
		res.Z = -res.Z;
	return res;
}

// Converts a meter vector to an Unreal length vector
static final function vector LengthVectorToUU(vector vec)
{
	local vector res;
	
	// Convert components
	res.X = vec.X * default.C_MeterToUU;
	res.Y = vec.Y * default.C_MeterToUU;
	res.Z = vec.Z * default.C_MeterToUU;
	
	// Account for right-hand system
	if (default.RightHand)
		res.Z = -res.Z;
	return res;
}

// Converts an Unreal velocity vector to a velocity vector
static final function vector VelocityVectorFromUU(vector vec) {
	local vector res;
	
	// Convert components
	res.X =	vec.X / default.C_MeterToUU;
	res.Y =	vec.Y / default.C_MeterToUU;
	res.Z =	vec.Z / default.C_MeterToUU;
	
	// Account for right-hand system
	if (default.RightHand)
		res.Z = -res.Z;
	return res;
}

// Converts a velocity vector to an Unreal velocity vector
static final function vector VelocityVectorToUU(vector vec) {
	local vector res;
	
	// Convert components
	res.X =	vec.X * default.C_MeterToUU;
	res.Y =	vec.Y * default.C_MeterToUU;
	res.Z =	vec.Z * default.C_MeterToUU;
	
	// Account for right-hand system
	if (default.RightHand)
		res.Z = -res.Z;
	return res;
}

// Converts a meter vector to an Unreal position vector
static final function vector MeterVectorToUU(vector vec) {
	local vector res;
	
	// Convert components
	res.X =	vec.X * default.C_MeterToUU;
	res.Y =	vec.Y * default.C_MeterToUU;
	res.Z =	vec.Z * default.C_MeterToUU;
	
	// Account for right-hand system
	if (default.RightHand)
		res.Z = -res.Z;
	return res;
}

// Converts an Unreal rotator to an angle vector
static final function vector AngleVectorFromUU(rotator rot)
{
	local vector rpy;

	rpy.x = AngleFromUU(rot.roll);
	rpy.y = AngleFromUU(rot.pitch);
	rpy.z = AngleFromUU(rot.yaw);

	return rpy;
}

// Converts a radian angle vector to an Unreal rotator
static final function rotator AngleVectorToUU(vector rpy)
{
	local rotator rot;

	rot.roll = AngleToUU(rpy.x);
	rot.pitch = AngleToUU(rpy.y);
	rot.yaw = AngleToUU(rpy.z);

	return rot;
}

// Converts a vector to a rotator with NO unit conversion
static final function rotator AngleVectorToRotator(vector rpy)
{
	local rotator rot;

	rot.roll = rpy.x;
	rot.pitch = rpy.y;
	rot.yaw = rpy.z;

	return rot;
}

// Converts a vector to a rotator with NO unit conversion
static final function vector AngleRotatorToVector(rotator rot)
{
	local vector rpy;

	rpy.x = rot.roll;
	rpy.y = rot.pitch;
	rpy.z = rot.yaw;

	return rpy;
}

// Normalizes angle in radians between [0, 2pi], where positive rotation is clockwise. Works on any value.
static final function float normRad_ZeroTo2PI(float rads)
{
	local float nRads;

	// First bound to (-2pi,2pi) and then move negative angles to position
	nRads = rads % (2 * pi);
	if (nRads < 0)
		nRads += 2 * PI;
	return nRads;
}

// Finds the difference between two angles in radians, where positive rotation is clockwise.
static final function float diffAngle(float a, float b)
{
	local float diff;

	// Find normalized difference
	diff = normRad_ZeroTo2PI(a) - normRad_ZeroTo2PI(b);

	// Sign the difference
	if (diff >= pi) {
		diff = pi - (diff % pi);
		diff = -1 * diff;
	} else if (diff <= -pi)
		diff = pi - (Abs(diff) % pi);
	return diff;
}

// Returns the conversion factor from angles to degrees.
static final function float getC_AngleToDegree()
{
	return default.C_AngleToDegree;
}

defaultproperties
{
}
