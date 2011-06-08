/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

class ExampleAcousticArray extends AcousticArraySensor config (USAR);

defaultproperties
{
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=true
	bCollideWorld=true
	DrawScale=1

	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'AcousticArraySensor.Example.AcousticMicrophoneArray'
		CollideActors=true
		BlockActors=false
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object

	CollisionType=COLLIDE_BlockAll
	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
