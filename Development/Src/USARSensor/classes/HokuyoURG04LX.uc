/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class HokuyoURG04LX extends RangeScanner config (USAR);

// Behavior inside smoke
function float GetRangeRecursive(Actor PrevHitActor, vector StartLocation,
	float maxRangeRemaining, float curRange, float penetrationPower, out vector FinalHitLocation)
{
    local vector HitLocation, HitNormal, TempHitLocation, TempHitNormal;
    local Actor HitActor, TempHitActor;
    local SmokeInterface smoke;
    local float range;
    local bool insideSmoke;

    // Stop tracing if we don't have any laser range left.
    if (maxRangeRemaining <= 0.0)
        return curRange;
       
	// Trace further from the last hit position
    smoke = SmokeInterface(PrevHitActor);
    if (smoke != None) // The previous hit actor was of the smoke kind
    {
        // Test if we are inside the smoke
        HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation + 50000 *
			vector(curRot), StartLocation, true); 
        TempHitActor = HitActor.Trace(TempHitLocation, TempHitNormal, HitLocation + 50000 *
			-vector(curRot), HitLocation, true); 
        if (VSize(TempHitLocation-StartLocation) > 1.0)
        {
            insideSmoke = TRUE;
            HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation +
				maxRangeRemaining * vector(curRot), StartLocation, true);
            if (VSize(HitLocation-StartLocation) > VSize(TempHitLocation-StartLocation))
            {
                HitActor = TempHitActor;
                HitLocation = TempHitLocation;
            }
        }
        else //Previous actor was not smoky
        {
            insideSmoke = FALSE;
            HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation +
				maxRangeRemaining * vector(curRot), StartLocation, true);
        }
        smoke = SmokeInterface(HitActor);
    }
    else
    {
        HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation + maxRangeRemaining *
			vector(curRot), StartLocation, true);
        smoke = SmokeInterface(HitActor);
        insideSmoke = (smoke != None) && (smoke.IsInsideSmoke( PrevHitActor ));
    }
    
    // Check global smoke penetration
    range = VSize(HitLocation-StartLocation);
    penetrationPower = penetrationPower - class'UnitsConverter'.static.LengthFromUU(range) *
		GetGlobalSmokeDensity();
    if (penetrationPower < 0.0)
    {
        FinalHitLocation = Location;
        return 0.0;
    }
    
    // Hitted nothing
    if (HitActor == None)
    {
        FinalHitLocation = HitLocation;
        return curRange + maxRangeRemaining;
    }
    
    // No smoke, so a normal object
    if (smoke == None || smoke.SmokeAlwaysBlock())
    {
        FinalHitLocation = HitLocation;
        return curRange + VSize(HitLocation-StartLocation);
    }
    
    // Smoke. Are we inside the smoke?
    if (insideSmoke)
    {
        // Update penetration power
        penetrationPower = penetrationPower - class'UnitsConverter'.static.LengthFromUU(range) *
			smoke.GetDensity();
    
        // Blocks. See nothing.
        if (penetrationPower < 0.0)
        {
            FinalHitLocation = Location;
            return 0.0;
        }
        
        // Start a new trace
        FinalHitLocation = HitLocation;
        
        return GetRangeRecursive(HitActor, HitLocation, maxRangeRemaining - range, curRange +
			range, penetrationPower, FinalHitLocation);
    }
    else
    {
        // Start a new trace
        // The penetration is updated "Inside" the smoke
        FinalHitLocation = HitLocation;
        return GetRangeRecursive(HitActor, HitLocation + 5.0 * vector(curRot), maxRangeRemaining -
			range, curRange + range, penetrationPower, FinalHitLocation);
    }
} 

//   Retreives the range data using trace and reports this range in UU or meters depending on presence of converter
//   The Trace method traces a line to point of first collision.
//   Takes actor calling trace collision properties into account.
//   Returns first hit actor, level if hit level, or none if hit nothing
function float GetRange()
{
	local float range;
    local vector HitLocation;
    
	// The value of 0.00575 density*meter has been found by experimentation.
	// This value is particular to the Hokuyo, see Formsma et al:
	// http://code.google.com/p/usarsim-smoke-fire/
    range = GetRangeRecursive(self, Location, MaxRange, 0.0, 0.00575, HitLocation);
    
    // Finally convert to meters
    range = class'UnitsConverter'.static.LengthFromUU(VSize(HitLocation - Location));
	return range;
}

function float GetGlobalSmokeDensity()
{
	local HeightFog fog;
	
	//Process global smoke behavior
	foreach AllActors(class'HeightFog',fog)
	{
		if (fog == None || fog.Location.z < Location.z)
			continue;
			
		return fog.Component.Density;
	}
	
	// no global smoke object was found
	return 0.0;
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
