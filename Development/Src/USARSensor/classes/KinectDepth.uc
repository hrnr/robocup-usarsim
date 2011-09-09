/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class KinectDepth extends RangeSensor config (USAR);

var float FovX;
var float FovY;
var float ResolutionX;
var float ResolutionY;
var int Frame;
var int FrameCount;
var bool bSendRangeData;

simulated function ConvertParam()
{
	super.ConvertParam();
	ResolutionX = class'UnitsConverter'.static.AngleToUU(ResolutionX);
	ResolutionY = class'UnitsConverter'.static.AngleToUU(ResolutionY);
	FovX = class'UnitsConverter'.static.AngleToUU(FovX);
	FovY = class'UnitsConverter'.static.AngleToUU(FovY);
}

// Called after play begins
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	bSendRangeData = false;
	
	// Activate item timer based on the scan interval of each class
// 	SetTimer(0.0, false); TEMP COMMENT TO SEE IF DATA COMES OUT!
}

function String GetData()
{
	local String rangeData, point;
	local int i, j, start;
	local rotator turn;
	
	rangeData = "";
	// if no scan just send status data
	if( !bSendRangeData )
	{
	   rangeData = "{Name " $ ItemName $ "} {Frames 0}";
	   return rangeData;
        }


	// Top to bottom, left to right, venetian blinds scan
	start = -FovY / 2 + FovY * Frame / FrameCount;
	for (i = start; i < start + FovY / FrameCount; i += ResolutionY)
		for (j = -FovX / 2; j <= FovX / 2; j += ResolutionX)
		{
			turn.Pitch = i;
			turn.Yaw = j;
			curRot = class'Utilities'.static.rTurn(Rotation, turn);
			point = String(int(GetRange() * 100));
			if (rangeData == "")
				rangeData = point;
			else
				rangeData = rangeData $ "," $ point;
		}
	rangeData = "{Name " $ ItemName $ "} {Frame " $ Frame $ "} {Range " $ rangeData $ "}";
	Frame = (Frame + 1) % FrameCount;
	if (Frame == 0)
	{
//		SetTimer(0.0, false);
	        bSendRangeData = false;
//		`log("Kinect scan complete", ,'Kinect');
		LogInternal("Kinect scan complete");
	}
	else
	{
//		`log("Kinect scan " $ Frame $ "/" $ FrameCount $ ", " $ (FrameCount - Frame) *
//			ScanInterval $ " second(s) left", ,'Kinect');
		LogInternal("Kinect scan " $ Frame $ "/" $ FrameCount $ ", " $ (FrameCount - Frame) *
			ScanInterval $ " second(s) left");
	}
	return rangeData;
}

function String Set(String opcode, String args)
{
	if (Caps(opcode) == "SCAN")
	{
//		SetTimer(ScanInterval, true);
	        bSendRangeData = true;
		`log("Starting Kinect scan", ,'Kinect');
		return "OK";
	}
	return "Failed";
}

function String GetConfData()
{
	local String outstring;
//	LogInternal("In GetConfData from from KinectDepth");
	outstring = super.GetConfData();
	outstring $= " {Resolution " $ class'UnitsConverter'.static.Str_AngleFromUU(ResolutionX) $
		"," $ class'UnitsConverter'.static.Str_AngleFromUU(ResolutionY) $ "} {Fov " $
		class'UnitsConverter'.static.Str_AngleFromUU(FovX) $ "," $
		class'UnitsConverter'.static.Str_AngleFromUU(FovY) $ "}";
	return outstring;
}

defaultproperties
{
	FovY=1
	FovX=0.75
	Frame=0
	FrameCount=60
	ResolutionY=0.0015625
	ResolutionX=0.0015625
	ItemType="RangeImager"


	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=true
	bCollideWorld=true
	
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'SICKSensor.lms200.Sensor'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object

}
