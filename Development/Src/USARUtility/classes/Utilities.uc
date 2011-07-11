/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 *   Utils.uc
 *   author: Chris Scrapper
 *   brief: Utility class for USARSim. 
 *
 *   This class contains multiple utility functions:
 *   gaussRand - Gaussian random number generator given a mean and standard deviation
 *   tokenizer - returns a dynamic array of string tokens.  Takes a string of args 
 *               and a string that specifies the delimiter.
 */
class Utilities extends Object config(USARBot);

// Persistent variables needed for gaussRand function
var float y2;
var bool use_last;
// PhysX DLL proxy instance
var const PhysXProxy PhysXProxyInstance;

// Generates Gaussian random number given a mean and a standard deviation(sigma)
// Uses Box-Muller method
simulated function float gaussRand(float mean, float sigma)
{
	local float x1, x2, w, y1;
	
	w = 1.0;
	x1 = 0.0;
	x2 = 0.0;
	y1 = 0.0;
	if (sigma == 0)
		return 0;
	if (use_last)
	{
		y1 = y2;
		use_last = false;
	}
	else
	{
		while (w >= 1.0)
		{
			x1 = 2.0 * FRand() - 1.0;
			x2 = 2.0 * FRand() - 1.0;
			w = x1 * x1 + x2 * x2;
		}
		w = sqrt((-2.0 * Loge(w)) / w);
		y1 = x1 * w;
		y2 = x2 * w;
		use_last = true;
	}
	return mean + y1 * sigma;
}

// Gets the relative position between a part and its parent
static function vector GetRelativePosition(vector ChildPosition, vector ParentPosition,
	rotator ParentOrientation)
{
	local vector res, Forward, Right, Upward, Dif;

	// Find the parent's orientation
	if (ParentOrientation == rot(0, 0, 0))
	{
		Forward = vect(1, 0, 0);
		Right = vect(0, 1, 0);
		Upward  = vect(0, 0, -1);
	}
	else
	{
		Forward = (Vect(1, 0, 0) >> ParentOrientation);
		Right = (Vect(0, 1, 0) >> ParentOrientation);
		Upward  = (Vect(0, 0, -1) >> ParentOrientation);
	}

	// Project to the parent's coordinate
	dif = ChildPosition - ParentPosition;
	res.X = Dif Dot Forward;
	res.Y = Dif Dot Right;
	res.Z = Dif Dot Upward;
	res = class'UnitsConverter'.static.LengthVectorFromUU(res);

	return res;
}

// Converts a string like "1.2,45.3,7.8" to a vector
static final function vector ParseVector(String vstring)
{
	local vector v;
	local int i;

	v = vect(0, 0, 0);
	if (vstring != "")
	{
		i = InStr(vstring, ",");
		v.X = float(left(vstring, i));
		vstring = mid(vstring, i + 1);
		i = InStr(vstring, ",");
		v.Y = float(left(vstring, i));
		v.Z = float(mid(vstring, i + 1));
	}
	return v;
}

// Converts a string like "1.2,45.3,7.8" to a rotator
static final function rotator ParseRotator(String vstring)
{
	return rotator(ParseVector(vstring));
}

// Generates a turn in object coordinates. Handles gymbal lock issues.
static function rotator rTurn(rotator rHeading, rotator rTurnAngle)
{
	local vector vForward, vRight, vUpward;
	local vector vForward2, vRight2, vUpward2;
	local rotator T;
	local vector V;

	GetAxes(rHeading, vForward, vRight, vUpward);
	// Rotate in plane that contains vForward & vRight
	T.Yaw = rTurnAngle.Yaw;
	V = vector(T);
	vForward2 = V.X * vForward + V.Y * vRight;
	vRight2 = V.X * vRight - V.Y * vForward;
	vUpward2 = vUpward;

	// Rotate in plane that contains vForward & vUpward
	T.Yaw = rTurnAngle.Pitch;
	V = vector(T);
	vForward = V.X * vForward2 + V.Y * vUpward2;
	vRight = vRight2;
	vUpward = V.X * vUpward2 - V.Y * vForward2;

	// Rotate in plane that contains vUpward & vRight
	T.Yaw = rTurnAngle.Roll;
	V = vector(T);
	vForward2 = vForward;
	vRight2 = V.X * vRight + V.Y * vUpward;
	vUpward2 = V.X * vUpward - V.Y * vRight;
	return OrthoRotation(vForward2, vRight2, vUpward2);
}

// Enables or disables contact point generation between two actors
static final function SetActorPairIgnore(RB_BodyInstance body1, RB_BodyInstance body2,
	bool ignore)
{
	default.PhysXProxyInstance.SetActorPairIgnore(body1, body2, ignore);
}

// Sets the solver iteration count for the body. 
// The solver iteration count determines how accurately joints and contacts are resolved. 
// If you are having trouble with jointed bodies oscillating and behaving erratically, then
// setting a higher solver iteration count may improve their stability. (PhysX docs)
static final function SetIterationSolverCount(RB_BodyInstance instance, int iterCount)
{
	default.PhysXProxyInstance.SetIterationSolverCount(instance, iterCount);
}

// Retrieves the inertia tensor of the given rigid body; Return values are small!
static final function Vector GetMassSpaceInertiaTensor(RB_BodyInstance instance)
{
	return default.PhysXProxyInstance.GetMassSpaceInertiaTensor(instance);
}

static final function SetMassSpaceInertiaTensor(RB_BodyInstance instance, Vector InertiaTensor)
{
	default.PhysXProxyInstance.SetMassSpaceInertiaTensor(instance, InertiaTensor);
}

static final function float GetSolverExtrapolationFactor(RB_ConstraintInstance instance)
{
	return default.PhysXProxyInstance.GetSolverExtrapolationFactor(instance);
}

// Extrapolation factor for solving joint constraints. (PhysX docs)
// This parameter can be used to build stronger joints and increase the solver convergence. Higher values
// lead to stronger joints.
// note Setting the value too high can decrease the joint stability.
// note Currently, this feature is supported for D6, Revolute and Spherical Joints only.
static final function SetSolverExtrapolationFactor(RB_ConstraintInstance instance, float SolverExtrapolationFactor)
{
	default.PhysXProxyInstance.SetSolverExtrapolationFactor(instance, SolverExtrapolationFactor);
}

// Adjusts the mass of the specified item to match reality (takes mass in UU)
static function SetMass(DynamicSMActor act, float DesiredMass)
{
	local float oldScale, oldMass;
	local RB_BodySetup bs;
	
	// Change auto calculated mass to the desired mass
	DesiredMass = class'UnitsConverter'.static.MassToUU(DesiredMass);
	bs = act.StaticMeshComponent.StaticMesh.BodySetup;
	oldMass = act.StaticMeshComponent.BodyInstance.GetBodyMass();
	oldScale = bs.MassScale;
	if (oldMass > 0.0 && oldScale > 0.0)
	{
		bs.MassScale = DesiredMass / (oldMass / oldScale);
		act.StaticMeshComponent.BodyInstance.UpdateMassProperties(bs);
	}
}

// Parses a string of arguments into tokens. The tokens are split by the specified delimiter.
// Returns a dynamic array of strings
static final function array<String> tokenizer(String argStr, optional String delim)
{
	local int i;
	local int count;
	local array<String> opt;

	if (delim == "")
		delim = ",";
	count = 0;
	if (argStr != "")
		do
		{
			opt.Length = count + 1;
			i = InStr(argStr, delim);
			if (i == -1)
				opt[count] = argStr;
			else
			{
				opt[count] = Left(argStr, i);
				argStr = mid(argStr, i + 1);
			}
			count++;
		} until (i == -1);
	return opt;
}

// Trims characters from a string
static final function String Trim(coerce String S, optional String delim)
{
	S = TrimLeft(S, delim);
	S = TrimRight(S, delim);
	return S;
}

// Trims characters from the leading end of a string
static final function String TrimLeft(coerce String S, optional String delim)
{
	local int size;

	size = Len(S);
	if (delim == "")
		delim = " ";

	while (Left(S, 1) == delim)
		S = Right(S, --size);
	return S;
}

// Trims characters from the trailing end of a string
static final function String TrimRight(coerce String S, optional String delim)
{
	local int size;

	size = Len(S);
	if (delim == "")
		delim = " ";

	while (Right(S, 1) == delim)
		S = Left(S, --size);
	return S;
}

// Sets default values of persistent variables
defaultproperties
{
	use_last=true
	y2=0.0
	
	// PhysXProxy Instance
	Begin Object Class=PhysXProxy Name=SingletonPhysXProxy
	End Object
	PhysXProxyInstance=SingletonPhysXProxy
}
