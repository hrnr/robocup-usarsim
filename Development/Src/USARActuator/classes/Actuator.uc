/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Actuator - parent all actuators (sets of effectors to mount on a robot)
 * In essence actuators are like mini robots mounted on a parent robot
 * It is possible to mount sensors or other actuators on an actuator
 */
class Actuator extends Item abstract config (USAR);

// Array storing all configured subparts from the INI file
var config array<SpecItem> AddParts;
// Assign a Part to this field in properties to set as actuator base
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
//The offset for the tooltip of this actuator
var config vector TipOffset;

// Pass actuator messages to the platform
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
		LogInternal("Actuator: No parts in part list, was a PartList.Add(...) used?");
	for (i = 0; i < PartList.Length; i++)
		SetupPart(PartList[i]);
	// If no base, find one
	if (CenterItem == None)
	{
		LogInternal("Actuator: Package base not intialized, defaulting to first part");
		LogInternal("Actuator:  To fix this warning, declare Body=<item> in properties");
		// Cast cannot fail, only physical items are in the array to begin with
		if (Parts.Length > 0)
			MakeCenterItem(PhysicalItem(Parts[0]));
	}
	// Initialize joints
	JointItems.Length = Joints.Length;
	for (i = 0; i < Joints.Length; i++)
		JointItems[i] = SetupJoint(Joints[i]);
	// Initialize items (sensors, other actuators, etc)
	for (i = 0; i < AddParts.Length; i++)
		SetupItem(AddParts[i]);
}

// Send actuator status
simulated function ClientTimer()
{
	super.ClientTimer();
	// 
	//SendMisPkg(); Old (deprecated)
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

// Gets the specified actuator, or None if it was not found
simulated function Actuator GetActuator(String actName)
{
	local int i;
	local Actuator pkg;
	
	// Search for actuator in list
	if (Caps(actName) == Caps(self.Tag))
		return self;
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('Actuator'))
		{
			pkg = Actuator(Parts[i]).GetActuator(actName);
			if (pkg != None)
				return pkg;
		}
	return None;
}

// Gets configuration data from the actuator
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
			"} {MaxTorque " $ ji.MaxForce $ "} {MinValue " $ ji.Spec.GetMin() $
			"} {MaxValue " $ ji.Spec.GetMax() $ "}";
	}
	
	return outStr;
}

// Compiles configuration data from items of the given type and name
function String GetGeneralConfData(String iType, String iName)
{
	local String outStr;
	local int i;
	// Account for contained items
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].isType(iType) && (iName == "" || Parts[i].isName(iName)))
		{
			outStr = outStr $ " " $ Parts[i].GetConfData();
		}
		if (Parts[i].isA('Actuator'))
				outStr = outStr $ Actuator(Parts[i]).GetGeneralConfData(iType, iName);
	}
	return outStr;
}

// Compiles geometry data from items of the given type and name
function String GetGeneralGeoData(String iType, String iName)
{
	local String outStr;
	local int i;
	// Account for contained items
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].isType(iType) && (iName == "" || Parts[i].isName(iName)))
		{
			outStr = outStr $ " " $ Parts[i].GetGeoData();
		}
		if (Parts[i].isA('Actuator'))
				outStr = outStr $ Actuator(Parts[i]).GetGeneralGeoData(iType, iName);
	}
	return outStr;
}

// Gets data from this actuator (joint locations; deprecated mission package API)
function String GetMisPkgData()
{
	local String actuatorData;
	local int i;
	local array<float> position;

	// Get initial positions
	position.Length = JointItems.Length;
	for (i = 0; i < JointItems.Length; i++)
		position[i] = JointItems[i].CurValue;
	position = getRotation(position);
	actuatorData = "";
	// Return transformed positions
	for (i = 0; i < JointItems.Length; i++)
	{
		if (actuatorData != "")
			actuatorData = actuatorData $ " ";
		// Cannot get the current torque from the constraint, but it looks like it was never
		// provided before either in the UT3 version
		actuatorData = actuatorData $ "{Link " $ (i + 1) $ "} {Value " $
			position[i] $ "} {Torque 0}";
	}
	return actuatorData;
}

// Gets data from this actuator (joint locations)
function String GetData()
{
	local String actuatorData;
	local int i;
	local array<float> position;

	// Get initial positions
	position.Length = JointItems.Length;
	for (i = 0; i < JointItems.Length; i++)
		position[i] = JointItems[i].CurValue;
	position = getRotation(position);
	actuatorData = "";
	// Return transformed positions
	for (i = 0; i < JointItems.Length; i++)
	{
		if (actuatorData != "")
			actuatorData = actuatorData $ " ";
		// Cannot get the current torque from the constraint, but it looks like it was never
		// provided before either in the UT3 version
		actuatorData = actuatorData $ "{Link " $ (i + 1) $ "} {Value " $
			position[i] $ "}";
	}
	return actuatorData;
}

// Gets geometry data from the actuator
function String GetGeoData()
{
	local String outStr;
	local JointItem ji, pji;
	local int i, parent;
	local vector adjustedLocation;
	local quat adjustedRotation;
	
	// Name and location
	outStr = "{Name " $ ItemName $ "} {Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Location - Platform.CenterItem.Location);
	
	// Direction
	outStr = outStr $ "} {Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation - Platform.CenterItem.Rotation);
	
	// Mount point
	outStr = outStr $ "} {Mount " $ String(Platform.Class) $ "}";
	ji = None;
	// Iterate through joints
	for (i = 0; i < JointItems.Length; i++)
	{
		ji = JointItems[i];
		// Find parent link
		parent = FindParentIndex(ji.Parent);
		if (parent >= 0)
			pji = JointItems[parent];
		else
		{
			LogInternal("Actuator: No parent ( " $ parent $ ") for link " $ i + 1);
			pji = None;
		}
		outStr = outStr $ " {Link " $ (i + 1) $ "} {Parent " $ (parent +1 )$ "} {Location ";
		// Calculate location relative to parent
		adjustedLocation = GetJointOffset(ji.Spec);
		if (pji != None)
			adjustedLocation -= GetJointOffset(pji.Spec);
		outStr = outStr $ class'UnitsConverter'.static.LengthVectorFromUU(adjustedLocation) $ "} {Orientation ";
		
		// Calculate orientation relative to parent
		adjustedRotation = class'UnitsConverter'.static.VectorToUUQuat(ji.Spec.Direction);
		if (pji != None)
		{
//				LogInternal( "Link " $ i+1 $ " Rotation adjusted from " $ adjustedRotation $ " by parent " $ pji.Spec.Direction );
			adjustedRotation = QuatProduct(QuatInvert(class'UnitsConverter'.static.VectorToUUQuat(pji.Spec.Direction)), adjustedRotation);
		}
		outStr = outStr $ class'UnitsConverter'.static.UUQuatToVector(adjustedRotation) $ "}";
	}
	if(ji != None)
		outStr = outStr $ "{Tip " $ TipOffset $ "}";
	return outStr;
}

// Gets header information for this actuator
simulated function String GetHead()
{
	return "ASTA {Time " $ WorldInfo.TimeSeconds $ "} {Name " $ ItemName $ "}";
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

// Calculates the sum masses of all parts and returns it (polls sub-actuators too)
simulated function float GetMass()
{
	local float sumMass;
	local int i;

	sumMass = 0;
	// Add sub items
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].isA('PhysicalItem'))
			sumMass += PhysicalItem(Parts[i]).Spec.Mass;
		if (Parts[i].isA('Actuator'))
			sumMass += Actuator(Parts[i]).GetMass();
	}
	return sumMass;
}

// Gets configuration data from the actuator (deprecated mission package API)
function String GetMisPkgConfData() {
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
		if (Parts[i].isA('Actuator'))
			outStr = outStr $ " " $ Actuator(Parts[i]).GetMisPkgConfData();
	return outStr;
}

// Gets geometry data from the actuator (deprecated mission package API)
function String GetMisPkgGeoData()
{
	LogInternal( "Call to deprecated mission package API, please use Actuator API");
	return "GEO {Deprecated call to mission package api}";
}

// Gets header information for this actuator (deprecated mission package API)
simulated function String GetMisPkgHead()
{
	LogInternal( "Call to deprecated mission package API, please use Actuator API" );
	return "MISSTA {Time " $ WorldInfo.TimeSeconds $ "} {Name " $ ItemName $ "}";
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
			if (p.Spec.TemplateName == partName)
				return p;
		}
		else if (Parts[i].Name == partName)
			// Matched spawned item (sensor, actuator)
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

reliable server function RunSequence(int Sequence)
{
}

// Sends the legacy MISSTA message
simulated function SendMisPkg() // deprecated!
{
	MessageSendDelegate(GetMisPkgHead() @ GetMisPkgData());
}

// Handles SET commands sent to the actuators's sensors or sub-actuators
function SetCommand(String type, String iName, String opcode, String value)
{
	local int i;
	
	// Search local arrays
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].IsType(type) && (iName == "" || Parts[i].IsName(iName)))
			Parts[i].Set(opcode, value);
		// Search actuators
		if (Parts[i].isA('Actuator'))
			Actuator(Parts[i]).SetCommand(type, iName, opcode, value);
	}
}

reliable server function SetGripper(int Gripper)
{
}

// Changes the position of the given link to a new value (deprecated API for mission package)
reliable server function SetThisRotation(int link, float value, int order)
{
	if (order == 0)
		SetLinkTarget(link - 1, value);
}

// Changes the position of the given link to a new value
reliable server function SetLinkTarget(int link, float value)
{
	local array<float> target;
	local int i, len;
	// Check that link is within range (move reference to adapt)
	len = JointItems.Length;
	if (link >= 0 && link < len)
	{
		target.Length = len;
		// Copy old values
		for (i = 0; i < len; i++)
			target[i] = CmdPos[i];
		CmdPos[link] = value;
		// User control update
		target = updateRotation(target, link, value);
		for (i = 0; i < len; i++)
			// Set target per joint if different
			JointItems[i].SetTarget(target[i]);
		if (bDebug)
			LogInternal("Set target of joint " $ link $ " to " $ value);
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
		LogInternal("Actuator: Failed to spawn attachment: " $ desc.ItemName);
	else
	{
		test = GetPartByName(desc.Parent);
		// Base on a specified part
		if (test != None && test.isA('PhysicalItem'))
		{
			it.SetBase(test);
		}
		else
		{
			it.SetBase(self);
		}
		if(it.isA('Effector'))
		{
			Effector(it).parentActuator = self;
		}
		it.SetHardAttach(true);
		// Initialize item
		it.init(desc.ItemName, Platform);
//		if (bDebug)
			LogInternal("Actuator: Created part " $ String(it.Name));
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
		LogInternal("Actuator: Failed to realize joint " $ jt.Name);
	else
	{
		// See note in SetupItem as to why this is false
		ji.SetHardAttach(false);
		ji.SetBase(self);
		// Find parts for parent and child
		ji.Parent = GetPartByName(jt.Parent.Name);
		if (ji.Parent == None)
		{
			LogInternal("Actuator: Could not find parent for " $ String(jt.Name));
			return None;
		}
		ji.Child = GetPartByName(jt.Child.Name);
		if (ji.Child == None)
		{
			LogInternal("Actuator: Could not find child for " $ String(jt.Name));
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
			LogInternal("Actuator: Created joint '" $ String(ji.Name) $ "' for spec " $
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
		LogInternal("Actuator: Failed to realize part: " $ part.Name);
	else
	{
		// Initialize fields
		it.Spec = part;
		if (part.Mesh == None)
			LogInternal("Actuator: Static mesh for '" $ part.Name $ "' not found");
		else
		{
			it.StaticMeshComponent.SetStaticMesh(part.Mesh);
			if (part.Collision)
				it.SetPhysicalCollisionProperties();
			else
			{
				// Disable collision (and therefore movement)
				it.SetCollision(false, false);
				it.StaticMeshComponent.SetBlockRigidBody(false);
				it.SetPhysics(PHYS_None);
			}
			class'Utilities'.static.SetMass(it, part.Mass);
			// Found base?
			if (it.Spec.Name == Body.Name)
			{
				MakeCenterItem(it);
				if (bDebug)
					LogInternal("Actuator: Found package base " $ it.Spec.Name);
			}
			// Add item into actuator
			Parts.AddItem(it);
			if (bDebug)
				LogInternal("Actuator: Created part '" $ String(it.Name) $ "' for spec " $
					String(part.Name));
		}
	}
}
//called when the actuator is detached from its parent
function detachItem()
{
	super.detachItem();
	//turn on physics for the center item and set it as the actuator base
	CenterItem.SetBase(None);
	SetBase(CenterItem);
	CenterItem.SetPhysics(PHYS_RigidBody);
}
//called when the actuator is reattached to a parent
function bool reattachItem(Item newBase)
{
	local Rotator zero;
	if(!hasParent)
	{
		//turns off physics and sets the actuator as the base item
		CenterItem.SetPhysics(PHYS_None);
		SetBase(None);
		zero.roll =0;
		zero.pitch=0;
		zero.yaw=0;
		SetRotation(zero);
		SetLocation(CenterItem.Location);
		CenterItem.SetBase(self);
		//restore original offset of center item
		CenterItem.SetRelativeLocation(class'UnitsConverter'.static.MeterVectorToUU(Body.offset));
		CenterItem.SetRotation(class'UnitsConverter'.static.AngleVectorToUU(Body.Direction));
	}
	//turn off collision for all subparts so that the attaching actuator doesn't affect the parent
	SetActuatorCollision(false);
	//success = super.reattachItem(newBase);
	
	//set collision to false during move
	SetCollision(false);
	StaticMeshComponent.SetBlockRigidBody(false);
	//match item to parent
	SetRotation(newBase.Rotation);
	SetLocation(newBase.Location);
	SetBase(newBase);
	//turn collision back on
	SetCollision(true);
	StaticMeshComponent.SetBlockRigidBody(true);
	
	hasParent = true;
	
	//turn collision back on
	SetActuatorCollision(true);
	return true;
}
//set collision of all child parts
function SetActuatorCollision(bool bCollision)
{
	local int i;
	for(i = 0;i<Parts.length;i++)
	{
		Parts[i].SetCollision(bCollision, bCollision);
		Parts[i].StaticMeshComponent.SetBlockRigidBody(bCollision);
		if(Parts[i].isA('Actuator'))
		{
			Actuator(Parts[i]).SetActuatorCollision(bCollision);
		}
	}
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
		else if (Parts[i].isA('Actuator'))
			// Update these too
			Actuator(Parts[i]).UpdateJoints();
}

// Using the CmdPos[] array, user can implement gearing equations
simulated function array<float> updateRotation(array<float> Target, int Link, float Value)
{
	Target[Link] = Value;
	return Target;
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
	ItemType="Actuator"
}
