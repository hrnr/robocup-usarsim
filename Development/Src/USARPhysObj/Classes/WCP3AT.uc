    /*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/
class WCP3AT extends WCObject 
placeable;

DefaultProperties
{
    //WCObject Variables
    Begin Object Name=WCMesh
        SkeletalMesh=SkeletalMesh'P3AT.SkeletalMesh.P3AT'
        PhysicsAsset=PhysicsAsset'P3AT.SkeletalMesh.P3ATCollision_Physics'
        bSkipAllUpdateWhenPhysicsAsleep=false
        PhysicsWeight=1.0f
    End Object
    
    //Actor Variables
 	boundary = (x=.32,y=.256,z=.16);
	Components(0)=WCMesh
    bNoDelete=false
    DrawScale=1
    bDebug =false
    DrawScale3D=(X=1,Y=1,Z=1)

    //Pawn Variables
    Mass = 18
}

