Class FemaleVictim extends VictimPawn config(USAR) placeable;

defaultproperties
{
    // Size of all male victims is the same
    //DrawScale=1.65

	//Mesh=SkeletalMesh'GenericMale.GenericMale_SimpBones'
	/* Warnings: invalid property value
    // Animation subset
    Mesh=SkeletalMesh'UDN_CharacterModels_K.GenericFemale'
    // Collision Boxes for a Female Victim
    SegCols(0)=(SegName="Bip02 Head",ColClass=class'GFHead',Offset=(X=30,Y=2,Z=0))
    SegCols(1)=(SegName="Bip02 L UpperArm",ColClass=class'GFUpperArm',Offset=(X=40,Y=0,Z=-5))
    SegCols(2)=(SegName="Bip02 R UpperArm",ColClass=class'GFUpperArm',Offset=(X=40,Y=0,Z=5))
    SegCols(3)=(SegName="Bip02 L Forearm",ColClass=class'GFForeArm',Offset=(X=40,Y=2,Z=0))
    SegCols(4)=(SegName="Bip02 R Forearm",ColClass=class'GFForeArm',Offset=(X=40,Y=2,Z=0))
    SegCols(5)=(SegName="Bip02 L Hand",ColClass=class'GFHand',Offset=(X=32,Y=0,Z=-4))
    SegCols(6)=(SegName="Bip02 R Hand",ColClass=class'GFHand',Offset=(X=32,Y=0,Z=4))
    SegCols(7)=(SegName="Bip02 Spine",ColClass=class'GFChest',Offset=(X=60,Y=-20,Z=0))
    SegCols(8)=(SegName="Bip02 Pelvis",ColClass=class'GFPelvis',Offset=(X=0,Y=4,Z=0))
    SegCols(9)=(SegName="Bip02 L Thigh",ColClass=class'GFThigh',Offset=(X=84,Y=0,Z=3))
    SegCols(10)=(SegName="Bip02 R Thigh",ColClass=class'GFThigh',Offset=(X=84,Y=0,Z=-3))
    SegCols(11)=(SegName="Bip02 L Calf",ColClass=class'GFCalf',Offset=(X=65,Y=6,Z=1))
    SegCols(12)=(SegName="Bip02 R Calf",ColClass=class'GFCalf',Offset=(X=65,Y=6,Z=1))
    SegCols(13)=(SegName="Bip02 L Foot",ColClass=class'GFFoot',Offset=(X=15,Y=-24,Z=0))
    SegCols(14)=(SegName="Bip02 R Foot",ColClass=class'GFFoot',Offset=(X=15,Y=-24,Z=0))
	*/

	defaultMesh=SkeletalMesh'VictimPackage.Mesh.GenericFemale'
	defaultPhysicsAsset=PhysicsAsset'VictimPackage.Mesh.GenericFemale_Physics'
	defaultAnimTree=AnimTree'VictimPackage.animation.GenericFemale_AnimTree'
	defaultAnimSet.Add(AnimSet'VictimPackage.animation.GenericFemale_AnimSet')

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'VictimPackage.Mesh.GenericFemale'
		PhysicsAsset=PhysicsAsset'VictimPackage.Mesh.GenericFemale_Physics'
		AnimTreeTemplate=AnimTree'VictimPackage.animation.GenericFemale_AnimTree'
		AnimSets.Add(AnimSet'VictimPackage.animation.GenericFemale_AnimSet')
	End Object
}
