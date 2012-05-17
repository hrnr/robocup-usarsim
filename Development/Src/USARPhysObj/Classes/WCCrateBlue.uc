/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WCCrateBlue - crate spawnable by the world controller
 */
class WCCrateBlue extends WCObject placeable;

defaultproperties
{
	Mesh=StaticMesh'WCObjectPkg.Crates.CrateBlue'
	Mass = 5.0
	Name="WCCrateBlue"
}

