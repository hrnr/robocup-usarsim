/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class SatelliteTracker extends Object config (USARSatelliteTracker);

struct SatPose
{
    var() float Latitude;
    var() float Longitude;
    var() float Altitude;
};

struct SatData
{
    var() String sName;
    var() array<SatPose> Position;
};

var config array<SatData> Satellite;

defaultproperties
{
}
