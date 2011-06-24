/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Item - Base class for all USAR addons, including effectors, sensors, and actuators.
 */
class Item extends KActor config(USAR) abstract;

// The item name
var repnotify String ItemName;
// The item type
var String ItemType;
// True if the item is on a client
var bool IsClient;
// True if the item is an owner
var bool IsOwner;
// Robot on which the item is mounted
var BaseVehicle Platform;
// Interval between calls to ScanInterval()
var config float ScanInterval;

// Called when the item is put on a vehicle (replaces the old registration functions)
simulated function AttachItem()
{
}

// Called by Timer during certain conditions - where processing should be done
simulated function ClientTimer()
{
}

// Convert all variables of this class read from the UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{
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

// Initializes this item
function Init(String iName, BaseVehicle veh)
{
	// Initialize variables
    Platform = veh;
	SetName(iName);
	
	// Make object visible
	SetHidden(false);
	AttachItem();
}

// Convenience function to check whether this Item is actually a joint
simulated function bool IsJoint()
{
	return false;
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
simulated delegate MessageSendDelegate(String msg)
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
	bAlwaysRelevant=true
	bHardAttach=false
	bNoDelete=false
	bStatic=false
	bUpdateSimulatedPosition=true
	DrawScale=1.0
	IsClient=false
	IsOwner=false
	ItemType="Item"
	RemoteRole=ROLE_SimulatedProxy
}
