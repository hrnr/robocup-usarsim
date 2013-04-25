//USARAvatarNewCommon: Superclass handling functions for avatars
class USARAvatarNewCommon extends UTPawn config(USAR);

// Timer used for sending out pawn STA message, in seconds
var config float msgTimerSTA;

//Test comment for GIT CHECK

// Boolean variable that indicates whether the avatar is moving or not (set by the controller)
var bool isMoving; 

//==========================================
// Set the physics here
//==========================================
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
  
	SetPhysics(PHYS_Walking); // wake the physics up

	//SetPhysics(PHYS_RigidBody);
	//SetCollision(true, false);
	//CollisionComponent.BodyInstance.EnableCollisionResponse(false);

	// set up collision detection based on mesh's PhysicsAsset
	CylinderComponent.SetActorCollision(false, false); // disable cylinder collision
	Mesh.SetActorCollision(true, true); // enable PhysicsAsset collision
	Mesh.SetTraceBlocking(true, true); // block traces (i.e. anything touching mesh)

	// Set up timer that will deliver messages
	SetTimer(msgTimerSTA, true, 'TimerSTA');
}

// Called by the system timer function
function TimerSTA()
{
	local String outStr;

    outStr = "STA"; // Header
    outStr = outStr $ " {Time " $ WorldInfo.TimeSeconds $ "}"; // Time
	outStr = outStr $ " {Type " $ self.Class $ "}"; // Class Type
	if(self.Tag == 'None')
		outStr = outStr $ " {Name " $ self.Name $ "}"; // Name of avatar
	else
		outStr = outStr $ " {Name " $ self.Tag $ "}"; // Name of avatar
	outStr = outStr $ " {Location " $ class'UnitsConverter'.static.LengthVectorFromUU(Location) $ "}"; // Location
	outStr = outStr $ " {Orientation " $ class'UnitsConverter'.static.AngleVectorFromUU(Rotation) $ "}"; // Class Type
    outStr = outStr $ " {Walking " $ isMoving $ "}"; // Class Type

	MessageSendDelegate(outStr);
}

/*
simulated function Tick(Float Delta)
{
	local vector boneRotation;

		super.Tick(Delta);

	boneRotation = class'UnitsConverter'.static.UUQuatToVector(mesh.GetBoneQuaternion('Bip02-R-UpperArm'));
    `Log("Bip02-R-UpperArm Bone Rotation: " @ boneRotation.X @ boneRotation.Y @ boneRotation.Z);

	// Potentially interesting functions:
	//native final function GetBoneNames(out array<name> BoneNames);

}
*/

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

// Callback mechanism which uses a delegate to send messages
simulated delegate MessageSendDelegate(String msg)
{
	// Function is delegated to BotConnection's ReceiveMessage function, so it is empty here
}
/*
simulated event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	`Log("RigidBodyCollision is colliding...");
	Super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
}
*/
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

	//msgTimerSTA=0.05
	isMoving=false
}

