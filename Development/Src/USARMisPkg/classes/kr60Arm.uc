/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

class kr60Arm extends VacuumGripArm placeable config (USAR);

defaultproperties
{
	DrawScale=0.3;
	
	Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'kr60Arm.SkeletalMesh.kr60Arm';
		PhysicsAsset=PhysicsAsset'kr60Arm.SkeletalMesh.kr60Arm_Physics';
		AnimTreeTemplate=AnimTree'kr60Arm.SkeletalMesh.kr60Arm_AnimTree';
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
	JointSpecs[2]=( MaxLimit=-0.61, MinLimit=2.356, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -35 to 135
	JointSpecs[3]=( MaxLimit=-2.757, MinLimit=2.094, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -158 to 120
	JointSpecs[4]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -350 to 350
	JointSpecs[5]=( MaxLimit=-2.076, MinLimit=2.076, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -119 to 119
	JointSpecs[6]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -350 to 350
}
