/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Tachometer Sensor
 * Author:  Stephen Balakirsky 
 * Brief :  This sensor provides data that would typically be returned by a tachometer sensor.
 */
class Tachometer extends WheelSensor config (USAR);

var float OldTime;

// Need to initialize OldTime
simulated function AttachItem()
{
	super.AttachItem();
	OldTime = WorldInfo.TimeSeconds;
}

// Returns data from the tachometer
function String GetData()
{
	local String tachometerData, posString;
	local int i;
	local float newTime, timeDiff, positionOut, myVelocity, value;
	
	// Update wheel spins
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - OldTime;
	OldTime = newTime;
	// Avoid div by zero
	if (timeDiff < 0.000001 || Wheels.Length < 1)
		return "{Name " $ ItemName $ "}";
	tachometerData = "{Name " $ ItemName $ "} {Vel ";
	posString = "{Pos ";
	for (i = 0; i < Wheels.Length; i++)
	{
		value = Wheels[i].Wheel.CurValue;
		positionOut = value;
		
		myVelocity = (value - Wheels[i].Old) / timeDiff;
		if (i == 0)
		{
			posString = posString $ positionOut;
			tachometerData = tachometerData $ myVelocity;
		}
		else
		{
			posString = posString $ "," $ positionOut;
			tachometerData = tachometerData $ "," $ myVelocity;
		}
	}
	UpdateSpin();
	return tachometerData $ "} " $ posString $ "}";
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
	ItemType="Tachometer"

	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=false
	bCollideWorld=false
	DrawScale=1

	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'INSIMUSensor.Sensor'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object

	CollisionType=COLLIDE_BlockAll
	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
