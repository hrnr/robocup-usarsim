class ForceTest extends BaseTest;

var FileWriter LogWriter;

var Vector StartPosition;
var int TrialsLeft;

var Vector LastMeasureAcc;
var float LastMeasureAccTime;

struct ForceTestInfo
{
	var int Trials;
	var float Mass;
	var float Force;
	var float Time;
	var Vector ForceOffset;
};
var array<ForceTestInfo> Tests;

simulated function PostBeginPlay()
{
	local ForceTestInfo Info;

	Super.PostBeginPlay(); // first initialize parent object

	SetMass(1);

	// Initialize tests
	Info.Trials = 5;
	Info.Time = 0.1;

	Info.Mass = 1.0;
	Info.Force = 50;
	Tests.AddItem(Info);
	Info.Force = 100;
	Tests.AddItem(Info);

	Info.Mass = 2.0;
	Info.Force = 50;
	Tests.AddItem(Info);
	Info.Force = 100;
	Tests.AddItem(Info);
}

simulated function Initialize()
{
	Super.Initialize(); // first initialize parent object

	StartNewTest();
	InitTrial();

	//SetTimer(0.1, true, 'MeasureAcc');
}

/*
simulated function MeasureAcc()
{
	local Vector delta, vel, acc, loc1, loc2;

	loc1 = class'UnitsConverter'.static.LengthVectorFromUU( LastMeasureAcc );
	loc2 = class'UnitsConverter'.static.LengthVectorFromUU( Location );

	delta = loc2 - loc1;
	Vel = delta / (WorldInfo.TimeSeconds-LastMeasureAccTime);
	acc = Vel / (WorldInfo.TimeSeconds-LastMeasureAccTime);

	LastMeasureAcc = Location;
	LastMeasureAccTime = WorldInfo.TimeSeconds;
	LogInternal("Acceleration: " $ acc);
}
*/

function MoveToStartPosition()
{
	local Vector start;

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

function StartNewTest()
{
	if( LogWriter != none )
	{
		LogWriter.CloseFile();
		LogWriter.Destroy();
	}

	SetMass( Tests[0].Mass );

	LogWriter = spawn(class'FileWriter');
	LogWriter.OpenFile( "forcetest_" $ Tests[0].Time $ "_" $ Tests[0].Mass $ "_" $ Tests[0].Force $ "_" $ Tests[0].ForceOffset $ ".txt" );
	LogWriter.Logf("Trial StartLocationZ EndLocationZ VelocityZ AccelerationZ Force");

	TrialsLeft = Tests[0].Trials;
}

function EndTest()
{
	if( LogWriter != None ) 
	{
		LogWriter.CloseFile();
		LogWriter.Destroy();
	}
}

function InitTrial()
{
	local Vector Force;

	MoveToStartPosition();

	Force.Z = Tests[0].Force;
	StaticMeshComponent.AddForce(Force, Location,);

	StartPosition = Location;
	SetTimer(Tests[0].Time, false, 'MeasureForce');
}

simulated function MeasureForce()
{
	local Vector delta, vel, acc, loc1, loc2;
	local float force;

	loc1 = class'UnitsConverter'.static.LengthVectorFromUU( StartPosition );
	loc2 = class'UnitsConverter'.static.LengthVectorFromUU( Location );

	delta = loc2 - loc1;
	Vel = delta / Tests[0].Time;
	acc = Vel / Tests[0].Time;

	LogInternal("acc: " $ acc );

	force = 1 * VSize(acc);
	LogInternal("delta: " $ delta $ " vel: " $ Vel $ " force: " $ Force );

	LogWriter.Logf(TrialsLeft @ loc1.z @ loc2.z @ Vel.z @ Acc.z @ force );

	if( TrialsLeft == 0 )
	{
		EndTest();

		Tests.Remove(0, 1);

		if( Tests.Length == 0 )
			return;

		StartNewTest();
	}

	if( Tests.Length == 0 )
		return;

	TrialsLeft -= 1;
	InitTrial();
}


defaultproperties
{
	TrialsLeft=0;
}
