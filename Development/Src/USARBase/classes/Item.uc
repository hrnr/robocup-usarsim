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
 * Base class for all USAR addons, including effectors, sensors, and mission packages.
 */
class Item extends Actor config(USAR) abstract;

// The item position and direction
var vector Direction;
var vector Position;
// The item name
var repnotify String ItemName;
// The item type and mount point
var name ItemMount;
var String ItemType;
// Robot on which the item is mounted
var BaseVehicle Platform;
// Item's weight set in the configuration
var config float Weight;
// True if the item is on a client
var bool IsClient;
// True if the item is an owner
var bool IsOwner;
// Interval between calls to ScanInterval()
var config float ScanInterval;

// Called when the item is put on a vehicle (replaces the old registration functions)
simulated function AttachItem()
{
}

// Convert all variables of this class read from the UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{
}

// Initializes this item
function Init(String iName, Actor parent, vector pos, vector dir, BaseVehicle veh, name mount)
{
	local rotator rot;
	
	// Default mount to HARD
	if (mount == 'None')
		ItemMount = 'HARD';
	else
		ItemMount = mount;
	
	// Initialize variables
    Platform = veh;
	SetName(iName);
	SetBase(parent);
	rot.Roll = dir.X;
	rot.Pitch = dir.Y;
	rot.Yaw = dir.Z;
	SetRelativeRotation(rot);
	Position = pos;
	Direction = dir;
	
	// Make object visible
	SetHidden(false);
	AttachItem();
}

// Gets the header of the configuration data
simulated function String GetConfHead()
{
	return "CONF {Type " $ ItemType $ "}";
}

// Gets configuration data for this item
function String GetConfData()
{
	return "{Name " $ ItemName $ "}";
}

// Gets the header of the geometry data
simulated function String GetGeoHead()
{
	return "GEO {Type " $ ItemType $ "}";
}

// Gets geometry data for this item
function String GetGeoData()
{
	return "{Name " $ ItemName $ "}";
}

// Case insensitively checks to see if this item's name matches
simulated function bool IsName(String iName)
{
	return Caps(ItemName) == Caps(iName);
}

// Case insensitively checks to see if this item's type matches
simulated function bool IsType(String type)
{
	return Caps(ItemType) == Caps(type);
}

// Callback mechanism which uses a delegate to send messages
simulated delegate MessageSendDelegate(string msg)
{
	LogInternal("Item: no callback registered for MessageSendDelegate: " @ msg);
}

// Initializes this item
simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	
	// Initialization stuff with parameters and flags
	ConvertParam();
	SetClientFlag();
	IsOwner = true;
}

// Called after play begins
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	// Activate item timer based on the scan interval of each class
	if (ScanInterval > 0.0)
		SetTimer(ScanInterval, true);
}

replication
{
	if (bNetOwner && bNetDirty && Role == ROLE_Authority) 
		ItemName, IsOwner;
}

// Called when a replicated event occurs
simulated event ReplicatedEvent(name VarName)
{
	// Fix tag if item's name was set
	if (VarName == 'ItemName')
		Tag = name(ItemName);
}

// Sets a client parameter of this Item
function String Set(String opcode, String args)
{
	return "Failed";
}

// Sets a flag if the item is on a client
reliable client function SetClientFlag()
{
	IsClient = true;
}

// Changes the item's name
reliable server function SetName(String iName)
{
	ItemName = iName;
}

defaultproperties
{
	bAlwaysRelevant=true;
	bHardAttach=true;
	bUpdateSimulatedPosition=true;
	DrawScale=1.0;
	IsClient=false;
	IsOwner=false;
	ItemType="Item";
	RemoteRole=ROLE_SimulatedProxy;
}
