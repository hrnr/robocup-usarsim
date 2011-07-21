/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * StaticVehicle: vehicle with no geometry or motive power; use for static actuators (subclass
 * and attach in the INI file)
 */
class StaticVehicle extends USARVehicle config(USAR);

simulated function String GetStatus()
{
	return super.GetStatus() $ " {Type StaticVehicle}";
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CenterItem.SetHidden(!bDebug);
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