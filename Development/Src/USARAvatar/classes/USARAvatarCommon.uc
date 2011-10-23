/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * USARAvatarCommon: Superclass handling functions for avatars:
 * - Basic lightning defined in DefaultProperties
 * - Custom AIController in DefaultProperties
 */

class USARAvatarCommon extends UDKPawn;

//==========================================
// Set the physics here
//==========================================
simulated event PostBeginPlay()
{
  super.PostBeginPlay();
  SpawnDefaultController();
  SetPhysics(PHYS_Falling);
}


function SpawnDefaultController()
{
  LogInternal("USARAvatarCommon::SpawnDefaultController");
  
  if (Controller == none)
	ControllerClass=Class'USARAvatar.USARAIController';
  SetPhysics(PHYS_Walking);
  Super.SpawnDefaultController();
}


DefaultProperties
{
  ControllerClass=class'USARAvatar.USARAIController'
  
//Begin Object Name=CollisionCylinder
//	CollisionRadius=+0021.000000
//	CollisionHeight=+0044.000000
//	BlockZeroExtent=FALSE
//End Object
  
  Components.Remove(Sprite);
  //CylinderComponent=CollisionCylinder
  

  Begin Object Class=DynamicLightEnvironmentComponent Name=AvatarLightEnvironment
        ModShadowFadeoutTime=0.25
        MinTimeBetweenFullUpdates=0.2
        AmbientGlow=(R=.01,G=.01,B=.01,A=1)
        AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
        bSynthesizeSHLight=TRUE
  End Object
  
  Components.Add(AvatarLightEnvironment);
}

