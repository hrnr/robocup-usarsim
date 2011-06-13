/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class PioneerArmSquareBasePlate extends Decoration config (USAR);

defaultproperties
{
	DrawScale=1

	Begin Object Class=StaticMeshComponent Name=StMesh01
        StaticMesh=StaticMesh'PioneerArm.StaticMeshDeco.PioneerArmDeco_SquareBasePlate'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object
	
	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
