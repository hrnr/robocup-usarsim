/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class USARCamera extends Sensor config(USAR);

var const SceneCapture2DComponent SceneCapture;
var TextureRenderTarget2D TextureTarget;
var int MultiviewIndex, TextureResolutionX, TextureResolutionY;
var float X, Y, Width, Height;

simulated function PostBeginPlay()
{	
	super.PostBeginPlay();  // first post initialize parent object
	TextureTarget = class'TextureRenderTarget2D'.static.Create( TextureResolutionX, TextureResolutionY );
	SceneCapture.SetFrameRate(15);
	SceneCapture.SetCaptureParameters(TextureTarget, 80, 70, -1);
	SceneCapture.bEnableFog = true; // Without this, no smoke is seen by the camera.
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	SceneCapture.SetView(Location, Rotation); 
}

// Gets configuration data for this item
function String GetConfData()
{
	local string confData;
	confData = super.GetConfData();
	// Add information for the UPIS server
	confData $= "{TextureOffsetX " $ int(X) $ "}";
	confData $= "{TextureOffsetY " $ int(Y) $ "}";
	confData $= "{TextureResolutionX " $ TextureResolutionX $ "}";
	confData $= "{TextureResolutionY " $ TextureResolutionY $ "}";
	return confData;
}

defaultproperties
{
	MultiviewIndex=-1
	TextureResolutionX=320
	TextureResolutionY=240		
	ItemType="Camera"

	// Initialize the camera capture component
	Begin Object Class=SceneCapture2DComponent Name=SceneCapture2DComponent0 ObjName=SceneCapture2DComponent0 Archetype=SceneCapture2DComponent'Engine.Default__SceneCapture2DComponent'
		Name="SceneCapture2DComponent0"
		ObjectArchetype=SceneCapture2DComponent'Engine.Default__SceneCapture2DComponent'
	End Object
	SceneCapture=SceneCapture2DComponent0
	Components(0)=SceneCapture2DComponent0
	
	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=false
	bCollideWhenPlacing=false
	bCollideWorld=false
	
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'P3AT.StaticMeshDeco.P3ATDeco_BatteryPack'
		// For new camera model: StaticMesh=StaticMesh'Camera.Mesh.Camera'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object
}
