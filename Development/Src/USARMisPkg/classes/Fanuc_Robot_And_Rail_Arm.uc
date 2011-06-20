/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

// TODO Has no model
class Fanuc_Robot_And_Rail_Arm extends VacuumArm placeable config (USAR);

simulated function array<float> getRotation(array<float> pos)
{
	// Joint 3's real value must compensate for 2's position
	pos[2] -= pos[1];
	return pos;
}

simulated function updateRotation(int Link, float Value)
{
	if (1 == Link)
	{
		// Need to update joint 3 when joint 2 changes
		CmdPos[1] = Value;
		CmdPos[2] += Value;
	}
	else if (2 == Link)
		// Need to take 2 into account when changing 3
		CmdPos[2] = Value + CmdPos[1];
	else
		super.updateRotation(Link, Value);
}

defaultproperties
{
	SuctionLength=.25
	
	/*Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Mesh'
		PhysicsAsset=PhysicsAsset'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Physics'
		AnimTreeTemplate=AnimTree'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Anim'
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
	JointSpecs[1]=( MaxLimit=-2.967, MinLimit=2.967, MaxSpeed=2, MaxTorque=20 ) // -170 to 170
	JointSpecs[2]=( MaxLimit=-1.571, MinLimit=2.793, MaxSpeed=2, MaxTorque=20 ) // -90 to 160
	JointSpecs[3]=( MaxLimit=-2.967, MinLimit=4.538, MaxSpeed=2, MaxTorque=20 ) // -170 to 260
	JointSpecs[4]=( MaxLimit=-3.491, MinLimit=3.491, MaxSpeed=2, MaxTorque=20 ) // -200 to 200
	JointSpecs[5]=( MaxLimit=-2.443, MinLimit=2.443, MaxSpeed=2, MaxTorque=20 ) // -140 to 140
	JointSpecs[6]=( MaxLimit=-7.854, MinLimit=7.854, MaxSpeed=2, MaxTorque=20 ) // -450 to 450
	JointSpecs[7]=( MaxLimit=-0.001, MinLimit=3.260, MaxSpeed=1, MaxTorque=20 ) // -1 to 3260 (mm)*/
}
