/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
  * GroundTruthMovable.uc
  * Ground Truth Sensor
  * author:  Stephen Balakirsky 
  * brief :  This sensor allows for the use of both fixed and floating ground truth sensors
  *          in the same system. There should be a way to do this in the .ini file, but not
  *          sure how
  */

class GroundTruthMovable extends GroundTruth config (USAR);