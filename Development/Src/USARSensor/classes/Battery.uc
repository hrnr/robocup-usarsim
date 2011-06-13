/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

class Battery extends Sensor config(USAR);

var config float maxEnergy; // in Joule
var config float currentEnergy; // in Joule
var config float batteryLife; // in seconds
var bool bIsDead;

// privates
var float oldTime;
var float oldEnergy;
var float averageDischarge; // exponential moving average of discharge per second 
var const float movingAverageFactor; // how strong previous observations are weighted

// initialize this object
simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	if (bDebug)
	{ 
		LogInternal("Battery: Maximum Energy " $ maxEnergy);
		LogInternal("Battery: Current Energy " $ currentEnergy);
		LogInternal("Battery: Life " $ batteryLife);
	}
	averageDischarge = maxEnergy / batteryLife;
	oldTime = -1;
}

// callback mechanism which uses a delegate to notify (USARVehicle) the battery has died
delegate BatteryDiedDelegate()
{
	if (bDebug)
		LogInternal("Battery: Battery died, but no callback registered");
}

// No data to return, so don't send anything back
simulated function ClientTimer()
{
	local float newTime;
	local float deltaTime;
	local float deltaDischarge;	

	newtime = WorldInfo.TimeSeconds;
	deltaTime = newTime - oldTime;

	// Discharge battery based on max batteryLife
	if (oldTime > 0)
	{
		// Discharge battery based on lifetime
		if (!isDead())
			Discharge(maxEnergy * (deltaTime / batteryLife));
		if (bDebug)
			LogInternal("Battery: currentEnergy is " $ currentEnergy);
		
		// Compute exponential moving average of battery discharge
		deltaDischarge = oldEnergy - currentEnergy;
		if (deltaDischarge > 0)
		{
			averageDischarge = (averageDischarge * movingAverageFactor +
				deltaDischarge / deltaTime) / (movingAverageFactor + 1);
			if (bDebug)
				LogInternal("Battery: averageDischarge is " $ averageDischarge);
		}
	}
	
	// Remember for next call
	oldTime = newTime;
	oldEnergy = currentEnergy;
}

// Get maximum energy of battery in Joules
simulated function float GetMaxEnergy()
{ 
	return maxEnergy;
}

// Get current energy of battery in Joules
simulated function float GetCurrentEnergy()
{
	return currentEnergy;
}

// Get current energy of battery in Joules
simulated function bool IsDead()
{
	return bIsDead;
}

// Discharge battery with energy (in Joules)
simulated function Discharge(float energy)
{
	addEnergy(-energy);
}

// Charge battery with energy (in Joules)
simulated function Charge(float energy)
{
	addEnergy(energy);
}

// Expected lifetime based on exponential moving average of discharge per second
simulated function int ExpectedLifeTime()
{
	return int(getCurrentEnergy() / averageDischarge);
}

private function AddEnergy(float energy)
{
	currentEnergy += energy;
	if (currentEnergy > maxEnergy)
		currentEnergy = maxEnergy;
	if (currentEnergy < 0)
	{
		currentEnergy = 0;
		LogInternal("Battery: battery has died");
		bIsDead = true;
		BatteryDiedDelegate();
	}
	else
		bIsDead = false;
}

defaultproperties
{
	bDebug=false
	bIsDead=false
	movingAverageFactor=0.98
	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'P3AT.StaticMeshDeco.P3ATDeco_BatteryPack'
		BlockActors=false
	End Object

	CollisionType=COLLIDE_BlockAll
	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
