/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

////////////////////////////////////////////////
//		Based on   : PBS-03JN ( http://www.hokuyo-aut.jp/02sensor/07scanner/pbs.html )
//		IRScanner uses the IRSensor(the detection line can cross transparent materials)
//		To scan the environment. 
// 		Ported by  : Kaveh team, Reza Hasanzade - Majid Yasari
//		Bug report : majid.yasari@gmail.com

class IRScanner extends IRSensor config (USAR);

var config float Resolution;
var config float ScanFov;
var config bool bYaw;
var config bool bPitch;
var float time;

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
	rangeData = "";
	// from right to left (Counterclockwise)
	for (i = ScanFov / 2; i > -ScanFov / 2; i -= Resolution)
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
			rangeData = rangeData$","$class'UnitsConverter'.static.FloatString(range, 2);
	}
	return "{Name " $ ItemName $ "} {Resolution " $
		class'UnitsConverter'.static.Str_AngleFromUU(Resolution) $ "} {FOV " $
		class'UnitsConverter'.static.Str_AngleFromUU(ScanFov) $ "} {Range " $ rangeData $ "}";
}

function String Set(String opcode, String args)
{
	LogInternal("Opcode = "@opcode);
	if (Caps(opcode) == "SCAN")
	{
		timer();
		return "OK";
	}
	return "Failed";
}

function String GetConfData()
{
	local String confData;
	confData = super.GetConfData();
	confData @= "{Resolution " $ class'UnitsConverter'.static.FloatString(Resolution) $
		"} {Fov " $ class'UnitsConverter'.static.FloatString(ScanFov) $ "}";
	confData @= "{Paning " $ bYaw $ "} {Tilting " $ bPitch $ "}";
	return confData;
}

defaultproperties
{
	ItemType="IRScanner"
	DrawScale=10
}
