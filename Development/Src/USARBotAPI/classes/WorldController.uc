/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * World controller.
 * Controller allows to create, destroy and move objects in the world.
 * 
 * Commands:
 * 
 * CONTROL {Type Create} {ClassName class} {Name name} {Location x,y,z} {Rotation x,y,z}
 *     {Scale x,y,z} {Physics None/RigidBody/} {Permanent true/false}
 * CONTROL {Type Kill} {Name name}
 * CONTROL {Type KillAll} {MinPos x,y,z} {MaxPos x,y,z}
 * CONTROL {Type AbsMove} {Name name} {Location x,y,z} {Rotation x,y,z}
 * CONTROL {Type RelMove} {Name name} {Location x,y,z} {Rotation x,y,z}
 * CONTROL {Type Rotate} {Name name} {Speed x,y,z}
 * CONTROL {Type SetWP} {Name name} [{Speed s}|{Time t}] [{Move <true/false>}]
 *     [{Autoalign <true/false>}] [{Show <true/false>}] [{Loop <true/false>}]
 *     [{ResetOnClear <true/false>}] [{WP x,y,z;x,y,z;...}]
 * CONTROL {Type AddWP} {Name name} {WP x,y,z;x,y,z;...}
 * CONTROL {Type ClearWP} {Name name}
 * CONTROL {Type GetSTA} {Name name} {ClassName class} - get all objects, or just ones named name or of class class
 * 
 * Port and additions by Stephen Balakirsky
 * based on code by Marco Zaratti - marco.zaratti@gmail.com
*/
class WorldController extends Pawn config(USAR);

// Whether WC should destroy objects before exiting
var config bool cleanOnClose;
// Should log files be created on significant events?
var config bool logData;
// File number appended to log file name
var int LogPostfix;
// Objects controlled by this world controller
var array<WCObject> Objects;

// Clears all waypoint data of the specified object and moves it back to its start position
simulated function ClearAllWaypoints(WCObject item)
{
	local int numNodes;

	numNodes = item.WayPoints.Length;
	if (numNodes > 0)
	{
		// Clear arrays and restore to start
		item.WayPoints.Remove(0, numNodes);
		item.Paths.Remove(0, numNodes);
		item.PathProgress = 0;
		item.PathLength = 0;
		item.CurrentNode = 0;
		item.RestorePosition();
	}
}

// Fired when the world controller is cleaned up
simulated event Destroyed()
{
	local int i;
	local vector pos;

	if (bDebug)
		LogInternal("WorldController: Destroyed");
	// Clear traces and waypoints
	for (i = 0; i < Objects.Length; i++)
		ClearAllWaypoints(Objects[i]);
	// Clear all spawned objects
	if (cleanOnClose)
	{
		if (bDebug)
			LogInternal("WorldController: Destroying ALL spawned objects");
		pos = vect(0, 0, 0);
		KillAll(pos, pos);
	}
	super.Destroyed();
}

// Retrieves the robot with the specified name
simulated function BotController GetBotController(String botName)
{
	local int i;
	local BotDeathMatch usarGame;
	
	if (WorldInfo.Game.isA('BotDeathMatch'))
	{
		usarGame = BotDeathMatch(WorldInfo.Game);

		// Search for bot controller
		for (i = 0; i < usarGame.botList.length; i++)
			if (usarGame.botList[i].BotName == botName)
				return usarGame.botList[i];
	}
	return None;
}

// Gets the bounds of the specified object
simulated function vector GetObjectBounds(Actor obj)
{
	local Object.Box bbox;
	
	obj.GetComponentsBoundingBox(bbox);
	return bbox.Max - bbox.Min;
}

// Retrieves the object with the specified name
simulated function WCObject GetObjectByName(String objName)
{
	local int i;
	
	// (slow!) Look for the specified object
	for (i = 0; i < Objects.Length; i++)
		if (Caps(Objects[i].ObjectName) == Caps(objName))
			return Objects[i];
	return None;
}

// Retrieves the index of the object with the specified name
simulated function int GetObjectIndex(String objName)
{
	local int i;
	
	// (slow!) Look for the specified object
	for (i = 0; i < Objects.Length; i++)
		if (Caps(Objects[i].ObjectName) == Caps(objName))
			return i;
	return -1;
}

// Find the size of the current vector and the position in said vector
simulated function GetSegmentPos(WCObject item, out float segSize, out float segPos)
{
	local int node;
	
	node = item.CurrentNode;
	if (node == 0)
	{
		// On the first path
		segSize = item.Paths[0];
		segPos = item.PathProgress;
	}
	else
	{
		// On a subsequent path
		segSize = item.Paths[node] - item.Paths[node - 1];
		segPos = item.PathProgress - item.Paths[node - 1];
	}
}

// Gets the vector between the specified node of the item and the next node
simulated function vector GetSegmentVect(WCObject item, int node)
{
	local int maxNode;

	maxNode = item.WayPoints.Length - 1;
	if (node < maxNode)
		// Inside loop
		return item.WayPoints[node + 1] - item.WayPoints[node];
	else
		// Close loop
		return item.WayPoints[0] - item.WayPoints[node];
}

// Calculates the toal distance of the waypoints path of the given object. Also calculates the
// length of each segment and stores it in Paths (Paths[i] = distance from point 0 to i + 1)
// The object needs at least one waypoint for this to work (obviously?)
simulated function float GetTotalDistance(WCObject item, bool loop)
{
	local int i, numPoints;
	local float dist;
	
	numPoints = item.Waypoints.Length;
	if (numPoints > 0)
	{
		item.Paths.Length = numPoints;
		// Find all path lengths
		for (i = 0; i < numPoints; i++)
		{
			dist += VSize(GetSegmentVect(item, i));
			item.Paths[i] = dist;
		}
		// Always completely fill the segment length array as if it were looped
		if (loop || numPoints < 2)
			dist = item.Paths[numPoints - 1];
		else
			dist = item.Paths[numPoints - 2];
	}
	else
		dist = 0;
	return dist;
}

// Moves the specified world controller object to the given new position
function MoveItem(WCObject item, vector newLocation, rotator newRotation)
{
	if (bDebug)
		LogInternal("Moving '" $ item.ObjectName $ "' to " $
			class'UnitsConverter'.static.Str_LengthVectorFromUU(newLocation));
	// Teleport object
	item.SetPose(newLocation, newRotation);
}

// Moves the specified robot to the given new position
function MoveRobot(BotController mover, vector newLocation, rotator newRotation)
{
	if (bDebug)
		LogInternal("Moving '" $ mover.BotName $ "' to " $
			class'UnitsConverter'.static.Str_LengthVectorFromUU(newLocation));
	// Move the robot there with collision checks
	mover.Pawn.Move(newLocation - mover.Pawn.Location);
	mover.Pawn.SetRotation(newRotation);
}

// This function moves the specified object to a specified position in its path
simulated function SetObjectPosition(WCObject item, float dist)
{
	local vector newPos;
	local float segSize;
	local float segPos;

	// In bounds
	if (dist < 0)
		dist = 0;
	else if (dist > item.PathLength)
		dist = item.PathLength;
	// Roll up the node count onto the current segment
	while (dist >= item.Paths[item.CurrentNode])
		item.CurrentNode++;
	// Calculate position through segment math
	item.PathProgress = dist;
	GetSegmentPos(item, segSize, segPos);
	// Now calculate the new object position, use Move() to get there (respects collision!)
	newPos = item.Waypoints[item.CurrentNode] + GetSegmentVect(item, item.CurrentNode) *
		segSize / segPos;
	item.Move(newPos - item.Location);
}

// Update actor positions each tick (TODO Is there a better way?)
simulated function Tick(float DT)
{
	local int i;
	local WCObject item;
	local float progress;
	
	// Animate all the objects
	for (i = 0; i < Objects.Length; i++)
	{
		item = Objects[i];
		if (item != None && item.PathLength > 0)
		{
			// Moves the object along its path
			progress += item.PathProgress + item.PathSpeed * DT;
			// See if it has reached the end
			if (progress >= item.PathLength)
			{
				if (item.bLoop)
					progress -= item.PathLength;
				else
				{
					// Done
					progress = 0;
					item.PathLength = 0;
					item.RestorePosition();
				}
				item.CurrentNode = 0;
			}
			// Update if necessary
			SetObjectPosition(item, progress);
		}
	}
	super.Tick(DT);
}

// Commands to world controller
 
// AbsMove - moves an object to an absolute position in UU
function AbsMove(String objName, vector targetLocation, rotator targetRotation)
{
	local WCObject item;
	local BotController mover;
	
	// Find new location
	item = GetObjectByName(objName);
	mover = GetBotController(objName);
	if (item != None)
		MoveItem(item, targetLocation, targetRotation);
	else if (mover != None)
		MoveRobot(mover, targetLocation, targetRotation);
	else
		LogInternal("WorldController: No object named " $ objName);
}	

// Create - spawn an object at a given location with a given name
function Create(String objClass, String objName, String memory, vector objLocation,
	rotator objRotation, vector objScale, String objPhysics, bool isPermanent)
{
	local class<WCObject> objectClass;
	local WCObject item;
	
	// Avoid spawning a duplicate object
	if (GetObjectByName(objName) != None)
	{
		LogInternal("WorldController: Object named '" $ objName $ "' already exists");
		return;
	}
	// Save some user typing for common cases
	if (InStr(objClass, ".") < 0)
	{
		objClass = "USARPhysObj." $ objClass;
		LogInternal("WorldController: Object not fully qualified, assuming " $ objClass);
	}
	// Load the object data (class)
	objectClass = class<WCObject>(DynamicLoadObject(objClass, class'Class', true));
	if (objectClass == None)
	{
		LogInternal("WorldController: Invalid class name " $ objClass);
		return;
	}
	// Spawn object
	item = Spawn(objectClass, , , objLocation, objRotation);
	if (item == None)
	{
		LogInternal("WorldController: Cannot spawn object (is it inside existing geometry?)");
		return;
	}
	// Set default properties
	if (bDebug)
		LogInternal("WorldController: Spawned object '" $ objName $ "' at " $
			class'UnitsConverter'.static.Str_LengthVectorFromUU(objLocation));
	item.Init(objName, memory, isPermanent, objScale);
	// Set physics (defaults to rigid body)
	if (objPhysics != "RigidBody" && objPhysics != "Falling" && objPhysics != "Ground")
		item.SetPhysics(PHYS_None);
	Objects.AddItem(item);
}

// GetSTA - Get the status of objects; optionally filter by specified object class and name
function String GetSTA(String objClass, String objName)
{
	local name className;
	local int i;
	local WCObject item;
	local String outStr;
	local vector outSize;

	outStr = "STA";
	if (bDebug)
		LogInternal("WorldController: GetSTA");
	// Avoid having to save the class name explicitly and check at runtime
	// (also allows inherited classes to be checked)
	if (objClass != "")
		className = name(objClass);
	else
		className = 'WCObject';
	// Iterate through all objects
	for (i = 0; i < Objects.Length; i++)
	{
		item = Objects[i];
		if ((objClass == "" || item.isA(className)) &&
			(objName == "" || objName == item.ObjectName))
		{
			// Determine bounds real-time to return size
			outSize = GetObjectBounds(item);
			// Create message
			outStr = outStr $ " {Name " $ item.ObjectName $ "} {Size " $
				class'UnitsConverter'.static.Str_LengthVectorFromUU(outSize) $ "} {Location " $
				class'UnitsConverter'.static.Str_LengthVectorFromUU(item.Location) $
				"} {Rotation " $
				class'UnitsConverter'.static.Str_AngleVectorFromUU(item.Rotation) $ "}";
		}
	}
	return outStr;
}

// Kill - remove controlled object from world
function Kill(String objName)
{
	local int index;
	local WCObject item;
	
	index = GetObjectIndex(objName);
	if (index < 0)
		LogInternal("WorldController: Object '" $ objName $ "' not found");
	else
	{
		item = Objects[index];
		// Clean it up
		if (bDebug)
			LogInternal("WorldController: Killing object named " $ objName);
		ClearAllWaypoints(item);
		item.Destroy();
		// Faster than another linear search
		Objects.Remove(index, 1);
	}
}

// KillAll - remove all controlled objects from world
function KillAll(vector minPos, vector maxPos)
{
	local int i;
	local WCObject item;
	local FileLog fileLog;
	local vector size, logLoc, loc;
	
	fileLog = None;
	// Log kills if necessary
	if (logData && Objects.Length > 0)
	{
		fileLog = Spawn(class'FileLog');
		if (fileLog != None) 
		{
			fileLog.OpenLog("killLog" $ logPostfix);
			fileLog.Logf("Name, Class, Memory, X, Y, Z, Roll, Pitch, Yaw");
			logPostfix++;
		} 
	}
	if (bDebug)
		LogInternal("WorldController: Killing " $ Objects.Length $ " objects");
	// Destroy objects
	for (i = 0; i < Objects.Length; i++)
	{
		item = Objects[i];
		loc = item.Location;
		if (fileLog != None)
		{
			size = GetObjectBounds(item);
			// Convention of log file is a right-handed system with Z positive up and
			// Y positive left
			logLoc.X = loc.X;
			logLoc.Y = -loc.Y;
			logLoc.Z = size.Z - loc.Z;
			fileLog.Logf(item.ObjectName $ "," $ String(item.class) $ "," $ item.Memory $ "," $
				class'UnitsConverter'.static.Str_LengthVectorFromUU(logLoc) $ "," $
				class'UnitsConverter'.static.Str_AngleVectorFromUU(item.Rotation));
		}
		if (minPos == maxPos || (loc.X > minPos.X && loc.Y > minPos.Y && loc.Z > minPos.Z &&
			loc.X < maxPos.X && loc.Y < maxPos.Y && loc.Z < maxPos.Z))
		{
			// Clear waypoints
			ClearAllWaypoints(item);
			// Delete object
			if (!item.bPermanent)
			{
				item.Destroy();
				Objects.Remove(i, 1);
				i--;
			}
		}
	}
	if (fileLog != None)
		fileLog.CloseLog();
	// Cycle through all old WCObjects in the map, if any. These are left behind if an old
	// world controller was removed without killing all. To remove them, another WC can issue
	// a KillAll to remove these too
	if (minPos == maxPos)
		foreach AllActors(class'WCObject', item)
			if (!item.bPermanent)
				item.Destroy();
}

// RelMove - moves an object by a relative amount in UU
function RelMove(String objName, vector delLocation, rotator delRotation)
{
	local WCObject item;
	local BotController mover;
	
	// Find new location
	item = GetObjectByName(objName);
	mover = GetBotController(objName);
	if (item != None)
		MoveItem(item, delLocation + item.Location, delRotation + item.Rotation);
	else if (mover != None)
		MoveRobot(mover, delLocation + mover.Pawn.Location, delRotation + mover.Pawn.Rotation);
	else
		LogInternal("WorldController: No object named " $ objName);
}	

// Changes the velocity of a specified conveyor zone
function SetZoneVel(String objName, float newVelocity)
{
	local ConveyorVolume conveyor;
	local int i;
	local MaterialInstance myMaterial;
	
	// Find matching conveyor volume
	foreach AllActors(Class'ConveyorVolume', conveyor)
		if (String(conveyor.Tag) == objName)
		{
			conveyor.ZoneVelocity.X = conveyor.defaultSpeed.X * newVelocity;
			conveyor.ZoneVelocity.Y = conveyor.defaultSpeed.Y * newVelocity;
			conveyor.ZoneVelocity.Z = conveyor.defaultSpeed.Z * newVelocity;
			// Update materials with the new velocity to change appearance
			for (i = 0; i < conveyor.Conveyors.Length; i++)
			{
				myMaterial = conveyor.SpeedMaterial.MatInst;
				myMaterial.SetScalarParameterValue(conveyor.SpeedParameter, newVelocity);
				conveyor.Conveyors[i].StaticMeshComponent.SetMaterial(1, myMaterial);				
			}
			if (bDebug)
				LogInternal("WorldController: Set velocity of '" $ objname $ "' to " $
					class'UnitsConverter'.static.FloatString(newVelocity));
		}
	return;
}

defaultproperties
{
	bDebug=false
	LogPostfix=1
	DrawScale=1
	bNoDelete=false
	bStatic=false
	bBlockActors=false
	bCollideActors=false
	bAlwaysRelevant=true
}
