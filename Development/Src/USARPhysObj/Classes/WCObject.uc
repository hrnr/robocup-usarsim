/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WCObject - Object spawnable via World Controller
 * Based on code by Marco Zaratti (a long, long time ago)
 */
class WCObject extends KActor config(USAR) placeable;

// Should the object loop around?
var bool bLoop;
// Should the object move at all? (false = paused)
var bool bMoving;
// Should the object not be destroyed by a clear?
var bool bPermanent;
// Should the object be reset back to starting position on a clear?
var bool bResetOnClear;
// The object's current position in its path
var int CurrentNode;
// The object's mass in kilograms
var float Mass;
// RFID tag information for pallet sorting and moving
var String Memory;
// The object's static mesh
var StaticMesh Mesh;
// Object's WC name (independent of the automatically-generated real name)
var String ObjectName;
// Object's starting location for reset
var vector OriginalLocation;
// Object's starting rotation for reset
var rotator OriginalRotation;
// Distance along the path that the object has gone so far
var float PathProgress;
// Distance of the path the object can travel (or 0 if it cannot move)
var float PathLength;
// The speed at which the object moves along its path
var float PathSpeed;
// Lengths of individual segments in the object's path
var array<float> Paths;
// Locations of segments in the object's path
var array<vector> Waypoints;


// Find the size of the current vector and the position in said vector
simulated function GetSegmentPos(out float segSize, out float segPos)
{
	if (Paths.Length < 1)
	{
		// Degenerate case
		segSize = 0;
		segPos = 0;
	}
	else if (CurrentNode == 0)
	{
		// On the first path
		segSize = Paths[0];
		segPos = PathProgress;
	}
	else
	{
		// On a subsequent path
		segSize = Paths[CurrentNode] - Paths[CurrentNode - 1];
		segPos = PathProgress - Paths[CurrentNode - 1];
	}
}

// Gets the vector between the specified node of this item and the next node
simulated function vector GetSegmentVect(int node)
{
	local int maxNode;
	
	maxNode = WayPoints.Length - 1;
	if (node < maxNode)
		// Inside loop
		return WayPoints[node + 1] - WayPoints[node];
	else
		// Close loop
		return WayPoints[0] - WayPoints[maxNode];
}

// Initializes this object using the specified values
function Init(String objName, String mem, bool isPermanent, vector scale, String matName)
{
	local Material mat;
	
	// Set basics
	bPermanent = isPermanent;
	Memory = mem;
	ObjectName = objName;
	OriginalLocation = Location;
	OriginalRotation = Rotation;
	// Set drawscale BEFORE mesh to fix collision scaling problem
	SetDrawScale3D(scale);
	StaticMeshComponent.SetStaticMesh(Mesh);
	if (matName != "")
	{
		// Update material
		if (InStr(matName, ".") < 0)
		{
			matName = "WCObjectPkg.Crates." $ matName;
			LogInternal("WCObject: Material name not fully qualified, assuming " $ matName);
		}
		mat = Material(DynamicLoadObject(matName, class'Material', true));
		if (mat != None)
			StaticMeshComponent.SetMaterial(0, mat);
		else
			LogInternal("WCObject: Invalid material " $ matName);
	}
	// Need to do these to start physics
	class'Utilities'.static.SetMass(self, Mass * scale.X * scale.Y * scale.Z);
	SetPhysicalCollisionProperties();
	ForceUpdateComponents();
	StaticMeshComponent.WakeRigidBody();
}

// Restore the object's initial position
function RestorePosition()
{
	SetLocation(OriginalLocation);
	SetRotation(OriginalRotation);
}

// Rotate the actor at its rotation rate given the time elapsed since last rotation
function RotateRate(float DT)
{
	if (Physics == PHYS_None)
		SetRelativeRotation(RotationRate * DT);
	else
		StaticMeshComponent.SetRBRotation(Rotation + RotationRate * DT);
}

// Changes the object location and rotation cleanly
function SetPose(vector loc, rotator rot)
{
	if (Physics == PHYS_None)
	{
		SetLocation(loc);
		SetRotation(rot);
	}
	else
	{
		StaticMeshComponent.SetRBPosition(loc);
		StaticMeshComponent.SetRBRotation(rot);
	}
}

// Calculates the total distance of the waypoints path of this object. Also calculates the
// length of each segment and stores it in Paths (Paths[i] = distance from point 0 to i + 1)
function UpdateTotalDistance()
{
	local int i, numPoints;
	local float dist;
	
	numPoints = Waypoints.Length;
	if (numPoints > 0)
	{
		Paths.Length = numPoints;
		// Find all path lengths
		for (i = 0; i < numPoints; i++)
		{
			dist += VSize(GetSegmentVect(i));
			Paths[i] = dist;
		}
		// Always completely fill the segment length array as if it were looped
		if (bLoop || numPoints < 2)
			dist = Paths[numPoints - 1];
		else
			dist = Paths[numPoints - 2];
	}
	else
		dist = 0;
	// Properly store path length
	PathLength = dist;
}


defaultproperties
{
	bLoop=false
	bMoving=true
	bPermanent=false
	bResetOnClear=true
	CurrentNode=0
	Memory=""
	ObjectName="UnnamedObject"
	PathLength=0.0
	PathProgress=0.0
	PathSpeed=0.0
	
	Mass=0.1
	Mesh=None
	
	bBlocksTeleport=true
	bNetInitialRotation=true
	bConsiderAllStaticMeshComponentsForStreaming=true
	bNoDelete=false
	CollisionType=COLLIDE_BlockAll
	Name="DefaultWCObject"
	TickGroup=TG_PostAsyncWork
}
