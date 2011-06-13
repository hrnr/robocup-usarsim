/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * MissionPackage - parent all mission packages (sets of effectors to mount on a robot)
 */
class MissionPackage extends Item abstract config (USAR);

// Structure storing configuration information about a joint (replaces parallel arrays)
struct JointSpec {
	var float MinLimit;
	var float MaxLimit;
	var float MaxSpeed;
	var float InitSpeed;
	var float MaxTorque;
};

// Structure storing runtime information about a joint (replaces parallel arrays)
struct ArmJoint {
	var float ActualPos;
	var SkelControlSingleBone BoneControl;
	var name BoneName;
	var float FinalPos;
	var float MotorCmd;
	var float RelativePos;
	var float Speed;
	var float Step;
	var bool Update;
};

// Number of valid joints in the mission package
var int BoneCount;
// Actual delta time for the update function
var float DT;
// Joint state information
var array<ArmJoint> Joints;
// Joint configuration
var array<JointSpec> JointSpecs;
// Override for joint count automatically determined from array lengths
var config int NumberOfJoints;
// TODO replace with static meshes
var SkeletalMeshComponent SkelMeshComp;

// Send mission package status
simulated function ClientTimer()
{
	MessageSendDelegate(GetHead() @ GetData());
}

// Initializes the bone information and controllers in the joint status array
function CollectBoneInfo()	
{
	local array<name> boneNames;
	local int i;
	
	// Find bones in the skeletal mesh component
	Joints.Length = JointSpecs.Length;
	foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) 
	{
		// Count the bones
		SkelMeshComp.GetBoneNames(BoneNames);
		if (NumberOfJoints <= 0)
			BoneCount = BoneNames.Length;	
		else
			BoneCount = NumberOfJoints + 1;
		
		// Find controllers
		for (i = 1; i < BoneCount; i++)
		{
			Joints[i].BoneControl = SkelControlSingleBone(SkelMeshComp.FindSkelControl(
				name("Joint" $ i $ "Control")));
			Joints[i].BoneName=BoneNames[i];
			Joints[i].RelativePos = 0.0;
			Joints[i].Speed = JointSpecs[i].InitSpeed;
			Joints[i].Update = false;
		}
		
		// Should be only one skeletal mesh per package
		break;
	}
}

// Returns an array of the last-set positions of the joints on this mission package
function array<float> GetCommandPos()
{
	local array<float> commands;
	local int i;
	
	// Collect from array
	commands.Length = Joints.Length;
	for (i = 0; i < Joints.Length; i++)
	{
		commands[i] = Joints[i].MotorCmd;
	}
	return commands;
}

// Gets configuration data from the mission package
function String GetConfData() {
	local int i;
	local JointSpec joint1;
	local String outStr;
	local String jointType;
	outStr = "{Name " $ ItemName $ "} ";
	
	for (i = 1; i < BoneCount; i++) {
		joint1 = JointSpecs[i];
		// Determine joint type
		if (Joints[i].BoneControl.bApplyTranslation) 
			jointType = "Prismatic";
		else 
			jointType = "Revolute";
		// Create configuration string
		outStr = outStr $ "{Link " $ i $ "} {JointType " $ jointType $
			"} {MaxRotationSpeed " $ joint1.MaxSpeed $ "} {MaxTorque " $ 
			joint1.MaxTorque $ "} {MinRange " $ joint1.MinLimit $ "} {MaxRange " $
			joint1.MaxLimit $ "} ";
	}
	// FIXME -- add an effector on the end
	if (false)
		outStr = outStr $ "\r\nCONF {Type Effector} {Name " $ ItemName $
			"} {Opcode Grip} {MaxVal 1} {MinVal 0}";
	LogInternal(outStr);
	return outStr;
}

// Gets data from this mission package (joint locations)
function String GetData()
{
	local String missionPackageData;
	local int i;
	local float value;
	local float torque;
	
	// TODO convert to static meshes
	for (i = 1; i < BoneCount; i++) 
	{
		if (Joints[i].BoneControl.bApplyTranslation)
			value = class'UnitsConverter'.static.LengthFromUU(Joints[i].RelativePos) * DrawScale;
		else
			value = class'UnitsConverter'.static.AngleFromUU(Joints[i].RelativePos);
		Joints[i].ActualPos = value;
	}
	getRotation();
	missionPackageData = "";
	for (i = 1; i < BoneCount; i++) 
	{
		torque = 0;		/* FIXME - how do we get this? */
		value = Joints[i].ActualPos;
		if (missionPackageData != "")
			missionPackageData = missionPackageData $ " ";
		missionPackageData = missionPackageData $ "{Link " $ i $ "} {Value " $ value $
			"} {Torque " $ torque $ "}";
	}
	return missionPackageData;
}

// Gets geometry data from the mission package
function String GetGeoData()
{
	local array<name> boneNames;
	local String outStr;
	local int i;
	local int parentLink;
	local vector rawBoneLocation;
	local vector adjustedBoneLocation;
	local rotator rawBoneRotator;
	local vector adjustedBoneRotation;
	
	outStr = "{Name " $ ItemName $ "}";
	foreach ComponentList (class 'SkeletalMeshComponent', SkelMeshComp) {
		SkelMeshComp.GetBoneNames(boneNames);
		LogInternal("Number of bones: " $ BoneCount);

		/*
		 * Note the the first bone is the non-moving base, and should be ignored;
		 * we index from 1 accordingly.
		 */
		for (i = 1; i < BoneCount; i++) {
			outStr = outStr $ " {Link " $ i $ "} {ParentLink ";
			if (string(SkelMeshComp.GetParentBone(boneNames[i])) == "None")
				parentLink = -1;
			else {
				parentLink = int(Mid(SkelMeshComp.GetParentBone(boneNames[i]), 5));
				/* the parent link indexes are one more than we want them labeled,
				so subtract one accordingly */
				parentLink = parentLink - 1;
			}
			outStr = outStr $ parentLink $ "}";
			
			/*
			 * We need to use relative bone locations, since we are reporting
			 * links with respect to the base, and since we're using relative
			 * locations we need to scale by the DrawScale.
			 */
			rawBoneLocation = SkelMeshComp.GetBoneLocation(boneNames[i], 1);
			adjustedBoneLocation = scaleLengthVector(
				class'UnitsConverter'.static.LengthVectorFromUU(rawBoneLocation));
			outStr = outStr $ " {Location " $ adjustedBoneLocation $ "}";
			rawBoneRotator = QuatToRotator(SkelMeshComp.GetBoneQuaternion(boneNames[i], 1));
			adjustedBoneRotation = class'UnitsConverter'.static.AngleVectorFromUU(rawBoneRotator);
			outStr = outStr $ " {Orientation " $ adjustedBoneRotation $ "}";
			
			LogInternal(boneNames[i] $ " parent: " $ SkelMeshComp.GetParentBone(boneNames[i]));
			rawBoneLocation = SkelMeshComp.GetBoneLocation(boneNames[i], 0);
			LogInternal("Raw World: " $ class'UnitsConverter'.static.VectorString(rawBoneLocation));
			rawBoneLocation = SkelMeshComp.GetBoneLocation(boneNames[i], 1);
			LogInternal("Raw Local: " $ class'UnitsConverter'.static.VectorString(rawBoneLocation));
			rawBoneRotator = QuatToRotator(SkelMeshComp.GetBoneQuaternion(boneNames[i], 0));
			LogInternal("Raw Rotation: " $ class'UnitsConverter'.static.RotatorString(rawBoneRotator));
			rawBoneLocation = SkelMeshComp.GetBoneAxis(boneNames[i], AXIS_X); 
			LogInternal("X-Axis: " $ class'UnitsConverter'.static.VectorString(rawBoneLocation));
			rawBoneLocation = SkelMeshComp.GetBoneAxis(boneNames[i], AXIS_Y); 
			LogInternal("Y-Axis: " $ class'UnitsConverter'.static.VectorString(rawBoneLocation));
			rawBoneLocation = SkelMeshComp.GetBoneAxis(boneNames[i], AXIS_Z); 
			LogInternal("Z-Axis: " $ class'UnitsConverter'.static.VectorString(rawBoneLocation));
		}
		break;
	}
	LogInternal(outStr);
	return outStr;
}

// Gets header information for this mission package
simulated function String GetHead()
{
	return "MISSTA {Time " $ WorldInfo.TimeSeconds $ "} {Name " $ ItemName $ "}";
}

// Keeps the joint value in bounds
function float NormalizeValue(float targetValue, int Link)
{
	local float newValue;
	
	if (targetValue < JointSpecs[Link].MinLimit)
		newValue = JointSpecs[Link].MinLimit;
	else if (targetValue > JointSpecs[Link].MaxLimit)
		newValue = JointSpecs[Link].MaxLimit;
	else
		newValue = targetValue;
	return newValue;
}

// Using the Joints[] array and the member ActualPos, user can implement gearing equations
simulated function getRotation()
{
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CollectBoneInfo();
}

reliable server function runSequence(int Sequence)
{
}

// Scales a length vector to the draw scale
simulated function vector ScaleLengthVector(vector vin)
{
	return vin * DrawScale;
}

reliable server function setGripperToBox(int Gripper)
{
}

// This was the old code in setThisRotation, segregated to allow better user control
simulated function SetRotationDo(int Link, float Value)
{
	local ArmJoint joint1;
	local int newRotation;
	local int newSpeed;
	local float theValue, step;
	joint1 = Joints[Link];
	theValue = NormalizeValue(Value, Link);
	
	if (joint1.BoneControl.bApplyRotation)
	{
		// Reserved for message containing speed (right now fixed)
		newSpeed = class'UnitsConverter'.static.SpinSpeedToUU(joint1.Speed);
		newRotation = class'UnitsConverter'.static.AngleToUU(theValue); 
	}
	else if (joint1.BoneControl.bApplyTranslation)
	{
		theValue = theValue / DrawScale;
		newSpeed = class'UnitsConverter'.static.SpeedToUU(joint1.Speed);
		// Reserved for message containing speed (right now fixed)
		newRotation = class'UnitsConverter'.static.LengthToUU(theValue);
	}
	// Step size based on simulation update rate
	step = newSpeed * DT;
	if (newRotation < joint1.RelativePos)
		step = -step;
	// Update
	joint1.FinalPos = newRotation;
	joint1.Step = step;
	joint1.Update = true;
}

// Changes the position of the given link to a new value
reliable server function SetThisRotation(int Link, float Value, int Order)
{
	local SkelControlSingleBone BoneControl;
	local array<float> motorCmdOld;
	local int out_DeltaViewAxis, i;
		
	// Check that 'Link' is within range
	if (Link >= 0 && Link < BoneCount) {
		motorCmdOld.Length = BoneCount;
		// Copy old values
		for (i = 0; i < BoneCount; i++)
			motorCmdOld[i] = Joints[i].MotorCmd;
		BoneControl = Joints[Link].BoneControl;
		BoneControl.ClampRotAxis(BoneControl.BoneRotation.Yaw, out_DeltaViewAxis,
			-32768, 32767);
		if (Order == 0)
		{
			// User control update
			updateRotation(Link, Value);
			for (i = 1; i < BoneCount; i++)
				// Set rotation per joint if different
				if (motorCmdOld[i] != Joints[i].MotorCmd)
					SetRotationDo(i, Joints[i].MotorCmd);
		}
	}
}

// Called each tick to move the package to its new location
function Tick(float DeltaTime)
{
	local float finalPos;
	local float pos;
	local int i;
	local int JointRemDist;
	local int out_DeltaViewAxis;
	local SkelControlSingleBone BoneControl;
	DT = DeltaTime;
	
	// Iterate through bones and update
	for (i = 0; i < BoneCount; i++)
	{
		BoneControl = Joints[i].BoneControl;
		if (Joints[i].Update)
		{
			finalPos = Joints[i].FinalPos;
			pos = Joints[i].RelativePos;
			BoneControl.ClampRotAxis(BoneControl.BoneRotation.Yaw, out_DeltaViewAxis,
				-32768, 32767);
			// Close enough?
			JointRemDist = finalPos - pos;
			if (abs(JointRemDist) <= abs(Joints[i].Step))
			{
				// Snap to position
				if (BoneControl.bApplyRotation)
					BoneControl.BoneRotation.Yaw = finalPos;
				else if (BoneControl.bApplyTranslation)
					BoneControl.BoneTranslation.Z = finalPos;
				pos = finalPos;
				Joints[i].Update = false;
			}
			else
			{
				// Iterate to position
				pos += Joints[i].Step;
				if (BoneControl.bApplyRotation)
					BoneControl.BoneRotation.Yaw = pos;
				else if (BoneControl.bApplyTranslation)
					BoneControl.BoneTranslation.Z = pos;
			}
			// Update coordinates
			Joints[i].RelativePos = pos;
		}
	}
	super.Tick(DT);
}

// Call ClientTimer on each scan interval
simulated function Timer()
{
	if (Platform.GetBatteryLife() > 0)
		ClientTimer();
}

// Using the Joints[] array and the member MotorCmd, user can implement gearing equations
simulated function updateRotation(int Link, float Value)
{
	Joints[Link].MotorCmd = Value;
}

defaultproperties
{
	BlockRigidBody=true;
	bCollideComplex=true;
	bCollideActors=true;
	bBlockActors=false;
	bProjTarget=true;
	bCollideWhenPlacing=true;
	bCollideWorld=true;
}
