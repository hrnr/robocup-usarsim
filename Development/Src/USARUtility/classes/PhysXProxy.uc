class PhysXProxy extends Object
	DLLBind(PhysXProxy);

// Helpers
// BodyInstance must be wrapped in a struct
struct BodyInstancePointer
{
	var Object BodyInstance;
};

function BodyInstancePointer WrapBodyInstance( Object BodyInstance )
{
	local BodyInstancePointer bodyInst;
	bodyInst.BodyInstance = BodyInstance;
	return bodyInst;
}

// Functions that are normally not exposed in UDK
dllimport final function SetMassInternal( BodyInstancePointer bodyInst, float Mass );
function SetMass( RB_BodyInstance BodyInstance, float Mass )
{
	SetMassInternal(WrapBodyInstance(BodyInstance), Mass);
}

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

// Joint functions
dllimport final function float GetSolverExtrapolationFactorInternal( BodyInstancePointer jointInst);
function float GetSolverExtrapolationFactor( RB_ConstraintInstance JointInstance )
{
	return GetSolverExtrapolationFactorInternal(WrapBodyInstance(JointInstance));
}

dllimport final function SetSolverExtrapolationFactorInternal( BodyInstancePointer jointInst, float SolverExtrapolationFactor );
function SetSolverExtrapolationFactor( RB_ConstraintInstance JointInstance, float SolverExtrapolationFactor )
{
	SetSolverExtrapolationFactorInternal(WrapBodyInstance(JointInstance), SolverExtrapolationFactor);
}