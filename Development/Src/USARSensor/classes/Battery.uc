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
	super.PreBeginPlay(); // first initialize parent object
	if(bDebug)
	{ 
		LogInternal("Battery: maxEnergy=" $ maxEnergy);
		LogInternal("Battery: currentEnergy=" $ currentEnergy);
		LogInternal("Battery: batteryLife=" $ batteryLife);
	}
	averageDischarge = maxEnergy / batteryLife;
	oldTime = -1; // invalid
}

// callback mechanism which uses a delegate to notify (USARVehicle) the battery has died
delegate BatteryDiedDelegate()
{
	if (bDebug)
		LogInternal("Battery: Dead but no callback registered");
}

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
		{
			if (bDebug)
				LogInternal("Battery: dT=" $ deltaTime $ " discharge=" $ maxEnergy *
					(deltaTime / batteryLife));
			discharge(maxEnergy * (deltaTime / batteryLife));
		}
		if (bDebug)
			LogInternal("Battery: currentEnergy=" $ currentEnergy);
		
		// Compute exponential moving average of battery discharge
		deltaDischarge = oldEnergy - currentEnergy;
		if (deltaDischarge > 0)
		{
			averageDischarge = (averageDischarge * movingAverageFactor +
				deltaDischarge / deltaTime) / (movingAverageFactor + 1);
			if (bDebug)
				LogInternal("Battery: averageDischarge=" @ averageDischarge);
		}
	}
	
	// Remember for next call
	oldTime = newTime;
	oldEnergy = currentEnergy;
}

// Get maximum energy of battery in Joules
simulated function float getMaxEnergy()
{ 
	return maxEnergy;
}

// Get current energy of battery in Joules
simulated function float getCurrentEnergy()
{
	return currentEnergy;
}

// Get current energy of battery in Joules
simulated function bool isDead()
{
	return bIsDead;
}

// Discharge battery with energy (in Joules)
simulated function discharge(float energy)
{
	addEnergy(-energy);
}

// Charge battery with energy (in Joules)
simulated function charge(float energy)
{
	addEnergy(energy);
}

// Expected lifetime based on exponential moving average of discharge per second
simulated function int expectedLifeTime()
{
	return int(getCurrentEnergy() / averageDischarge);
}

private function addEnergy(float energy)
{
	currentEnergy += energy;
	if (currentEnergy > maxEnergy)
		currentEnergy = maxEnergy;
	if (currentEnergy < 0)
	{
		currentEnergy = 0;
		LogInternal("Battery: battery has died");
		bIsDead = true;
		BatteryDiedDelegate(); // callback to notify of batteryDied event
	}
	else
		bIsDead = false;
}

defaultproperties
{
	bDebug=false;
	bIsDead=false;
	movingAverageFactor=0.98;
	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'P3AT.StaticMeshDeco.P3ATDeco_BatteryPack'
		BlockActors=false
	End Object

	CollisionType=COLLIDE_BlockAll
	Components(1)=StMesh01  //Necessary for the skeletal mesh to actually become part of the class
	CollisionComponent=StMesh01 //Not sure if necessary, haven't tested yet.
}
