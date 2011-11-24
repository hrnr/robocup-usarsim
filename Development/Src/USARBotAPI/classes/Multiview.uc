/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class Multiview extends UDKHud config(USAR);

var config int CameraTileX;
var config int CameraTileY;
var config int CameraWidth;
var config int CameraHeight;

var int CamerasIndex;
var USARCamera CameraViews[64];

event PostRender() 
{
	local int i;

	super.PostRender();
	
	for (i = 0; i < CameraTileX * CameraTileY; i++)
		if (CameraViews[i] != None)
		{
			Canvas.SetPos(CameraViews[i].X, CameraViews[i].Y);
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
	local UsarVehicle bot;

	for (i = 0; i < CameraTileX * CameraTileY; i++)
		if (CameraViews[i] == None)
		{
			CameraViews[i] = Cam;
			Cam.MultiviewIndex = i;
			Cam.X = (i % CameraTileX) * CameraWidth;
			Cam.Y = (i / CameraTileY) * CameraHeight;
			Cam.Width = CameraWidth;
			Cam.Height = CameraHeight;

			// The controller might send GETCONF before the camera is initialized here.
			// Auto send CONF when the camera is added to fix this problem.
			bot = UsarVehicle(Cam.Platform);
			if( bot != none )
				bot.MessageSendDelegate(bot.GetGeneralConfData(Cam.ItemType, Cam.ItemName));
			return;
		}
}
