/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class kr60ArmWithGripper extends krArm placeable config (USAR);

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'kr60ArmWithGripper.SkeletalMesh.kr60ArmWithGripper';
		PhysicsAsset=PhysicsAsset'kr60ArmWithGripper.SkeletalMesh.kr60ArmWithGripper_Physics';
		AnimTreeTemplate=AnimTree'kr60ArmWithGripper.SkeletalMesh.kr60ArmWithGripper_AnimTree';
		bHasPhysicsAssetInstance=true;
		bSkipAllUpdateWhenPhysicsAsleep=true;
		bUpdateKinematicBonesFromAnimation=false;

		PhysicsWeight=0.0f;
		CollideActors=true;
		BlockActors=true;
		BlockRigidBody=true;
		BlockZeroExtent=true;
		BlockNonZeroExtent=true;
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=true, GameplayPhysics=true, EffectPhysics=true)
	End Object

	BaseSkelComponent=SKMesh01;
	SkelMeshComp=SKMesh01;
	Components(1)=SKMesh01;
	CollisionComponent=SKMesh01;
}
