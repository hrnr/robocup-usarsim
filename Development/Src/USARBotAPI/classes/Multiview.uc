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
	
	//fixes for May/November 2012 compatibility (see note below)
	local Texture Tex;
	local float Scale;
	local EBlendMode Blend;
	local LinearColor DrawColorLinear;

	super.PostRender();
	
	for (i = 0; i < CameraTileX * CameraTileY; i++)
		if (CameraViews[i] != None)
		{
			Canvas.SetPos(CameraViews[i].X, CameraViews[i].Y);
			Canvas.SetDrawColor(255, 255, 255, 255);
			//Canvas.DrawTextureBlended(CameraViews[i].TextureTarget, 1.0, BLEND_Opaque);
			
			//to make this compatible with both UDK-2012-05 and UDK-2012-11
			//copied from UDK-2012-05/Development/Src/Engine/Classes/Canvas.uc
			Tex = CameraViews[i].TextureTarget;
			Blend = BLEND_Opaque;
			Scale = 1.0;
			
			DrawColorLinear = Canvas.ColorToLinearColor(Canvas.DrawColor);
			if (Tex != None)
			{
				Canvas.DrawTile(Tex, Tex.GetSurfaceWidth()*Scale, Tex.GetSurfaceHeight()*Scale, 0, 0, Tex.GetSurfaceWidth(), Tex.GetSurfaceHeight(),DrawColorLinear,,Blend);
			}
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
			Cam.TextureResolutionX = CameraWidth;
			Cam.TextureResolutionY = CameraHeight;
			Cam.PostBeginPlay();

			// The controller might send GETCONF before the camera is initialized here.
			// Auto send CONF when the camera is added to fix this problem.
			bot = UsarVehicle(Cam.Platform);
			if( bot != none )
				bot.MessageSendDelegate(bot.GetGeneralConfData(Cam.ItemType, Cam.ItemName));
			return;
		}
}
