class GravityTest extends BaseTest;

var FileWriter LogWriter;

var float StartTime;
var Vector StartLocation;

var bool Started;
var int TrialsLeft;
var int TestNumber;

struct GravityTestInfo
{
	var float FallDistance;
	var int Trials;
	var float Gravity;
	var float Mass;
};
var array<GravityTestInfo> Tests;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay(); // first initialize parent object

	SetPhysicalCollisionProperties();
	StaticMeshComponent.BodyInstance.EnableCollisionResponse(true);

	StaticMeshComponent.SetNotifyRigidBodyCollision( true );
	StaticMeshComponent.ScriptRigidBodyCollisionThreshold = 10;
}

simulated function Initialize()
{
	local GravityTestInfo Info;

	Super.Initialize(); // first initialize parent object

	// Initialize tests
	Info.Trials = 10;
	Info.Mass = 1.0;

	Info.Gravity = -520;
	Info.FallDistance = 1024.0;
	Tests.AddItem(Info);
	Info.FallDistance = 2048.0;
	Tests.AddItem(Info);
	Info.FallDistance = 4096.0;
	Tests.AddItem(Info);
	Info.FallDistance = 8192.0;
	Tests.AddItem(Info);

	// Correction of 2.53
	// RBPhysicsGravityScaling=2.0
	/*
	Info.Gravity = -1317.056;
	Info.FallDistance = 1024.0;
	Tests.AddItem(Info);
	Info.FallDistance = 2048.0;
	Tests.AddItem(Info);
	Info.FallDistance = 4096.0;
	Tests.AddItem(Info);
	Info.FallDistance = 8192.0;
	Tests.AddItem(Info);
*/

	// Correction of 5.0656
	// RBPhysicsGravityScaling = 1.0
	Info.Gravity = -2634.112;
	Info.FallDistance = 1024.0;
	Tests.AddItem(Info);
	Info.FallDistance = 2048.0;
	Tests.AddItem(Info);
	Info.FallDistance = 4096.0;
	Tests.AddItem(Info);
	Info.FallDistance = 8192.0;
	Tests.AddItem(Info);

	FallDone();
}

/*
event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
				const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	LogInternal("RigidBodyCollision");
	gt.OnHitFloor();
}
*/


// Our test actor is done falling
// Start next test or trial.
simulated function FallDone()
{
	local float EndTime;
	local float FallDistance, SupposedToFall;
	local String StartLocationStr;

	if( Tests.Length == 0 )
		return;

	if( Started )
	{
		FallDistance = class'UnitsConverter'.static.LengthFromUU(StartLocation.Z) - class'UnitsConverter'.static.LengthFromUU(Location.Z);

		StartLocationStr = class'UnitsConverter'.static.LengthFromUU(StartLocation.X)$","$
			class'UnitsConverter'.static.LengthFromUU(StartLocation.Y)$","$
			class'UnitsConverter'.static.LengthFromUU(StartLocation.Z);

		// Write away test results
		EndTime = WorldInfo.TimeSeconds-StartTime;
		SupposedToFall = 4.9*Square(EndTime);
		LogWriter.Logf(TrialsLeft @ EndTime @ StartLocationStr @ GetStatus() @ FallDistance @ SupposedToFall @ (SupposedToFall/FallDistance) );
	}

	if( TrialsLeft == 0 )
	{
		EndTest();

		if( Started )
			Tests.Remove(0, 1);
		else
			Started = true;

		if( Tests.Length == 0 )
			return;

		StartNewTest();
	}

	// Start new trial
	MoveToStartPosition();
	StartTime = WorldInfo.TimeSeconds;
	StartLocation = Location;
	TrialsLeft -= 1;

	SetTimer(sqrt(class'UnitsConverter'.static.LengthFromUU(Tests[0].FallDistance)/4.9), false, 'FallDone');
}


function StartNewTest()
{
	if( LogWriter != none )
	{
		LogWriter.CloseFile();
		LogWriter.Destroy();
	}

	WorldInfo.WorldGravityZ = Tests[0].Gravity;
	SetMass( Tests[0].Mass );

	TestNumber += 1;
	LogWriter = spawn(class'FileWriter');
	LogWriter.OpenFile(WorldInfo.WorldGravityZ $ "_" $ Tests[0].FallDistance $ "_" $ Tests[0].Mass $ ".txt" );
	LogWriter.Logf("Trial Time StartPosX,StartPosY,StartPosZ PosX,PosY,PosZ VelX,VelY,VelZ FallDistance SupposedToFall Correction");

	TrialsLeft = Tests[0].Trials;
}

function MoveToStartPosition()
{
	local Vector start;
	Start.z = Tests[0].FallDistance;

	if( Physics == PHYS_RigidBody )
	{
		StaticMeshComponent.SetRBPosition( Start );
		StaticMeshComponent.SetRBRotation( rot(0,0,0) );
		StaticMeshComponent.SetRBLinearVelocity( Vect(0,0,0), false );
		StaticMeshComponent.SetRBAngularVelocity( Vect(0,0,0), false );
	}
	else
	{
		SetLocation(Start);
		SetRotation(rot(0,0,0));
		Velocity = Vect(0,0,0);
	}
}

function string GetStatus()
{
	local String status;
	status = class'UnitsConverter'.static.LengthFromUU(Location.X)$","$
		class'UnitsConverter'.static.LengthFromUU(Location.Y)$","$
		class'UnitsConverter'.static.LengthFromUU(Location.Z);
	status @= class'UnitsConverter'.static.LengthFromUU(Velocity.X)$","$
		class'UnitsConverter'.static.LengthFromUU(Velocity.Y)$","$
		class'UnitsConverter'.static.LengthFromUU(Velocity.Z);
	return status;
}

function EndTest()
{
	if( LogWriter != None ) 
	{
		LogInternal("Stopped: " $ (WorldInfo.TimeSeconds)-StartTime );
		LogWriter.CloseFile();
		LogWriter.Destroy();
	}
}

simulated
event Destroyed()
{
	super.Destroyed();

	LogInternal("GRAVITY TEST ACTOR DESTROYED");
}

defaultproperties
{
	Started=false;
	TrialsLeft=0;
}
