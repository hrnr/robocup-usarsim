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
 * Effector - parent all robot controllable moving objects.
 */
class Effector extends Item abstract;

simulated function AttachItem()
{
	MessageSendDelegate = Platform.ReceiveMessageFromEffector;
}

simulated function Timer()
{
	super.Timer();
	ClientTimer();
}

simulated function ClientTimer();

// Gets the header of the effector data
simulated function String GetHead()
{
	return "EFF {Type " $ ItemType $ "}";
}

// Gets the geometry data
simulated function String GetGeoData()
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
