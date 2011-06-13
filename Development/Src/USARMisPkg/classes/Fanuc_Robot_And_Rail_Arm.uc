/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class Fanuc_Robot_And_Rail_Arm extends vacuumGripArm placeable config (USAR);

simulated function getRotation()
{
	// Joint 3's real value must compensate for 2's position
	Joints[3].ActualPos -= Joints[2].ActualPos;
}

simulated function updateRotation(int Link, float Value)
{
	if (2 == Link)
	{
		// Need to update joint 3 when joint 2 changes
		Joints[2].MotorCmd = Value;
		Joints[3].MotorCmd += Value;
	}
	else if (3 == Link)
		// Need to take 2 into account when changing 3
		Joints[3].MotorCmd = Value + Joints[2].MotorCmd;
	else
		super.updateRotation(Link, Value);
}

defaultproperties
{
	grippedObject=None;
	gDebug=0;
	suctionLength=.25;
	lastBoneOffset=.66;

	DrawScale=25;
	
	Begin Object Class=SkeletalMeshComponent Name=SKMesh01
		SkeletalMesh=SkeletalMesh'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Mesh';
		PhysicsAsset=PhysicsAsset'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Physics';
		AnimTreeTemplate=AnimTree'FANUC_ROBOT_AND_RAIL.fanuc_robot_rail_Anim';
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
	JointSpecs[1]=( MaxLimit=-2.967, MinLimit=2.967, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -170 to 170
	JointSpecs[2]=( MaxLimit=-1.571, MinLimit=2.793, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -90 to 160
	JointSpecs[3]=( MaxLimit=-2.967, MinLimit=4.538, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -170 to 260
	JointSpecs[4]=( MaxLimit=-3.491, MinLimit=3.491, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -200 to 200
	JointSpecs[5]=( MaxLimit=-2.443, MinLimit=2.443, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -140 to 140
	JointSpecs[6]=( MaxLimit=-7.854, MinLimit=7.854, MaxSpeed=2, InitSpeed=2, MaxTorque=20 ); // -450 to 450
	JointSpecs[7]=( MaxLimit=-0.001, MinLimit=3.260, MaxSpeed=1, InitSpeed=1, MaxTorque=20 ); // -1 to 3260 (mm)
}
