/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class RangeSensor extends Sensor config(USAR) abstract;

var config float MaxRange,MinRange;
var Rotator curRot;
var config bool bSendRange;

simulated function ConvertParam()
{
	super.ConvertParam();
	MaxRange = class'UnitsConverter'.static.LengthToUU(MaxRange);
	MinRange = class'UnitsConverter'.static.LengthToUU(MinRange);
}

//   Retreives the range data using trace and reports this range in UU or meters depending on presence of converter
//   The Trace method traces a line to point of first collision.
//   Takes actor calling trace collision properties into account.
//   Returns first hit actor, level if hit level, or none if hit nothing
simulated function float GetRange()
{
    local vector HitLocation,HitNormal;
    local float range;
  
	if (Trace(HitLocation, HitNormal, Location + MaxRange * vector(curRot), Location, true) == None)
		range = class'UnitsConverter'.static.LengthFromUU(MaxRange);
	else
	{
		range = VSize(HitLocation - Location); // Range in UU 
		range = class'UnitsConverter'.static.LengthFromUU(range); // Convert to meters
	}
	return range;
}

simulated function ClientTimer()
{
    local String rangeData;
	local float range;
	curRot = Rotation;
	range = getRange();
    rangeData = "{Name " $ ItemName $ " Range " $ class'UnitsConverter'.static.FloatString(range) $ "}";
	if (bSendRange)
		RangeSendDelegate(self, range);
	else
		MessageSendDelegate(getHead() @ rangeData);
}

delegate RangeSendDelegate(Actor a, float range)
{
	LogInternal("No range send delegate has been set");
}

simulated function String GetConfData()
{
    local String outstring;
	outstring = super.GetConfData();
	outstring @= "{MaxRange " $ class'UnitsConverter'.static.Str_LengthFromUU(MaxRange) $
		"} {MinRange " $ class'UnitsConverter'.static.Str_LengthFromUU(MinRange) $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Range"
}
