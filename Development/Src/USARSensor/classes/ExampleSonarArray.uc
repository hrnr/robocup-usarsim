/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class ExampleSonarArray extends RangeSensorArray config(USAR);

var config float Spacing;
var config int GridSize;
var config float maxRange;

simulated function ConvertParam()
{
	super.ConvertParam();
	spacing = class'UnitsConverter'.static.LengthToUU(spacing);
	maxRange = class'UnitsConverter'.static.LengthToUU(maxRange);
}

simulated function postBeginPlay()
{
	local int i,j;
	local vector v;
	local rotator r;
	local int gridDim;
	
	super.postBeginPlay();
	gridDim = spacing * (gridSize - 1);
	for (i = -gridDim / 2; i <= gridDim / 2; i += spacing)
		for (j =- gridDim / 2; j <= gridDim / 2; j += spacing)
		{
			v.y = i;
			v.z = j;
			addRangeSensor(class'SonarSensor', v, r, maxRange);
		}
}

defaultproperties
{
	ItemType="PCL"
}
