// USARAvatarNewController: custom AIController class for avatars
class USARAvatarNewController extends UDKBot;

/* Functions that might be useful in later development
function UpdateRotation( float DeltaTime )
{
}

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
}

function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);
}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}
*/

function GoToLocation(vector vec, rotator rot)
{
	SetDestinationPosition(vec);
	ExecutePathFindMove();
}

/******************************************************************
 *
 *  ExecutePathFindMove makes the call to the FindPathTo so that a list
 *  of possible PathNodes will be cached in RouteCache.
 *
 ******************************************************************/
function ExecutePathFindMove()
{
	ScriptedMoveTarget = FindPathTo(GetDestinationPosition());

	`Log("Route length is"@RouteCache.Length);
	if( RouteCache.Length > 0 )
	{
		//`Log("Launching PathFind");
		PushState('PathFind');
	}
}

//-----------------------------------------------------------------
//                     STATES
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//
//  This is almost the same if not identical to AiController
//  ScriptedRouteMove. For each route in the RouteCache (initialized
//  with a call to FindPathTo(destVector), push a state that will
//  make the pawn goto a location determined by a PathNode location.
//  You will need to have multiple PathNodes on your map for this to
//  work properly. This does not use NavigationMeshes, only Linked
//  PathNodes. PathNodes are manually placed. NavigationMeshes uses
//  Pylons and other type of actors, so the two systems are different.
//
//-----------------------------------------------------------------
state PathFind
{
	local Name nodeName;
Begin:
	if( RouteCache.Length > 0 )
	{
		//for each route in routecache push a ScriptedMove state.
		ScriptedRouteIndex = 0;
		while (Pawn != None && ScriptedRouteIndex < RouteCache.length && ScriptedRouteIndex >= 0)
		{
			//Get the next route (PathNode actor) as next MoveTarget.
			ScriptedMoveTarget = RouteCache[ScriptedRouteIndex];
			if (ScriptedMoveTarget != None)
			{
				nodeName = RouteCache[ScriptedRouteIndex].Tag;
				if(nodeName=='PathNode')
					nodeName = RouteCache[ScriptedRouteIndex].Name;

				`Log("ScriptedRoute is at index:"@ScriptedRouteIndex@"| next node is"@nodeName);
				PushState('ScriptedMove');
			}
			else
			{
				`Log("ScriptedMoveTarget is invalid for index:"@ScriptedRouteIndex);
			}
			ScriptedRouteIndex++;
		}
		PopState();
	}	
}

//-----------------------------------------------------------------
//
//  This is the state that is put on the state stack for each PathNode
//  found when pathfinding. So if you click on a destination and it has
//  3 PathNode on its route, this state will be stacked 3 times for
//  moving to a destination. The destination actor represented
//  by ScriptedMoveTarget is the PathNode.
//
//-----------------------------------------------------------------
state ScriptedMove
{
	local vector Distance;

Begin:
	while(ScriptedMoveTarget != none && Pawn != none && !Pawn.ReachedDestination(ScriptedMoveTarget))
	{
		// check to see if it is directly reachable
		if (ActorReachable(ScriptedMoveTarget))
		{
			// then move directly to the actor
			MoveToward(ScriptedMoveTarget, ScriptedMoveTarget, , false);
			//MoveTo(ScriptedMoveTarget.Location, ScriptedMoveTarget);
			SetDestinationPosition(ScriptedMoveTarget.Location);
		}
		else
		{
			// attempt to find a path to the target
			MoveTarget = FindPathToward(ScriptedMoveTarget);
			if (MoveTarget != None)
			{
				// move to the first node on the path
				MoveToward(MoveTarget, MoveTarget, , false);
				SetDestinationPosition(MoveTarget.Location);
			}
			else
			{
				// abort the move
				`warn("Failed to find path to"@ScriptedMoveTarget);
				ScriptedMoveTarget = None;
			}
		}
	}
	PopState();
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	return false;
}

function bool TryStrafe(vector sideDir)
{
	return false;
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		return false;
	}


function bool FindStrafeDest()
{
	return false;
}

DefaultProperties
{
	bCanDoSpecial=true
	bIsPlayer=true
    bForceStrafe=false;
}

