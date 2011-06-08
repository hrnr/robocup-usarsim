class ForceTest2Helper extends DynamicSMActor;

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
	End Object

	bWorldGeometry=true;
	bCollideActors=true

	bStatic=false
	bNoDelete=false
}
