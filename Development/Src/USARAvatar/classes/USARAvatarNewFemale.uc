Class USARAvatarNewFemale extends USARAvatarNewCommon placeable;

defaultproperties
{
    Drawscale=0.7034; // This makes the avatar ~1.6m, the average height for a female
	GroundSpeed=440.0 // Currently, the male walks, the female runs

	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'UsarAvatar_NewFemale.animation.AT_CH_Human'
		AnimSets(0) = AnimSet'UsarAvatar_NewFemale.animation.GenericFemale_AnimSet'
		SkeletalMesh=SkeletalMesh'UsarAvatar_NewFemale.Mesh.GenericFemale'
		PhysicsAsset=PhysicsAsset'UsarAvatar_NewFemale.Mesh.GenericFemale_Physics'
		Translation=(Z=-60.0)
	End Object

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=true	
}

/*Class USARAvatarNewFemale extends USARAvatarNewCommon config(USAR) placeable;

var AnimNodeSlot CutomAnimation;
var UDKSkelControl_TurretConstrained Bip02RUpperArm;
var SkelControlSingleBone Bip02;
var SkelControlSingleBone Bip02RFinger4;
var Texture2D textureToApply;
var bool addToAngle; 

var MaterialInstanceConstant MatInst;

simulated function PostBeginPlay()
{
   MatInst = new Class'MaterialInstanceConstant';
   MatInst.SetParent(Mesh.GetMaterial(0));
   textureToApply = Texture2D'UsarAvatar_NewFemale.Texture.GenericFemale_cloth';
   MatInst.SetTextureParameterValue('FemaleTexture', textureToApply);
   Mesh.SetMaterial(0, MatInst);

   Super.PostBeginPlay();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	Bip02RUpperArm = UDKSkelControl_TurretConstrained( mesh.FindSkelControl('Bip02RUpperArm') );
	Bip02 = SkelControlSingleBone( mesh.FindSkelControl('Bip02') );
	Bip02RFinger4 = SkelControlSingleBone( mesh.FindSkelControl('Bip02RFinger4') );
    CutomAnimation = AnimNodeSlot(Mesh.FindAnimNode('CustomAnimation'));
}

simulated function Tick(Float Delta)
{
	//local Texture tempTexture;
	//Mesh.GetMaterial(0).GetTextureParameterValue('FemaleTexture', tempTexture);
	//Worldinfo.Game.Broadcast(self,tempTexture.Name);
	//local Vector newLocation;
	     if(Bip02RUpperArm.DesiredBoneRotation.Pitch<=-15000)
			addToAngle = true;
		 else if(Bip02RUpperArm.DesiredBoneRotation.Pitch>=4500)
			addToAngle = false;

		 if(addToAngle)
			Bip02RUpperArm.DesiredBoneRotation.Pitch+=100;
         else
			Bip02RUpperArm.DesiredBoneRotation.Pitch-=100;
		 //CutomAnimation.PlayCustomAnim('Swim', 1.0);
		 CutomAnimation.PlayCustomAnim('WalkF', 0.4);
		 //newLocation = Location;
		 //newLocation.X+=100;
		 //Move(newLocation);
	//Bip02RUpperArm.BoneRotation.Yaw+=100;
	Bip02.BoneTranslation.X+=3;
    //Bip02RFinger4.BoneRotation.Yaw-=20;

	//ArmLocation.Z += 100; //giant multiplier so we extend the arm more.
	//ArmLocation.X += 100; 
	//Utp=MyPawn(Pawn); //this simply gets our pawn so we can then point to our SkelControl
	//RightArmIK.EffectorLocation=Location + ArmLocation;
}

defaultproperties
{
	addToAngle=false
	//textureToApply = UsarAvatar_NewMale.Texture.GenericMale_cloth
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

	defaultMesh=SkeletalMesh'UsarAvatar_NewFemale.Mesh.GenericFemale'
	defaultPhysicsAsset=PhysicsAsset'UsarAvatar_NewFemale.Mesh.GenericFemale_Physics'
	defaultAnimTree=AnimTree'UsarAvatar_NewFemale.animation.GenericFemale_AnimTree'
	defaultAnimSet.Add(AnimSet'UsarAvatar_NewFemale.animation.GenericFemale_AnimSet')

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'UsarAvatar_NewFemale.Mesh.GenericFemale'
		PhysicsAsset=PhysicsAsset'UsarAvatar_NewFemale.Mesh.GenericFemale_Physics'
		AnimTreeTemplate=AnimTree'UsarAvatar_NewFemale.animation.GenericFemale_AnimTree'
		AnimSets.Add(AnimSet'UsarAvatar_NewFemale.animation.GenericFemale_AnimSet')
	End Object

}
*/