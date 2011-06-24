/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Parents all static mesh based objects on a robot.
 */
class Part extends Object config(USAR);

// Whether collision should be enabled on this part.
var bool Collision;
// The direction the part points towards
var vector Direction;
// The part's mass in kilograms
var float Mass;
// The static mesh used for rendering
var StaticMesh Mesh;
// The location of the object relative to its "RelativeTo" parent
var vector Offset;
// The object from which this part's offset is relative
var Part RelativeTo;

defaultproperties
{
	Collision=true
	Direction=(X=0.0,Y=0.0,Z=0.0)
	Mass=0.0
	Offset=(X=0.0,Y=0.0,Z=0.0)
	RelativeTo=None
}
