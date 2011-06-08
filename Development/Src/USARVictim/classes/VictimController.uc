class VictimController extends AIController config(USAR);

var VictimPawn MyVictimPawn;
var Pawn thePlayer;

var float perceptionDistance;

var float distanceToPlayer;
var float distanceToTargetNodeNearPlayer;

var Name AnimSetName;

var Float IdleInterval;

defaultproperties
{
    perceptionDistance=1000

	AnimSetName="IDLE"
	IdleInterval=2.5f
}

function SetPawn(VictimPawn NewPawn)
{
    MyVictimPawn=NewPawn;
	Possess(MyVictimPawn, false);
}

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    if (aPawn.bDeleteMe)
	{
		`Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
		 ScriptTrace();
		 GotoState('Dead');
    }
	else
	{
		Super.Possess(aPawn, bVehicleTransition);
		/*
		Pawn.SetMovementPhysics();
		
		if (Pawn.Physics == PHYS_Walking)
		{
			Pawn.SetPhysics(PHYS_Falling);
	    }
		*/
		GotoState('Idle');
    }
}

function Tick(Float Delta)
{
	//if(IsInState('Idle'))
	//{	

	//}
}

state Idle
{
    event SeePlayer(Pawn SeenPlayer)
	{
	    thePlayer=SeenPlayer;
        distanceToPlayer=VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer < perceptionDistance)
        { 
        	//Worldinfo.Game.Broadcast(self, "I can see you!");
            //GotoState('Chaseplayer');
        }
    }

Begin:
    //Worldinfo.Game.Broadcast(self, "Idle ...");

	Sleep(IdleInterval);

	// Continue idling
	GotoState('Idle');

}
