/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class RangeScanner extends RangeSensor config (USAR);

var config float Resolution;
var config float ScanFov;
var config bool bYaw;
var config bool bPitch;
var float Time;

simulated function ConvertParam()
{
	super.ConvertParam();
	Resolution = class'UnitsConverter'.static.AngleToUU(Resolution);
    ScanFov = class'UnitsConverter'.static.AngleToUU(ScanFov);
}

function String GetData()
{
	local String rangeData;
	local int i;
	local float range;
	local rotator turn;

	time = WorldInfo.TimeSeconds;
    // from right to left
	for (i = ScanFov / 2; i >= -ScanFov / 2; i -= Resolution)
	{
		if (bYaw)
			turn.Yaw = i;
		if (bPitch)
			turn.Pitch = i;
		curRot = class'Utilities'.static.rTurn(Rotation, turn);
		range = GetRange();
		if (rangeData == "")
			rangeData = class'UnitsConverter'.static.FloatString(range, 2);
		else
			rangeData = rangeData $ "," $ class'UnitsConverter'.static.FloatString(range, 2);
	}
	return "{Name " $ ItemName $ "} {Resolution " $
		class'UnitsConverter'.static.Str_AngleFromUU(Resolution) $ "} {FOV " $
		class'UnitsConverter'.static.Str_AngleFromUU(ScanFov) $ "} {Range " $ rangeData $ "}";
}

function String Set(String opcode, String args)
{
	if (Caps(opcode) == "SCAN")
	{
		Timer();
		return "OK";
	}
	return "Failed";
}

function String GetConfData()
{
    local String outstring;
	outstring = super.GetConfData();
	outstring @= "{Resolution " $ class'UnitsConverter'.static.Str_AngleFromUU(Resolution) $
	    "} {Fov " $ class'UnitsConverter'.static.Str_AngleFromUU(ScanFov) $ "}";
	outstring @= "{Panning " $ bYaw $ "} {Tilting " $ bPitch $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="RangeScanner"
	OutputCurve=(Points=((InVal=0,OutVal=0),(InVal=1000,OutVal=1000)))
	DrawScale=10
}
