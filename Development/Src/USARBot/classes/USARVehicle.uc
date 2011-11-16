/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARVehicle: parent class of all USAR Robots. Descend actual robot classes from the
 * appropriate vehicle type such as WheeledRobot or AirRobot.
 */
class USARVehicle extends BaseVehicle config(USAR);

// Enables or disables volumeOverride
var config bool bUseVolumeOverride;

// Array of pairs of parts that do not generate contacts; used to construct more complex joints
struct DisableContactPair {
	var Part Part1;
	var Part Part2;
};
var array<DisableContactPair> DisableContacts;

// Whether an acoustic sensor is installed
var bool HasAcoustic;
// Whether this robot is normalized
var bool Normalized;
// Location and rotation where the robot started, to fix bug where robot moves after spawning
// changing locations of subsequent parts
var vector OriginalLocation;
var rotator OriginalRotation;
// A separate, per robot controllable timer which allows status updates at different rates
var float StatusTimer;
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
	super.ClientTimer();
	UpdateJoints();
}

// Notify when this vehicle is removed
simulated event Destroyed()
{
	if (bDebug)
		LogInternal("USARVehicle: Destroyed");
	super.Destroyed();
}

// Drives the vehicle using the parameters in the given message, which should be checked
function Drive(ParsedMessage msg)
{
}

// Gets the specified actuator, or None if it was not found
simulated function Actuator GetActuator(String actName)
{
	local int i;
	local Actuator pkg;
	
	// Search for actuator in list
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('Actuator'))
		{
			pkg = Actuator(Parts[i]).GetActuator(actName);
			if (pkg != None)
				return pkg;
		}
	return None;
}

// Gets the estimated life remaining in the battery; negative is a dead battery
simulated function int GetBatteryLife()
{
	if (VehicleBattery == None)
		return super.GetBatteryLife();
	else
		return VehicleBattery.ExpectedLifeTime();
}

// Compiles configuration data from items of the given type and name
function String GetGeneralConfData(String itemType, String itemName)
{
	local String outStr;
	local int i;
	
	// Look for items
	outStr = "";
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].isType(itemType) && (itemName == "" || Parts[i].isName(itemName)))
			// Filter matched, return data
			outStr = outStr $ " " $ Parts[i].GetConfData();
		if (Parts[i].isA('Actuator'))
			outStr = outStr $ Actuator(Parts[i]).GetGeneralConfData(itemType, itemName);
	}
	if (outStr != "")
		outStr = "CONF {Type " $ itemType $ "}" $ outStr;
	return outStr;
}

// Compiles geometry data from items of the given type and name
function String GetGeneralGeoData(String itemType, String itemName)
{
	local String outStr;
	local int i;
	
	// Look for items
	outStr = "";
	for (i = 0; i < Parts.Length; i++)
	{
		if (Parts[i].isType(itemType) && (itemName == "" || Parts[i].isName(itemName)))
			// Filter matched, return data
			outStr = outStr $ " " $ Parts[i].GetGeoData();
		if (Parts[i].isA('Actuator'))
			outStr = outStr $ Actuator(Parts[i]).GetGeneralGeoData(itemType, itemName);
	}
	if (outStr != "")
		outStr = "GEO {Type " $ itemType $ "}" $ outStr;
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

// Calculates the sum masses of all parts and returns it (polls actuators too)
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

// Gets configuration data from all actuators (deprecated mission package version)
function String GetMisPkgConfData()
{
	local String outStr;
	local int i;
	
	// Look for actuators
	outStr = "CONF {Type MisPkg}";
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('Actuator'))
			outStr = outStr $ " " $ Actuator(Parts[i]).GetMisPkgConfData();
	return outStr;
}

// Gets geometry data from all actuators (deprecated mission package version)
function String GetMisPkgGeoData()
{
	local String outStr;
	local int i;
	
	// Look for actuators
	outStr = "GEO {Type MisPkg}";
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('Actuator'))
			outStr = outStr $ " " $ Actuator(Parts[i]).GetMisPkgGeoData();
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

// Gets robot status sent out on each tick
simulated function String GetStatus()
{
	return "STA {Time " $ WorldInfo.TimeSeconds $ "} {Battery " $ GetBatteryLife() $ "}";
}

// Transforms the return value of a joint by some gearing equation
simulated function float JointTransform(JointItem ji, float value)
{
	return value;
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
	if (PartList.Length < 1)
		LogInternal("USARVehicle: No parts in part list, was a PartList.Add(...) used?");
	for (i = 0; i < PartList.Length; i++)
		SetupPart(PartList[i]);
	// Warn on null body
	if (CenterItem == None)
	{
		LogInternal("USARVehicle: Vehicle body not intialized, defaulting to first part");
		LogInternal("USARVehicle:  To fix this warning, declare Body=<item> in properties");
		// Cast cannot fail, only physical items are in the array to begin with
		if (Parts.Length > 0)
			CenterItem = PhysicalItem(Parts[0]);
	}
	// Initialize joints
	for (i = 0; i < Joints.Length; i++)
		SetupJoint(Joints[i]);
	// Initialize items (sensors etc)
	for (i = 0; i < AddParts.Length; i++)
		SetupItem(AddParts[i]);
	// Disable contacts between specified item pairs
	for (i = 0; i < DisableContacts.Length; i++)
		class'Utilities'.static.SetActorPairIgnore(
			GetPartByName(DisableContacts[i].Part1.TemplateName).StaticMeshComponent.BodyInstance,
			GetPartByName(DisableContacts[i].Part2.TemplateName).StaticMeshComponent.BodyInstance,
			true
		);
	// Status timer
	SetTimer(StatusTimer, true, 'SendStatus');
}

// Sends the robot's status to the client
function SendStatus()
{
	MessageSendDelegate(GetStatus());
}

// Sets all joint targets to the specified value
function SetAllJointTargets(float target)
{
	local int i;
	
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
			JointItem(Parts[i]).SetTarget(target);
}

// Handles SET commands sent to the robot's sensors or actuators
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

// Sets the specified joint's target to the specified value
function SetJointTargetByName(String jointName, float target)
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
				ji.SetTarget(target);
				break;
			}
		}
}

// Sets the damping of a joint given its name
function SetJointDampingByName(String jointName, float stiffness)
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
				ji.SetDamping(stiffness);
				break;
			}
		}
}

// Sets the stiffness of a joint given its name
function SetJointStiffnessByName(String jointName, float stiffness)
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
				ji.SetStiffness(stiffness);
				break;
			}
		}
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
		LogInternal("USARVehicle: Failed to spawn attachment: " $ desc.ItemName);
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
			it.SetBase(CenterItem);
		}
		it.SetHardAttach(true);
		// Override static mesh if specified
		if (desc.Mesh != none)
			it.SetStaticMesh(desc.Mesh);
		// Initialize item
		it.init(desc.ItemName, self);
		if (bDebug)
			LogInternal("USARVehicle: Created part " $ String(it.Name));
		// Set up batteries properly (into its variable)
		if (it.isA('Battery'))
			VehicleBattery = Battery(it);
		// Set up audio sensor
		if (it.IsType("Acoustic"))
			SetupAudio();
		// Add item to robot or to world
		if(desc.startAttached)
			Parts.AddItem(it);
		else
		{
			it.detachItem();
			offParts.AddItem(it);
		}
	}
}
// Initializes joints and their corresponding constraints
reliable server function SetupJoint(Joint jt)
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
	if (ji == None)
		LogInternal("USARVehicle: Failed to realize joint " $ jt.Name);
	else
	{
		// See note in SetupItem as to why this is false
		ji.SetHardAttach(false);
		ji.SetBase(CenterItem);
		// Find parts for parent and child
		ji.Parent = GetPartByName(jt.Parent.TemplateName);
		if (ji.Parent == None)
		{
			LogInternal("USARVehicle: Could not find parent for " $ String(jt.Name));
			return;
		}
		ji.Child = GetPartByName(jt.Child.TemplateName);
		if (ji.Child == None)
		{
			LogInternal("USARVehicle: Could not find child for " $ String(jt.Name));
			return;
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
			LogInternal("USARVehicle: Created joint '" $ String(ji.Name) $ "' for spec " $
				String(jt.Name));
	}
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
		LogInternal("USARVehicle: Failed to realize part: " $ part.Name);
	else
	{
		// Initialize fields
		it.Spec = part;
		if (part.Mesh == None)
			LogInternal("USARVehicle: Static mesh for '" $ part.Name $ "' not found");
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
			class'Utilities'.static.SetIterationSolverCount(
				it.StaticMeshComponent.BodyInstance, part.SolverIterationCount);
			// Initialize center item properly (for sensors and parenting reasons)
			if (part.TemplateName == Body.TemplateName)
			{
				CenterItem = it;
				if (bDebug)
					LogInternal("USARVehicle: Found vehicle body " $ String(Body.TemplateName));
			}
			// Add item into world
			Parts.AddItem(it);
			if (bDebug)
				LogInternal("USARVehicle: Created part '" $ String(it.Name) $ "' for spec " $
					String(part.TemplateName));
		}
	}
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

	// Iterate through joints and update their positions (CurPos) to match the values
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			// Update joints
			ji = JointItem(Parts[i]);
			if (ji.Parent != None && ji.Child != None)
				ji.Spec.Update(ji);
			ji.CurValue = JointTransform(ji, ji.CurValue);
		}
		else if (Parts[i].isA('Actuator'))
			// Update these too
			Actuator(Parts[i]).UpdateJoints();
}

defaultproperties 
{
	bDebug=false
	bNoDelete=false
	bStatic=false
	HasAcoustic=false
	Normalized=false
	Physics=PHYS_None
	StatusTimer=0.1
}
