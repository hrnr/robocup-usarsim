/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

//#exec OBJ LOAD FILE=..\Textures\USARSim_Objects_Textures.utx
class ReferenceGPSCoordinate extends PathNode;

var() int LatitudeDegree;
var() float LatitudeMinute;
var() int LongitudeDegree;
var() float LongitudeMinute;

defaultproperties
{
	// Icon for the Reference GPS Coordinate
    // Texture=Texture'USARSim_Objects_Textures.Trace.GPSCoordinate'
    bStatic=false
    bHidden=true
    bNoDelete=true
    bCollideWhenPlacing=false
    bMovable=true
    bCollideActors=false
    bLockLocation=false
    DrawScale=1
}
