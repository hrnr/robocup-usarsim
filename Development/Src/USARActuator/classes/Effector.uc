/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Effector - class for very, very simple binary objects
 */
class Effector extends Actuator abstract config (USAR);

// Whether the effector is on or off. 0 means off and 1 means on.
// Not a boolean to maintain compat with the SetGripper/Actuator series functionality
var int IsOn;

// Gets configuration data from the effector
function String GetConfData()
{
	return "{Name " $ ItemName $ "}";
}

// Gets geometry data from the effector
function String GetGeoData()
{
	local String outstring;
	
	// Name and location
	outstring = "{Name " $ ItemName $ "} {Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Location - Platform.CenterItem.Location);
	
	// Direction
	outstring = outstring $ "} {Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation - Platform.CenterItem.Rotation);
	
	// Mount point
	outstring = outstring $ "} {Mount " $ String(Platform.Class) $ "}";
	return outstring;
}

// Gets data from this effector (on or off)
function String GetData()
{
	if (IsOn == 0)
		return "{Off}";
	else
		return "{On}";
}

// Gets header information for this effector
simulated function String GetHead()
{
	return "EFF {Type " $ ItemType $ "} {Name " $ ItemName $ "}";
}

// Turns the effector on or off
function Operate(bool on)
{
}

simulated function SendMisPkg()
{
}

defaultproperties
{
	IsOn=0
	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=false
	bCollideWhenPlacing=false
	bCollideWorld=false
	Physics=PHYS_None
	ItemType="Effector"
}
