/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/
/*
 * by Stephen Balakirsky
*/
class WCPathNode extends WCObject;

defaultproperties
{
	boundary=(x=0.05,y=0.05,z=0.07);

	Begin Object Class=StaticMeshComponent Name=SKMesh01
        StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Onslaught_PowerCell_Core'
        CollideActors=True
        BlockActors=False   //Must be set to false for hard-attach
        BlockRigidBody=True
        BlockZeroExtent=True
        BlockNonZeroExtent=True
		//        PhysicsAsset=PhysicsAsset'P3AT.SkeletalMesh.P3ATCollision_Physics'
	End Object
	
	bStatic=false
	bNoDelete=false
	CollisionType=COLLIDE_BlockAll

	Components(1)=SKMesh01  //Necessary for the skeletal mesh to actually become part of the SICK class
	CollisionComponent=SKMesh01 //Not sure if necessary, haven't tested yet.
}
