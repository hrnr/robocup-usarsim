/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/
/*
 *  by Stephen Balakirsky
*/
class ConveyorVolume extends GravityVolume placeable;
/* Default speed of the volume */
var() vector defaultSpeed; 

/* Name of the volume */
var() string conveyorTag;  
/*
var() Material PositiveSpeedMat;
var() Material ZeroSpeedMat;
var() Material NegativeSpeedMat;
*/

/* variable speed material for conveyor */
var() MaterialInstanceActor SpeedMaterial;

/* name of parameter to change in material */
var() name SpeedParameter;

/* Conveyors that are attached to this volume */
var() array<StaticMeshActor> Conveyors; 

defaultproperties
{
// PhysicsVolume
	RigidBodyDamping=40.;
	bPhysicsOnContact=true;
	bNeutralZone=true;
	bMoveProjectiles=true;
	// Volume
	bForcePawnWalk=true;
	bProcessAllActors=true;
	//
	defaultSpeed=(x=0,y=-60,z=0); //When does this set the zone velocities?
	FluidFriction=0
	GroundFriction=0
}
