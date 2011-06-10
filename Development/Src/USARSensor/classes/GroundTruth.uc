/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
  * GroundTruth.uc
  * Ground Truth Sensor
  * author:  Stephen Balakirsky based on UT2004 GroundTruth.uc code
  * brief :  This sensor provides ground truth of the robot's current
  *          location and orientation.  Since this is ground truth
  *          there is no sensor noise
  */

class GroundTruth extends Sensor config (USAR);

// Returns data from the ground truth sensor
function String GetData()
{
	local vector rotTrue;
	
	rotTrue = class'UnitsConverter'.static.AngleVectorFromUU(Platform.CenterItem.Rotation);
	return "{Name " $ ItemName $ "} {Location " $
		class'UnitsConverter'.static.LengthVectorFromUU(Platform.CenterItem.Location) $
		"} {Orientation " $ rotTrue $ "}";
}

function String GetConfData()
{
    local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="GroundTruth"

	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=false
	bCollideWorld=false
	DrawScale=1

	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'INSIMUSensor.Sensor'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object

	CollisionType=COLLIDE_BlockAll
	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
