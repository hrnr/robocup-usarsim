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
	var class<Actor> VehicleClass;
	var name Parent;
	var String ItemName;
	var name Platform;
	var vector Position;
	var vector Direction;
	var rotator uuDirection;
};

// Array storing all configured parts from the INI file
var config array<SpecItem> AddParts;
// The body (true parent) of the robot
var Part Body;
// The item at the center of the robot
var PhysicalItem CenterItem;
// The vehicle dimensions set by each vehicle class
var vector Dimensions;
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
	
	// Remove all parts
	for (i = 0; i < Parts.length; i++)
		Parts[i].Destroy();
}

// Gets the estimated life remaining in the battery; negative is a dead battery
simulated function int GetBatteryLife()
{
	return 99999;
}

// Gets configuration data for this item
function String GetConfData()
{
	return "{Name " $ self.Class $ "}";
}

// Gets geometry data for this item
function String GetGeoData()
{
	return "{Name " $ self.Class $ "}";
}

// Gets a part's actor representation using its spec name
simulated function PhysicalItem GetPartByName(name partName)
{
	local int i;
	local PhysicalItem p;
	
	// Search for part (slow!)
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isA('PhysicalItem'))
		{
			p = PhysicalItem(Parts[i]);
			if (Caps(String(p.Spec.Name)) == Caps(String(partName)))
				return p;
		}
	
	// Not found
	return None;
}

// Gets a robot-wide property to fix build-order problems (wheel radius primarily)
simulated function float GetProperty(String key)
{
	return 0.0;
}

// Callback mechanism which uses a delegate to send messages
simulated delegate MessageSendDelegate(String msg)
{
	LogInternal("BaseVehicle: no callback registered for MessageSendDelegate: " @ msg);
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
	LogInternal("BaseVehicle: Set headlights of '" $ String(Name) $ "' to " $ light);
}

// Called each tick (frame)
function Tick(float DeltaTime);

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
