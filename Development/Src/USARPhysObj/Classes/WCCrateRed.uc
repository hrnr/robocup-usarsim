/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WCCrateRed - crate spawnable by the world controller
 */
class WCCrateRed extends WCObject placeable;

defaultproperties
{
	Mesh=StaticMesh'WCObjectPkg.Crates.CrateRed'
	Mass = 5.0
	Name="WCCrateRed"
}

