/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// Touch SENSOR
// Creates an arc of "touch" sensors that can act as one bumper sensor
// This class is basically the same as the USARSim-2004 Touch class and following functions
// have been added 
//		
//		Based on   : Phidgets circular touch sensor-RB-Phi-46(http://www.robotshop.ca/phidgets-touch-sensor-1.html) 
// 		Ported by  : Kaveh team, Mehdi Karamnejad - Majid Yasari
//		Bug report : majid.yasari@gmail.com

class Touch extends Sensor config (USAR);

const TouchRange = 0.16; // 3mm
const ScanStep = 0.25; // 4.7mm
const PointsPerCircle = 6;
var config float Diameter;
var float uuRadius;
var int nCircles;
var float CircleStep;
var String test;

//convert all variables of this object read from UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{	
	uuRadius = class'UnitsConverter'.static.LengthToUU(Diameter) / 2;
	nCircles = int(uuRadius / ScanStep) + 1;
	CircleStep = 2 * pi / PointsPerCircle;
}

function bool isTouch()
{
	local vector HitLocation, HitNormal;
	local Actor Bumper;
	local vector RotX, RotY, RotZ;
	local rotator curRot;
	local vector startVec;
	local int i, j; 
	curRot = Rotation;
	startVec = Location;
	GetAxes(Rotation, RotX, RotY, RotZ);
	
	// Send one Trace straight ahead
	Bumper = Trace(HitLocation, HitNormal, startVec + touchRange * vector(curRot), startVec, true);
	if (Bumper != None)
	{		
		if (bDebug) LogInternal("Bump with " $ Bumper);
		return true;
	}
	
	// Detect along the circle from the edge to the center with step ScanStep;
	for (i = 0; i < nCircles; i++)
		// Radius = (nCircles - i) * ScanStep;
		for (j = 0; j < PointsPerCircle; j++)
		{
			startVec = Location + uuRadius * cos(j * CircleStep) * RotY + uuRadius * sin(j * CircleStep) * RotZ;
			Bumper = Trace(HitLocation, HitNormal, startVec + touchRange * vector(curRot), startVec, true);
			if (Bumper != None)
			{
				if (bDebug) LogInternal("Bump with " $ Bumper);
				return true;
			}
		}

	return false;
}

function String GetData()
{
	return "{Name " $ ItemName $ " Touch " $ isTouch() $ "}";
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{Diameter " $ class'UnitsConverter'.static.FloatString(Diameter) $ "}";
	return outstring;
}

defaultproperties
{
	bDebug=false
	ItemType="Touch"
	DrawScale3D=(X=0.1)
	DrawScale=0.4762
}
