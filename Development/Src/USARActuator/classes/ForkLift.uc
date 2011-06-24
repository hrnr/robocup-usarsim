/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class ForkLift extends Actuator placeable config (USAR);

defaultproperties
{
	/*Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'ForkLift.MissionMesh'
		PhysicsAsset=PhysicsAsset'ForkLift.MissionPhys'
		AnimTreeTemplate=AnimTree'ForkLift.MissionAnim'
		bHasPhysicsAssetInstance=true
		bSkipAllUpdateWhenPhysicsAsleep=true
		bUpdateKinematicBonesFromAnimation=false

		PhysicsWeight=0.0
		CollideActors=true
		BlockActors=true
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=true, GameplayPhysics=true, EffectPhysics=true)
	End Object

	BaseSkelComponent=SKMesh01
	SkelMeshComp=SKMesh01

	CollisionType=COLLIDE_BlockAll
	Components(1)=SKMesh01
	CollisionComponent=SKMesh01
	
	// Joint Max Limit (rad), Joint Min Limit (rad), Joint Max Speed (m/s or rad/s), Init Speed, Joint Max Torque
	JointSpecs[0]=( MaxLimit=0, MinLimit=0, MaxSpeed=0, MaxTorque=20 )
	JointSpecs[1]=( MaxLimit=-0.1, MinLimit=0.1, MaxSpeed=.25, MaxTorque=20 ) // -0.1 to 0.1 (rad)
	JointSpecs[2]=( MaxLimit=0.0, MinLimit=5.0, MaxSpeed=.5, MaxTorque=20 ) // 0 to 5 (m)
	JointSpecs[3]=( MaxLimit=-0.9, MinLimit=5.0, MaxSpeed=.5, MaxTorque=20 ) // -0.9 to 5 (m)
	JointSpecs[4]=( MaxLimit=-1.0, MinLimit=1.0, MaxSpeed=.5, MaxTorque=20 ) // -1 to 1 (m)
	JointSpecs[5]=( MaxLimit=-0.5, MinLimit=0.5, MaxSpeed=.5, MaxTorque=20 ) // -0.5 to 0.5 (m)
	JointSpecs[6]=( MaxLimit=-0.5, MinLimit=0.5, MaxSpeed=.5, MaxTorque=20 ) // -0.5 to 0.5 (m)*/
}
