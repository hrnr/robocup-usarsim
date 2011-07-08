/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class RotatingPointCloudScanner extends Sensor config(USAR);

var config int numberOfBeams;
var config float HFieldOfView;
var config float VFieldOfView;
var config float MaxRange;
var config float spinRate;
var config float scanRate;
var RangeSensorArray rsa;
var class<RangeSensor> RangeSensorClass;
var String PclData;
var float AngularVRate; 
var float CurAngle;

simulated function ConvertParam()
{
	super.ConvertParam();
	HFieldOfView = class'UnitsConverter'.static.angleToUU(HFieldOfView);
	VFieldOfView = class'UnitsConverter'.static.angleToUU(VFieldOfView);	
	MaxRange = class'UnitsConverter'.static.LengthToUU(MaxRange);
	AngularVRate = VFieldOfView / SpinRate;
	LogInternal("AngularVRate is " $ angularVRate);
}

simulated function PostBeginPlay()
{
	local float angularResolution,i;
	local Rotator r;
	local vector v;
	super.postBeginPlay();
	
	rsa = Spawn(class'RangeSensorArray', self, , Location);
	rsa.setBase(self);
	rsa.bSendPoints = true;
	rsa.PointSendDelegate = GetPoint;
	CurAngle = -VFieldOfView / 2;
	r.pitch = CurAngle;
	rsa.setRelativeRotation(r);
	AngularResolution = HFieldOfView / (numberOfBeams - 1);
	
	for (i = -HFieldOfView / 2.0; i <= HFieldOfView / 2.0; i += angularResolution)
	{
		r.yaw = i;
		rsa.addRangeSensor(rangeSensorClass, v, r, maxRange, scanRate);
	}
}

simulated function GetPoint(Actor a, vector pt)
{
	pt = (pt >> a.Rotation) << Rotation;
	if (PclData == "")
		PclData = "" $ pt;
	else
		pclData = pclData $ ";" $ pt;
}

simulated event Tick(float deltaTime)
{
	local rotator r;
	local float angleToRotate;
	
	AngleToRotate = deltaTime * AngularVRate;
	CurAngle = CurAngle + AngleToRotate;
	if (CurAngle > VFieldOfView / 2.0)
		CurAngle = -VFieldOfView / 2.0;
	r.pitch = CurAngle;
	rsa.setRelativeRotation(r);
}

simulated event Destroyed()
{
	super.Destroyed();
	rsa.Destroy();
}

function String GetData()
{
	local String data;
	data = PclData;
	PclData = "";
	return "{Name " $ ItemName $ "} {" $ data $ "}";
}

defaultproperties
{
	ItemType="PCL"
	rangeSensorClass=class'USARSensor.SonarSensor'
}
