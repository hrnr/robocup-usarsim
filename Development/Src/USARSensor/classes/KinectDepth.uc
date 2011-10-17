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
var int PixelsX;
var int PixelsY;
var int Frame;
var int FrameCount;
var bool bSendRangeData;

simulated function ConvertParam()
{
	super.ConvertParam();
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
	local String rangeData;
	local float range;
	local int i, j, startY;
	local rotator turn;
	local float ResolutionX;
	local float ResolutionY;
//	local int rangeCountDebug;
//	local int debugCounter, debugCounter2;
	local float FovX_2;
	
	rangeData = "";
//	rangeCountDebug = 0;
	// if no scan just send status data
	rangeData = "{Name " $ ItemName $ "} {Resolution " $ PixelsX $ "," $
	            PixelsY $ "} {FOV " $ 
				class'UnitsConverter'.static.Str_AngleFromUU(FovX) $ "," $ class'UnitsConverter'.static.Str_AngleFromUU(FovY) $ "}";
	if( !bSendRangeData )
	{
	   rangeData = rangeData $  " {Frames 0} {Frame 0}";
	   return rangeData;
        }

	rangeData = rangeData $ " {Frames " $ FrameCount $ "} {Frame " $ Frame $
	            "} {Range ";
	// Top to bottom, left to right, venetian blinds scan
	startY = -FovY / 2 + FovY * Frame / FrameCount;
	ResolutionX = FovX/PixelsX;
	ResolutionY = FovY/PixelsY;
//	LogInternal("KinectDepth: FovX " $ FovX $ " ResolutionX: " $ PixelsX);
//	debugCounter2=0;
	FovX_2 = FovX/2.;
	for (i = 0; i < PixelsY/FrameCount; i++)
	  {
//	    debugCounter = 0;
		for (j = 0; j < PixelsX; j++)
		{
			turn.Pitch = startY + i*ResolutionY;
			turn.Yaw = -FovX_2 + j*ResolutionX;
			curRot = class'Utilities'.static.rTurn(Rotation, turn);
			
			range = GetRange();
//			rangeCountDebug++;
			if (rangeData == "")
				rangeData = class'UnitsConverter'.static.FloatString(range, 2);
			else
				rangeData = rangeData $ "," $ class'UnitsConverter'.static.FloatString(range, 2);
//			debugCounter++;
		}
//		LogInternal( "Kinect resx: " $ ResolutionX $ " line " $ debugCounter2++ $" elements/line: " $ debugCounter );
	  }
	rangeData = rangeData $ "}";
//	LogInternal("KinectDepth: " $ rangeData );
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
//		LogInternal("Kinect scan " $ Frame $ "/" $ FrameCount $ "(" $ rangeCountDebug $ 
//		    " elements), " $ (FrameCount - Frame) *
//			ScanInterval $ " second(s) left");
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
	outstring $= " {Resolution " $ PixelsX $
		"," $ PixelsY $ "} {Fov " $
		class'UnitsConverter'.static.Str_AngleFromUU(FovX) $ "," $
		class'UnitsConverter'.static.Str_AngleFromUU(FovY) $ "}";
	return outstring;
}

defaultproperties
{
	FovY=2.3561925
	FovX=3.14159
	Frame=0
	FrameCount=60
	PixelsY=480 // number of returns in the y-direction
	PixelsX=640 // number of returns in the x-direction
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
