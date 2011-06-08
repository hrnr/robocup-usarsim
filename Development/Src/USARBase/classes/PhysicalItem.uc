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
class PhysicalItem extends Object config(USAR);

var vector Direction;
var bool IsDummy;
var float Mass;
var StaticMesh Mesh;
var vector Offset;
var RobotPart PartActor;
var PhysicalItem RelativeTo;

defaultproperties
{
	Mass=100.0
}
