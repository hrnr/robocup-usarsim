class BaseTest extends KActor;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1, false, 'Initialize');
}

simulated function Initialize()
{
	StaticMeshComponent.SetRBPosition( Vect(0,0,0) );
	StaticMeshComponent.SetRBRotation( rot(0,0,0) );
	StaticMeshComponent.SetRBLinearVelocity( Vect(0,0,0), false );
	StaticMeshComponent.SetRBAngularVelocity( Vect(0,0,0), false );
}

simulated function SetMass( float Mass )
{
	local float oldscale;
	local RB_BodySetup bs;

	oldscale = StaticMeshComponent.StaticMesh.BodySetup.MassScale;
	bs = StaticMeshComponent.StaticMesh.BodySetup;
	bs.MassScale = Mass/(StaticMeshComponent.BodyInstance.GetBodyMass()*(1.0/oldscale));
	StaticMeshComponent.BodyInstance.UpdateMassProperties( bs );
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'USAR_GravityTest.Mesh_GravityTest'
		//StaticMesh=StaticMesh'LT_Mech.SM.Mesh.S_LT_Mech_SM_Cratebox02a'
	End Object

	bWakeOnLevelStart=true;

	bStatic=false
	bNoDelete=false

	//bCollideWorld=true;
	bCollideComplex=true;
	bNoEncroachCheck=false;
	//bPhysRigidBodyOutOfWorldCheck=true;
}
