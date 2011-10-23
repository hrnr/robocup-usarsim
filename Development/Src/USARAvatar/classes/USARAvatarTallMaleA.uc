/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARAvatarTallMaleA: Class handling the skeletal mesh SK_UsarAvatar_TallMaleA
 */
class USARAvatarTallMaleA extends USARAvatarCommon;

simulated function PostBeginPlay()
{
super.PostBeginPlay();

		`Log("SOMETHING IS WORKING");
	
// Just have a hazy idea what this does but its from PlayFeignDeath

		//Pawn.SetPawnRBChannels(TRUE);
		//Mesh.ForceSkelUpdate();

		//PreRagdollCollisionComponent = CollisionComponent;
		//CollisionComponent = Mesh;


// Turning collision on for skelmeshcomp and off for cylinder

		//CylinderComponent.SetActorCollision(false, false);
		//Mesh.SetActorCollision(true, true);
		//Mesh.SetTraceBlocking(true, true);
}

DefaultProperties
{
  //bBlockActors=true
  CollisionType=COLLIDE_BlockAll
  bCollideActors=true
 // bCollideWorld=true
 // bPathColliding=true
 // bProjTarget=false
 // bCollideWhenPlacing=false

 Begin Object class=SkeletalMeshComponent Name=UsarAvatar_MaleA
	CastShadow=true
	LightEnvironment=AvatarLightEnvironment
	//BlockRigidBody=true;
        CollideActors=true
        BlockZeroExtent=true
	BlockNonZeroExtent=true
	BlockActors=true

    SkeletalMesh=SkeletalMesh'UsarAvatar_TallMaleA.Mesh.SK_UsarAvatar_TallMaleA'
    AnimSets(0)=AnimSet'UsarAvatar_TallMaleA.AnimSet.AnimSet_UsarAvatar_TallMaleA'
    AnimTreeTemplate=AnimTree'UsarAvatar_TallMaleA.AnimTree.AnimTree_UsarAvatar_TallMaleA'

    // This raises the mesh so the feet arent passing through the floor
    //Translation=(Z=-5)
    //Translation=(Z=-1.47)
End Object



Components.Add(UsarAvatar_MaleA)
CollisionComponent=UsarAvatar_MaleA
 GroundSpeed=180;
 DrawScale3D=(X=180,Y=180,Z=180)
 //Drawscale = 170.0
// Turn collision on for skelmeshcomp and off for cylinder

//CollisionComponent=CollisionCylinder
//Components.Add(CollisionCylinder)
//Mesh=UsarAvatar_MaleA

}

