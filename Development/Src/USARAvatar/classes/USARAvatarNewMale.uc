Class USARAvatarNewMale extends USARAvatarNewCommon placeable;

defaultproperties
{
    DrawScale=0.6486 // This makes the avatar ~1.7m, the average height for a male
	GroundSpeed=300.0 // Currently, the male walks, the female runs

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'UsarAvatar_NewMale.Mesh.GenericMale'
		PhysicsAsset=PhysicsAsset'UsarAvatar_NewMale.Mesh.GenericMale_Physics'
		AnimTreeTemplate=AnimTree'UsarAvatar_NewMale.animation.AT_CH_Human'
		AnimSets(0)=AnimSet'UsarAvatar_NewMale.animation.GenericMale_AnimSet'
		Translation=(Z=-60.0)
	End Object
}
