/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WCP3AT - P3AT robot body spawnable by the world controller
 */
class WCP3AT extends WCObject placeable;

defaultproperties
{
	// TODO The P3AT static mesh has only the middle part. Create a new mesh with everything
	// joined together and replace this
	Mesh=StaticMesh'P3AT_static.ChassisMiddle'
	
	Name="WCP3AT"
}

