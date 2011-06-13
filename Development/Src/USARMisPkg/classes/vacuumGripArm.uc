/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class vacuumGripArm extends MissionPackage placeable config (USAR);

var Actor grippedObject;
var Pose grippedObjectOffset;
var Pose vehiclePoseInGripped; // gives the vehicle pose in the gripped objects frame. 
                               // This pose should remain constant while object is gripped.
var int gDebug;
var int dirty; // should we turn back on physics
var float suctionLength; // the distance away from the effector that the suction will work
var float lastBoneOffset; // the length of the last bone; offset from elbow to end
var int vacuumBone; // the number of the bone that the vacuum is attached to
var EPhysics originalPhysics;
var EPhysics platformPhysics;
var int vacuumBreak; // 0 - platform will be blocked by collisions, 1 - vacuum will break due to collisions.

simulated function ConvertParam()
{
	super.ConvertParam();
	suctionLength = -class'UnitsConverter'.static.LengthToUU(suctionLength);
	lastBoneOffset = -class'UnitsConverter'.static.LengthToUU(lastBoneOffset) * DrawScale;
}

simulated function PostBeginPlay()
{
	local array<name> boneNames;
	
	super.postBeginPlay();
	SetBase(Owner);
	SkelMeshComp.GetBoneNames(boneNames);
	if (vacuumBone < 0 || vacuumBone >= boneNames.Length)
		vacuumBone = boneNames.Length - 1;
	dirty = 0;
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
	local Pose boxTransformInv;
	local vector lastBone, rayAxis;

	// Only one component that matches
	foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
	{
		SkelMeshComp.GetBoneNames(boneNames);
		break;
	}
		
	grippedObject = _object;
	originalPhysics = grippedObject.Physics;
	grippedObject.SetPhysics(PHYS_None);

	// Get last joint information
	rayAxis = SkelMeshComp.GetBoneAxis(boneNames[vacuumBone], AXIS_Z);
	lastBone = SkelMeshComp.GetBoneLocation(boneNames[vacuumBone], 0);
	
	// Get where box should attach
	grippedObjectOffset.rot = SkelMeshComp.GetBoneQuaternion(boneNames[vacuumBone], 0);
	grippedObjectOffset.tran = lastBone + (rayAxis * lastBoneOffset);
	grippedObjectOffset = class'PoseMath'.static.PoseInvert(grippedObjectOffset);
	boxTransform.tran = grippedObject.Location;
	boxTransform.rot = QuatFromRotator(grippedObject.Rotation);
	grippedObjectOffset = class'PoseMath'.static.PosePoseMult(grippedObjectOffset, boxTransform);
	if (gDebug > 0)
		LogInternal( "Set grippedObject to bone " $ (boneNames.Length-1) );
	// Compute vehiclePoseInGripped
	boxTransformInv = class'PoseMath'.static.PoseInvert(boxTransform);
	// Overloaded use of boxTransform to represent vehicle pose
	boxTransform.tran = Platform.CenterItem.Location;
	boxTransform.rot = QuatFromRotator(Platform.CenterItem.Rotation);
	vehiclePoseInGripped = class'PoseMath'.static.PosePoseMult(boxTransformInv, boxTransform);
}

function ungripObject()
{
	grippedObject.SetPhysics(originalPhysics);
	grippedObject = None;
}

simulated function Tick(float DT2)
{
	local array<name> boneNames;
	local vector lastBone;
	local rotator rotTransform;
	local vector rayAxis, rayEnd, rayStart;
	local Pose tempMatrix;
	local float distance;

	// See if we should do anything
	if (dirty == 1)
	{
		dirty = 0;
		Platform.CenterItem.ForceUpdateComponents();	
		Platform.CenterItem.SetPhysics(platformPhysics);
	}
	else if (dirty > 1)
		dirty--;
	else {
		// Only one component that matches
		foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
		{
			SkelMeshComp.GetBoneNames(boneNames);
			break;
		}
		
		// Get last joint information
		rayAxis = SkelMeshComp.GetBoneAxis(boneNames[vacuumBone], AXIS_Z);
		lastBone = SkelMeshComp.GetBoneLocation(boneNames[vacuumBone], 0);
		// Get where box should attach
		rayStart = lastBone + (rayAxis * lastBoneOffset);
		// Get location of rayEnd (only used for drawing line)
		rayEnd = lastBone + (rayAxis * suctionLength);
		
		if (gDebug > 0)
			DrawDebugLine(rayStart, rayEnd, 0, 0, 255); // blue line for ray
		
		if (grippedObject != None) {
			tempMatrix.rot = SkelMeshComp.GetBoneQuaternion(boneNames[vacuumBone], 0);
			tempMatrix.tran = rayStart;
			tempMatrix = class'PoseMath'.static.PosePoseMult(tempMatrix, grippedObjectOffset);
			grippedObject.SetLocation(tempMatrix.tran);
			rotTransform = QuatToRotator(tempMatrix.rot);
			grippedObject.SetRotation(rotTransform);
			grippedObject.ForceUpdateComponents();
			
			// Check distance, if too great, then break connection
			distance = sqrt((grippedObject.Location.x - tempMatrix.tran.x) * (grippedObject.Location.x - tempMatrix.tran.x) +
				(grippedObject.Location.y - tempMatrix.tran.y) * (grippedObject.Location.y - tempMatrix.tran.y) +
				(grippedObject.Location.z - tempMatrix.tran.z) * (grippedObject.Location.z - tempMatrix.tran.z));
			if (distance > 5)
			{
				if (vacuumBreak >= 1)
					ungripObject();
				else
				{
					// Restore physics
					platformPhysics = Platform.CenterItem.Physics;
					tempMatrix.tran = grippedObject.Location;
					tempMatrix.rot = QuatFromRotator(grippedObject.Rotation);
					tempMatrix = class'PoseMath'.static.PosePoseMult(tempMatrix, vehiclePoseInGripped);
					Platform.CenterItem.SetPhysics(PHYS_None);
					Platform.CenterItem.SetLocation(tempMatrix.tran);
					Platform.CenterItem.SetRotation(QuatToRotator(tempMatrix.rot));
					dirty = 2;
				}
			}
			if (gDebug > 0)
				// Draw green line to gripped object
				DrawDebugLine(rayStart, grippedObject.Location, 0, 255, 0);
		}
	}
    super.tick(DT2);
}

reliable server function setGripperToBox(int Gripper)
{
	local array<name> boneNames;
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
			// get last joint information
			rayAxis = SkelMeshComp.GetBoneAxis(boneNames[vacuumBone], AXIS_Z);
			lastBone = SkelMeshComp.GetBoneLocation(boneNames[vacuumBone], 0);
	
			// get where box should attach
			rayStart = lastBone + (rayAxis * lastBoneOffset);
	
			// get location of rayEnd
			rayEnd = lastBone + (rayAxis * suctionLength);

			A = Trace(HitLocation, HitNormal, rayEnd, rayStart, true);
			if (A == None)
				`log("Trace: Nothing to grip from bone " $ (boneNames.Length - 1));
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
	vacuumBreak=1;
	vacuumBone=-1;
	grippedObject=None;
	gDebug=0;
	suctionLength=.25;
	lastBoneOffset=.66;
}
