/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WCCrate - crate spawnable by the world controller
 */
class WCCrate extends WCObject placeable;

defaultproperties
{
	Mesh=StaticMesh'WCObjectPkg.Crates.Crate'
	
	Name="WCCrate"
}

