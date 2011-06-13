/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class krArm extends MissionPackage placeable config (USAR);

var Actor grippedObject;
var Pose grippedObjectOffset;
var RB_ConstraintActor constraint;
var int scale;
var int gDebug;
var float suctionLength; // the distance away from the effector that the suction will work
var float lastBoneOffset; // the length of the last bone; offset from elbow to end
var float platformAngle; // yaw of platform in radians
var vector goalLocation; // the goal location for the 7th joint
var int movePos; // is the 7th joint moving in a positive direction (1 or -1)

simulated function ConvertParam()
{
	super.ConvertParam(); // first convert parent object
	suctionLength = -class'UnitsConverter'.static.LengthToUU(suctionLength);
	lastBoneOffset = -class'UnitsConverter'.static.LengthToUU(lastBoneOffset) * DrawScale;
}

reliable server function runSequence(int Sequence)
{
	switch(Sequence)
	{
	case 1:
		gDebug = 1;
		break;
	case 0:
		gDebug = 0;
		break;
	default:
	}
}

function gripObject(Actor _object) 
{
	local array<name> boneNames;
	local Pose boxTransform;
	local name lastName;
	local vector lastBone, rayAxis;

	// Only one component that matches
	foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
	{
		SkelMeshComp.GetBoneNames(boneNames);
		break;
	}
		
	grippedObject = _object;
	grippedObject.SetPhysics(PHYS_None);
	lastName=boneNames[boneNames.Length - 1];

	// Get last joint information
	rayAxis = SkelMeshComp.GetBoneAxis(lastName, AXIS_Z);
	lastBone = SkelMeshComp.GetBoneLocation(lastName, 0);
	
	// Get where box should attach
	grippedObjectOffset.rot = SkelMeshComp.GetBoneQuaternion(lastName, 0);
	grippedObjectOffset.tran = lastBone + (rayAxis * lastBoneOffset);
	grippedObjectOffset = class'PoseMath'.static.PoseInvert(grippedObjectOffset);
	boxTransform.tran = grippedObject.Location;
	boxTransform.rot = QuatFromRotator(grippedObject.Rotation);
	grippedObjectOffset = class'PoseMath'.static.PosePoseMult(grippedObjectOffset, boxTransform);
	if (gDebug > 0)
		LogInternal("Set grippedObject");
}

function ungripObject()
{
	grippedObject.SetPhysics(PHYS_RigidBody);
	grippedObject = None;
}

simulated function Tick(float DT2)
{
	local array<name> boneNames;
	local vector lastBone;
	local name lastName;
	local rotator rotTransform;
	local vector rayAxis, rayEnd, rayStart;
	local Pose tempMatrix;
	
	// Only one component that matches
	foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
	{
		SkelMeshComp.GetBoneNames(boneNames);
		break;
	}
	
	// Get last joint information
	lastName=boneNames[boneNames.Length - 1];
	rayAxis = SkelMeshComp.GetBoneAxis(lastName, AXIS_Z);
	lastBone = SkelMeshComp.GetBoneLocation(lastName, 0);
	
	// get where box should attach
	rayStart = lastBone + (rayAxis * lastBoneOffset);
	
	// get location of rayEnd
	rayEnd = lastBone + (rayAxis * suctionLength);

	if (gDebug > 0)
		DrawDebugLine(rayStart, rayEnd, 0, 0, 255);
	
	if (grippedObject != None) {
		tempMatrix.rot = SkelMeshComp.GetBoneQuaternion(lastName, 0);
		tempMatrix.tran = rayStart;
		tempMatrix = class'PoseMath'.static.PosePoseMult(tempMatrix, grippedObjectOffset);
		grippedObject.SetLocation(tempMatrix.tran);
		rotTransform = QuatToRotator(tempMatrix.rot);
		grippedObject.SetRotation(rotTransform);
		grippedObject.ForceUpdateComponents();
		if (gDebug > 0)
			DrawDebugLine(rayStart, grippedObject.Location, 0, 255, 0);
	}
    super.tick(DT2);
}

reliable server function setGripperToBox(int Gripper)
{
	local array<name> boneNames;
	local name lastName;
	local Actor A;
	local vector HitLocation, HitNormal;
	local vector rayAxis, rayEnd, lastBone, rayStart;
	
	switch(Gripper)
	{
		case 0:
			ungripObject();
			break;

		case 1:
			// Only one component that matches
			foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
			{
				SkelMeshComp.GetBoneNames(boneNames);
				break;
			}
			
			// Get last joint information
			lastName=boneNames[boneNames.Length - 1];
			rayAxis = SkelMeshComp.GetBoneAxis(lastName, AXIS_Z);
			lastBone = SkelMeshComp.GetBoneLocation(lastName, 0);
	
			// get where box should attach
			rayStart = lastBone + (rayAxis * lastBoneOffset);
	
			// get location of rayEnd
			rayEnd = lastBone + (rayAxis * suctionLength);

			A = Trace(HitLocation, HitNormal, rayEnd, rayStart, true);
			if (A == None)
				`log("Trace: Nothing to grip...");
			else 
			{
				if (gDebug > 0)
				{
					`log(A);
					`log("... can be gripped...");
				}
				gripObject(A);
			}
			break;

		default:
			LogInternal("kr60ArmGripper: Default");
			break;
	}
}

defaultproperties
{
	grippedObject=None;
	scale=1;
	gDebug=0;
	suctionLength=.25;
	lastBoneOffset=.66;
	DrawScale=0.3;	
	CollisionType=COLLIDE_BlockAll;
	
	// Joint Max Limit (rad), Joint Min Limit (rad), Joint Max Speed (m/s or rad/s), Init Speed, Joint Max Torque
	JointSpecs[0]=( MaxLimit=0, MinLimit=0, MaxSpeed=0, InitSpeed=0, MaxTorque=20 );
	JointSpecs[1]=( MaxLimit=-3.228, MinLimit=3.228, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -185 to 185
	JointSpecs[2]=( MaxLimit=-0.61, MinLimit=2.356, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -35 to 135
	JointSpecs[3]=( MaxLimit=-2.757, MinLimit=2.094, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -158 to 120
	JointSpecs[4]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -350 to 350
	JointSpecs[5]=( MaxLimit=-2.076, MinLimit=2.076, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -119 to 119
	JointSpecs[6]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, InitSpeed=2, MaxTorque=20 ); // -350 to 350
}
