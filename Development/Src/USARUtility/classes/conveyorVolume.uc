/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * ConveyorVolume - a volume that moves items along like a conveyor belt
 */
class ConveyorVolume extends GravityVolume placeable;

// Default speed of the volume
var vector DefaultSpeed;
// Variable speed material for conveyor
var MaterialInstanceActor SpeedMaterial;
// Name of parameter to change in material
var name SpeedParameter;
// Conveyors that are attached to this volume
var() array<StaticMeshActor> Conveyors;

defaultproperties
{
	RigidBodyDamping=40.
	bPhysicsOnContact=true
	bNeutralZone=true
	bMoveProjectiles=true
	bForcePawnWalk=true
	bProcessAllActors=true
	DefaultSpeed=(x=0,y=-60,z=0)
	FluidFriction=0
	GroundFriction=0
}
