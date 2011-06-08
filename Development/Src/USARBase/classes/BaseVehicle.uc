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
 * BaseVehicle: parent class of USARVehicle, which parents all robots. Do not directly descend from this class.
 */
class BaseVehicle extends Pawn config(USAR) abstract;

// FIXME delete
struct SpecItem {
	var class<Actor> ItemClass;
	var class<Actor> VehicleClass;
	var name Parent;
	var string ItemName;
	var name Platform;
	var vector Position;
	var vector Direction;
	var rotator uuDirection;
};

// The body (true parent) of the robot
var PhysicalItem Body;
// Components declared in the default properties.
var array<PhysicalItem> ComponentList;
// The vehicle dimensions set by each vehicle class
var vector Dimensions;
// Headlights on?
var bool HeadLights;
// Joints connecting the vehicle to its parts
var array<Joint> Joints;
// Timer used for sending out sensor data
var config float MsgTimer;
// Array storing all configured parts from the INI file
var config array<SpecItem> Parts;
// Array storing all active parts on the robot
var array<Item> PartsList;
// The weight of the vehicle assigned in the INI file
var config float Weight;

// Used by subclasses to send periodic status messages to MessageSendDelegate() to appear on the socket
simulated function ClientTimer();

// Convert all variables of this class read from the INI file from SI to UU units
simulated function ConvertParam()
{
	local int i;
	for (i = 0; i < Parts.length; i++)
	{
		Parts[i].Position = class'UnitsConverter'.static.LengthVectorToUU(Parts[i].Position);
		Parts[i].Direction = class'UnitsConverter'.static.DeprecatedRotatorVectorToUU(Parts[i].Direction);
	}
}

// Creates a new item of the specified class
function Item CreateItem(SpecItem Desc, Actor Parent)
{
	local vector RotX, RotY, RotZ;
	local Item theItem;
	
	if (Parent == None)
		theItem = None;
	else {
		// Compute parent information
		GetAxes(Parent.Rotation, RotX, RotY, RotZ);
		
		// Create item actor
		theItem = Item(spawn(Desc.ItemClass, Parent, , Parent.Location + Desc.Position.X *
			RotX + Desc.Position.Y * RotY + Desc.Position.Z * RotZ));
		theItem.setHardAttach(true);
		
		// Initialize item
		theItem.init(Desc.ItemName, Parent, Desc.Position, Desc.Direction, self, Desc.Parent);
		LogInternal("New Item: " $ theItem);
	}
	return theItem;
}

// Creates a part (overriden in USARVehicle to provide proper initialization)
reliable server function Item CreatePart(int ID)
{
	return CreateItem(Parts[ID], Body.PartActor);
}

// Called when the robot is destroyed
simulated event Destroyed()
{
	local int i;
	
	// Remove all parts
	for (i = 0; i < PartsList.length; i++)
		PartsList[i].Destroy();
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

// Gets a robot-wide property to fix build-order problems (wheel radius primarily)
function float getProperty(String key)
{
	return 0.0;
}

// Callback mechanism which uses a delegate to send messages
simulated delegate MessageSendDelegate(string msg)
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
	local int i;
	
	// Start timer
	super.PostBeginPlay();
	SetTimer(msgTimer, true);
	
	// Create parts from specifications
	for (i = 0; i < Parts.Length; i++) 
		PartsList[i] = CreatePart(i);
}

// Receives messages from the Effectors and forwards to MessageSendDelegate
simulated function ReceiveMessageFromEffector(string msg)
{
	MessageSendDelegate(msg);
}

// Receives messages from the Sensors and forwards to MessageSendDelegate
simulated function ReceiveMessageFromSensor(string msg)
{
	MessageSendDelegate(msg);
}

// Turns the headlights on or off
reliable server function SetHeadLights(bool light)
{
	HeadLights = light;
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
	bConsiderAllStaticMeshComponentsForStreaming=true;
	HeadLights=false;

	// Collision properties
	BlockRigidBody=true
	bBlockActors=true
	bCollideActors=true
	bCollideWorld=true
	bPathColliding=true
	bProjTarget=true
	bCollideWhenPlacing=true
}
