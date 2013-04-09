Class USARAvatarNewMale extends USARAvatarNewCommon placeable;

defaultproperties
{
    DrawScale=0.6486 // This makes the avatar ~1.7m, the average height for a male
	GroundSpeed=300.0 // Currently, the male walks, the female runs

	//Mesh=SkeletalMesh'GenericMale.GenericMale_SimpBones'
	/* Warnings: invalid property value
    // Animation subset
    Mesh=SkeletalMesh'UDN_CharacterModels_K.GenericFemale'
    // Collision Boxes for a Female Victim
    SegCols(0)=(SegName="Bip02 Head",ColClass=class'GFHead',Offset=(X=30,Y=2,Z=0))
    SegCols(1)=(SegName="Bip02 L UpperArm",ColClass=class'GFUpperArm',Offset=(X=40,Y=0,Z=-5))
    SegCols(2)=(SegName="Bip02 R UpperArm",ColClass=class'GFUpperArm',Offset=(X=40,Y=0,Z=5))
    SegCols(3)=(SegName="Bip02 L Forearm",ColClass=class'GFForeArm',Offset=(X=40,Y=2,Z=0))
    SegCols(4)=(SegName="Bip02 R Forearm",ColClass=class'GFForeArm',Offset=(X=40,Y=2,Z=0))
    SegCols(5)=(SegName="Bip02 L Hand",ColClass=class'GFHand',Offset=(X=32,Y=0,Z=-4))
    SegCols(6)=(SegName="Bip02 R Hand",ColClass=class'GFHand',Offset=(X=32,Y=0,Z=4))
    SegCols(7)=(SegName="Bip02 Spine",ColClass=class'GFChest',Offset=(X=60,Y=-20,Z=0))
    SegCols(8)=(SegName="Bip02 Pelvis",ColClass=class'GFPelvis',Offset=(X=0,Y=4,Z=0))
    SegCols(9)=(SegName="Bip02 L Thigh",ColClass=class'GFThigh',Offset=(X=84,Y=0,Z=3))
    SegCols(10)=(SegName="Bip02 R Thigh",ColClass=class'GFThigh',Offset=(X=84,Y=0,Z=-3))
    SegCols(11)=(SegName="Bip02 L Calf",ColClass=class'GFCalf',Offset=(X=65,Y=6,Z=1))
    SegCols(12)=(SegName="Bip02 R Calf",ColClass=class'GFCalf',Offset=(X=65,Y=6,Z=1))
    SegCols(13)=(SegName="Bip02 L Foot",ColClass=class'GFFoot',Offset=(X=15,Y=-24,Z=0))
    SegCols(14)=(SegName="Bip02 R Foot",ColClass=class'GFFoot',Offset=(X=15,Y=-24,Z=0))
	*/

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'UsarAvatar_NewMale.Mesh.GenericMale'
		PhysicsAsset=PhysicsAsset'UsarAvatar_NewMale.Mesh.GenericMale_Physics'
		AnimTreeTemplate=AnimTree'UsarAvatar_NewMale.animation.AT_CH_Human'
		AnimSets(0)=AnimSet'UsarAvatar_NewMale.animation.GenericMale_AnimSet'
		Translation=(Z=-60.0)

         /*bUsePrecomputedShadows=FALSE
         BlockActors=TRUE
         BlockZeroExtent=TRUE 
         BlockNonZeroExtent=TRUE 
         BlockRigidBody=TRUE 
         HiddenGame=TRUE*/
         
		 //bNotifyRigidBodyCollision=true 
         //ScriptRigidBodyCollisionThreshold=0.001
         
/*
		MinDistFactorForKinematicUpdate=0
		bHasPhysicsAssetInstance=true
                HiddenGame=FALSE
                HiddenEditor=FALSE
                LightEnvironment=MyLightEnvironment
                bUpdateKinematicBonesFromAnimation=true
		bUpdateJointsFromAnimation=true
		PhysicsWeight=1.0
		BlockRigidBody=true
		CollideActors=true
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=false
		RBChannel=RBCC_Pawn
		RBCollideWithChannels=(Default=true,BlockingVolume=TRUE,EffectPhysics=true,GameplayPhysics=true)
		*/
	End Object

	//CollisionComponent=WPawnSkeletalMeshComponent

	//Physics=PHYS_Interpolating
/*
   BounceForce=3500
   BlockRigidBody=TRUE 
   bCollideActors=TRUE 
   bBlockActors=TRUE 
   bWorldGeometry=FALSE 
   bCollideWorld=TRUE 
   bNoEncroachCheck=FALSE 
   bProjTarget=TRUE 
   bUpdateSimulatedPosition=FALSE 
   bStasis=FALSE*/
}
