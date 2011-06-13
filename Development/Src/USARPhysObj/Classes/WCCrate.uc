    /*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/
class WCCrate extends WCObject 
placeable;

DefaultProperties
{
    //WCObject Variables
    Begin Object Name=WCMesh
       SkeletalMesh=SkeletalMesh'WCObjectPkg.crate480x318x225'
        PhysicsAsset=PhysicsAsset'WCObjectPkg.crate480x318x225_Physics'
//        SkeletalMesh=SkeletalMesh'WCObjectPkg.crate1x1'
//       PhysicsAsset=PhysicsAsset'WCObjectPkg.crate1x1_Physics'
        bSkipAllUpdateWhenPhysicsAsleep=false
        PhysicsWeight=1.0f
    End Object
    
    //Actor Variables
 	boundary = (x=1,y=1,z=1);
   Components(0)=WCMesh
    bNoDelete=false
    DrawScale=1
    bDebug =false
    DrawScale3D=(X=1,Y=1,Z=1)

    //Pawn Variables
    Mass = 18
}

