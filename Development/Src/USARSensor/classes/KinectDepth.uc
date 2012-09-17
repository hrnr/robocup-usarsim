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
var vector HitLoc,HitNor;

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
	//local String RJoin;
	local float range;
	local int i, j, startY;
	local rotator turn;
	local float ResolutionX;
	local float ResolutionY;
	//local array<string> RStr;
	local String ranFS;
	local String ranIS;
//	local int rangeCountDebug;
//	local int debugCounter, debugCounter2;
	local float FovX_2;
	local float YCount;

	
	rangeData = "";
//	rangeCountDebug = 0;
	// if no scan just send status data
	rangeData = "{Name " $ ItemName $ "} {Resolution " $ PixelsX $ "," $
	            PixelsY $ "} {FOV " $ 
				class'UnitsConverter'.static.Str_AngleFromUU(FovX) $ "," $ class'UnitsConverter'.static.Str_AngleFromUU(FovY) $ "}";
    if( !bSendRangeData )
		{
	   rangeData $= " {Frames 0} {Frame 0}";
	   return rangeData;
        }
//    `log("FrameStart");
	rangeData $= " {Frames " $ FrameCount $ "} {Frame " $ Frame $
	            "} {Range ";
	// Top to bottom, left to right, venetian blinds scan
	startY = -FovY / 2 + FovY * (FrameCount - Frame) / FrameCount;
	ResolutionX = FovX/PixelsX;
	ResolutionY = FovY/PixelsY;
//	LogInternal("KinectDepth: FovX " $ FovX $ " ResolutionX: " $ PixelsX);
//	debugCounter2=0;
	FovX_2 = FovX/2.;
    YCount = PixelsY/FrameCount;
	turn.Pitch = startY + ResolutionY;
	turn.Yaw = -FovX_2 - ResolutionX;
	for (i = 0; i < YCount; i++)
	  {
	  turn.Pitch -= ResolutionY;
	  turn.Yaw = -FovX_2 - ResolutionX;
	  //`log("Val: " $ startY + i*ResolutionY $ "Cos: " $ cos(startY + i*ResolutionY));
	  //turn.Pitch = startY + i*ResolutionY;
//	    debugCounter = 0;
		for (j = 0; j < PixelsX; j++)
		{
		turn.Yaw += ResolutionX;
		//turn.Yaw = -FovX_2 + j*ResolutionX;
		curRot = class'Utilities'.static.rTurn(Rotation, turn);
			
		
		//range = GetRange();
		if (Trace(HitLoc, HitNor, Location + MaxRange * vector(curRot), Location, true) == None)
			range = class'UnitsConverter'.static.LengthFromUU(MaxRange);
	    else
	    {
			range = VSize(HitLoc - Location); // Range in UU 
			range = class'UnitsConverter'.static.LengthFromUU(range); // Convert to meters
			range = range*cos(class'UnitsConverter'.static.AngleFromUU(Turn.Yaw))*cos(class'UnitsConverter'.static.AngleFromUU(Turn.Pitch)); //Convert Range to Depth
		}
		if(((Frame == 0) && (i == 0) && ((j == 0) || (j == PixelsX-1))) || ((Frame == FrameCount-1) && (i == YCount - 1) && ((j == 0) || (j == PixelsX-1))))
		{drawDebugLine(Location,HitLoc,0,255,0,true);}
//			////////rangeCountDebug++;
			    //////RStr[(i*(PixelsY/FrameCount-1))+j] = class'UnitsConverter'.static.FloatString(range, 2);
				ranIS = String(int(range));
				ranFS = String(int((range - int(range)) * 100));
			    //RStr[(i*(PixelsX))+j] = ranIS $ "." $ ranFS;
				rangeData $= ranIS $ "." $ ranFS $ ",";
				////////rangeData $= "," $ class'UnitsConverter'.static.FloatString(range, 2);
//			///////debugCounter++;
		}
//		LogInternal( "Kinect resx: " $ ResolutionX $ " line " $ debugCounter2++ $" elements/line: " $ debugCounter );
	  }
	//JoinArray(RStr, RJoin,",", true);
	//`log("Num of Ranges: " $ RStr.length);
	//rangeData $= RJoin $ "}";
	rangeData $= "}";
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
//	`log("FrameEnd");
	return rangeData;
}

function String Set(String opcode, String args)
{
	if (Caps(opcode) == "SCAN")
	{
//		SetTimer(ScanInterval, true);
	        bSendRangeData = true;
		flushPersistentDebugLines();
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
	FovY=0.7854//2.3561925
	FovX=1.01226//3.14159
	Frame=0
	FrameCount=20
	PixelsY=240 // number of returns in the y-direction480
	PixelsX=320 // number of returns in the x-direction640
	ItemType="RangeImager"



	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=true
	bCollideWorld=true
}
