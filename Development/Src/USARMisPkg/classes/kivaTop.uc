/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class kivaTop extends vacuumGripArm placeable config (USAR);

defaultproperties
{
	gDebug=1;
	suctionLength=-.25;
	lastBoneOffset=.20;
	vacuumBone=1;
	vacuumBreak=0;
	DrawScale=1;
	
	Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'kiva.SkeletalMesh.kivaTop';
		PhysicsAsset=PhysicsAsset'kiva.PhysicsAsset.kivaTop_Physics';
		AnimTreeTemplate=AnimTree'kiva.AnimTree.kivaTop_AnimTree';
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

	CollisionType=COLLIDE_BlockAll;
	Components(1)=SKMesh01;
	CollisionComponent=SKMesh01;
	
	// Joint Max Limit (rad), Joint Min Limit (rad), Joint Max Speed (m/s or rad/s), Init Speed, Joint Max Torque
	JointSpecs[0]=( MaxLimit=0, MinLimit=0, MaxSpeed=0, InitSpeed=0, MaxTorque=20 );
	JointSpecs[1]=( MaxLimit=-3.228, MinLimit=3.228, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -185 to 185
	// The previous line was ported directly; there is no typo (Init speed > max speed).
}
