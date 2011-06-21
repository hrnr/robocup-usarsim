/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * MissionPackage - parent all mission packages (sets of effectors to mount on a robot)
 * In essence mission packages are like mini robots mounted on a parent robot
 * It is possible to mount sensors or other mission packages on a mission package
 */
class MissionPackage extends Item abstract config (USAR);

// Array storing all configured subparts from the INI file
var config array<SpecItem> AddParts;
// Assign a Part to this field in properties to set as package base
var Part Body;
// Stores instance of Body so a GetPartByName is not called 3x+ per tick
var PhysicalItem CenterItem;
// Positions where the joints were last sent (for the gearing equations)
var array<float> CmdPos;
// Actual joints (duplicates the Parts array, for convenience)
var array<JointItem> JointItems;
// Joint configuration
var array<Joint> Joints;
// Location and rotation where the package started, to fix bug where package moves after spawning
// changing locations of subsequent parts
var vector OriginalLocation;
var rotator OriginalRotation;
// Components declared in the default properties
var array<Part> PartList;
// Array storing all active parts on the robot
var array<Item> Parts;

// Pass mission package messages to the platform
simulated function AttachItem()
{
	local int i;
	
	// Initialization
	MessageSendDelegate = Platform.ReceiveMessageFromEffector;	
	super.AttachItem();
	CmdPos.Length = Joints.Length;
	OriginalRotation = Rotation;
	OriginalLocation = Location;
	
	// Initialize parts
	CenterItem = None;
	if (PartList.Length < 1)
		LogInternal("MissionPackage: No parts in part list, was a PartList.Add(...) used?");
	for (i = 0; i < PartList.Length; i++)
		SetupPart(PartList[i]);
	// If no base, find one
	if (CenterItem == None)
	{
		LogInternal("MissionPackage: Package base not intialized, defaulting to first part");
		LogInternal("MissionPackage:  To fix this warning, declare Body=<item> in properties");
		// Cast cannot fail, only physical items are in the array to begin with
		if (Parts.Length > 0)
			MakeCenterItem(PhysicalItem(Parts[0]));
	}
	// Initialize joints
	JointItems.Length = Joints.Length;
	for (i = 0; i < Joints.Length; i++)
		JointItems[i] = SetupJoint(Joints[i]);
	// Initialize items (sensors, other mission packages, etc)
	for (i = 0; i < AddParts.Length; i++)
		SetupItem(AddParts[i]);
}

// Send mission package status
simulated function ClientTimer()
{
	MessageSendDelegate(GetHead() @ GetData());
}

// Called when the robot is destroyed
simulated event Destroyed()
{
	local int i;
	
	super.Destroyed();
	// Remove all parts
	for (i = 0; i < Parts.Length; i++)
		Parts[i].Destroy();
	JointItems.Length = 0;
}

// Finds the index of the joint whose child is the specified part
simulated function int FindParentIndex(Item p)
{
	local int i;

	// Find first joint whose "child" field is the specified part
	for (i = 0; i < JointItems.Length; i++)
		if (JointItems[i].Child.Name == p.Name)
			return i;
	return -1;
}

// Gets configuration data from the mission package
function String GetConfData() {
	local int i;
	local JointItem ji;
	local String outStr;
	local String jointType;
	
	outStr = "{Name " $ ItemName $ "}";
	for (i = 0; i < JointItems.Length; i++)
	{
		ji = JointItems[i];
		// Determine joint type
		if (ji.JointIsA('PrismaticJoint'))
			jointType = "Prismatic";
		else if (ji.JointIsA('RevoluteJoint'))
			jointType = "Revolute";
		else
			jointType = "Unknown";
		// Create configuration string
		outStr = outStr $ " {Link " $ (i + 1) $ "} {JointType " $ jointType $
			"} {MaxRotationSpeed 1.571} {MaxTorque " $ ji.MaxForce $ "} {MinRange " $
			ji.Spec.GetMin() $ "} {MaxRange " $ ji.Spec.GetMax() $ "}";
	}
	// Account for contained items
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('MissionPackage'))
			outStr = outStr $ " " $ Parts[i].GetConfData();
	return outStr;
}

// Gets data from this mission package (joint locations)
function String GetData()
{
	local String missionPackageData;
	local int i;
	local array<float> position;

	// Get initial positions
	position.Length = JointItems.Length;
	for (i = 0; i < JointItems.Length; i++)
		position[i] = JointItems[i].CurValue;
	//position = getRotation(position);
	missionPackageData = "";
	// Return transformed positions
	for (i = 0; i < JointItems.Length; i++)
	{
		if (missionPackageData != "")
			missionPackageData = missionPackageData $ " ";
		// Cannot get the current torque from the constraint, but it looks like it was never
		// provided before either in the UT3 version
		missionPackageData = missionPackageData $ "{Link " $ (i + 1) $ "} {Value " $
			position[i] $ "} {Torque 0}";
	}
	return missionPackageData;
}

// Gets geometry data from the mission package
function String GetGeoData()
{
	local String outStr;
	local JointItem ji, pji;
	local int i, parent;
	local vector adjustedLocation;
	local vector adjustedRotation;
	
	// Iterate through joints
	outStr = "{Name " $ ItemName $ "}";
	for (i = 0; i < JointItems.Length; i++)
	{
		ji = JointItems[i];
		// Find parent link
		parent = FindParentIndex(ji.Parent);
		if (parent >= 0)
		{
			pji = JointItems[parent];
			parent++;
		}
		else
			pji = None;
		outStr = outStr $ " {Link " $ (i + 1) $ "} {ParentLink " $ parent $ "} {Location ";
		// Calculate location relative to parent
		adjustedLocation = GetJointOffset(ji.Spec);
		if (pji != None)
			adjustedLocation -= GetJointOffset(pji.Spec);
		outStr = outStr $ adjustedLocation $ "} {Orientation ";
		// Calculate orientation relative to parent
		adjustedRotation = ji.Spec.Direction;
		if (pji != None)
			adjustedRotation -= pji.Spec.Direction;
		outStr = outStr $ adjustedRotation $ "}";
	}
	// Account for contained items
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('MissionPackage'))
			outStr = outStr $ " " $ Parts[i].GetGeoData();
	return outStr;
}

// Gets header information for this mission package
simulated function String GetHead()
{
	return "MISSTA {Time " $ WorldInfo.TimeSeconds $ "} {Name " $ ItemName $ "}";
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

// Gets the specified mission package, or None if it was not found
simulated function MissionPackage GetMisPkg(String misName)
{
	local int i;
	local MissionPackage pkg;
	
	// Search for mission package in list
	if (Caps(misName) == Caps(self.Tag))
		return self;
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('MissionPackage'))
		{
			pkg = MissionPackage(Parts[i]).GetMisPkg(misName);
			if (pkg != None)
				return pkg;
		}
	return None;
}

// Gets a part's actor representation using its spec name
simulated function Item GetPartByName(name partName)
{
	local int i;
	local PhysicalItem p;
	
	// Search for part (slow!)
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('PhysicalItem'))
		{
			// Check spec for the name
			p = PhysicalItem(Parts[i]);
			if (p.Spec.Name == partName)
				return p;
		}
		else if (Parts[i].Name == partName)
			// Matched spawned item (sensor, mission package)
			return Parts[i];
	
	// Not found
	return None;
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

// Using the Joints[] array and the member ActualPos, user can implement gearing equations
simulated function array<float> getRotation(array<float> positions)
{
	return positions;
}

// Assigns the specified item as "base" overwriting any previous choice
simulated function MakeCenterItem(PhysicalItem it)
{
	CenterItem = it;
	it.SetPhysics(PHYS_None);
	it.SetHardAttach(false);
	it.SetBase(self);
}

reliable server function runSequence(int Sequence)
{
}

reliable server function setGripperToBox(int Gripper)
{
}

// This was the old code in setThisRotation, segregated to allow better user control
simulated function SetRotationDo(int Link, float Value)
{
	JointItems[Link].SetTarget(Value);
}

// Changes the position of the given link to a new value
reliable server function SetThisRotation(int Link, float Value, int Order)
{
	local array<float> motorCmdOld;
	local int i, len;
	
	// Check that link is within range (move reference to adapt)
	len = JointItems.Length;
	Link--;
	if (Link >= 0 && Link < len)
	{
		motorCmdOld.Length = len;
		// Copy old values
		for (i = 0; i < len; i++)
			motorCmdOld[i] = CmdPos[i];
		if (Order == 0)
		{
			// User control update
			updateRotation(Link, Value);
			for (i = 0; i < len; i++)
				// Set rotation per joint if different
				if (motorCmdOld[i] != CmdPos[i])
					SetRotationDo(i, CmdPos[i]);
			if (bDebug)
				LogInternal("Set rotation of joint " $ Link $ " to " $ Value);
		}
	}
}

// Creates and initializes an Item from its specification in the INI file
reliable server function SetupItem(SpecItem desc)
{
	local Item it, test;
	local vector pos;
	local rotator dir;
	
	// Creates a new item of the specified class
	pos = class'UnitsConverter'.static.LengthVectorToUU(desc.Position);
	dir = class'UnitsConverter'.static.AngleVectorToUU(desc.Direction);
	pos = pos >> OriginalRotation;
	// Create item actor
	it = Item(Spawn(desc.ItemClass, self, name(desc.ItemName), OriginalLocation + pos,
		OriginalRotation + dir));
	if (it == None)
		LogInternal("MissionPackage: Failed to spawn attachment: " $ desc.ItemName);
	else
	{
		test = GetPartByName(desc.Parent);
		// Base on a specified part
		if (test != None && test.isA('PhysicalItem'))
			it.SetBase(test);
		else
			it.SetBase(self);
		// NOTE: HardAttach=true causes an unusual bug where the item spirals off of the robot
		// when rotating in place; until resolved, do NOT hard attach
		it.SetHardAttach(false);
		// Initialize item
		it.init(desc.ItemName, Platform, desc.Parent);
		if (bDebug)
			LogInternal("MissionPackage: Created part " $ String(it.Name));
		// Add item to world
		Parts.AddItem(it);
	}
}

// Initializes joints and their corresponding constraints
reliable server function JointItem SetupJoint(Joint jt)
{
	local JointItem ji;
	local vector spawnLocation;
	local rotator spawnRotation;
	
	// Create instance to store actual joint parameters
	spawnRotation = class'UnitsConverter'.static.AngleVectorToUU(jt.Direction);
	// Twist is normally about the X axis. This makes the joints consistent with DH notation
	// that states that the Z axis (in this case the SAE z axis pointing down) is the axis
	// of revolution
	spawnRotation = class'Utilities'.static.rTurn(spawnRotation, rot(16384, 0, 0));
	spawnLocation = GetJointOffset(jt) >> OriginalRotation;
	ji = Spawn(class'JointItem', self, '', OriginalLocation + spawnLocation, OriginalRotation +
		spawnRotation);
	// Find errors early
	if (ji == None)
		LogInternal("MissionPackage: Failed to realize joint " $ jt.Name);
	else
	{
		// See note in SetupItem as to why this is false
		ji.SetHardAttach(false);
		ji.SetBase(self);
		// Find parts for parent and child
		ji.Parent = GetPartByName(jt.Parent.Name);
		if (ji.Parent == None)
		{
			LogInternal("MissionPackage: Could not find parent for " $ String(jt.Name));
			return None;
		}
		ji.Child = GetPartByName(jt.Child.Name);
		if (ji.Child == None)
		{
			LogInternal("MissionPackage: Could not find child for " $ String(jt.Name));
			return None;
		}
		// Initialize joint
		jt.Init(ji);
		// This line seems to be required to avoid weird bug with initial physics on some robots
		// Without this line, some robots will spawn in midair and will only start physics when
		// a joint or drive command is sent
		ji.Constraint.ConstraintInstance.InitConstraint(ji.Parent.CollisionComponent,
			ji.Child.CollisionComponent, ji.Constraint.ConstraintSetup, 1, self,
			ji.Parent.CollisionComponent, false);
		Parts.AddItem(ji);
		if (bDebug)
			LogInternal("MissionPackage: Created joint '" $ String(ji.Name) $ "' for spec " $
				String(jt.Name));
	}
	return ji;
}

// Sets up a part's parameters and spawns it into the world (static constrained pieces)
reliable server function SetupPart(Part part)
{
	local PhysicalItem it;
	local vector spawnLocation;
	local rotator spawnRotation;
	
	// Determine start location
	spawnRotation = class'UnitsConverter'.static.AngleVectorToUU(part.Direction);
	spawnLocation = GetPartOffset(part) >> OriginalRotation;
	it = Spawn(class'PhysicalItem', self, '', OriginalLocation + spawnLocation,
		OriginalRotation + spawnRotation);
	if (it == None)
		// Error when creating
		LogInternal("MissionPackage: Failed to realize part: " $ part.Name);
	else
	{
		// Initialize fields
		it.Spec = part;
		if (part.Mesh == None)
			LogInternal("MissionPackage: Static mesh for '" $ part.Name $ "' not found");
		else
		{
			it.StaticMeshComponent.SetStaticMesh(part.Mesh);
			it.SetPhysicalCollisionProperties();
			it.SetMass(part.Mass);
			// Found base?
			if (it.Spec.Name == Body.Name)
			{
				MakeCenterItem(it);
				if (bDebug)
					LogInternal("MissionPackage: Found package base " $ it.Spec.Name);
			}
			// Add item into mission package
			Parts.AddItem(it);
			if (bDebug)
				LogInternal("MissionPackage: Created part '" $ String(it.Name) $ "' for spec " $
					String(part.Name));
		}
	}
}

// Call ClientTimer on each scan interval
simulated function Timer()
{
	if (Platform.GetBatteryLife() > 0)
		ClientTimer();
}

// Updates the joint angles to match the constraint pointers
simulated function UpdateJoints()
{
	local int i;
	local JointItem ji;

	// Iterate through joints and update their positions (CurPos) to match the values
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			// Update joints
			ji = JointItem(Parts[i]);
			if (ji.Parent != None && ji.Child != None)
				ji.Spec.Update(ji);
		}
		else if (Parts[i].isA('MissionPackage'))
			// Update these too
			MissionPackage(Parts[i]).UpdateJoints();
}

// Using the CmdPos[] array, user can implement gearing equations
simulated function updateRotation(int Link, float Value)
{
	CmdPos[Link] = Value;
}

defaultproperties
{
	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=false
	bCollideWhenPlacing=false
	bCollideWorld=false
	Physics=PHYS_None
}
