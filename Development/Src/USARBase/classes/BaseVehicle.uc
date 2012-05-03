/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * BaseVehicle: parent class of USARVehicle, which parents all robots. Do not directly descend from this class.
 */
class BaseVehicle extends Pawn config(USAR) abstract;

// FIXME delete
struct SpecItem {
	var class<Actor> ItemClass;
	var name Parent;
	var String ItemName;
	var vector Position;
	var vector Direction;
	var rotator uuDirection;
	var StaticMesh Mesh;
	var bool startAttached;
	
	structdefaultproperties
	{
		startAttached = true;
	}
};

// Array storing all configured parts from the INI file
var config array<SpecItem> AddParts;
// The body (true parent) of the robot
var Part Body;
// The item at the center of the robot
var PhysicalItem CenterItem;
// Headlights on?
var bool HeadLights;
// Joints connecting the vehicle to its parts
var array<Joint> Joints;
// Timer used for sending out sensor data
var config float MsgTimer;
// Components declared in the default properties
var array<Part> PartList;
// Array storing all active parts on the robot
var array<Item> Parts;
//Array storing all inactive parts on the robot (e.g. detached actuators)
var array<Item> offParts;
// The weight of the vehicle assigned in the INI file
var config float Weight;

// Called by Timer() while the battery is alive to send back status messages if necessary
simulated function ClientTimer()
{
}

// Called to convert parameters from SI to UU
simulated function ConvertParam()
{
}

// Called when the robot is destroyed
simulated event Destroyed()
{
	local int i;
	
	super.Destroyed();
	// Remove all active and inactive parts
	for (i = Parts.length-1; i >= 0; i-- )
		Parts[i].Destroy();
	for (i = offParts.length-1; i >= 0; i-- )
		offParts[i].Destroy();
}

// Called when an item is destroyed
simulated function OnItemRemoved( Item ii )
{
	local int i;
	local JointItem ji;

	self.Parts.RemoveItem( ii );
	self.offParts.RemoveItem( ii );

	// Bug; The next time JointItem is used (SetVelocity, SetTarget, etc), UDK crashes...
	// Seems UDK does not check if initialized contraints are still valid after a rigid body is destroyed
	for (i = Parts.length-1; i >= 0; i-- )
	{
		ji = JointItem(Parts[i]);
		if( ji != none && (ji.Child == ii || ji.Parent == ii) )
		{
			ji.Destroy();
		}
	}
	for (i = offParts.length-1; i >= 0; i-- )
	{
		ji = JointItem(offParts[i]);
		if( ji != none && (ji.Child == ii || ji.Parent == ii) )
		{
			ji.Destroy();
		}
	}
}

// Gets the estimated life remaining in the battery; negative is a dead battery
simulated function int GetBatteryLife()
{
	return 99999;
}

// Gets configuration data for this item
function String GetConfData()
{
	return "CONF {Name " $ self.Class $ "}";
}

// Gets geometry data for this item
function String GetGeoData()
{
	return "GEO {Name " $ self.Class $ "}";
}

// Gets a part's actor representation using its spec name
simulated function Item GetPartByName(name partName)
{
	local int i;
	local PhysicalItem p;
	local JointItem j;

	// Search for part (slow!)
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('PhysicalItem'))
		{
			// Check spec for the name
			p = PhysicalItem(Parts[i]);
			if (p.Spec.TemplateName == partName)
				return p;
		}
		else if( Parts[i].IsJoint() )
		{
			j = JointItem(Parts[i]);
			if (j.Spec.Name == partName)
				return j;
		}
		else if (Parts[i].Name == partName)
			// Matched spawned item (sensor, actuator)
			return Parts[i];
	
	// Not found
	return None;
}
//returns the index of a part in the list of discarded parts. returns -1 if not found.
simulated function int GetOffPartIndexByName(String partName)
{
	local int i;
	for (i = 0; i < offParts.Length; i++)
	{
		if(offParts[i].isName(partName))
		{
			return i;
		}
	}
	// Not found
	return -1;
}
//returns the index of a part in the robots' part list. returns -1 if not found.
//returns the index of a part in the list of discarded parts. returns -1 if not found.
simulated function int GetPartIndexByName(String partName)
{
	local int i;
	for (i = 0; i < Parts.Length; i++)
	{
		if(Parts[i].isName(partName))
		{
			return i;
		}
	}
	// Not found
	return -1;
}
// Gets a robot-wide property to fix build-order problems (wheel radius primarily)
simulated function float GetProperty(String key)
{
	return 0.0;
}

// Callback mechanism which uses a delegate to send messages
simulated delegate MessageSendDelegate(String msg)
{
	// Double spawning spams the log window after death - testing only
	// LogInternal("BaseVehicle: no callback registered for MessageSendDelegate: " @ msg);
}

// Initialize this object
simulated function PreBeginPlay()
{
	super.PreBeginPlay(); // first initialize parent object
	ConvertParam();
}

// Called after play has begun to create and instantiate all subcomponents
simulated function PostBeginPlay()
{
	// Start timer
	super.PostBeginPlay();
	SetTimer(msgTimer, true);
}

// Receives messages from the Effectors and forwards to MessageSendDelegate
simulated function ReceiveMessageFromEffector(String msg)
{
	MessageSendDelegate(msg);
}

// Receives messages from the Sensors and forwards to MessageSendDelegate
simulated function ReceiveMessageFromSensor(String msg)
{
	MessageSendDelegate(msg);
}

// Turns the headlights on or off
reliable server function SetHeadLights(bool light)
{
	HeadLights = light;
}

// Called by the system timer function
simulated function Timer()
{
	ClientTimer();
}

defaultproperties 
{
	// Default properties
	bConsiderAllStaticMeshComponentsForStreaming=true
	bNoDelete=false
	bStatic=false
	bDebug=false
	HeadLights=false

	// Collision properties
	BlockRigidBody=false
	bBlockActors=false
	bCollideActors=false
	bCollideWorld=false
	bPathColliding=false
	bProjTarget=false
	bCollideWhenPlacing=false
	
	// No physics required, this is a controller actor
	Physics=PHYS_None
}
