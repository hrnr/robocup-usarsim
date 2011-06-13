/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Parents all static mesh physics objects added to the world.
 */
class PhysicalItem extends Item;

// The part which instantiated this item
var Part Spec;

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=None
	End Object

	bWakeOnLevelStart=true
}
