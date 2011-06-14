/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * This class simulates the encoder sensor.
 * 
 * The added config params are:
 *  Resolution:   The resoulution of the encoder defined in UU.
 *  Noise:		The Noise added to the encoder value.
 * 
 * The returned value is:
 *  Tick: The data range is (-65535/uuResolution)~(65535/uuResolution).
 *   Positive value means clockwise direction. It's the controller's
 *   resposible to count how many circles the part has rotated.
 * 	
 * Author: Behzad Tabibian
 */
class Encoder extends WheelSensor config (USAR);

var config float Resolution;

// Retrieves encoder data
simulated function String GetData()
{
	local int i, tick;
	local String outstring;
	local float totalSpin;
	
	UpdateSpin();
	outstring = "";
	if (Wheels.Length < 1)
		return outstring;
	for (i = 0; i < Wheels.Length; i++)
	{
		totalSpin = (1 + RandRange(-Noise, Noise)) * Wheels[i].Spun;
		tick = int((totalSpin % 2 * PI) / Resolution);
		// Look for the wheel number in ItemName, should contain a W and # of wheel(s) to report
		if (InStr(ItemName, "W" $ i) >= 0)
		{
			if (outstring != "")
				outstring = outstring $ " ";
			outstring = outstring $ "{Name W" $ i $ "} {Tick " $ tick $ "}";
		}
	}
	return outstring;
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{Resolution " $ class 'UnitsConverter'.static.FloatString(Resolution) $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Encoder"
	DrawScale=0.004762
	DrawScale3D=(X=0.001)
}
