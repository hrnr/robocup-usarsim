/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

class Multiview extends HUD config(USAR);

var config int CameraTileX;
var config int CameraTileY;
var config int CameraWidth;
var config int CameraHeight;

var int CamerasIndex;
var USARCamera CameraViews[64];

function DrawHUD() 
{
	local int i;
	
	for (i = 0; i < CameraTileX * CameraTileY; i++)
		if (CameraViews[i] != None)
		{
			Canvas.CurX = CameraViews[i].X;
			Canvas.CurY = CameraViews[i].Y;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.DrawTextureBlended(CameraViews[i].TextureTarget, 1.0, BLEND_Opaque);
		}	  
}

function Tick(float DeltaTime)
{
	local USARCamera Cam;

	super.Tick(DeltaTime);
	foreach AllActors(class 'USARSensor.USARCamera', Cam)
		if (Cam.IsClient && Cam.IsOwner && Cam.MultiviewIndex == -1)
			AddCamera(Cam);
}

function AddCamera(USARCamera Cam)
{
	local int i;

	for (i = 0; i < CameraTileX * CameraTileY; i++)
		if (CameraViews[i] == None)
		{
			CameraViews[i] = Cam;
			Cam.MultiviewIndex = i;
			Cam.X = (i % CameraTileX) * CameraWidth;
			Cam.Y = (i / CameraTileY) * CameraHeight;
			Cam.Width = CameraWidth;
			Cam.Height = CameraHeight;
			return;
		}
}
