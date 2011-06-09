/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

// Based on Erik Winter's IRSensor class
//
// This class modifies the way noise is handled. It allows to shape noise
// in any way with an InterpCurve.
// Note: Noise shaped this way is no more linear but parabolic
//
// by Marco Zaratti - marco.zaratti@gmail.com
// 
//==============================================================================
//
// This class is basically the same as the USARSim RangeSensor class
// For the moment only the Range and output curve parameters are changed
//	author: Erik Winter
//  created: 2005-02-24	Created the class from the USARSim RangeSensor class
//
//  modified:	2005-03-07	Made the IR look straight through transparent materials
//				2005-03-15  If the IR hits a transparent material it now sends out a new trace from the HitLocation recursively
//							until it hits a non-transparent material or reaches MaxRange
//
//	Todo:
//		- Apply the fact that the IR can see through, and though miss glass walls
//			* halfly done, if it hits a transparent material it returns maxRange. On these maps it should be an okay simplification, Fully Done
//
///////////////////////////////////////////////////////////////////////////////////////
//		
//		Based on   : Sharp-GP2Y0A02YK(http://www.acroname.com/robotics/parts/R144-GP2Y0A02YK.html 
//		IR2 sensor works like the IR sensor except that the
//		Noise applied to the sensor is different(parabolic).
// 		Ported by  : Kaveh team, Reza Hasanzade - Majid Yasari
//		Bug report : majid.yasari@gmail.com


class IR2Sensor extends RangeSensor config (USAR);

simulated function float GetRange()
{
    local vector HitLocation, HitNormal;
    local vector curLoc, dir;
    local float range;
	local TraceHitInfo mtl;

	range = 0;	
	curLoc = Location;
	dir = vector(Rotation);
	
	while (range < MaxRange)
    {
		if (Trace(HitLocation, HitNormal, curLoc + MaxRange * dir, curLoc, true, , mtl) == None)
		{
			range = MaxRange;
			break;
		}
		else
            range = VSize(HitLocation-Location);
		
		if (InStr(String(mtl.Material), "Trans") == -1) // The IR hitted a non-transparent material.
			break;
		else
		{
			curLoc = HitLocation + MinRange	* dir;
			range = VSize(curLoc - Location);
		}
	}
	
	range = range > MaxRange ? MaxRange : range;
	range = range < MinRange ? MinRange : range;

	// Convert to standard unit
	range = class'UnitsConverter'.static.LengthFromUU(range);
	return range;
}

simulated function ClientTimer()
{
    local String rangeData;
	local float range;
	
	range = GetRange();
    rangeData = "{Name " $ ItemName $ " Range " $
		class'UnitsConverter'.static.FloatString(range) $ "}";
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
    local String confData;
	confData = super.GetConfData();
	confData @= "{MaxRange " $ class'UnitsConverter'.static.Str_LengthFromUU(MaxRange) $
		"} {MinRange " $ class'UnitsConverter'.static.Str_LengthFromUU(MinRange) $ "}";
	return confData;
}

defaultproperties
{
	ItemType="IR2"
}
