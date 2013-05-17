//USARAvatarNewCommon: Superclass handling functions for avatars
class USARAvatarNewCommon extends UTPawn config(USAR);

// Timer used for sending out pawn STA message, in seconds
var config float msgTimerSTA;

// Boolean variable that indicates whether the avatar is moving or not (set by the controller)
var bool isMoving; 

/*
 * Commented out functions that shows how to do the following (these are simple examples left for further development).
 *   1) Read (and log) the bone rotation of a specific bone name (Bip02-R-UpperArm)
 *   2) Play a custom animation (requires an AnimNodeSlot called 'CustomAnimation' inside the 'UsarAvatar_NewMale.animation.AT_CH_Human' AnimTree)
 *   3) Change the bone rotation of the 'Bip02-R-UpperArm' bone. In order to add limits, we use the UDKSkelControl_TurretConstrained skeletal control. Other skeletal controls could be used.
 *   4) Change the texture of an avatar in real-time (assumes the original Texture inside the material is called 'MaleTexture' and requires a new texture 'UsarAvatar_NewMale.Texture.GenericFemale_cloth')
 *   5) Functions triggered by collision detection engine 
 
// 2) Play a custom animation
var AnimNodeSlot CustomAnimation;

// 3) Change the bone rotation of the 'Bip02-R-UpperArm' bone
var UDKSkelControl_TurretConstrained Bip02RUpperArm;

// 4) Change the texture of an avatar in real-time
var MaterialInstanceConstant MatInst;
var Texture2D textureToApply;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
		
	// 2) Play a custom animation (requires an AnimNodeSlot called 'CustomAnimation' inside the 'UsarAvatar_NewMale.animation.AT_CH_Human')
    CustomAnimation = AnimNodeSlot(Mesh.FindAnimNode('CustomAnimation'));
    
    // 3) Change the bone rotation of the 'Bip02-R-UpperArm' bone
	Bip02RUpperArm = UDKSkelControl_TurretConstrained( mesh.FindSkelControl('Bip02RUpperArm') );
}

// 4) Change the texture of an avatar in real-time
simulated function PostBeginPlay()
{
   MatInst = new Class'MaterialInstanceConstant';
   MatInst.SetParent(Mesh.GetMaterial(0));
   textureToApply = Texture2D'UsarAvatar_NewMale.Texture.GenericFemale_cloth';
   MatInst.SetTextureParameterValue('MaleTexture', textureToApply);
   Mesh.SetMaterial(0, MatInst);

   Super.PostBeginPlay();
}

simulated function Tick(Float Delta)
{
	local vector boneRotation;

    super.Tick(Delta);

    // 1) Read (and log) the bone rotation of a specific bone name (Bip02-R-UpperArm)
	boneRotation = class'UnitsConverter'.static.UUQuatToVector(mesh.GetBoneQuaternion('Bip02-R-UpperArm'));
    `Log("Bip02-R-UpperArm Bone Rotation: " @ boneRotation.X @ boneRotation.Y @ boneRotation.Z);
    
    // 2) Play a custom animation (requires an AnimNodeSlot called 'CustomAnimation' inside the 'UsarAvatar_NewMale.animation.AT_CH_Human')
    CustomAnimation.PlayCustomAnim('WalkF', 0.4);
    
    // 3) Change the bone rotation of the 'Bip02-R-UpperArm' bone
	Bip02RUpperArm.DesiredBoneRotation.Pitch+=100; // Note that this value is in UU! Use a converter to be able to use radians/degrees...
}

// 5) Functions triggered by collision detection engine
//       Please note that RigidBodyCollision only gets triggerred when teh Physics is set to PHYS_RigidBody
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    `log("USARAVatar: Touch Called");
}

event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
{
    `log("USARAVatar: Bump Called");
}

simulated event RigidBodyCollision (PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
    `log("USARAVatar: RigidBodyCollision Called");
}

event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	`Log("USARAVatar: Hit Wall Called");
}
*/


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
  
	SetPhysics(PHYS_Walking); // wake the physics up

	// Note: this allows the event RigidBodyCollision to be triggered by does not allow animations to be played
	//SetPhysics(PHYS_RigidBody);

	// Sets up collision detection based on mesh's PhysicsAsset
	SetCollision(true, true);
	CylinderComponent.SetActorCollision(false, false); // disable cylinder collision
	Mesh.SetActorCollision(true, true); // enable PhysicsAsset collision
	Mesh.SetBlockRigidBody(true);
	Mesh.SetNotifyRigidBodyCollision(true);
	Mesh.SetTraceBlocking(true, true); // block traces (i.e. anything touching mesh)
	CollisionComponent.SetActorCollision(true, true);
	CollisionComponent.SetBlockRigidBody(true);
	CollisionComponent.SetNotifyRigidBodyCollision(true);
	CollisionComponent.SetTraceBlocking(true, true);
	

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

DefaultProperties
{
	ControllerClass=class'USARAvatar.USARAvatarNewController'

	// Various properties, from UTPawn, that can be overwritten
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
		bSynthesizeSHLight=true
	End Object
	Components.Add(AvatarLightEnvironment);

	Begin Object Name=WPawnSkeletalMeshComponent
        bUsePrecomputedShadows=false
		bHasPhysicsAssetInstance=true
        HiddenGame=false
        HiddenEditor=false
        //bUpdateKinematicBonesFromAnimation=true
		//bUpdateJointsFromAnimation=true
		//PhysicsWeight=1.0
		BlockRigidBody=true
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		//RBChannel=RBCC_Pawn
		//RBCollideWithChannels=(Default=true,BlockingVolume=TRUE,EffectPhysics=true,GameplayPhysics=true)
	End Object
	CollisionComponent=WPawnSkeletalMeshComponent

    BlockRigidBody=true 
    bCollideActors=true 
    bBlockActors=true 
    bWorldGeometry=false 
    bCollideWorld=true 
	bCollideComplex=true
    //bNoEncroachCheck=FALSE 

	//msgTimerSTA=0.05
	isMoving=false
}

