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
// Should the object not be destroyed by a clear?
var bool bPermanent;
// Should the object be reset back to starting position on a clear?
var bool bResetOnClear;
// The object's current position in its path
var int CurrentNode;
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

// Initializes this object using the specified values
function Init(String objName, String mem, bool isPermanent, vector scale)
{
	bPermanent = isPermanent;
	Memory = mem;
	ObjectName = objName;
	OriginalLocation = Location;
	OriginalRotation = Rotation;
	SetDrawScale3D(scale);
	StaticMeshComponent.SetStaticMesh(Mesh);
	// Need to do these to start physics
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

defaultproperties
{
	bLoop=false
	bPermanent=false
	bResetOnClear=true
	CurrentNode=0
	Memory=""
	ObjectName="UnnamedObject"
	PathLength=0.0
	PathProgress=0.0
	PathSpeed=0.0
	
	Mesh=None
	
	bBlocksTeleport=true
	bNetInitialRotation=true
	bConsiderAllStaticMeshComponentsForStreaming=true
	bNoDelete=false
	CollisionType=COLLIDE_BlockAll
	Name="DefaultWCObject"
	Physics=PHYS_RigidBody
	TickGroup=TG_PostAsyncWork
}
