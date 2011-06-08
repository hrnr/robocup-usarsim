class Multiview extends HUD
    config(USAR);

var config int CameraTileX;
var config int CameraTileY;
var config int CameraWidth;
var config int CameraHeight;

var int CamerasIndex;
var USARCamera CameraViews[64];

function DrawHUD() 
{
	local int i;
	//local Object.LinearColor blackColor;
	
	for(i = 0; i < CameraTileX * CameraTileY; i++) {
		if(CameraViews[i] != None) {
			Canvas.CurX = CameraViews[i].X;
			Canvas.CurY = CameraViews[i].Y;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.DrawTextureBlended(CameraViews[i].TextureTarget, 1.0, BLEND_Opaque);
		}	  
	}
}

function Tick(float DeltaTime)
{
	local USARCamera Cam;

	Super.Tick(DeltaTime);
	
	// TODO: Replace this with a less inefficient way to find cameras.	
	foreach AllActors(class 'USARSensor.USARCamera', Cam) {
		if (Cam.IsClient && Cam.IsOwner && Cam.MultiviewIndex==-1) {
			AddCamera(Cam);
		}
	}
	
}

function AddCamera(USARCamera Cam)
{
	//CameraTileX = 3;
	//CameraTileY = 3;
	//CameraWidth = 320;
	//CameraHeight = 240;
	local int i;

	for(i = 0; i < CameraTileX * CameraTileY; i++) {
		if(CameraViews[i] == None) {
			CameraViews[i] = Cam;
			Cam.MultiviewIndex = i;
			Cam.X = (i % CameraTileX) * CameraWidth;
			Cam.Y = (i / CameraTileY) * CameraHeight;
			Cam.Width = CameraWidth;
			Cam.Height = CameraHeight;
			return;
		}
	}
}
