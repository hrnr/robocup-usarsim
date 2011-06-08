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
class WCPallet extends WCObject 	 
placeable;

defaultproperties
{
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////

	boundary=(x=.148,y=.16,z=.068); /* distance from center to edges of unscaled mesh (in uu 74x80x34)
									   * Note that in generator tool, need mm for entire object (2000x this number) */
	Begin Object Class=StaticMeshComponent Name=SKMesh01 ObjName=SKMesh01
        StaticMesh=StaticMesh'ASC_Deco2.SM.Mesh.S_ASC_Deco_SM_FruitCrate02'
		BlockRigidBody=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
	End Object
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnv01 ObjName=DynamicLightEnvComponent_01
    End Object
	Components(0)=MyLightEnv01
	Components(1)=SKMesh01
	bStatic=false
	bNoDelete=false
	DrawScale3D=(X=1,Y=1,Z=1)

	// FIXME -- these gave warnings, and may need to be replaced with
	// something instead of just being commented out
	// bWakeOnLevelStart=True
	// StaticMeshComponent=SKMesh01
	// ReplicatedMesh=StaticMesh'ASC_Deco2.SM.Mesh.S_ASC_Deco_SM_FruitCrate02'
	Components.Add(SKMesh01)
	Tag="GameBreakableActor"
	DrawScale=1.
	CollisionComponent=SKMesh01
	CollisionType=COLLIDE_BlockAll
}


