/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * Parents all static mesh based objects on a robot.
 */
class Part extends Object config(USAR);

// The direction the part points towards.
var vector Direction;
// Whether the part is a "dummy" part. Dummy parts get a special mesh on construction.
var bool IsDummy;
// The part's mass in kilograms.
var float Mass;
// The static mesh used for rendering.
var StaticMesh Mesh;
// The location of the object relative to its "RelativeTo" parent.
var vector Offset;
// The object from which this part's offset is relative.
var Part RelativeTo;

defaultproperties
{
	Mass=0.0
}
