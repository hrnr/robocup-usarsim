class PhysXProxy extends Object
	DLLBind(PhysXProxy);

// Helpers
// BodyInstance must be wrapped in a struct
struct BodyInstancePointer
{
	var Object BodyInstance;
};

function BodyInstancePointer WrapBodyInstance( RB_BodyInstance BodyInstance )
{
	local BodyInstancePointer bodyInst;
	bodyInst.BodyInstance = BodyInstance;
	return bodyInst;
}

// Test function, prints some general things
// NOTE: only prints to the console if compiled in debugged mode (32 bit)
dllimport final function GeneralPhysX();

// -- Functions that are normally not exposed in UDK
// Changes the solver iteration count. Determines how accurately joints are solved. 
// Value between 0 and 255 (default 8).
dllimport final function SetIterationSolverCountInternal( BodyInstancePointer bodyInst, int iterCount );
function SetIterationSolverCount( RB_BodyInstance BodyInstance, int iterCount )
{
	SetIterationSolverCountInternal(WrapBodyInstance(BodyInstance), iterCount);
}

// Disables contact generation between two rigid bodies.
// This means they won't collide.
dllimport final function SetActorPairIgnoreInternal( BodyInstancePointer bodyInst1, 
			BodyInstancePointer bodyInst2, int ignore );
function SetActorPairIgnore( RB_BodyInstance BodyInstance1, RB_BodyInstance BodyInstance2, bool ignore )
{
	SetActorPairIgnoreInternal(WrapBodyInstance(BodyInstance1), WrapBodyInstance(BodyInstance2), int(ignore));
}

// Retrieves the center of mass.
// TODO: determine what unit scale PhysX uses.
dllimport final function Vector GetCMassLocalPositionInternal( BodyInstancePointer bodyInst );
function Vector GetCMassLocalPosition( RB_BodyInstance BodyInstance )
{
	return GetCMassLocalPositionInternal(WrapBodyInstance(BodyInstance));
}

