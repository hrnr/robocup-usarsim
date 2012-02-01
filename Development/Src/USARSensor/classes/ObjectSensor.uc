/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class ObjectSensor extends RangeScanner config (USAR);
// Define behavior inside smoke
function float GetRangeRecursive(Actor PrevHitActor, vector StartLocation,
	float maxRangeRemaining, float curRange, float penetrationPower, out vector FinalHitLocation, out Actor FinalHitActor, 
	optional out Material FinalHitMaterial)
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	local SmokeInterface smoke;
	local float range;
	local TraceHitInfo HitInfo;
	
	// Don't trace if we don't have anything left
	if (maxRangeRemaining <= 0.0)
		return curRange;
		
	// Start a new trace
	HitActor = PrevHitActor.Trace(HitLocation, HitNormal, StartLocation + maxRangeRemaining *
		vector(curRot), StartLocation, true,,HitInfo);
	smoke = SmokeInterface(HitActor);
	range = VSize(HitLocation - StartLocation);

	// Hitted nothing
	if (HitActor == None)
	{
		FinalHitLocation = StartLocation + maxRangeRemaining * vector(curRot);
		FinalHitActor = None;
		return curRange + maxRangeRemaining;
	}

	// No smoke, so a normal object. Smoke that uses particles always block.
	if (smoke == None || smoke.SmokeAlwaysBlock())
	{
		FinalHitLocation = HitLocation;
		FinalHitActor = HitActor;
		FinalHitMaterial = HitInfo.Material;
		return curRange + VSize(HitLocation - StartLocation);
	}

	// Probably hitted regional smoke. The SICK will ignore the this type of smoke for now.
	FinalHitLocation = HitLocation;
	return GetRangeRecursive(HitActor, HitLocation, maxRangeRemaining - range,
		curRange + range, penetrationPower, FinalHitLocation, FinalHitActor, FinalHitMaterial);
}
function float GetRange()
{
	local float range;
	local vector HitLocation;
	local Actor HitActor;
	range = GetRangeRecursive(self, Location, MaxRange, 0.0, 0.00575, HitLocation, HitActor);
	// Finally convert to meters
	range = class'UnitsConverter'.static.LengthFromUU(VSize(HitLocation - Location));
	if(range >= MaxRange)
		DrawDebugLine(Location, HitLocation, 255, 0, 0, true);
	else
		DrawDebugLine(Location, HitLocation, 0, 255, 0, true);
	return range;
}
function DoScan(out Actor HitObject, out Material material)
{
	local vector HitLocation;
	local Actor HitActor;
	local Material HitMaterial;
	local float range;
	range = GetRangeRecursive(self, Location, MaxRange, 0.0, 0.00575, HitLocation, HitActor, HitMaterial);
	
	HitObject = HitActor;
	material = HitMaterial;
	if(bDebug)
	{	
		if(range >= MaxRange)
			DrawDebugLine(Location, HitLocation, 255, 0, 0, true);
		else
			DrawDebugLine(Location, HitLocation, 0, 255, 0, true);
	}
}
function String GetData()
{	
	local int i, c;
	local Actor hit;
	local rotator turn;
	local Material mat;
	local String packetAppend;
	local array<Actor> hitActors;
	local array<Material> hitMaterials;
	if(bDebug)
		FlushPersistentDebugLines();
	time = WorldInfo.TimeSeconds;
	// from right to left
	for (i = ScanFov / 2; i >= -ScanFov / 2; i -= Resolution)
	{
		if (bYaw)
			turn.Yaw = i;
		if (bPitch)
			turn.Pitch = i;
		curRot = class'Utilities'.static.rTurn(Rotation, turn);
		DoScan(hit, mat);
		if(hit != None && hitActors.Find(hit) == INDEX_NONE)
		{
			hitActors.AddItem(hit);
			if(StaticMeshActor(hit) != None)
			{
				for(c = 0;c<StaticMeshActor(hit).StaticMeshComponent.GetNumElements();c++)
				{
					mat = Material(StaticMeshActor(hit).StaticMeshComponent.GetMaterial(c));
					if(mat != None && hitMaterials.Find(mat) == INDEX_NONE)
						hitMaterials.AddItem(mat);
				}
			}
		} else if(hit != None)
		{
			if(mat != None && hitMaterials.Find(mat) == INDEX_NONE)
				hitMaterials.AddItem(mat);
		}
		
	}
	packetAppend = "{Name " $ ItemName $ "}";
	for(i = 0;i<hitActors.Length; i++)
	{
		packetAppend $= " {Object} {"$string(hitActors[i].Tag)$" "$
									string(class'UnitsConverter'.static.LengthVectorFromUU(hitActors[i].Location))$
									" "$string(class'UnitsConverter'.static.AngleVectorFromUU(hitActors[i].Rotation))$"}";
	}
	for(i = 0;i<hitMaterials.Length;i++)
	{
		packetAppend $= " {Material "$ string(hitMaterials[i].Name) $"}";
	}
	return packetAppend;
}
defaultproperties
{
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=true
	bCollideWorld=true
	ItemType = "ObjectSensor";
	ItemName = "ObjectSensor";
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'SICKSensor.lms200.Sensor'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object
}
