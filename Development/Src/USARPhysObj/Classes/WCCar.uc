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
 * by Stephen Balakirsky
*/
class WCCar extends WCObject;

defaultproperties
{
	boundary=(x=.83,y=.32,z=.064);

	Begin Object Class=StaticMeshComponent Name=SKMesh01
        StaticMesh=StaticMesh'HU_City.SM.S_Car_07'
        CollideActors=False // Must be false to fall properly to ground
        BlockActors=True   
        BlockRigidBody=True
        BlockZeroExtent=True
        BlockNonZeroExtent=True
	End Object

	CollisionType=COLLIDE_BlockAll

	Components(1)=SKMesh01  //Necessary for the skeletal mesh to actually become part of the class
	CollisionComponent=SKMesh01 //Not sure if necessary, haven't tested yet.
}
