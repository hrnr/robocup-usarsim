/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Sensor - parents all sensors on the robot
 */
class Sensor extends Item config(USAR) abstract;

// Configuration for noise
var config float Noise;
// Variables to be used in the gaussian random number generator
var float Mean;
var float Sigma;
// Whether the sensor sends back time stamps as well
var config bool bWithTimeStamp;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// For some reason the rigid body still interfers with the physics,
	// even when Physics = PHYS_None. Disabling block rigid body fixes this.
	if( StaticMeshComponent.BodyInstance != None && Physics == PHYS_None )
		StaticMeshComponent.BodyInstance.SetBlockRigidBody(false);
}

// Called when sensor is attached to a vehicle
simulated function AttachItem()
{
	MessageSendDelegate = Platform.ReceiveMessageFromSensor;
}

// Gets the geometry data
function String GetGeoData()
{
	local String outstring;
	local int linkIndex;
	local String mountstring;
	// Name and location
	outstring = "{Name " $ ItemName $ "} {Location ";
	if(directParent != None && directParent.isA('Actuator'))
	{
		mountString = "{Mount "$ directParent.ItemName $ "}";
		linkIndex = Actuator(directParent).FindParentIndex(Item(Base));
		if(linkIndex != -1)
		{
			outstring = outstring $ class'UnitsConverter'.static.LengthVectorFromUU(Location - Actuator(directParent).JointItems[linkIndex].Child.Location);
			mountString = mountString $ "{MountLink "$(linkIndex+1)$"}";
		}else
			outstring = outstring $ class'UnitsConverter'.static.LengthVectorFromUU(Location - Actuator(directParent).CenterItem.Location);
	}
	else
	{
		outstring = outstring $ class'UnitsConverter'.static.LengthVectorFromUU(Location - Platform.CenterItem.Location); 
		mountString = "{Mount " $ String(Platform.Class) $ "}";
	}
	// Direction
	outstring = outstring $ "} {Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation - Platform.CenterItem.Rotation) $ "}";
	
	return outstring $ mountString;
}

// Gets the header of the sensor data
simulated function String GetHead()
{
	local String outstring;

	// Add timestamp if necessary
	outstring = "SEN";
	if (bWithTimeStamp)
		outstring @= "{Time " $ WorldInfo.TimeSeconds $ "}";
	
	// Add sensor type
	outstring @= "{Type " $ ItemType $ "}";
	return outstring;
}

defaultproperties
{
	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=false
	bCollideWorld=false
	
	ItemType="Sensor"
	Mean=0.0
	Sigma=0.05
	Physics=PHYS_None
}
