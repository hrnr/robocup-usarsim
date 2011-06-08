/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class Box extends KActorSpawnable placeable; 

defaultproperties
{
	bWakeOnLevelStart=true;
	
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'SBox2.SM.SBox2';
		bNotifyRigidBodyCollision=true 
		HiddenGame=false
		ScriptRigidBodyCollisionThreshold=0.001 
		LightingChannels=(Dynamic=true) 
	End Object
	
	CollisionType=COLLIDE_BlockAll;
}
