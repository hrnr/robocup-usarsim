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

// Functions that are normally not exposed in UDK
dllimport final function SetIterationSolverCountInternal( BodyInstancePointer bodyInst, int iterCount );
function SetIterationSolverCount( RB_BodyInstance BodyInstance, int iterCount )
{
	SetIterationSolverCountInternal(WrapBodyInstance(BodyInstance), iterCount);
}

dllimport final function int GetIterationSolverCountInternal( BodyInstancePointer bodyInst );
function int GetIterationSolverCount( RB_BodyInstance BodyInstance )
{
	return GetIterationSolverCountInternal(WrapBodyInstance(BodyInstance));
}

dllimport final function SetActorPairIgnoreInternal( BodyInstancePointer bodyInst1, 
			BodyInstancePointer bodyInst2, int ignore );
function SetActorPairIgnore( RB_BodyInstance BodyInstance1, RB_BodyInstance BodyInstance2, bool ignore )
{
	SetActorPairIgnoreInternal(WrapBodyInstance(BodyInstance1), WrapBodyInstance(BodyInstance2), int(ignore));
}

dllimport final function Vector GetCMassLocalPositionInternal( BodyInstancePointer bodyInst );
function Vector GetCMassLocalPosition( RB_BodyInstance BodyInstance )
{
	return GetCMassLocalPositionInternal(WrapBodyInstance(BodyInstance));
}

dllimport final function Vector GetMassSpaceInertiaTensorInternal( BodyInstancePointer bodyInst );
function Vector GetMassSpaceInertiaTensor( RB_BodyInstance BodyInstance )
{
	return GetMassSpaceInertiaTensorInternal(WrapBodyInstance(BodyInstance));
}

dllimport final function SetMassSpaceInertiaTensorInternal( BodyInstancePointer bodyInst, Vector Tensor );
function SetMassSpaceInertiaTensor( RB_BodyInstance BodyInstance, Vector InertiaTensor )
{
	SetMassSpaceInertiaTensorInternal(WrapBodyInstance(BodyInstance), InertiaTensor);
}

