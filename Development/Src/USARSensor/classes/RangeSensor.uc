/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class RangeSensor extends Sensor config(USAR) abstract;

var config float MaxRange, MinRange;
var rotator curRot;
var config bool bSendRange;

simulated function ConvertParam()
{
	super.ConvertParam();
	MaxRange = class'UnitsConverter'.static.LengthToUU(MaxRange);
	MinRange = class'UnitsConverter'.static.LengthToUU(MinRange);
}

// Retreives the range data using trace and reports this range in UU or meters depending on presence of converter
//  The Trace method traces a line to point of first collision.
//  Takes actor calling trace collision properties into account.
//  Returns first hit actor, level if hit level, or none if hit nothing
function float GetRange()
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

// Get range data from the program as a string
function String GetData()
{
	return "{Name " $ ItemName $ "} {Range " $
		class'UnitsConverter'.static.FloatString(GetRange()) $ "}";
}

// Don't call parent to avoid sending excess data if bSendRange is true
simulated function ClientTimer()
{
/*
	if( bSendRange )
		LogInternal( "going to GetData with sendRange true" );
	else
		LogInternal( "going to GetData with sendRange false" );
*/
	curRot = Rotation;
	if (bSendRange)
		RangeSendDelegate(self, GetRange());
	else
		MessageSendDelegate(GetHead() @ GetData());
}

delegate RangeSendDelegate(Actor a, float range)
{
	LogInternal("No range send delegate has been set");
}

function String GetConfData()
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
