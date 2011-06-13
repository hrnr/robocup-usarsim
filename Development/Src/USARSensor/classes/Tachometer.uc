/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

/*
  * Tachometer.uc
  * Tachometer Sensor
  * author:  Stephen Balakirsky 
  * brief :  This sensor provides data that would typically be returned by a tachometer sensor.
  */

class Tachometer extends Sensor config (USAR);

struct TachWheel
{
	var JointItem Wheel;
	var float OldPosition;
};
var array<TachWheel> Wheels;
var float OldTime;

simulated function AttachItem()
{
	super.AttachItem();
	FindTires();
}

simulated function FindTires()
{
	local JointItem ji;
	local int i;
	local int index;
	
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("Tachometer: Not attached to a SkidSteeredVehicle");
		SetTimer(0, false);
		return;
	}
	
	index = 0;
	for(i = 0; i < Platform.Parts.Length; i++)
		if (Platform.Parts[i].isJoint())
		{
			ji = JointItem(Platform.Parts[i]);
			if (ji.JointIsA('WheelJoint') && WheelJoint(ji.Spec).bIsDriven)
			{
				Wheels[index].Wheel = ji;
				Wheels[index].OldPosition = ji.CurAngle;
				index++;
			}
		}
	oldTime = WorldInfo.TimeSeconds;
}

// Returns data from the tachometer
function String GetData()
{
	local String tachometerData;
	local int i;
	local float oldPos;
	local float diff;
	local float rollsOver;
	local float myVelocity;
	local float newTime;
	local float timeDiff;
	local String posString;
	local float positionOut;
	
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - oldTime;
	oldTime = newTime;
	tachometerData = "{Name " $ ItemName $ "} {Vel ";
	posString = "{Pos ";
	for (i = 0; i < Wheels.Length; i++)
	{
		diff = Wheels[i].Wheel.CurAngle - Wheels[i].OldPosition;
		if (diff < -PI)
			rollsOver = 1;
		else if (diff > PI)
			rollsOver = -1;
		else
			rollsOver = 0;
		oldPos = Wheels[i].Wheel.CurAngle;
		Wheels[i].OldPosition = oldPos;
		if (oldPos <= 0)
			positionOut = oldPos + 2 * PI;
		else if (oldPos >= 2 * PI)
			positionOut = oldPos - 2 * PI;
		else
			positionOut = oldPos * degToRad;
			
		myVelocity = degToRad * (rollsOver * 2 * PI + diff) / timeDiff;
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
