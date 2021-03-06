/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class SICK extends RangeScanner config (USAR);

// Define behavior inside smoke
function float GetRangeRecursive(Actor PrevHitActor, vector StartLocation,
	float maxRangeRemaining, float curRange, float penetrationPower, out vector FinalHitLocation)
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	local SmokeInterface smoke;
	local float range;

	// Don't trace if we don't have anything left
	if (maxRangeRemaining <= 0.0)
		return curRange;
		
	// Start a new trace
	HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation + maxRangeRemaining *
		vector(curRot), StartLocation, true);
	smoke = SmokeInterface(HitActor);
	range = VSize(HitLocation - StartLocation);

	// Hitted nothing
	if (HitActor == None)
	{
		FinalHitLocation = HitLocation;
		return curRange + maxRangeRemaining;
	}

	// No smoke, so a normal object. Smoke that uses particles always block.
	if (smoke == None || smoke.SmokeAlwaysBlock())
	{
		FinalHitLocation = HitLocation;
		return curRange + VSize(HitLocation - StartLocation);
	}

	// Probably hitted regional smoke. The SICK will ignore the this type of smoke for now.
	FinalHitLocation = HitLocation;
	return GetRangeRecursive(HitActor, HitLocation, maxRangeRemaining - range,
		curRange + range, penetrationPower, FinalHitLocation);
} 

// Retreives the range data using trace and reports this range in UU or meters depending on presence of converter
//  The Trace method traces a line to point of first collision.
//  Takes actor calling trace collision properties into account.
//  Returns first hit actor, level if hit level, or none if hit nothing
function float GetRange()
{
	local float range;
	local vector HitLocation;
	range = GetRangeRecursive(self, Location, MaxRange, 0.0, 0.00575, HitLocation);

	// Finally convert to meters
	range = class'UnitsConverter'.static.LengthFromUU(VSize(HitLocation - Location));
	return range;
}

defaultproperties
{
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=true
	bCollideWorld=true
	
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'SICKSensor.lms200.Sensor'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object
}
