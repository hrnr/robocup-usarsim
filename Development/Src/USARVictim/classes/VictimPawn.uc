class VictimPawn extends UTPawn config(USAR);

var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var SkeletalMesh defaultMesh;
var PhysicsAsset defaultPhysicsAsset;

var VictimController MyController;

var bool bplayed;
var Name AnimSetName;
var AnimNodeSequence MyAnimPlayControl;

var () array<NavigationPoint> MyNavigationPoints;

const MAX_TIMER_DELAY = 1;

defaultproperties
{
	AnimSetName="IDLE"

	Begin Object Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		ShadowFilterQuality=SFQ_High
	End Object

	Begin Object Name=WPawnSkeletalMeshComponent
		LightEnvironment           =MyLightEnvironment
		bOwnerNoSee                =False
		CastShadow                 =True

		BlockRigidBody             =TRUE
		BlockActors                =TRUE
		BlockZeroExtent            =TRUE
		//PhysicsWeight              =0
		
		bHasPhysicsAssetInstance   =FALSE
		bCastDynamicShadow         =TRUE
        CollideActors              =True
		//bEnableFullAnimWeightBodies=False
		//bPerBoneVolumeEffects      =True

		//bAllowApproximateOcclusion =True
		//bForceDirectLightMap       =True
		//bUsePrecomputedShadows     =False
		//bHasPhysicsAssetInstance=True;
		
		//Scale=0.2
		Scale=0.75

		//bPhysRigidBodyOutOfWorldCheck=TRUE
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE
		BlockNonZeroExtent=TRUE
		//bIgnoreControllersWhenNotRendered=FALSE // ?
		///bUpdateKinematicBonesFromAnimation=TRUE
		//bChartDistanceFactor=TRUE
		//bOverrideAttachmentOwnerVisibility=TRUE
		///bUpdateSkelWhenNotRendered=TRUE // ?
		bUseAsOccluder=TRUE
		LightingChannels=(Dynamic=TRUE)
		RBChannel=RBCC_Pawn
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled3=TRUE,Pawn=TRUE)
	End Object
	Mesh=WPawnSkeletalMeshComponent

	Components.Add(WPawnSkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0041.000000
		//CollisionHeight=+0044.000000
		CollisionHeight=+0022.000000
		BlockZeroExtent=false
		Scale=0.2
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder

	bCollideActors=true
	bPushesRigidBodies=true
	bStatic=false
	bMovable=false
	bCollideWorld=true
	CollisionType=COLLIDE_BlockAll 

	/*
	// older collision test
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0048.000000
		CollisionHeight=+0048.000000
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder
	CollisionType=COLLIDE_BlockAll 

	AlwaysRelevantDistanceSquared=+1960000.0
	bPhysRigidBodyOutOfWorldCheck=TRUE
	bRunPhysicsWithNoController=TRUE
	bNoEncroachCheck=FALSE

	bCollideWorld=TRUE
	*/
	
}

simulated function PostBeginPlay()
{
	SetPhysics(PHYS_Interpolating);

	if (MyController == none) {
		MyController=Spawn(class'VictimController', self);
		MyController.SetPawn(self);		
	}

	//SetTimer(1.0, false);
	//InitRagdoll();
	//ForceRagdoll();
}


simulated event Tick(float DeltaTime)
{
}
