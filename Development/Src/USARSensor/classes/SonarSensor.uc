/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class SonarSensor extends RangeSensor config(USAR);

// Ported to USARSim for UT3
// -- Sebastian Drews Fri, 23 Apr 2010 09:26:03 +0100

// define the angle of the "real" signal cone
var config float beamAngle;

// define the maximal angle of incidence, signals with a larger AOI than that
// are invalid
var config float maxAngleOfIncidence;

// the number of cones to create
var config int numberOfCones;

// define how many traces per cone should be send
var config int tracesPerCone;


// convert all variables of this object read from the UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{
	super.ConvertParam(); 
	// convert beamAngle which is given in rad
	beamAngle = class'UnitsConverter'.static.AngleToUU(beamAngle);
}

// ClientTimer() is called every ScanInterval seconds (SetTimer() in 
// parent RangeSensor)
// The idea is to send out Traces along the surface of cones of different size.
simulated function ClientTimer()
{
	local vector HitLocation, HitNormal, rotatedSensorDirection;
	local float currentRange;
	local float coneRange;
	local int i, j;
	local rotator sensorDirection;
	local quat QuatRotationAxis;
	local float angleOfIncidence;
	local String rangeData;

	// 180 degrees are 2^15 (32768) unreal angle units
	// NOTE: The numberOfCones and tracesPerCone have a massive impact on
	// the performance of the simulation.
	// 20 cones with 32 tracesPerCone are ok if there is only one sonar
	// installed on the robot.
	// But if there are lets say 8 (P2AT) 60 traces still lead to a very 
	// low performance (at least with ut2004 on linux).

	sensorDirection = Rotation;

	// send one Trace straight ahead
	if (Trace(HitLocation, HitNormal, Location + MaxRange * vector(sensorDirection), Location, true) == None)
		currentRange = MaxRange;
	else
		currentRange = VSize(HitLocation - Location);

	// send out Trace's along cones
	for (i = 1; i <= numberOfCones; i++)
	{
		sensorDirection.Pitch += int(beamAngle / 2 / numberOfCones);
		
		for (j = 0; j < tracesPerCone; j++)
		{
			QuatRotationAxis = QuatFromAxisAndAngle(vector(Rotation), 2 * Pi / tracesPerCone * j);
			rotatedSensorDirection = QuatRotateVector(QuatRotationAxis, vector(sensorDirection));

			if (Trace(HitLocation, HitNormal, Location + MaxRange * rotatedSensorDirection,
				Location, true) != None)
			{
				coneRange = VSize(HitLocation - Location);
				angleOfIncidence = Acos(Normal(HitNormal) dot Normal(rotatedSensorDirection));
				// check whether the angle of incidence is
				// small enough
				if ((coneRange < currentRange) && (angleOfIncidence < maxAngleOfIncidence))
					currentRange = coneRange;
			}
		}
	}

	if (currentRange > MaxRange) currentRange = MaxRange;
	if (currentRange < MinRange) currentRange = MinRange;

	// convert UU to SI units for output
	currentRange = class'UnitsConverter'.static.LengthFromUU(currentRange);
	rangeData = "{Name " $ ItemName $ "} {Range " $
		class'UnitsConverter'.static.FloatString(currentRange) $ "}";
	MessageSendDelegate(getHead() @ rangeData);
}

simulated function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ class'UnitsConverter'.static.FloatString(ScanInterval) $
		"} {beamAngle " $ class'UnitsConverter'.static.Str_AngleFromUU(beamAngle) $
		"} {maxAngleOfIncidence " $ class'UnitsConverter'.static.FloatString(maxAngleOfIncidence) $
		"} {tracesPerCone " $ tracesPerCone $ "} {numberOfCones " $ numberOfCones $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Sonar"
}
