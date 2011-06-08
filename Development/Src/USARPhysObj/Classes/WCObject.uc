/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * TODO: Change to avoid using Skeletal meshes
 * Port to UT3 and additions by Stephen Balakirsky
 * Based on code by Marco Zaratti
 */
class WCObject extends SVehicle config(USAR) // UTPawn seems to work, GameBreakableActor drop through the floor! Others tried DynamicSMActor and InterpActor ;
	placeable; // placeable allows the actor to be placed from the editor
var() string wcoName;
var() string wcoMemory;
var() string wcoClass;
var() vector boundary; // values from center of object to extream points in meters
var() int dirty; // does the physics need updating
var() bool permanent; // should the object not be destroyed by a clear?

// convert all variables of this object read from the UTUSAR.ini from SI to UU units
// initialize this object
simulated function PreBeginPlay()
{
	super.PreBeginPlay(); // first initialize parent object
	boundary.x = class'UnitsConverter'.static.LengthToUU(boundary.x);
	boundary.y = class'UnitsConverter'.static.LengthToUU(boundary.y);
	boundary.z = class'UnitsConverter'.static.LengthToUU(boundary.z);
}

simulated function PostBeginPlay() 
{
    super.PostBeginPlay();
    Mesh.WakeRigidBody();
}

defaultproperties
{
    // Local Variables
    permanent=false
	boundary=(x=.1,y=.1,z=0)
	dirty=0
    Begin Object Class=SkeletalMeshComponent Name=WCMesh
      bUseSingleBodyPhysics=1
      bForceDiscardRootMotion=True
      CollideActors=True
      BlockActors=True
      BlockZeroExtent=True
      BlockNonZeroExtent=True
      BlockRigidBody=True
      RBChannel=RBCC_GameplayPhysics
      RBCollideWithChannels=(Default=True,Vehicle=True,GameplayPhysics=True,EffectPhysics=True)
      bNotifyRigidBodyCollision=True
      ScriptRigidBodyCollisionThreshold=250.000000
      Name="WCMesh"
   End Object

    //Actor Variables
    //bStasis=false // Deprecated in UDK/UT3
	BlockRigidBody=True
	bStatic=false
	bBlockActors=false
	bCollideWhenPlacing=true
	bHardAttach=false
	bConsiderAllStaticMeshComponentsForStreaming=true
    Components(0)=WCMesh
    Components(1)=none //get rid of collision cylinder
    Physics=PHYS_RigidBody
    TickGroup=TG_PostAsyncWork
    bNetInitialRotation=True
    bBlocksTeleport=True
    CollisionComponent=WCMesh
    
    //PawnVariables
    Mesh=WCMesh
    
    //SVehicle Variables
    COMOffset=(x=0,y=0,z=-4)
    
   
   //Object Variables
   Name="Default__WCObject"
}
