/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/


/*
 * USARAIController: custom AIController class for avatars
 */
class USARAIController extends AIController;

var() bool bPawnNearDestination;//-- True if pawn is close to TargetLoc and can stop moving
var() float DistanceRemaining;//-- Distance from Pawn's location to TargetLoc's location
var() vector TargetLoc, TargetLocAppend;//-- Target that the avatar has to reach
var() vector TargetLocMeter;//-- Target that the avatar has to reach
var() String walkType, walkTypeAppend;
var() vector globalDistance;
var array<vector> WaypointList; //-- List storing Targets defined by the append command
var array<String> WalkTypeList;
var float CloseEnough;
var int WayPointIndex; //declare it at the start so you can use it throughout the script

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}


event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("UnitController created");
}

//============================================================================
// IdleState is used when the avatar is not doing anything in the environment
//============================================================================
auto state IdleState
{

  Begin:
  `log("Idle State");
  stopLatentExecution();
  Pawn.Acceleration=vect(0,0,0);
  Pawn.ZeroMovementVariables();

}

//========================================================================================================
/** Move an avatar towards a location
move_type is the type of action and can take the following values:
     - Walk_Forward: walk forward
     - Walk_Backward: walk backward
     - Run: run

move_target is the location (x,y) that the avatar is trying to reach

move_action is the type of action applied on the new location to reach, and can take the following values:
       - New: Ask the avatar to move to a new location
       - Pause: Pause the current action the avatar is performing
       - Resume: Resume the action performed by the avatar before being paused
       - Append: Add a new location to a list of locations
*/
//========================================================================================================
function MoveForwardToLocation(String move_type, vector move_target, String move_action)
{
  //-- Give the avatar a new location to reach
  if (move_action=="New")
  {
    WaypointList.Remove(0, WaypointList.Length);
    WalkTypeList.Remove(0, WalkTypeList.Length);
    WaypointList.InsertItem(0,class'UnitsConverter'.static.LengthVectorToUU(move_target));
    WalkTypeList.InsertItem(0,move_type);
    WayPointIndex=0;
  }
  //-- Add move_target to a list of locations
  else if (move_action=="Append")
  {
    WaypointList.AddItem(class'UnitsConverter'.static.LengthVectorToUU(move_target));
    WalkTypeList.AddItem(move_type);
    //`log ("Array size 1"@WaypointList.Length);
  }
}


//=====================================
// TODO: Move the avatar to a pathnode
//=====================================
function MoveForwardToPathnode(String pathnode, String action)
{
`log("+++++ Move Forward Pathnode ++++++");
}

//========================================
// Push the PauseAvatarState state
// Called by ProcessMove in BotConnection
//========================================
function PauseAction()
{
`log("+++++ Pause ++++++");
PushState('PauseAvatarState');
}

//========================================
// Push the ResumeAvatarState state
// Called by ProcessMove in BotConnection
//========================================
function ResumeAction()
{
`log("+++++ Resume ++++++");
PopState();
PushState('ResumeAvatarState');
}

//=====================================
// Pause the avatar's current movement
//=====================================
state PauseAvatarState
{
Begin:
  // Stop all latent functions
  stopLatentExecution();
  // Set the acceleration to (0,0,0)
  Pawn.Acceleration=vect(0,0,0);
  Pawn.ZeroMovementVariables();
}

//=====================================
// Resume the avatar's movement
//=====================================
state ResumeAvatarState
{
Begin:
//PopState();
}

//=================================================================
// Tick function
// Function that runs at every tick and listens to the user entry
//=================================================================
function Tick(float DeltaTime)
{
  //Use local as its only needed in this function
  local vector Distance;

  super.Tick(DeltaTime);

  //`log ("Array size 2"@WaypointList.Length);
  //`log ("Current Index"@WayPointIndex);
  if (!IsInState('PauseAvatarState'))
  {
  if (WaypointList.Length>0)
  {
   Distance=WaypointList[WayPointIndex]-Pawn.Location;
   Distance.Z=0; //-- We want 2D distance

   //-- Get remaining distance
   DistanceRemaining=Sqrt((Distance.X*Distance.X) + (Distance.Y*Distance.Y));

   if (DistanceRemaining <= CloseEnough)
   {
      WayPointIndex++;
   }
   
   if (WayPointIndex >= WaypointList.Length)
   {
      if (!IsInState('IdleState'))
         GoToState('IdleState');
   }
   else
    {
      // Set the speed of the avatar depending on the Type parameter
      if (WalkTypeList[WayPointIndex]=="Walk_Forward" ||WalkTypeList[WayPointIndex]=="Run")
      {
         Pawn.SetRotation(Rotator(-Distance));
         // If the Walk_Forward parameter is passed
         if (WalkTypeList[WayPointIndex]=="Walk_Forward")
            Pawn.GroundSpeed=180;
         // If the Run parameter is passed
         if (WalkTypeList[WayPointIndex]=="Run")
            Pawn.GroundSpeed=750;
      }
      // Rotate the pawn so that his back faces the target
      else if (WalkTypeList[WayPointIndex]=="Walk_Backward")
         Pawn.SetRotation(Rotator(Distance));
    
    DrawDebugLine(Pawn.Location,WaypointList[WayPointIndex],0,255,255,false);
    
    PopState();
    if (!IsInState('WalkToLocationState'))
    {
     PushState('WalkToLocationState');
    }
    }
   }
    //PopState();
    //PushState('IdleState');
  }

}

//=========================
// Use the MoveTo function
//=========================
state WalkToLocationState
{
 Begin:
 if (WaypointList.Length > 0)// make sure there is a location to move to
 {
   //`log("Move to Waypoint");
   MoveTo(WaypointList[WayPointIndex]);
 }
}


DefaultProperties
{
 // Set the value of CloseEnough
 CloseEnough=10.0f;
}

