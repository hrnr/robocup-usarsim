//USARAvatarNewCommon: Superclass handling functions for avatars
class USARAvatarNewCommon extends UTPawn;

//==========================================
// Set the physics here
//==========================================
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
  
	SetPhysics(PHYS_Walking); // wake the physics up
	
	// set up collision detection based on mesh's PhysicsAsset
	CylinderComponent.SetActorCollision(false, false); // disable cylinder collision
	Mesh.SetActorCollision(true, true); // enable PhysicsAsset collision
	Mesh.SetTraceBlocking(true, true); // block traces (i.e. anything touching mesh)
}

// Override global, family-based assignment of character model.
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	return;
}


function SpawnDefaultController()
{  
	if (Controller == none)
		ControllerClass=Class'USARAvatar.USARAvatarNewController';

	Super.SpawnDefaultController();
}


DefaultProperties
{
	ControllerClass=class'USARAvatar.USARAvatarNewController'

	// Various properties, from UTPawn, that can be overwritten
	bCollideComplex=false
	bCollideActors=true
    bCollideWorld=true

	bCanCrouch=false
	bCanClimbLadders=false
	bCanPickupInventory=false
	bCanDoubleJump=false
	//RotationRate=(Pitch=64000,Yaw=64000,Roll=64000)
	bCanStrafe=false
	bCanSwim=false
	bCanWalk=true

	GroundSpeed=440.0 // Changes the speed of the avatar, can be changed in uc code
	AirSpeed=440.0
	WaterSpeed=220.0
	DodgeSpeed=600.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78

	Begin Object Class=DynamicLightEnvironmentComponent Name=AvatarLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bSynthesizeSHLight=TRUE
	End Object
  
	Components.Add(AvatarLightEnvironment);
}

