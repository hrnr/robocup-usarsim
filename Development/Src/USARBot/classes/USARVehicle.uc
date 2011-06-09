/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * USARVehicle: parent class of all USAR Robots. Descend actual robot classes from the appropriate vehicle
 * type such as WheeledRobot or AirRobot.
 */
class USARVehicle extends BaseVehicle config(USAR);

// Whether or not you wish to use volumeOverride, which will change the volume based on that value
var config bool bUseVolumeOverride;
// Value between 0.0001 (muted) and 1.0 (normal volume) used for sound if bUseVolumeOverride is true
var config float volumeOverride;
// Whether an acoustic sensor is installed
var bool HasAcoustic;
// Whether this robot is normalized. Unsure of the meaning.
var bool Normalized;
// Where the robot started
var vector OriginalLocation;
// Vehicle's installed battery
var Battery VehicleBattery;

// This function is called once when the battery has died in order to stop all current actions like driving
simulated function BatteryDied()
{
	LogInternal("USARVehicle: Battery is dead");
}

// Creates and initializes a part
reliable server function Item CreatePart(int ID)
{
	local Item item;
	local int i;
	
	// Parent creates the part
	item = super.CreatePart(ID);
	
	// Set up batteries properly (into its variable)
	if (item.isA('Battery')) {
		VehicleBattery = Battery(item);
		for (i = 0; i < PartsList.Length; i++)
		{
			// Sensors need the battery installed
			if (PartsList[i].isA('Sensor'))
				Sensor(PartsList[i]).ConnectToBattery(VehicleBattery);
		}
	}
	
	// Set up audio sensor
	if (item.IsType("Acoustic"))
		SetupAudio();
	return item;
}

// Clean up the joint constraints and spawned parts when this vehicle is removed
simulated event Destroyed()
{
	local int i;
	local PhysicalItem pitem;
	
	// Wipe up parent first
	super.Destroyed();
	
	// Clean out joints
	for (i = 0; i < Joints.Length; i++)
		if (Joints[i].Constraint != None)
			Joints[i].Constraint.Destroy();
	
	// Clean out parts' actors
	for (i = 0; i < ComponentList.Length; i++)
	{
		pitem = ComponentList[i];
		if (pitem.PartActor != None)
			pitem.PartActor.Destroy();
	}
}

// Gets configuration data from all mission packages
function String GetMisPkgConfData()
{
	local String outStr;
	local int i;
	
	// Look for mission packages
	outStr = "CONF {Type MisPkg}";
	for (i = 0; i < PartsList.Length; i++)
		if (PartsList[i].isA('MissionPackage'))
			outStr = outStr $ " " $ PartsList[i].GetConfData();
	return outStr;
}

// Gets geometry data from all mission packages
function String GetMisPkgGeoData()
{
	local String outStr;
	local int i;
	
	// Look for mission packages
	outStr = "GEO {Type MisPkg}";
	for (i = 0; i < PartsList.Length; i++)
		if (PartsList[i].isA('MissionPackage'))
			outStr = outStr $ " " $ PartsList[i].GetGeoData();
	return outStr;
}

// Gets geometry data from sensors matching the given type and/or name
function String GetSensorGeoData(String sensorType, String sensorName)
{
	return GetGeneralGeoData('Sensor', sensorType, sensorName);
}

// Gets configuration data from sensors matching the given type and/or name
function String GetSensorConfData(String sensorType, String sensorName)
{
	return GetGeneralConfData('Sensor', sensorType, sensorName);
}

// Gets geometry data from effectors matching the given type and/or name
function String GetEffectorGeoData(String effectorType, String effectorName)
{
	return GetGeneralGeoData('Effector', effectorType, effectorName);
}

// Gets configuration data from effectors matching the given type and/or name
function String GetEffectorConfData(String effectorType, String effectorName)
{
	return GetGeneralConfData('Effector', effectorType, effectorName);
}

// Compiles configuration data from items of the given type and name
simulated function String GetGeneralConfData(name itemClass, String itemType, String itemName)
{
	local String outStr;
	local int i;
	local int firstIndex;
	
	// Look for items
	outStr = "";
	firstIndex = -1;
	for (i = 0; i < PartsList.Length; i++)
		if (PartsList[i].isA(itemClass) && PartsList[i].isType(itemType) &&
			(itemName == "" || PartsList[i].isName(itemName)))
		{
			// Filter matched, return data
			outStr = outStr $ " " $ PartsList[i].GetConfData();
			if (firstIndex < 0)
				firstIndex = i;
		}
	
	// Add header from first item
	if (outStr != "")
		outStr = PartsList[firstIndex].GetConfHead() $ outStr;
	return outStr;
}

// Compiles geometry data from items of the given type and name
simulated function String GetGeneralGeoData(name itemClass, String itemType, String itemName)
{
	local String outStr;
	local int i;
	local int firstIndex;
	
	// Look for items
	outStr = "";
	firstIndex = -1;
	for (i = 0; i < PartsList.Length; i++)
		if (PartsList[i].isA(itemClass) && PartsList[i].isType(itemType) &&
			(itemName == "" || PartsList[i].isName(itemName)))
		{
			// Filter matched, return data
			outStr = outStr $ " " $ PartsList[i].GetGeoData();
			if (firstIndex < 0)
				firstIndex = i;
		}
	
	// Add header from first item
	if (outStr != "")
		outStr = PartsList[firstIndex].GetGeoHead() $ outStr;
	return outStr;
}

// Initializes all joints to true zero
simulated function InitJoints()
{
	local int i;
	local Rotator r;

	for (i = 0; i < Joints.Length; i++)
	{
		r = rot(0, 0, 0);
		if (Joints[i].jointType == JOINTTYPE_Pitch)
			r.Pitch = Joints[i].CurAngularTarget;
		else if (Joints[i].jointType == JOINTTYPE_Yaw)
			r.Yaw = Joints[i].CurAngularTarget;
		else if (Joints[i].jointType == JOINTTYPE_Roll)
			r.Roll = Joints[i].CurAngularTarget;
		SetAngularTarget(Joints[i].Constraint, r);
	}
}

simulated function PostBeginPlay()
{
	local int i;
	super.PostBeginPlay();
	OriginalLocation = Location;
	
	// Initialize parts
	for (i = 0; i < ComponentList.Length; i++)
		SetupPart(ComponentList[i]);
}

// Set the angular target of a constraint using a rotator
function SetAngularTarget(RB_ConstraintActor constraint, Rotator rot)
{
	local Quat q;
	q = QuatFromRotator(rot);
	constraint.ConstraintInstance.SetAngularPositionTarget(q);
}

// Sets all joint angles to the specified angle
simulated function SetAllJointAngles(int UUAngle)
{
	local int i;
	local Rotator r;
	
	for (i = 0; i < Joints.Length; i++)
	{
		Joints[i].CurAngularTarget = UUAngle + Joints[i].TrueZero;
		
		r = rot(0,0,0);
		if (Joints[i].jointType == JOINTTYPE_Pitch)
			r.Pitch = Joints[i].CurAngularTarget;
		else if (Joints[i].jointType == JOINTTYPE_Yaw)
			r.Yaw = Joints[i].CurAngularTarget;
		else if (Joints[i].jointType == JOINTTYPE_Roll)
			r.Roll = Joints[i].CurAngularTarget;
		
		SetAngularTarget(Joints[i].Constraint, r);
	}
}

// Update a joint angle target if changed
simulated function SetJointAngle(String JointName, int UUAngle)
{
	local int i;
	local Rotator r;
	
	for (i = 0; i < Joints.Length; i++)
	{
		if (Caps(String(Joints[i].Name)) == Caps(JointName))
		{
			Joints[i].CurAngularTarget = UUAngle + Joints[i].TrueZero;
			r = rot(0, 0, 0);
			if (Joints[i].jointType == JOINTTYPE_Pitch)
				r.Pitch = Joints[i].CurAngularTarget;
			else if (Joints[i].jointType == JOINTTYPE_Yaw)
				r.Yaw = Joints[i].CurAngularTarget;
			else if (Joints[i].jointType == JOINTTYPE_Roll)
				r.Roll = Joints[i].CurAngularTarget;
			
			SetAngularTarget(Joints[i].Constraint, r);
			break;
		}
	}
}

// Sets the damping of a joint given its index
simulated function SetJointDamping( int i, float damping )
{
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(Joints[i].MaxForce * Joints[i].Stiffness,
		damping, Joints[i].MaxForce * Joints[i].Stiffness);
}

// Sets the maximum force of a joint given its index
simulated function SetJointMaxForce( int i, float force )
{
	Joints[i].MaxForce = force;
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(force * Joints[i].Stiffness,
		0.25, force * Joints[i].Stiffness);
}

// Sets the stiffness of a joint given its index
simulated function SetJointStiffness(int i, float stiffness)
{
	Joints[i].Stiffness = stiffness;
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(Joints[i].MaxForce * stiffness,
		0.25, Joints[i].MaxForce * stiffness);
}

// Sets the stiffness of a joint given its name
simulated function SetJointStiffnessByName( name JointName, float stiffness )
{
	local int i;
	for (i = 0; i < Joints.Length; i++)
		if (Joints[i].Name == JointName)
		{
			SetJointStiffness(i, stiffness);
			break;
		}
}

// Adjusts the mass of the specified item to match reality
simulated function SetMass(PhysicalItem Part1, float DesiredMass)
{
	local float OldScale;
	local RB_BodySetup bs;

	DesiredMass /= 34000.0; // 1uu mass is 34kg. Assume desired mass is in grams.

	// Change auto calculated mass to the desired mass
	OldScale = Part1.PartActor.StaticMeshComponent.StaticMesh.BodySetup.MassScale;
	bs = Part1.PartActor.StaticMeshComponent.StaticMesh.BodySetup;
	bs.MassScale = DesiredMass / (Part1.PartActor.StaticMeshComponent.BodyInstance.GetBodyMass() * (1.0 / OldScale));
	Part1.PartActor.StaticMeshComponent.BodyInstance.UpdateMassProperties(bs);
	logInternal("New mass " $ Part1.Name @ Part1.PartActor.StaticMeshComponent.BodyInstance.GetBodyMass());
}

// Normalizes or un-normalizes this vehicle
reliable server function SetNormalized(bool nom)
{
	Normalized = nom;
}

// In the future this should be done on each robot camera change so that we hear the active robot's sensor
// only, if it does in fact have an acoustic sensor
simulated function SetupAudio()
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
}

// Sets up a part's parameters and spawns it into the world (static constrained pieces)
simulated function SetupPart(PhysicalItem part)
{
	local Vector angle, OffsetInUU, SpawnLocation;
	local Rotator r;

	if (part.PartActor == None)
	{
		angle.Y = class'UnitsConverter'.static.AngleFromDeg(part.Direction.X); // Pitch
		angle.Z = class'UnitsConverter'.static.AngleFromDeg(part.Direction.Y); // Yaw
		angle.X = class'UnitsConverter'.static.AngleFromDeg(part.Direction.Z); // Roll
		r = class'UnitsConverter'.static.AngleVectorToUU(angle);
		
		OffsetInUU = class'UnitsConverter'.static.MeterVectorToUU(part.Offset);
		OffsetInUU.Z = -OffsetInUU.Z;
		
		if (part.RelativeTo != None)
		{
			SetupPart(part.RelativeTo);
			SpawnLocation = part.RelativeTo.PartActor.Location + OffsetInUU;
		}
		else
			SpawnLocation = OriginalLocation + OffsetInUU;
		if (part.IsDummy)
			part.PartActor = CreateDummyActor(SpawnLocation, Rotation + r);
		else
		{
			part.PartActor = Spawn(class'RobotPart', self, '', SpawnLocation, Rotation + r);
			part.PartActor.StaticMeshComponent.SetStaticMesh(part.Mesh);
			part.PartActor.SetPhysicalCollisionProperties();
		}
		SetMass(part, part.Mass);
	}
	else
		LogInternal("SetupPart: '" $ String(part.Name) $ "' already has an actor: " $
			String(part.PartActor.Name));
}

// Check battery; if alive, call client timer functions
simulated function Timer()
{
	if (VehicleBattery == None || !VehicleBattery.isDead())
		super.Timer();
}

// Creates an empty robot actor.
simulated function RobotPart CreateDummyActor(Vector loc, Rotator r)
{
	local RobotPart dummy;
	
	dummy = Spawn(class'RobotPart', Self , , loc, r);
	dummy.SetPhysicalCollisionProperties();
	dummy.SetCollision(true, false);
	
	return dummy;
}

defaultproperties 
{
	HasAcoustic=false;
	Normalized=false;
}
