/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Effector - parent all robot controllable moving objects.
 */
class Effector extends Item abstract;

// Sets the delegate so messages get sent
simulated function AttachItem()
{
	MessageSendDelegate = Platform.ReceiveMessageFromEffector;
}

// Fires ClientTimer when necessary
simulated function Timer()
{
	if (Platform.GetBatteryLife() > 0)
		ClientTimer();
}

// Gets the header of the effector data
simulated function String GetHead()
{
	return "EFF {Type " $ ItemType $ "}";
}

// Gets the geometry data
function String GetGeoData()
{
	local String outstring;
	
	// Name and location
	outstring = "{Name " $ ItemName $ " Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Location - Base.Location);
	
	// Direction
	outstring = outstring $ " Orientation " $
		class'UnitsConverter'.static.AngleVectorFromUU(Rotation-Base.Rotation);
	
	// Mount point
	outstring = outstring $ " Mount " $ ItemMount $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Effector";
	
	BlockRigidBody=false;
	CollisionType=COLLIDE_BlockAll;
	bCollideActors=false;
	bBlockActors=false;
	bProjTarget=true;
	bHardAttach=true;
	bCollideWhenPlacing=false;
	bCollideWorld=false;
}
