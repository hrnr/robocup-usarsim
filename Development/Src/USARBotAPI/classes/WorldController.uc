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
 * CONTROL {Type Create} {ClassName class} {Name name} {location x,y,z} {rotation x,y,z} {sclae x,y,z} {Physics None/Ground/Falling/RigidBody/Walking} {Permanent true/false}
 * CONTROL {Type Kill} {Name name}
 * CONTROL {Type KillAll} {MinPos x,y,z} {MaxPos x,y,z} // note that MinPos and MaxPos are optional.
 * 														// if specified, then non-permanent objects in the defined
 * 														// volume are removed. If not specified, then all objects
 * 														// are killed.
 * CONTROL {Type AbsMove} {Name name} {location x,y,z} {rotation x,y,z}
 * CONTROL {Type RelMove} {Name name} {location x,y,z} {rotation x,y,z}
 * 
 * CONTROL {Type Rotate} {Name name} {Speed x,y,z}
 * 
 * CONTROL {Type SetWP} {Name name} [{Speed s}|{Time t}] [{Move <true/false>}]
 * 		[{Autoalign <true/false>}] [{Show <true/false>}] [{Loop <true/false>}]
 * 		[{ResetOnClear <true/false>}] [{WP x,y,z;x,y,z;...}]
 * CONTROL {Type AddWP} {Name name} {WP x,y,z;x,y,z;...}
 * CONTROL {Type ClearWP} {Name name}
 * CONTROL {Type GetSTA} {Name name} {ClassName class} - get all objects, or just ones named name or of class class
 * 
 * Port and additions by Stephen Balakirsky
 * based on code by Marco Zaratti - marco.zaratti@gmail.com
*/

class WorldController extends Pawn config(USAR);
var config bool logData; // should log files be created on significant events?
var int logPostfix;      // file number appended to log file name
enum wcPhysics
{
	wcPhysics_None,
	wcPhysics_Falling,
	wcPhysics_Ground,
	wcPhysics_RigidBody,
	wcPhysics_Walking,
};

var String wpdelim; //Waypoint list delimiter.
var array<texture> traceTexture;
var config bool cleanOnClose;   // If WC should destroy its objects before exiting.
var int cmdIdx;                 // Used to loop through all WC enqueued commands

// This struct holds all the controlled objects.
struct ControlledObject
{
	var WCObject wcoActor;                // A reference to the object.
	var vector startLoc;
	var rotator startRot;

	// Animation state is controlles by these 2 bools
	// Rotation and waypoints movement can be activated independently.
	var bool bMoving;
	var bool bRotating;

	var array<vector> aWayPoints;   // Waypoints used to move the object across a path.
	var array<float> aSegLengths;   // aSegLength[i] = distance from point [0] to [i+1]
	var float fSpeed;           // Movement speed.
	var bool bLoop;             // Should waypoints travel be looped.
	var bool bAlign;            // If the object is aligned to the path.
	var bool bShow;             // Show tracings.
	var bool bResetOnClear;     // Resets its start posistion and rotation on clearWaypoints.
	var float fTotalDistance;   // Total path length.
	var float fCurrentDistance;  // Current point in the path.
	var int nCurrentPoint;       // Current waypoint.
	var rotator rRotSpeed;    // A constant angular speed for rotation.
	var EPhysics objPhysics;     // what kind of physics should we use?
};
var array<ControlledObject> controlledObjects;

////////////////////////////////////////////////////////////////////////////////

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	logPostfix = 1;
}

simulated event Destroyed()
{
	local int id, len;
	local vector trash;

	len = controlledObjects.Length;
	for (id = 0; id < len; id++)
	{
		ShowTracesOf(id, false);
		ClearWaypointsOf(id);
	}
	if (cleanOnClose)
	{
		trash.x = 0;
		trash.y = 0;
		trash.z = 0;
		KillAll(trash, trash);
	}
	super.Destroyed();
}

// Returns the index of the object 'getName', -1 if not found.
simulated function int GetObject(String getName)
{
	local int i;

	for (i = 0; i < controlledObjects.length; i++)
		if (controlledObjects[i].wcoActor.wcoName == getName)
			return i;
	return -1;
}

// Returns the reference of the robot 'getName', None if not found in the map.
simulated function BotController GetController(String getName)
{
	local int i;
	local BotDeathMatch UsarGame; 
	UsarGame = BotDeathMatch(WorldInfo.Game);

	for (i = 0; i < UsarGame.botList.length; i++)
		if (UsarGame.botList[i].PlayerReplicationInfo.PlayerName == getName)
			return UsarGame.botList[i];
	return None;
}

//////////////////////////////////////////////////////////////////////////////////
// Commands to world controller

/*
   Create - Create an object at a given location with a given name
   NOTE: ScaleIn currently does not do anything! This is because of problems with collision scaling.
 */
function Create(String ClassToMake, String NameIn, String MemoryIn, vector LocationIn,
	vector RotationIn, vector ScaleIn, String PhysicsToUse, bool permanentIn)
{
	local int id;
	local vector newLocation;
	local Rotator newRotation;
	local class<WCObject> objectClass;
	local WCObject wcoActor; 

	id = GetObject(NameIn);
	if (id != -1)
	{
		LogInternal("WorldController:Create: Object of name " $ NameIn $ " already exists!");
		return;
	}
	newLocation = class'UnitsConverter'.static.LengthvectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AnglevectorToUU(RotationIn);
	objectClass = class<WCObject>(DynamicLoadObject(ClassToMake, class'Class'));
	if (objectClass == None)
		return;
	wcoActor = Spawn(objectClass, , , newLocation, newRotation);
	if (wcoActor != None)
	{
		id = controlledObjects.length;
		controlledObjects.Insert(id, 1);
		controlledObjects[id].wcoActor = wcoActor;
	}
	else
	{
		LogInternal("WorldController: Error adding bot");
		return;
	}
	LogInternal("WorldController: Spawned robot model named " $ NameIn $ " at: " $newLocation $
		" memory: " $ MemoryIn);
	controlledObjects[id].wcoActor.wcoName = NameIn;
	controlledObjects[id].wcoActor.wcoMemory = MemoryIn;
	controlledObjects[id].wcoActor.wcoClass = ClassToMake;
	controlledObjects[id].startLoc = newLocation;
	controlledObjects[id].startRot = newRotation;
	controlledObjects[id].bResetOnClear = true;
	controlledObjects[id].wcoActor.permanent = permanentIn;
	if (PhysicsToUse == "None")
	{
		controlledObjects[id].objPhysics = PHYS_None;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
	}
	else if (PhysicsToUse == "Falling")
	{
		controlledObjects[id].objPhysics = PHYS_Falling;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_Falling);
	}
	else if (PhysicsToUse == "RigidBody")
	{
		controlledObjects[id].objPhysics = PHYS_RigidBody;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_RigidBody);
	}
	else if (PhysicsToUse == "Walking")
	{
		controlledObjects[id].objPhysics = PHYS_Walking;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_Walking);
	}
	else
		controlledObjects[id].objPhysics = PHYS_None;
}

// SetZoneVel - Set Zone Velocity
function SetZoneVel(String NameIn, float velocityIn)
{
	local ConveyorVolume A;
	local int count;
	local MaterialInstance myMaterial;

	foreach AllActors(Class'ConveyorVolume', A)
	{
		if (A.conveyorTag == NameIn)
		{
			A.ZoneVelocity.X = A.defaultSpeed.X * velocityIn;
			A.ZoneVelocity.Y = A.defaultSpeed.Y * velocityIn;
			A.ZoneVelocity.Z = A.defaultSpeed.Z * velocityIn;
			
			for (count = 0; count < A.Conveyors.Length; count++)
			{
				myMaterial = A.SpeedMaterial.MatInst;
				myMaterial.SetScalarParameterValue(A.SpeedParameter, velocityIn);
				A.Conveyors[count].StaticMeshComponent.SetMaterial(1, myMaterial);				
			}
		}
	}
	return;
}

// GetSTA - Get the status of objects. If class is specified, only return objects of that class;
// if name is specified, only that name
function String GetSTA(String ClassIn, String NameIn)
{
	local int len, id;
	local String OutStr;
	local vector OutSize;

	OutStr = "STA ";
	len = controlledObjects.Length;
	if (len > 0)
		for (id = 0; id < len; id++)
		{
			if (ClassIn != "" && ClassIn != controlledObjects[id].wcoActor.wcoClass)
				continue;
			if (NameIn != "" && NameIn != controlledObjects[id].wcoActor.wcoName)
				continue;
			OutSize.x = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.x * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.x; 
			OutSize.y = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.y * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.y; 
			OutSize.z = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.z * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.z; 
			OutStr = OutStr $ "{Name " $ controlledObjects[id].wcoActor.wcoName $"}" ;
			OutStr = OutStr $ "{Memory " $ controlledObjects[id].wcoActor.wcoMemory $"}" ;
			OutStr = OutStr $ "{Size " $ OutSize $"}";
			OutStr = OutStr $ "{Location " $ class'UnitsConverter'.static.Str_LengthvectorFromUU(controlledObjects[id].wcoActor.Location) $"}";
			OutStr = OutStr $ "{Rotation " $ class'UnitsConverter'.static.Str_AnglevectorFromUU(controlledObjects[id].wcoActor.Rotation) $"}";
		} 
	return OutStr;
}
 
// RelMove - moves an object or a robot by a relative amount; currently only supports the movement of a mesh
function RelMove(String NameIn, vector LocationIn, vector RotationIn)
{
	local BotController mover;
	local vector newLocation;
	local Rotator newRotation;
	local int id;

	newLocation = class'UnitsConverter'.static.LengthvectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AnglevectorToUU(RotationIn);
	id = GetObject(NameIn);
	if (id != -1)
	{
		newLocation += controlledObjects[id].wcoActor.Location;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
		controlledObjects[id].wcoActor.SetLocation(newLocation);
		newRotation = controlledObjects[id].wcoActor.Rotation + newRotation;
		controlledObjects[id].wcoActor.SetRotation(newRotation);
		controlledObjects[id].wcoActor.SetPhysics(controlledObjects[id].objPhysics);
	}
	else if (GetController(NameIn) != None)
	{
		mover = GetController(NameIn);
		mover.pawn.Move(newLocation);
		LogInternal("WorldController: Moving robot located at: " $ mover.pawn.Location);
		LogInternal("	by " $ newLocation $ " " $ newRotation);
		LogInternal("   to " $ newLocation);
	}
	else
		LogInternal("WorldController: Unable to find robot named " $ NameIn);
}	
 
// AbsMove - moves an object or a robot to an absolute position; currently only supports the movement of a mesh
function AbsMove(String NameIn, vector LocationIn, vector RotationIn)
{
	local vector newLocation;
	local Rotator newRotation;
	local int id;

	newLocation = class'UnitsConverter'.static.LengthvectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AnglevectorToUU(RotationIn);
	id = GetObject(NameIn);
	if (id != -1)
	{
		LogInternal("WorldController: Moving object " $ controlledObjects[id].wcoActor.wcoName);
		LogInternal("   From: " $controlledObjects[id].wcoActor.location$ " " $controlledObjects[id].wcoActor.Rotation);
		LogInternal("   to relative: " $ newLocation $ " " $ newRotation);
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
		controlledObjects[id].wcoActor.dirty = 2;
		controlledObjects[id].wcoActor.SetLocation(newLocation);
		controlledObjects[id].wcoActor.SetRotation(newRotation);
		controlledObjects[id].wcoActor.ForceUpdateComponents();
	}
	else
		LogInternal("WorldController: Unable to find robot named: " $ NameIn);
}	

// Kill - remove controlled object from world
function Kill(String NameIn)
{
	local int id;

	LogInternal("WorldController killing object named: " $ NameIn);
	id = GetObject(NameIn);
	if (id == -1)
	{
		LogInternal("WorldController: unable to remove actor " $ NameIn);
		return;
	}
	ShowTracesOf(id, false);
	ClearWaypointsOf(id);
	controlledObjects[id].wcoActor.Destroy();
	controlledObjects.Remove(id, 1);
}

// KillAll - remove all controlled objects from world
function KillAll(vector MinPos, vector MaxPos)
{
	local int len, id;
	local WCObject wco;
	local vector currentLoc;
	local String fileName;
	local FileLog myLog;
	local vector posvector, palletvector;

	myLog = None;
	palletvector.x = 0;
	palletvector.y = 0;
	palletvector.z = 0;

	if (MinPos != MaxPos)
	{
		MinPos = class'UnitsConverter'.static.LengthvectorToUU(MinPos);
		MaxPos = class'UnitsConverter'.static.LengthvectorToUU(MaxPos);
	}
	if (logData)
	{
		myLog = spawn(class'FileLog');
		if (myLog != None) 
		{
			fileName = "killLog" $ logPostfix;
			myLog.OpenLog(fileName);
			myLog.Logf("name, class, memory, x, y, z, roll, pitch, yaw");
			logPostfix += 1;
		} 
	}
	len = controlledObjects.Length;
	LogInternal("WorldController: Killing " $ len $ " Objects");
	if (len > 0)
	{
		for (id = 0; id < len; id++)
		{
			if (myLog != None)
			{
				posvector = controlledObjects[id].wcoActor.location;
				if (controlledObjects[id].wcoActor.wcoMemory == "Pallet")
				{
					palletvector = posvector;
					palletvector.x -= controlledObjects[id].wcoActor.boundary.x;
					palletvector.y += controlledObjects[id].wcoActor.boundary.y;
					palletvector.z -= controlledObjects[id].wcoActor.boundary.z;
					palletvector.z *= -1;
					palletvector.y *= -1;
				}
				posvector.z -= controlledObjects[id].wcoActor.boundary.Z;
				posvector.z *= -1; // convention of log file has z positive up
				posvector.y *= -1.;
				
				myLog.Logf(controlledObjects[id].wcoActor.wcoName $ "," $ 
					controlledObjects[id].wcoActor.wcoClass $ "," $
					controlledObjects[id].wcoActor.wcoMemory $ "," $
					class'UnitsConverter'.static.Str_LengthvectorFromUU(posvector - palletvector) $ "," $
					class'UnitsConverter'.static.Str_AnglevectorFromUU(controlledObjects[id].wcoActor.rotation));
			}
		}
		for (id = 0; id < len; id++)
		{
			currentLoc = controlledObjects[id].wcoActor.Location;
			LogInternal("Package Location: " $ currentLoc);
			if (MinPos == MaxPos || (currentLoc.x > MinPos.x && currentLoc.y > MinPos.y &&
				currentLoc.z > MinPos.z && currentLoc.x < MaxPos.x && currentLoc.y < MaxPos.y &&
				currentLoc.z < MaxPos.z))
			{
				ShowTracesOf(id, false);
				ClearWaypointsOf(id);
				if (!controlledObjects[id].wcoActor.permanent)
				{
					controlledObjects[id].wcoActor.Destroy();
					controlledObjects.Remove(id, 1);
					// Need to adjust the array since we deleted some of it
					id--;
					len--;
				}
			}
		}
	}
	if (logData)
		myLog.CloseLog();
	// Then cycle through all the other WC objects in the map, if any. You can
	// find these objects when a previous WorldController created them and
	// then quit without removing them. You can for example create a WC, then
	// use it to populate the map and quit the WC leaving all the objects in the map.
	// When you want to remove these objects you create another WC and issue a KillAll.
	if (MinPos == MaxPos)
		foreach AllActors(class'WCObject', wco)
			wco.Destroy();
}


function vector setElevationPose(vector locationIn, int idIn)
{
	local vector HitLocation, HitNormal;
    local vector range;
	local vector testTrace;
	local float maxElevation;
	local vector myReturn;
	local float rangeMeters;
		
	range.x = 0;
	range.y = 0;
	rangeMeters = 0;
	while (rangeMeters < 2)
	{
		rangeMeters += 1;
		// Move objects that are up to 1 meter above the ground to the ground 
		range.z = class'UnitsConverter'.static.LengthToUU(rangeMeters);
	
		// lets get trace information!
		// try points around object to find highest elevation
		testTrace = locationIn;
		testTrace.x += controlledObjects[idIn].wcoActor.boundary.X;
		if (Trace(HitLocation, HitNormal, testTrace - 2 * range, testTrace + range) != None)
			maxElevation = HitLocation.z;
		else
			maxElevation = -100000;
		testTrace.x -= 2 * controlledObjects[idIn].wcoActor.boundary.X;
		if (Trace(HitLocation, HitNormal, testTrace - 2 * range, testTrace + range) != None)
		{
			if (maxElevation < HitLocation.z)
				maxElevation = HitLocation.z;
		}
		testTrace.x += controlledObjects[idIn].wcoActor.boundary.X;
		testTrace.y += controlledObjects[idIn].wcoActor.boundary.Y;
		if (Trace(HitLocation, HitNormal, testTrace - 2 * range, testTrace + range) != None)
		{
			if (maxElevation < HitLocation.z)
				maxElevation = HitLocation.z;
		}
		testTrace.y -= 2 * controlledObjects[idIn].wcoActor.boundary.Y;
		if (Trace(HitLocation, HitNormal, testTrace - 2 * range, testTrace + range) != None)
		{
			if (maxElevation < HitLocation.z)
				maxElevation = HitLocation.z;
		}
		if (maxElevation > -90000)
		{
			myReturn.z = maxElevation + controlledObjects[idIn].wcoActor.boundary.Z;
			return myReturn;
		}
		else
		{
			LogInternal("WorldController: Unable to set object elevation");
			myReturn.z = locationIn.z;
		}
	}
	return myReturn;
}		

simulated function bool IsVectNull(vector v)
{
    return v.X ~= 0 && v.Y ~= 0 && v.Z ~= 0;
}

simulated function bool IsRotNull(rotator r)
{
    return r.Roll ~= 0 && r.Pitch ~= 0 && r.Yaw ~= 0;
}

// Adds the USARRemoteBot(Controller).WC[cmdIdx].wpList to the 'id' object.
// Returns the number of waypoints added.
simulated function int AddWPListTo(int id)
{
	return 0; // TODO Remove when function is restored
}

// Shows or hides (deleting) the waypoint trace for the 'id' object.
// This func will always destroy all previous traces, if any. This
// assures that, even if you change waypoints, the traces will be
// correctly drawn.
simulated function ShowTracesOf(int id, bool show)
{
	// TODO Remove when function is restored
}

// Clears all waypoints data of object 'id'.
// That means that all arrays are cleared
// (aWayPoints, aSegLengths, ATracings) and
// the objects is moved to its starting position.
simulated function ClearWaypointsOf(int id)
{
    local int numNodes;

    numNodes = controlledObjects[id].aWayPoints.Length;
    if (numNodes > 0)
    {
        // Deletes aWayPoints array
        controlledObjects[id].aWayPoints.Remove(0, numNodes);
        // Deletes aSegLength array
        controlledObjects[id].aSegLengths.Remove(0,numNodes);
        controlledObjects[id].fCurrentDistance = 0.0;
        controlledObjects[id].nCurrentPoint = 0;
        controlledObjects[id].fTotalDistance = 0.0;
        controlledObjects[id].bMoving = false;
    }
}

// Calculates the toal distance of the waypints path of the 'id' object.
// closedLoop specify if the path must be considered closed
// or open. Closed path is always longer than open.
// It also calculates the length of each segment and store it in aSegLengths.
// aSegLength[i] = distance from point [0] to [i+1].
simulated function float CalculateWPDistanceOf(int id, bool closedLoop)
{
    local int i;
    local int numPoints;
    local vector segment;
    local float segLen, dist;

    numPoints = controlledObjects[id].aWayPoints.Length -1;

    if (numPoints >= 0)
    {
        // First find the open path length (points = num of wp -1)
        while(i < numPoints)
        {
            segment = controlledObjects[id].aWayPoints[i + 1] - controlledObjects[id].aWayPoints[i];
            dist += VSize(segment);
            controlledObjects[id].aSegLengths[i] = dist;
            i++;
        }
        segment = controlledObjects[id].aWayPoints[0] - controlledObjects[id].aWayPoints[i];
        segLen = dist + VSize(segment);
        // We always fill completely the segment length array (as if it were looped).
        controlledObjects[id].aSegLengths[i] = segLen;
        if (closedLoop)
            dist = segLen;
    }
    else
        dist = 0;
    return dist;
}

//Returns the vector [node] ->[node +1] of the object 'id'.
simulated function vector GetSegmentVect(int id, int node)
{
    local int maxNode;

    maxNode = controlledObjects[id].aWayPoints.Length -1;
    if (node < maxNode)
        // The object is moving from: [node] -> [node +1]
        return (controlledObjects[id].aWayPoints[node +1] - controlledObjects[id].aWayPoints[node]);
    else// We're closing the loop: [lastNode] -> [0].
        return (controlledObjects[id].aWayPoints[0] - controlledObjects[id].aWayPoints[node]);
}

// Returns:
// segSize: the size of the vector [node] ->[node +1].
// segPos: the position inthe curent segment.
simulated function GetSegmentPos(int id, int node, out float segSize, out float segPos)
{
    // aSegLengths[node] is the distance that the object will cover at the end of the current segment.
    // So, the current segment size can be obtained this way:
    // aSegLengths[node] - aSegLengths[node -1].
    if (node == 0)
    {
        segSize = controlledObjects[id].aSegLengths[0];
        segPos = controlledObjects[id].fCurrentDistance;
    }
    else
    {
        segSize = controlledObjects[id].aSegLengths[node] - controlledObjects[id].aSegLengths[node -1];
        segPos = controlledObjects[id].fCurrentDistance - controlledObjects[id].aSegLengths[node -1];
    }
}

// This function sets the object 'id' at a specified position in the path.
simulated function SetTheObjectTo(int id, float dist)
{
    local int node;
    local vector segVect, newPos;
    local float segSize;
    local float segPos;

    if (dist < 0)
        dist = 0;
    else if (dist > controlledObjects[id].fTotalDistance)
        dist = controlledObjects[id].fTotalDistance;
    controlledObjects[id].fCurrentDistance = dist;
    node = controlledObjects[id].nCurrentPoint;
    // Finds the node where we are (last node we passed).
    // 'node' cannot become bigger than the size of waypoints array
    // because we have limited dist at the beginning of this function.
    while (dist >= controlledObjects[id].aSegLengths[node])
        node++;
    // Updates the current node
    controlledObjects[id].nCurrentPoint = node;
    GetSegmentPos(id, node, segSize, segPos);
    segVect = GetSegmentVect(id, node);
    // Performs linear interpolation.
	LogInternal("WorldController: NewPos " $ class'UnitsConverter'.static.vectorString(newPos));
    // Now calculate the new object position. We must use Move(), that is a
    // relative movement function. We're also reusing segVect var.
	segVect = newPos - controlledObjects[id].wcoActor.Location;
	controlledObjects[id].wcoActor.Move(segVect);
}

simulated function Tick(float Delta)
{
    local int i;
	local int len, id;
	
    len = controlledObjects.Length;
    for (id = 0; id < len; id++)
    {
		if (controlledObjects[id].wcoActor.dirty == 1)
		{
			controlledObjects[id].wcoActor.dirty = 0;
			controlledObjects[id].wcoActor.SetPhysics(controlledObjects[id].objPhysics);
			controlledObjects[id].wcoActor.ForceUpdateComponents();
		}
		else if (controlledObjects[id].wcoActor.dirty > 1)
			controlledObjects[id].wcoActor.dirty--;
    }

    // Animate all the objects
    for (i=0; i < controlledObjects.length; i++)
    {
        // Waypoint animation
        if (controlledObjects[i].bMoving)
        {
            // Moves the objec along the path
            controlledObjects[i].fCurrentDistance += controlledObjects[i].fSpeed*Delta;

            // See if we have reached the end of the path
            if (controlledObjects[i].fCurrentDistance >= controlledObjects[i].fTotalDistance)
            {
                if (controlledObjects[i].bLoop)
                    controlledObjects[i].fCurrentDistance -= controlledObjects[i].fTotalDistance;
                else
                {
                    controlledObjects[i].fCurrentDistance = 0;
                    controlledObjects[i].bMoving = false;
                }
                controlledObjects[i].nCurrentPoint = 0;
            }
            if (controlledObjects[i].bMoving)
                SetTheObjectTo(i, controlledObjects[i].fCurrentDistance);
        }
    }
	super.Tick(Delta);
}

function SendLine(String outString)
{

}

defaultproperties
{
    bDebug=false
    wpdelim=";"
	DrawScale=1
    bNoDelete=false
    bStatic=false
    bBlockActors=false
	bCollideActors=false
	bAlwaysRelevant=true
}
