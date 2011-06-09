/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

// BUMPER ARRAY SENSOR
// Creates an arc of "touch" sensors that can act as one bumper sensor
// This class is basically the same as the USARSim-2004 BumperArray class
// 
// Based on   : iRobot-RB-Iro-9740
// Ported by  : Kaveh team, Mehdi Karamnejad - Majid Yasari
// Bug report : majid.yasari@gmail.com

class BumperArray extends Sensor config (USAR);

const sensorCount = 20;
const URotToRadian = 0.000095873799;

// Config variables that can be changed in USARBot.ini
// Variables for each individual sensor on the bumper
var config float Diameter;
var config float TouchRange;
var config float ScanStep;
var config float PointsPerCircle;
var config bool bDrawLines;

// Information about the arc of sensors (Angles must be given in rads)(Radius must be in meters)
var config float arcAngle;
var config float arcRadius;
var config float arcPitch;
var config float arcYaw;
var config float arcRoll;

var vector sensorLocations[sensorCount];
var float uuRadius;
var int nCircles;
var float CircleStep;
var bool pointsInit;
var() String testmsg;

// convert all variables of this object read from the UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{
	super.ConvertParam(); // first convert parent object
	uuRadius= class'UnitsConverter'.static.LengthToUU(Diameter) / 2;
	nCircles = int(uuRadius / ScanStep)+1;
	CircleStep = 2 * pi / PointsPerCircle;
	TouchRange = class'UnitsConverter'.static.LengthToUU(TouchRange);
	ScanStep = class'UnitsConverter'.static.LengthToUU(ScanStep);	
}

// Returns a rotated vector of the input vector rotated by the rotator r
// Uses matrix rotation using the pitch,yaw,roll used by unreal
// The input vectors are assumed to exist in a space with the z axis is positive up
// (The returned vector puts the z axis positive down to work with unreal)
function vector vectRotate(vector v, rotator r)
{
	local float cR;
	local float cP;
	local float cY;
	local float sR;
	local float sP;
	local float sY;
	local vector newVect;

	cR = cos(r.Roll	* (pi / 32768));
	cP = cos(r.Pitch * (pi / 32768));
	cY = cos(r.Yaw * (pi / 32768));

	sR = sin(r.Roll * (pi / 32768));
	sP = sin(r.Pitch * (pi / 32768));
	sY = sin(r.Yaw * (pi / 32768));

	// Calculations assume roll is on the x axis, yaw on the z axis, and pitch is on the y axis
	newVect.X = v.X*(cY*cP) + v.Y*(-sY*cR + cY*sP*sR) + v.Z*(sY*sR + cY*sP*cR);
	newVect.Y = v.X*(sY*cP) + v.Y*(cY*cR + sY*SP*sR) + v.Z*(-cY*sR + sY*sP*cR);
	newVect.Z = -(v.X*(-sP) + v.Y*(cP*sR) + v.Z*(cP*cR));

	return newVect;
}

// Creates the sensor locations in an arc at a given radius from the location of the bumperArray sensor
function createTouchLocations()
{
	local float i;
	local float arcAngleStart;
	local float arcAngleEnd;
	local rotator r;

	r.Pitch = class'UnitsConverter'.static.AngleToUU(arcPitch);
	r.Roll = class'UnitsConverter'.static.AngleToUU(arcRoll);
	r.Yaw = class'UnitsConverter'.static.AngleToUU(arcYaw);
	arcAngleStart = arcAngle / 2;
	arcAngleEnd = -(arcAngle / 2);
	if (bDebug)
		LogInternal("Creating Bumper Array Arc");
	
	// Create the arc
	for(i = 0; i < sensorCount; i += 1.0){
		sensorLocations[i].X = class'UnitsConverter'.static.LengthToUU(arcRadius) *
			cos(arcAngleStart + (i / (sensorCount - 1)) * (arcAngleEnd - arcAngleStart));
		sensorLocations[i].Y = class'UnitsConverter'.static.LengthToUU(arcRadius) *
			sin(arcAngleStart + (i / (sensorCount - 1)) * (arcAngleEnd - arcAngleStart));
		sensorLocations[i].Z = 0.0;
		if (bDebug)
			LogInternal(" Sensor #" $ i $ " has coords BEFORE ROT: " $ sensorLocations[i]);
		sensorLocations[i] = vectRotate(sensorLocations[i], r);
		sensorLocations[i].Z *= -1.0;
		if (bDebug)
			LogInternal(" Sensor #" $ i $ " has coords AFTER ROT :" $ sensorLocations[i]);
	}
	pointsInit = true;
}

simulated event Destroyed()
{
	if (bDrawLines)
		FlushPersistentDebugLines();
	super.Destroyed();
}

function bool isTouch()
{
	local vector HitLocation, HitNormal;
	local actor Bumper;
	local vector RotX, RotY, RotZ;
	local rotator curRot;
	local vector startVec;
	local int i, j, s;
	local vector tempSensorLoc;
	local vector lineStart;

	if (!pointsInit)
		createTouchLocations();
	curRot = Rotation;
	startVec = Location;
	GetAxes(Rotation, RotX, RotY, RotZ);
	if (bDrawLines)
		FlushPersistentDebugLines();
	
	for (s = 0; s < sensorCount; s++)
	{
		// Code for detecting touch borrowed from touchsensor.u (some modifications have been made for this sensor)
		tempSensorLoc = vectRotate(sensorLocations[s],curRot);
		startVec = Location + tempSensorLoc;
		Bumper = Trace(HitLocation, HitNormal, startVec + touchRange * (tempSensorLoc /
			VSize(tempSensorLoc)), startVec, true);
		if (bDrawLines)
			DrawDebugLine(lineStart, startVec + touchRange * (tempSensorLoc /
				VSize(tempSensorLoc)), 0, 255, 0, true);																
		if (Bumper != None)
		{
			if (bDebug)
				LogInternal("Bumper Array["$s$"] bumped with "$Bumper);
			return true;
		}

		// Detect along the circle from the edge to the center with step ScanStep
		for (i = 0; i < nCircles; i++)
			for (j = 0; j < PointsPerCircle; j++)
			{
				startVec = Location + tempSensorLoc + uuRadius * cos(j * CircleStep) * RotY +
					uuRadius * sin(j * CircleStep) * RotZ;
				Bumper = Trace(HitLocation, HitNormal, startVec + touchRange * (tempSensorLoc /
					VSize(tempSensorLoc)), startVec, true);															 
				if (bDrawLines)
					DrawDebugLine(lineStart, startVec + touchRange * (tempSensorLoc /
						VSize(tempSensorLoc)), 0, 0, 255, true);																
				if (Bumper != None)
				{
					if (bDebug)
						LogInternal("Bumper Array["$s$"] bumped with "$Bumper);
					return true;
				}
			}
	}
	return false;
}

function String GetData()
{
	return "{Name " $ ItemName $ " Touch " $ isTouch() $ "}";
}

simulated function ClientTimer()
{
	MessageSendDelegate(GetHead() @ GetData());
}

simulated function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{Diameter " $ class'UnitsConverter'.static.FloatString(Diameter) $ "}";
	outstring @= "{ArcRotation Pitch " $
		class'UnitsConverter'.static.FloatString(arcPitch) $ " Roll " $
		class'UnitsConverter'.static.FloatString(arcRoll) $ " Yaw " $
		class'UnitsConverter'.static.FloatString(arcYaw) $ "}";
	outstring @= "{ArcRadius " $ class'UnitsConverter'.static.FloatString(arcRadius) $ "}";
	outstring @= "{ArcAngle " $ class'UnitsConverter'.static.FloatString(arcAngle) $ "}";
	return outstring;
}

defaultproperties
{
	bDebug=true;
	ItemType="TouchArray";
	DrawScale3D=(X=0.1);
	DrawScale=0.4762;
}
