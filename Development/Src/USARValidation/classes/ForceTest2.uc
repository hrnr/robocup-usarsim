class ForceTest2 extends BaseTest;

var FileWriter LogWriter;

var Vector StartPosition;
var int TrialsLeft;

struct ForceTest2Info
{
	var int Trials;
	var float Mass;
	var float Force;
	var float Time;
	var Vector ForceOffset;
};
var array<ForceTestInfo> Tests;

var ForceTest2Helper StaticMeshAnchor;
var RB_ConstraintActor Constraint;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay(); // first initialize parent object

	//SetMass(1);
	SetMass(10);
	StaticMeshAnchor.SetMass(10);

	StaticMeshAnchor = Spawn(class'ForceTest2Helper',,, Location+Vect(200, 0, 0), Rotation );

	Constraint = Spawn(class'RB_ConstraintActorSpawnable',,, Location+Vect(100, 0, 0), Rotation );

	Constraint.ConstraintSetup.bSwingLimited = true;
	Constraint.ConstraintSetup.bTwistLimited = true;

	Constraint.ConstraintSetup.Swing1LimitAngle = 180.0;

	Constraint.SetDisableCollision(true);

	Constraint.InitConstraint( self, StaticMeshAnchor,,, 6000.0);

	Constraint.ConstraintInstance.SetAngularPositionDrive(true, false);
}

simulated function Initialize()
{
	local Quat q;

	Super.Initialize(); // first initialize parent object

		
	q = QuatFromRotator(rot(0,0,0));
	Constraint.ConstraintInstance.SetAngularPositionTarget(q);

	Constraint.ConstraintInstance.SetAngularDriveParams(100, 0, 0);

	//LogInternal("AngularDriveSpring: " $ Constraint.ConstraintInstance.AngularDriveSpring );

	SetTimer(0.5, true, 'DoForce');
}

simulated function DoForce()
{
	StaticMeshComponent.AddForce( Vect(0, -100, 0), Location );
}

defaultproperties
{
	TrialsLeft=0;
}
