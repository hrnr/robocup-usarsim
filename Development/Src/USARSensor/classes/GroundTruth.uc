/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
  * GroundTruth.uc
  * Ground Truth Sensor
  * author:  Stephen Balakirsky based on UT2004 GroundTruth.uc code
  * brief :  This sensor provides ground truth of the robot's current
  *          location and orientation.  Since this is ground truth
  *          there is no sensor noise
  */

class GroundTruth extends Sensor config (USAR);
var config bool FixedToPlatform;

// Returns data from the ground truth sensor
function String GetData()
{
	local String rotTrue;

	if( FixedToPlatform )
	{
		rotTrue = class'UnitsConverter'.static.Str_AngleVectorFromUU(Platform.CenterItem.Rotation, 3);
		return "{Name " $ ItemName $ "} {Location " $
			class'UnitsConverter'.static.Str_LengthVectorFromUU(Platform.CenterItem.Location, 3) $
			"} {Orientation " $ rotTrue $ "}";
	}
	else
	{
		rotTrue = class'UnitsConverter'.static.Str_AngleVectorFromUU(Rotation, 3);
		return "{Name " $ ItemName $ "} {Location " $
			class'UnitsConverter'.static.Str_LengthVectorFromUU(Location, 3) $
			"} {Orientation " $ rotTrue $ "}";
	}
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="GroundTruth"
//	FixedToPlatform = true;
}
