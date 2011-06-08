class SmokeLocalDynamicParticle extends Emitter
                                  implements(SmokeInterface);                             
                                  
var(Smoke) float SmokeDensity;

var float fKillMySelf;

function float GetDensity(optional vector hitLocation)
{
    return SmokeDensity;
}

function bool IsInsideSmoke( actor a )
{
    return false;
}

function bool SmokeAlwaysBlock()
{
    return true;
}


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
    
    // Use LifeSpan? Seems to be 0 all the time
    fKillMySelf = WorldInfo.TimeSeconds + 10.0;
    
	SetCollision( true, true, true );
    CylinderComponent(CollisionComponent).SetCylinderSize( 32, 32 );
}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    
    if( fKillMySelf < WorldInfo.TimeSeconds)
    {
        Destroy();
        return;
    }
    
    Move( ParticleSystemComponent.Bounds.origin - Location );
}

defaultproperties
{
    TickGroup=TG_PreAsyncWork 
    
    SmokeDensity=1.0;
    

	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false 
 	CollisionType=COLLIDE_BlockWeapons
 
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=38.0
		CollisionHeight=150.0
		BlockNonZeroExtent=false
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
			
	CollisionComponent=CollisionCylinder
	
	Components.Add(CollisionCylinder)
    
    bNoDelete=false
    bHardAttach=false
    bDestroyOnSystemFinish=true
}
