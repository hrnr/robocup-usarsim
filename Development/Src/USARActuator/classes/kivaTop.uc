/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * kivaTop - simple example actuator (has a model)
 */
class kivaTop extends Actuator placeable config (USAR);

defaultproperties
{
	// KivaTop didn't have a base, so made a small part to become one
	Begin Object Class=Part Name=BaseItem
		Mesh=StaticMesh'Kiva_static.PackageBase'
		Collision=false
		Mass=1.0
	End Object
	Body=BaseItem
	PartList.Add(BaseItem)
	
	Begin Object Class=Part Name=TopItem
		Mesh=StaticMesh'Kiva_static.Top'
		Mass=0.2
		RelativeTo=BaseItem
	End Object
	PartList.Add(TopItem)
	
	Begin Object Class=RevoluteJoint Name=RotateJoint
		Parent=BaseItem
		Child=TopItem
		Damping=50
		MaxForce=500
		LimitLow=-3.228
		LimitHigh=3.228
	End Object
	Joints.Add(RotateJoint)
}
