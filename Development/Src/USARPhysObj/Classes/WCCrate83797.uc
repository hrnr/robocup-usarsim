    /*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/
class WCCrate83797 extends WCObject 
placeable;

DefaultProperties
{
    //WCObject Variables
    Begin Object Name=WCMesh
        SkeletalMesh=SkeletalMesh'WCObjectPkg.crate273x132x126'
        PhysicsAsset=PhysicsAsset'WCObjectPkg.crate273x132x126_Physics'
        bSkipAllUpdateWhenPhysicsAsleep=false
        PhysicsWeight=1.0f
    End Object
    
    //Actor Variables
 	boundary = (x=.1365,y=.066,z=.063);
	Components(0)=WCMesh
    bNoDelete=false
    DrawScale=1
    bDebug =false
    DrawScale3D=(X=1,Y=1,Z=1)

    //Pawn Variables
    Mass = 18
}

