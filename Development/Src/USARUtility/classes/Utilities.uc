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

// persistent variables needed for gaussRand function
var float y2;
var bool use_last;

/*
 *  Generates Gaussian distribution of random numbers given a mean
 *  and a standard deviation(sigma).  Uses Box-Muller method
 */
simulated function float gaussRand(float mean, float sigma) {
       local float x1, x2, w, y1;
       w =1.0;
       x1=0.0;
       x2=0.0;
       y1=0.0;

       if( sigma == 0 )
           return 0;

       if( use_last )
       {
           y1 = y2;
           use_last=false;
       }
       else
       {
           while (w >= 1.0)
           {
                 x1 = 2.0 * FRand() - 1.0;
                 x2 = 2.0 * FRand() - 1.0;
                 w = x1 * x1 + x2 * x2;
           }

           w = sqrt( (-2.0 * Loge(w))/w);
           y1 = x1 * w;
           y2 = x2 * w;
           use_last=true;
       }
       return (mean + y1 * sigma);
}

/*
 *  Parses a string of arguments into tokens.  The tokens are split
 *  by the delimiter specified by delim.
 *  Returns a dynamic array of string.
 */
static final function array<string> tokenizer(string argStr, string delim)
{
    local int i;
    local int count;
//    local bool rVal;
    local array<string> opt;

//    rVal=false;
    count = 0;

    if( argStr != "" )
    {
//        rVal=true;
        do
        {
            opt.Length=count+1;
            i=InStr(argStr,",");
    	    if( i == -1 )
                opt[count]=argStr;
            else
            {
                 opt[count]=Left(argStr,i);
                 argStr = mid(argStr,i+1);
            }
            count++;
         } until ( i == -1 );
    }
    return opt;
}

static final function string TrimLeft(coerce string S, optional string delim)
{
    local int size;

    size = Len(S);
    if(delim == "")
        delim = " ";

    while (Left(S, 1) == delim)
        S = Right(S, --size);
    return S;
}

static final function string TrimRight(coerce string S, optional string delim)
{
    local int size;

    size = Len(S);
    if(delim == "")
        delim = " ";

    while (Right(S, 1) == delim)
        S = Left(S, --size);
    return S;
}

static final function string Trim(coerce string S, optional string delim)
{
	S=TrimLeft(S,delim);
	S=TrimRight(S,delim);
    return S;
}

// converts a string like "1.2,45.3,7.8" to a vector
static final function vector ParseVector(string vstring)
{
	local vector v;
    local int i;
	v = vect(0,0,0);
	if (vstring!="")
	{
        i = InStr(vstring,",");
        v.X = float(left(vstring,i));
        vstring = mid(vstring,i+1);
        i = InStr(vstring,",");
        v.Y = float(left(vstring,i));
        v.Z = float(mid(vstring,i+1));
	}
	return v;
}

// converts a string like "1.2,45.3,7.8" to a rotator
static final function rotator ParseRotator(string vstring)
{
	return rotator(ParseVector(vstring));
}

/*
 * Generate a turn in object coordinates.
 * Handles gymbal lock issues.
 */
static function rotator rTurn(rotator rHeading,rotator rTurnAngle)
{
    local vector vForward,vRight,vUpward;
    local vector vForward2,vRight2,vUpward2;
    local rotator T;
    local vector  V;

    GetAxes(rHeading,vForward,vRight,vUpward);
    //  rotate in plane that contains vForward&vRight
    T.Yaw=rTurnAngle.Yaw; V=vector(T);
    vForward2=V.X*vForward + V.Y*vRight;
    vRight2=V.X*vRight - V.Y*vForward;
    vUpward2=vUpward;

    // rotate in plane that contains vForward&vUpward
    T.Yaw=rTurnAngle.Pitch; V=vector(T);
    vForward=V.X*vForward2 + V.Y*vUpward2;
    vRight=vRight2;
    vUpward=V.X*vUpward2 - V.Y*vForward2;

    // rotate in plane that contains vUpward&vRight
    T.Yaw=rTurnAngle.Roll; V=vector(T);
    vForward2=vForward;
    vRight2=V.X*vRight + V.Y*vUpward;
    vUpward2=V.X*vUpward - V.Y*vRight;

    T=OrthoRotation(vForward2,vRight2,vUpward2);

   return(T);
}

/*
 * Get the relative position between a part and its parent
 */
function vector getRelativePosition(vector ChildPosition, vector ParentPosition, rotator ParentOrientation)
{
    local vector res, Forward, Right, Upward, Dif;

    // Find the parent's orientation
    if (ParentOrientation == Rot(0,0,0))
    {
        Forward = vect(1,0,0);
        Right   = vect(0,1,0);
        Upward  = vect(0,0,-1);
    }
    else
    {
        Forward = (Vect(1,0,0) >> ParentOrientation);
        Right   = (Vect(0,1,0) >> ParentOrientation);
        Upward  = (Vect(0,0,-1) >> ParentOrientation);
    }

    // Project to the parent's coordinate
    dif = ChildPosition - ParentPosition;
    res.X = Dif Dot Forward;
    res.Y = Dif Dot Right;
    res.Z = Dif Dot Upward;
    
    res = res / 250;

    return res;
}

/*
 * Function that returns the current steering angle of a KCarWheelJoint
 
simulated function int getSteerAngleOfKCarWheelJoint(KCarWheelJoint WheelJ)
{
	local Quat curQ;
	local Vector axis11, axis12, axis21, axis22;
	local Quat relQ2;
	local Vector newAxis12;
	local float difCos2, difSign2;
	local int curAng2;

	curQ = WheelJ.KConstraintActor1.KGetRBQuaternion();
	axis11 = QuatRotateVector(curQ,WheelJ.KPriAxis1);
	axis12 = QuatRotateVector(curQ,WheelJ.KSecAxis1);

	curQ = WheelJ.KConstraintActor2.KGetRBQuaternion();
	axis21 = QuatRotateVector(curQ,WheelJ.KPriAxis2);
	axis22 = QuatRotateVector(curQ,WheelJ.KSecAxis2);

	relQ2 = QuatFindBetween(axis11,axis21);
	newAxis12 = QuatRotateVector(relQ2,axis12);

	difCos2 = newAxis12 Dot axis22;
	if (difCos2>1.0) difCos2 = 1.0;
	if (difCos2<-1.0) difCos2 = -1.0;

	difSign2 = (axis22 Cross newAxis12) Dot axis21;
	if (difSign2<0) difSign2=-1.0;
	else difSign2=1.0;

	curAng2 = difSign2 * ACos(difCos2)*32768/PI;

	return curAng2;
}*/

// Sets default values of persistent variables.
defaultproperties
{
    use_last=true;
    y2=0.0;
}
