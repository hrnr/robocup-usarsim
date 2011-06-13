/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARVehicle: parent class of all USAR Robots. Descend actual robot classes from the appropriate vehicle
 * type such as WheeledRobot or AirRobot.
 */
class USARVehicle extends BaseVehicle config(USAR);

// Enables or disables volumeOverride
var config bool bUseVolumeOverride;
// Whether an acoustic sensor is installed
var bool HasAcoustic;
// Whether this robot is normalized
var bool Normalized;
// Location and rotation where the robot started, to fix bug where robot moves after spawning
// changing locations of subsequent parts
var vector OriginalLocation;
var rotator OriginalRotation;
// Vehicle's installed battery
var Battery VehicleBattery;
// Value between 0.0001 (muted) and 1.0 (normal volume) used to change all sound volumes
var config float volumeOverride;

// Called when the battery has died in order to stop all current actions like driving
simulated function BatteryDied()
{
	LogInternal("USARVehicle: Battery is dead");
}

// Sends out status messages per timer if set (parent method is empty)
simulated function ClientTimer()
{
	MessageSendDelegate(GetStatus());
	UpdateJoints();
}

// Creates an empty robot actor when isDummy is true on a Part spec
function PhysicalItem CreateDummyActor(vector loc, rotator r)
{
	local PhysicalItem dummy;
	
	dummy = Spawn(class'PhysicalItem', self , , loc, r);
	dummy.SetPhysicalCollisionProperties();
	dummy.SetCollision(true, false);
	return dummy;
}

// Notify when this vehicle is removed
simulated event Destroyed()
{
	if (bDebug)
		LogInternal("USARVehicle: Destroyed");
	super.Destroyed();
}

// Gets the estimated life remaining in the battery; negative is a dead battery
simulated function int GetBatteryLife()
{
	if (VehicleBattery == None)
		return super.GetBatteryLife();
	else
		return VehicleBattery.ExpectedLifeTime();
}

// Gets configuration data from effectors matching the given type and/or name
simulated function String GetEffectorConfData(String effectorType, String effectorName)
{
	return GetGeneralConfData('Effector', effectorType, effectorName);
}

// Gets geometry data from effectors matching the given type and/or name
simulated function String GetEffectorGeoData(String effectorType, String effectorName)
{
	return GetGeneralGeoData('Effector', effectorType, effectorName);
}

// Compiles configuration data from items of the given type and name
function String GetGeneralConfData(name itemClass, String itemType, String itemName)
{
	local String outStr;
	local int i;
	local int firstIndex;
	
	// Look for items
	outStr = "";
	firstIndex = -1;
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA(itemClass) && Parts[i].isType(itemType) && (itemName == "" ||
			Parts[i].isName(itemName)))
		{
			// Filter matched, return data
			outStr = outStr $ " " $ Parts[i].GetConfData();
			if (firstIndex < 0)
				firstIndex = i;
		}
	
	// Add header from first item
	if (outStr != "")
		outStr = Parts[firstIndex].GetConfHead() $ outStr;
	return outStr;
}

// Compiles geometry data from items of the given type and name
function String GetGeneralGeoData(name itemClass, String itemType, String itemName)
{
	local String outStr;
	local int i;
	local int firstIndex;
	
	// Look for items
	outStr = "";
	firstIndex = -1;
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA(itemClass) && Parts[i].isType(itemType) && (itemName == "" ||
			Parts[i].isName(itemName)))
		{
			// Filter matched, return data
			outStr = outStr $ " " $ Parts[i].GetGeoData();
			if (firstIndex < 0)
				firstIndex = i;
		}
	
	// Add header from first item
	if (outStr != "")
		outStr = Parts[firstIndex].GetGeoHead() $ outStr;
	return outStr;
}

// Gets a part's offset from the robot center, taking offsets of parents into account
simulated function vector GetJointOffset(Joint jt)
{
	local vector pos;
	
	pos = class'UnitsConverter'.static.MeterVectorToUU(jt.Offset);
	if (jt.RelativeTo != None)
		pos += GetPartOffset(jt.RelativeTo);
	return pos;
}

// Gets configuration data from all mission packages
function String GetMisPkgConfData()
{
	local String outStr;
	local int i;
	
	// Look for mission packages
	outStr = "CONF {Type MisPkg}";
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('MissionPackage'))
			outStr = outStr $ " " $ Parts[i].GetConfData();
	return outStr;
}

// Gets geometry data from all mission packages
function String GetMisPkgGeoData()
{
	local String outStr;
	local int i;
	
	// Look for mission packages
	outStr = "GEO {Type MisPkg}";
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('MissionPackage'))
			outStr = outStr $ " " $ Parts[i].GetGeoData();
	return outStr;
}

// Gets a part's offset from the robot center, taking offsets of parents into account
simulated function vector GetPartOffset(Part pt)
{
	local vector pos;
	
	pos = class'UnitsConverter'.static.MeterVectorToUU(pt.Offset);
	if (pt.RelativeTo != None)
		pos += GetPartOffset(pt.RelativeTo);
	return pos;
}

// Finds the rotation of MyRotation relative to BaseRotation
simulated function rotator GetRelativeRotation(rotator MyRotation, rotator BaseRotation)
{
	local vector X, Y, Z;
	
	GetAxes(MyRotation, X, Y, Z);
	return OrthoRotation(X << BaseRotation, Y << BaseRotation, Z << BaseRotation);
}

// Gets configuration data from sensors matching the given type and/or name
simulated function String GetSensorConfData(String sensorType, String sensorName)
{
	return GetGeneralConfData('Sensor', sensorType, sensorName);
}

// Gets geometry data from sensors matching the given type and/or name
simulated function String GetSensorGeoData(String sensorType, String sensorName)
{
	return GetGeneralGeoData('Sensor', sensorType, sensorName);
}

// Gets robot status sent out on each tick
simulated function String GetStatus()
{
	return "STA ";
}

// Initializes the robot after play begins
simulated function PostBeginPlay()
{
	local int i;
	super.PostBeginPlay();
	
	// Fix for bug where robot moves after spawning
	OriginalLocation = Location;
	OriginalRotation = Rotation;
	
	// Initialize parts
	CenterItem = None;
	for (i = 0; i < PartList.Length; i++)
		SetupPart(PartList[i]);
	// Warn on null body
	if (CenterItem == None)
	{
		LogInternal("USARVehicle: Vehicle body not intialized, defaulting to first part");
		LogInternal("USARVehicle:  To fix this warning, declare Body=<item> in properties");
		// Can't fail, only physical items are in the array to begin with
		CenterItem = PhysicalItem(Parts[0]);
	}
	// Initialize joints
	for (i = 0; i < Joints.Length; i++)
		SetupJoint(Joints[i]);
	// Initialize items (sensors etc)
	for (i = 0; i < AddParts.Length; i++)
		SetupItem(AddParts[i]);
}

// Restores the part's rotation and location to the specified values to deal with symmetry
// See TempRotatePart
simulated function RestoreRotatePart(Actor p, vector savedPosition, rotator savedRotation)
{
	p.SetRotation(savedRotation);
	p.SetLocation(savedPosition);
}

// Sets the damping factor for all joints
function SetAllJointsDamping(float damping)
{
	local int i;

	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
			SetJointDamping(JointItem(Parts[i]), damping);
}

// Sets the maximum force for all joints
function SetAllJointsMaxForce(float force)
{
	local int i;

	for (i = 0; i < Joints.Length; i++)
		if (Parts[i].IsJoint())
			SetJointMaxForce(JointItem(Parts[i]), force);
}

// Sets all joint angles to the specified angle
function SetAllJointAngles(int UUAngle)
{
	local int i;
	
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
			SetJointTarget(JointItem(Parts[i]), UUAngle);
}

// Set the angular target of a constraint using a rotator
function SetAngularTarget(RB_ConstraintActor constraint, Rotator rot)
{
	local Quat q;
	q = QuatFromRotator(rot);
	constraint.ConstraintInstance.SetAngularPositionTarget(q);
}

// Updates the specified joint's angle
function SetJointAngle(String jointName, int UUAngle)
{
	local int i;
	local JointItem ji;
	
	// Look for matching joint using proper name (joint name, NOT JointItem name)
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			if (Caps(String(ji.GetJointName())) == Caps(jointName))
			{
				SetJointTarget(ji, UUAngle);
				break;
			}
		}
}

// Sets the damping of a joint given its index
function SetJointDamping(JointItem ji, float damping)
{
	// Recalculate using damping
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(ji.MaxForce * ji.Stiffness,
		damping, ji.MaxForce * ji.Stiffness);
	if (bDebug)
		LogInternal("USARVehicle: Set damping of '" $ String(ji.GetJointName()) $
			"' to " $ class'UnitsConverter'.static.FloatString(damping));
}

// Sets the maximum force of a joint
function SetJointMaxForce(JointItem ji, float force)
{
	ji.MaxForce = force;
	
	// Recalculate using force
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(force * ji.Stiffness,
		0.25, force * ji.Stiffness);
	if (bDebug)
		LogInternal("USARVehicle: Set max force of '" $ String(ji.GetJointName()) $
			"' to " $ class'UnitsConverter'.static.FloatString(force));
}

// Sets the stiffness of a joint
function SetJointStiffness(JointItem ji, float stiffness)
{
	ji.Stiffness = stiffness;
	
	// Recalculate using stiffness
	ji.Constraint.ConstraintInstance.SetAngularDriveParams(ji.MaxForce *
		stiffness, 0.25, ji.MaxForce * stiffness);
	if (bDebug)
		LogInternal("USARVehicle: Set stiffness of '" $ String(ji.GetJointName()) $
			"' to " $ class'UnitsConverter'.static.FloatString(stiffness));
}

// Sets the stiffness of a joint given its name
function SetJointStiffnessByName(name jointName, float stiffness)
{
	local int i;
	local JointItem ji;
	
	// Look for matching joint using proper name (joint name, NOT JointItem name)
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			if (Caps(String(ji.GetJointName())) == Caps(jointName))
			{
				SetJointStiffness(ji, stiffness);
				break;
			}
		}
}

// Updates the joint at the given index
function SetJointTarget(JointItem ji, int UUAngle)
{
	local Joint jt;
	local rotator angle;
	local int target;
	
	jt = ji.Spec;
	
	// Update the values to match new target
	target = UUAngle + ji.TrueZero;
	ji.CurAngularTarget = target;
	angle = rot(0, 0, 0);
	
	// Update angle as appropriate to the joint type
	if (jt.JointType == JOINTTYPE_Pitch)
		angle.pitch = target;
	else if (jt.JointType == JOINTTYPE_Yaw)
		angle.yaw = target;
	else if (jt.JointType == JOINTTYPE_Roll)
		angle.roll = target;
	SetAngularTarget(ji.Constraint, angle);
	if (bDebug)
		LogInternal("USARVehicle: Set target of '" $ String(jt.Name) $
			"' to " $ class'UnitsConverter'.static.AngleFromUU(UUAngle));
}

// Adjusts the mass of the specified item to match reality (takes mass in UU)
function SetMass(Item actor, float DesiredMass)
{
	local float oldScale, oldMass;
	local RB_BodySetup bs;

	// Change auto calculated mass to the desired mass
	DesiredMass = class'UnitsConverter'.static.MassToUU(DesiredMass);
	bs = actor.StaticMeshComponent.StaticMesh.BodySetup;
	oldMass = actor.StaticMeshComponent.BodyInstance.GetBodyMass();
	oldScale = bs.MassScale;
	if (oldMass > 0.0 && oldScale > 0.0)
	{
		bs.MassScale = DesiredMass / (oldMass / oldScale);
		actor.StaticMeshComponent.BodyInstance.UpdateMassProperties(bs);
		if (bDebug)
			LogInternal("USARVehicle: Set mass of '" $ String(actor.Name) $ "' to " $
				class'UnitsConverter'.static.FloatString(DesiredMass) $ " uu");
	}
	else if (bDebug)
		LogInternal("USARVehicle: " $ String(actor.Name) $ " has zero mass, cannot scale");
}

// Normalizes or un-normalizes this vehicle
reliable server function SetNormalized(bool nom)
{
	Normalized = nom;
	if (bDebug)
		LogInternal("USARVehicle: Set normalized of '" $ String(self.Name) $ "' to " $ nom);
}

// In the future this should be done on each robot camera change so that we hear the active robot's sensor
// only, if it does in fact have an acoustic sensor
reliable server function SetupAudio()
{
	local AudioDevice AD;
	
	// If we have not initialized audio before, set flag now
	if (HasAcoustic)
		return;
	else
		HasAcoustic = true;
	
	// Get the audio device attached to this game
	AD = class'Engine'.static.GetAudioDevice();
	if (bUseVolumeOverride)
		// Config dictates using volumeOverride value for game volume
		AD.TransientMasterVolume = volumeOverride;
	else
		// Robot has an acoustic sensor so turn sound volume to normal
		AD.TransientMasterVolume = 1.0;
	if (bDebug)
		LogInternal("USARVehicle: Initialized audio for '" $ String(Name));
}

// Creates and initializes an Item from its specification in the INI file
reliable server function SetupItem(SpecItem desc)
{
	local Item it;
	local vector pos;
	local rotator dir;
	
	// Creates a new item of the specified class
	pos = class'UnitsConverter'.static.LengthVectorToUU(desc.Position);
	dir = class'UnitsConverter'.static.AngleVectorToUU(desc.Direction);
	pos = pos >> OriginalRotation;
	
	// Create item actor
	it = Item(spawn(desc.ItemClass, self, , OriginalLocation + pos, OriginalRotation + dir));
	it.SetHardAttach(true);
	it.SetBase(CenterItem);
	
	// Initialize item
	it.init(desc.ItemName, self, desc.Parent);
	if (bDebug)
		LogInternal("USARVehicle: Created part " $ String(it.Name));
	
	// Set up batteries properly (into its variable)
	if (it.isA('Battery'))
		VehicleBattery = Battery(it);
	
	// Set up audio sensor
	if (it.IsType("Acoustic"))
		SetupAudio();
	
	// Add item to world
	Parts.AddItem(it);
}

// Initializes joints and their corresponding constraints
reliable server function SetupJoint(Joint jt)
{
	local JointItem ji;
	local vector spawnLocation, savedLocation;
	local rotator spawnRotation, savedRotation, angle;
	local Matrix rotMatrix;
	local int trueZero, limitHigh, limitLow;
	
	// NOTE: Constraint limits are always symmetrical, but joints can be asymmetrical
	// Make the limits symmetrical; map set angles to the actual constraint limits
	limitHigh = class'UnitsConverter'.static.AngleToUU(jt.LimitHigh);
	limitLow = class'UnitsConverter'.static.AngleToUU(jt.LimitLow);
	trueZero = int((-limitHigh - limitLow) / 2.0);
	// Create instance to store actual joint parameters
	spawnRotation = class'UnitsConverter'.static.AngleVectorToUU(jt.Angle);
	spawnLocation = GetJointOffset(jt) >> OriginalRotation;
	ji = Spawn(class'JointItem', self, '', OriginalLocation + spawnLocation, OriginalRotation +
		spawnRotation);
	ji.SetHardAttach(true);
	ji.SetBase(CenterItem);
	ji.TrueZero = trueZero;
	ji.Spec = jt;
	
	// Find parts for parent and child
	ji.Parent = GetPartByName(jt.Parent.Name);
	if (ji.Parent == None)
	{
		LogInternal("USARVehicle: Could not find parent for " $ String(jt.Name));
		return;
	}
	ji.Child = GetPartByName(jt.Child.Name);
	if (ji.Child == None)
	{
		LogInternal("USARVehicle: Could not find child for " $ String(jt.Name));
		return;
	}
	
	// Initialize parameters
	ji.CurAngularTarget = trueZero;
	ji.MaxForce = jt.MaxForce;
	ji.Constraint = Spawn(class'Hinge', self, '', OriginalLocation + spawnLocation,
		OriginalRotation + spawnRotation);
	ji.SetHardAttach(true);
	ji.SetBase(CenterItem);
	angle = rot(0, 0, 0);
	
	// Setup joint limits of movement (depending on the joint type)
	if (jt.JointType == JOINTTYPE_Pitch)
	{
		angle.Pitch = trueZero;
		ji.Constraint.ConstraintSetup.bSwingLimited = false;
		ji.Constraint.ConstraintSetup.bTwistLimited = true;
	}
	else if (jt.JointType == JOINTTYPE_Yaw)
	{
		angle.Yaw = trueZero;
		ji.Constraint.ConstraintSetup.bSwingLimited = false;
		ji.Constraint.ConstraintSetup.bTwistLimited = true;
	}
	else if (jt.JointType == JOINTTYPE_Roll)
	{
		angle.Roll = trueZero;
		ji.Constraint.ConstraintSetup.bSwingLimited = true;
		ji.Constraint.ConstraintSetup.bTwistLimited = false;
	}
	else if (jt.JointType == JOINTTYPE_Fixed)
	{
		ji.Constraint.ConstraintSetup.bSwingLimited = true;
		ji.Constraint.ConstraintSetup.bTwistLimited = true;
	}
	else if (jt.JointType == JOINTTYPE_Free)
	{
		ji.Constraint.ConstraintSetup.bSwingLimited = false;
		ji.Constraint.ConstraintSetup.bTwistLimited = false;
	}
	ji.Constraint.ConstraintSetup.LinearXSetup.LimitSize = 0.0;
	ji.Constraint.ConstraintSetup.LinearYSetup.LimitSize = 0.0;
	ji.Constraint.ConstraintSetup.LinearZSetup.LimitSize  = 0.0;
	ji.Constraint.ConstraintSetup.bEnableProjection = true;
	
	// Perform fix to handle asymmetrical joints
	TempRotatePart(ji.Spec, ji.Child, angle, savedLocation, savedRotation);
	ji.Constraint.InitConstraint(ji.Parent, ji.Child, , , 6000.0);
	RestoreRotatePart(ji.Child, savedLocation, savedRotation);

	// Joints can specify a rotation to modify the constraint axis
	// The constraint will be initialized again with the new axis.
	rotMatrix = MakeRotationMatrix(class'UnitsConverter'.static.AngleVectorToUU(jt.RotateAxis));
	ji.Constraint.ConstraintSetup.PriAxis1 = TransformVector(rotMatrix,
		ji.Constraint.ConstraintSetup.PriAxis1);
	ji.Constraint.ConstraintSetup.SecAxis1 = TransformVector(rotMatrix,
		ji.Constraint.ConstraintSetup.SecAxis1);
	ji.Constraint.ConstraintSetup.PriAxis2 = TransformVector(rotMatrix,
		ji.Constraint.ConstraintSetup.PriAxis2);
	ji.Constraint.ConstraintSetup.SecAxis2 = TransformVector(rotMatrix,
		ji.Constraint.ConstraintSetup.SecAxis2);
	ji.Constraint.ConstraintInstance.InitConstraint(ji.Parent.CollisionComponent,
		ji.Child.CollisionComponent, ji.Constraint.ConstraintSetup, 1, self,
		ji.Parent.CollisionComponent, false);
	
	// Enable angular drive and set the initial drive parameters
	if (jt.JointType == JOINTTYPE_Pitch || jt.JointType == JOINTTYPE_Yaw)
	{
		ji.Constraint.ConstraintInstance.SetAngularPositionDrive(true, false);
		SetJointStiffness(ji, 1.0);
	}
	else if (jt.JointType == JOINTTYPE_Roll)
	{
		ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, true);
		SetJointStiffness(ji, 1.0);
	}
	else if (jt.JointType == JOINTTYPE_Fixed)
	{
		ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
		SetJointStiffness(ji, 1.0);
	}
	else
		ji.Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
	
	// Set initial angle
	SetJointTarget(ji, 0);
	Parts.AddItem(ji);
	if (bDebug)
		LogInternal("USARVehicle: Created joint '" $ String(ji.Name) $ "' for spec " $
			String(jt.Name));
}

// Sets up a part's parameters and spawns it into the world (static constrained pieces)
reliable server function SetupPart(Part part)
{
	local PhysicalItem actor;
	local vector spawnLocation;
	local rotator spawnRotation;
	
	// Determine start location
	spawnRotation = class'UnitsConverter'.static.AngleVectorToUU(part.Direction);
	spawnLocation = GetPartOffset(part) >> OriginalRotation;
	if (part.IsDummy)
		actor = CreateDummyActor(OriginalLocation + spawnLocation,
			OriginalRotation + spawnRotation);
	else
	{
		actor = Spawn(class'PhysicalItem', self, '', OriginalLocation + spawnLocation,
			OriginalRotation + spawnRotation);
		actor.Spec = part;
		actor.StaticMeshComponent.SetStaticMesh(part.Mesh);
		actor.SetPhysicalCollisionProperties();
	}
	SetMass(actor, part.Mass);
	
	// Initialize center item properly (for sensors and parenting reasons)
	if (part.Name == Body.Name)
	{
		CenterItem = actor;
		if (bDebug)
			LogInternal("USARVehicle: Found vehicle body " $ String(Body.Name));
	}
	
	// Add item into world
	Parts.AddItem(actor);
	if (bDebug)
		LogInternal("USARVehicle: Created part '" $ String(actor.Name) $ "' for spec " $
			String(part.Name));
}

// TempRotatePart and RestoreRotatePart are used to deal with the problem that the constraint 
// angle limits are specified symmetrically. The part is temporary rotated so the high and
// low limits become symmetrical if there were not already when initializing the constraint
simulated function TempRotatePart(Joint jt, Actor p, Rotator angle,
	out vector savedPosition, out rotator savedRotation)
{
	local Vector pos, jointpos;
	
	// Save old position and location
	savedPosition = p.Location;
	savedRotation = p.Rotation;
	
	// Transform position and direction temporarily
	jointpos = OriginalLocation + GetJointOffset(jt);
	pos = TransformVectorByRotation(angle, p.Location - jointpos);
	p.SetRotation(p.Rotation + angle);
	p.SetLocation(pos + jointpos);
}

// Check battery; if alive, call client timer functions
simulated function Timer()
{
	if (GetBatteryLife() > 0)
		super.Timer();
}

// Updates the joint angles to match the constraint pointers
simulated function UpdateJoints()
{
	local int i;
	local JointItem ji;
	local PhysicalItem parent, child;
	local float angle;
	local rotator relRot, rotTemp;
	local vector X1, Y1, Z1, X2, Y2, Z2;

	// Iterate through joints and update their positions (CurAngle) to match the UU angles
	// of the Constraint instance inside them
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			parent = ji.Parent;
			child = ji.Child;
			if (parent == None || child == None)
				continue;
			if (ji.Spec.InverseMeasure)
				relRot = GetRelativeRotation(parent.Rotation, child.Rotation);
			else 
				relRot = GetRelativeRotation(child.Rotation, parent.Rotation);
			
			// Determine measurement type for drive
			if (ji.Spec.MeasureType == EMEASURE_Pitch)
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Pitch);
			else if (ji.Spec.MeasureType == EMEASURE_Yaw)
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Yaw);
			else if (ji.Spec.MeasureType == EMEASURE_Roll)
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Roll);
			else if (ji.Spec.MeasureType == EMEASURE_Pitch_RemoveYaw)
			{
				rotTemp = rot(0, 0, 0);
				rotTemp.Yaw = -relRot.Yaw;
				relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Pitch);
			}
			else if (ji.Spec.MeasureType == EMEASURE_Yaw_RemovePitch)
			{
				rotTemp = rot(0, 0, 0);
				rotTemp.Pitch = -relRot.Pitch;
				relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Yaw);
			}
			else if (ji.Spec.MeasureType == EMEASURE_Yaw_RemoveRoll)
			{
				rotTemp = rot(0, 0, 0);
				rotTemp.Roll = -relRot.Roll;
				relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Yaw);
			}
			else if (ji.Spec.MeasureType == EMEASURE_Roll_RemoveYaw)
			{
				rotTemp = rot(0, 0, 0);
				rotTemp.Yaw = -relRot.Yaw;
				relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Roll);
			}
			else if (ji.Spec.MeasureType == EMEASURE_Roll_RemovePitch)
			{
				rotTemp = rot(0, 0, 0);
				rotTemp.Pitch = -relRot.Pitch;
				relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
				angle = class'UnitsConverter'.static.AngleFromUU(relRot.Roll);
			}
			else if (ji.Spec.MeasureType == EMEASURE_Axis)
			{
				GetAxes(parent.Rotation, X1, Y1, Z1);
				GetAxes(child.Rotation, X2, Y2, Z2);
				angle = acos(X1 dot X2);
				// Assume X1 and X1 are within 90 degrees to the left or right
				// Then we still need to know if the angle is positive or negative
				if (acos((Normal(X1 cross Z1)) dot X2) < 0.0)
					angle = -angle;
			}
			
			// Update angle representation
			if (ji.Spec.InverseMeasureAngle)
				angle = -angle;
			ji.CurAngle = angle;
		}
}

defaultproperties 
{
	bDebug=false
	bNoDelete=false
	bStatic=false
	HasAcoustic=false
	Normalized=false
	Physics=PHYS_None
}
