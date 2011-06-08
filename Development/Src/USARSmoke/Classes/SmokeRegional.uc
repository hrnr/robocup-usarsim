class SmokeRegional extends StaticMeshActor
                        implements(SmokeInterface);

var SmokeVolumeConstantDensityInfo DensityInfo;

function float GetDensity(optional vector hitLocation)
{
    if( DensityInfo == None ) {
        return 0.0;    
    }
	return FogVolumeConstantDensityComponent(DensityInfo.DensityComponent).Density;
}

function bool IsInsideSmoke( actor a )
{
    local SmokeRegional RSM;
    local vector HitLoc;
    local vector HitNorm;

    // Trace from actor location to the center of the smoke
    // If not obstructed by the smoke actor then we are inside the smoke
    ForEach a.TraceActors(class'SmokeRegional', RSM, HitLoc, HitNorm, Location, a.Location)
    {
        if( RSM == self )
            return false;
    }
    return true;
}

function bool SmokeAlwaysBlock()
{
    return false;
}

defaultproperties
{
	bStatic=false
	bMovable=false
    
    DensityInfo=None
	
    bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
    CollisionType=COLLIDE_BlockWeapons
    
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
        StaticMesh=StaticMesh'USARSmokePackage.RegionalSmokeBaseMesh'
		bAllowApproximateOcclusion=TRUE
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=TRUE
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1) 
}
