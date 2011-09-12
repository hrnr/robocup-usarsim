/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * StaticPlatform: platform with no geometry or motive power; use for static actuators (subclass
 * and attach in the INI file)
 */
class StaticPlatform extends USARVehicle config(USAR);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CenterItem.SetHidden(!bDebug);
}

// Returns configuration data of this robot
function String GetConfData()
{
	return super.GetConfData() $ " {Type StaticPlatform} {SteeringType None} {Mass 0} ";
}

// Gets robot status (adds zero steer amounts)
simulated function String GetStatus()
{
	return super.GetStatus() $ " {Type StaticPlatform}";
}

// Gets the robot's steering type
simulated function String GetSteeringType()
{
	return "None";
}


defaultproperties
{
	bDebug=false

	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.EmptyMesh'
		Collision=false
		Mass=100
	End Object
	PartList.Add(BodyItem)
	
	Body=BodyItem
}
