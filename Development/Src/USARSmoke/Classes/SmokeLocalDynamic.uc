//=============================================================================
// Emitter actor class.
// Copyright 2010 Sander, Inc. All Rights Reserved.
//=============================================================================
class SmokeLocalDynamic extends Actor
    placeable;

	
var(Smoke) float SpawnRate;  
var(Smoke) int SpawnEmittersCount;
var(Smoke) float PauseIntervalMin;
var(Smoke) float PauseIntervalMax;
var(Smoke) float SpawnIntervalMin;
var(Smoke) float SpawnIntervalMax;

var float fNextChangeTime;
var bool bSpawning;

simulated event PostBeginPlay()
{  
	Super.PostBeginPlay();

    SetTimer(SpawnRate,true);
}

simulated
function Timer()
{
    local Emitter newemitter;
    local int i;
    
    // If we are not spawning, then we had a pause
    if( !bSpawning )
    {
        bSpawning = !bSpawning;
        SetTimer(SpawnRate,true);
        fNextChangeTime = WorldInfo.TimeSeconds + FRand()*(SpawnIntervalMax - SpawnIntervalMin) + SpawnIntervalMin;
    }
    
    // Spawn emitters
    for(i=0; i<SpawnEmittersCount; i++)
    {
        newemitter= Spawn( class'SmokeLocalDynamicParticle' );
        newemitter.SetLocation( Location );
        newemitter.SetRotation( Rotation );
        newemitter.SetTemplate( ParticleSystem'USARSmokePackage.SingleSmokeParticle' );
    }
    
    // See if we need to pause
    if( fNextChangeTime < WorldInfo.TimeSeconds )
    {
        SetTimer(FRand()*(PauseIntervalMax - PauseIntervalMin) + PauseIntervalMin,true);
        bSpawning = !bSpawning;
    }
}


defaultproperties
{
    SpawnRate=0.05;
    SpawnEmittersCount=1;
    bSpawning=true;
    PauseIntervalMin=0.15;
    PauseIntervalMax=0.5;
    SpawnIntervalMin=0.2;
    SpawnIntervalMax=0.4;

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_Emitter'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		bIsScreenSizeScaled=True
		ScreenSize=0.0025
	End Object
	Components.Add(Sprite)
}
