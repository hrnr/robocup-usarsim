class SmokeLocalStatic extends Emitter
                       implements(SmokeInterface);
                       
var(Smoke) float SmokeDensity;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetCollision( true, true, true );
}

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

defaultproperties
{
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
 	CollisionType=COLLIDE_BlockWeapons
 
	SmokeDensity=0.5;

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponentFireSmokeEmitter
		Template=ParticleSystem'USARSmokePackage.FireSmokeEmitter'
	End Object
	
	ParticleSystemComponent=ParticleSystemComponentFireSmokeEmitter

	Begin Object Class=StaticMeshComponent Name=CollisionMesh
		StaticMesh=StaticMesh'USARSmokePackage.FireSmokeEmitterCollision'
		bAcceptsLights=true
		hiddenGame=true
		Translation=(X=0.0,Y=0.0,Z=+600.0)
	End Object
			
	CollisionComponent=CollisionMesh
	
	Components.Add(CollisionMesh)
	Components.Add(ParticleSystemComponentFireSmokeEmitter)
}
