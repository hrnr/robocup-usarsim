// PhysXProxy.cpp : Defines the exported functions for the DLL application.

#include "stdafx.h"
#include <stdio.h>

#undef min
#undef max
#include "NxPhysics.h"

#define PHYSXPROXYDLL_API __declspec(dllexport)

extern "C"
{
	struct FVector
	{
		FVector() {}
		FVector( float x, float y, float z) : x(x), y(y), z(z) {}
		float x,y,z;
	};

#if 0
	struct FString
	{
		wchar_t* Data;
		int ArrayNum;
		int ArrayMax;

		void UpdateArrayNum()
		{
			ArrayNum = wcslen(Data)+1;
			assert(ArrayNum <= ArrayMax);
		}
	};
#endif // 0

	struct BodyInstancePointer
	{
		void *pBodyInstance;
	};

#ifdef _WIN64
	// Fix for 64 bit dll. 64 bit dll bind is not very well supported.
	void *Fix64Bit( void * pBodyInstanceWrapper )
	{
		return (void*)(int)pBodyInstanceWrapper;;
	}
#endif // _WIN64

	// General example to access PhysX information
	PHYSXPROXYDLL_API void GeneralPhysX()
	{
		NxU32 apiRev, descRev, branchId;
		NxU32 nbScenes, nbCompartments;
		NxVec3 gravity;
		NxU32 i;

		NxPhysicsSDK *pPhysicsSDK = NxGetPhysicsSDK();

		// Get Internal version
		pPhysicsSDK->getInternalVersion( apiRev, descRev, branchId );
		printf("PhysX version: %u %u %u\n", apiRev, descRev, branchId );

		// Get number of scenes and then extract the first (and only) scene
		nbScenes = pPhysicsSDK->getNbScenes();
		printf("Scenes: %u\n", nbScenes );

		if( nbScenes == 0 )
		{
			printf("No scenes\n");
			return;
		}

		NxScene *pScene = pPhysicsSDK->getScene( 0 );
		if( !pScene )
		{
			printf("Failed to retrieve scene\n");
			return;
		}

		// Retrieve the number of compartments (should be 3)
		nbCompartments = pScene->getNbCompartments();
		printf("Number of compartments: %u\n", nbCompartments ); 

		// Print gravity
		pScene->getGravity( gravity );
		printf("Gravity is (x,y,z): %f %f %f\n", gravity.x, gravity.y, gravity.z);

		// Get actors array and print number of actors
		NxU32 nbActors;
		NxActor **pActorArray;
		nbActors = pScene->getNbActors();
		pActorArray = pScene->getActors();
		printf("Number of actors: %u\n", nbActors);

		// Get Number of joints
		NxU32 nbJoints;
		nbJoints = pScene->getNbJoints();
		printf("Number of joints: %u\n", nbJoints);

		// Print forcefield information
		NxU32 nbForceFields;
		nbForceFields = pScene->getNbForceFields();
		NxForceField **pForceFieldArray = pScene->getForceFields();
		NxForceField *pForceField;
		printf("Number of forcefields: %u\n", nbForceFields);
		for( i =0; i < nbForceFields; i++ )
		{
			pForceField = pForceFieldArray[i];
			if( !pForceField )
			{
				printf("Invalid forcefield %u\n", i);
				continue;
			}

			printf("%u, rigid body type: %u\n", i, 
				pForceField->getRigidBodyType() );
		}
	}

	// Retrieves the PhysX scene
	NxScene *GetScene()
	{
		NxU32 nbScenes;
		NxPhysicsSDK *pPhysicsSDK = NxGetPhysicsSDK();

		// Get number of scenes
		nbScenes = pPhysicsSDK->getNbScenes();
		if( nbScenes == 0 )
		{
			printf("No scenes\n");
			return NULL;
		}

		NxScene *pScene = pPhysicsSDK->getScene( 0 );
		if( !pScene )
		{
			printf("Failed to retrieve scene\n");
			return NULL;
		}
		return pScene;
	}

	// Lookup the matching actor by comparing the userdata to the object
	// pObject is a pointer to a RB_BodyInstance class.
	// NOTE: Could also try to reconstruct the body instance class and then call GetNxActor() on it directly
	//		 But that could give problems if the the body instance class changes.
	NxActor *GetActor( BodyInstancePointer *pBodyInstanceWrapper )
	{
		NxScene *pScene;
		NxActor **pActorArray;
		NxActor *pActor;
		NxU32 i, nbActors;
		void *pObject;

#ifdef _WIN64
		pBodyInstanceWrapper = (BodyInstancePointer *)Fix64Bit( (void *)pBodyInstanceWrapper );
#endif // _WIN64

		if( !pBodyInstanceWrapper )
		{
			return NULL;
		}

		pObject = pBodyInstanceWrapper->pBodyInstance;
		if( !pObject )
		{
			return NULL;
		}

		pScene = GetScene();
		if( !pScene )
			return NULL;

		nbActors = pScene->getNbActors();
		pActorArray = pScene->getActors();
		for( i=0; i < nbActors; i++ )
		{
			pActor = pActorArray[i];
			if( !pActor )
				continue;

			// Check if the BodyInstance pointers match
			if( pActor->userData == pObject)
			{
				return pActor;
			}
		}
		return NULL;
	}

	// Lookup the matching joint by comparing the userdata to the object
	// pObject is a pointer to a RB_ConstraintInstance class.
	NxJoint *GetJoint( BodyInstancePointer *pBodyInstanceWrapper )
	{
		NxScene *pScene;
		NxJoint *pJoint;
		void *pObject;

#ifdef _WIN64
		pBodyInstanceWrapper = (BodyInstancePointer *)Fix64Bit( (void *)pBodyInstanceWrapper );
#endif // _WIN64

		if( !pBodyInstanceWrapper )
		{
			return NULL;
		}

		pObject = pBodyInstanceWrapper->pBodyInstance;
		if( !pObject )
		{
			return NULL;
		}

		pScene = GetScene();
		if( !pScene )
			return NULL;

		pScene->resetJointIterator();
		while( (pJoint = pScene->getNextJoint()) != NULL )
		{
			if( pJoint->userData == pObject)
			{
				return pJoint;
			}
		}
		return NULL;
	}

	// Directly set the mass of the specified actor
	PHYSXPROXYDLL_API void SetMassInternal( BodyInstancePointer *pBodyInstWrapper, float mass )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("SetMassInternal: Invalid body instance!\n");
			return;
		}

		pActor->setMass( mass );
	}

	// Changes the iteration solver count of the specified actor
	PHYSXPROXYDLL_API void SetIterationSolverCountInternal( BodyInstancePointer *pBodyInstWrapper, int iterCount )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("SetIterationSolverCountInternal: Invalid body instance!\n");
			return;
		}

		pActor->setSolverIterationCount( iterCount );
	}

	PHYSXPROXYDLL_API int GetIterationSolverCountInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetIterationSolverCountInternal: Invalid body instance!\n");
			return -1;
		}

		return pActor->getSolverIterationCount( );
	}

	// Make two actors not generate contacts between each other
	PHYSXPROXYDLL_API void SetActorPairIgnoreInternal( BodyInstancePointer *pBodyInstWrapper1, 
			BodyInstancePointer *pBodyInstWrapper2, int ignore )
	{
		NxActor *pActor1 = GetActor(pBodyInstWrapper1);
		NxActor *pActor2 = GetActor(pBodyInstWrapper2);

		if( !pActor1 || !pActor2 )
		{
			printf("SetActorPairFlagsInternal: Invalid body instance(s)!\n");
			return;
		}

		NxScene *pScene = GetScene();
		if( !pScene )
			return;

		NxU32 flags = pScene->getActorPairFlags( *pActor1, *pActor2 );
		if( ignore )
		{
			if( flags & NX_IGNORE_PAIR )
				return;
			pScene->setActorPairFlags( *pActor1, *pActor2, flags|NX_IGNORE_PAIR );
		}
		else
		{
			if( (flags & NX_IGNORE_PAIR) == 0 )
				return;
			pScene->setActorPairFlags( *pActor1, *pActor2, flags&~NX_IGNORE_PAIR );
		}
	}



	PHYSXPROXYDLL_API FVector* GetCMassLocalPositionInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.

		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetCMassLocalPositionInternal: Invalid body instance!\n");
			result.x = result.y = result.z = 666.0f;
			return &result;
		}

		NxVec3 cmass = pActor->getCMassLocalPosition();
		result.x = cmass.x;
		result.y = cmass.y;
		result.z = cmass.z;
		return &result;
	}

	PHYSXPROXYDLL_API void SetCMassOffsetLocalPositionInternal( BodyInstancePointer *pBodyInstWrapper, FVector *ucmass )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("SetCMassOffsetLocalPositionInternal: Invalid body instance!\n");
			return;
		}

#ifdef _WIN64
		ucmass = (FVector *)Fix64Bit( (void *)ucmass );
#endif // _WIN64

		NxVec3 cmass;
		cmass.x = ucmass->x;
		cmass.y = ucmass->y;
		cmass.z = ucmass->z;

		pActor->setCMassOffsetLocalPosition( cmass );
	}

	// Set/get the iteration mass space inertia tensor of the specified actor
	PHYSXPROXYDLL_API void SetMassSpaceInertiaTensorInternal( BodyInstancePointer *pBodyInstWrapper, FVector *utensor )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("SetMassSpaceInertiaTensorInternal: Invalid body instance!\n");
			return;
		}

#ifdef _WIN64
		utensor = (FVector *)Fix64Bit( (void *)utensor );
#endif // _WIN64

		NxVec3 tensor;
		tensor.x = utensor->x;
		tensor.y = utensor->y;
		tensor.z = utensor->z;

		pActor->setMassSpaceInertiaTensor( tensor );
	}

	PHYSXPROXYDLL_API FVector* GetMassSpaceInertiaTensorInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.

		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetMassSpaceInertiaTensorInternal: Invalid body instance!\n");
			result.x = result.y = result.z = 666.0f;
			return &result;
		}

		NxVec3 tensor = pActor->getMassSpaceInertiaTensor();
		result.x = tensor.x;
		result.y = tensor.y;
		result.z = tensor.z;
		return &result;
	}

	PHYSXPROXYDLL_API float GetSolverExtrapolationFactorInternal( BodyInstancePointer *pJointInstWrapper )
	{
		NxJoint *pJoint = GetJoint(pJointInstWrapper);
		if( !pJoint )
		{
			printf("GetSolverExtrapolationFactor: Invalid joint instance!\n");
			return -1;
		}

		return pJoint->getSolverExtrapolationFactor();
	}

	PHYSXPROXYDLL_API void SetSolverExtrapolationFactorInternal( BodyInstancePointer *pJointInstWrapper, float solverExtrapolationFactor )
	{
		NxJoint *pJoint = GetJoint(pJointInstWrapper);
		if( !pJoint )
		{
			printf("SetSolverExtrapolationFactorInternal: Invalid joint instance!\n");
			return;
		}

		pJoint->setSolverExtrapolationFactor( solverExtrapolationFactor );
	}

	/* The remaining functions below are added for testing/debugging */
	PHYSXPROXYDLL_API FVector* GetVelocityInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.

		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetVelocityInternal: Invalid body instance!\n");
			result.x = result.y = result.z = 666.0f;
			return &result;
		}

		NxVec3 velocity = pActor->getLinearVelocity();
		result.x = velocity.x;
		result.y = velocity.y;
		result.z = velocity.z;
		return &result;
	}

	PHYSXPROXYDLL_API FVector* GetLinearMomentumInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.

		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetLinearMomentumInternal: Invalid body instance!\n");
			result.x = result.y = result.z = 666.0f;
			return &result;
		}

		NxVec3 linearmomentum = pActor->getLinearMomentum();
		result.x = linearmomentum.x;
		result.y = linearmomentum.y;
		result.z = linearmomentum.z;
		return &result;
	}

	PHYSXPROXYDLL_API FVector* GetAngularMomentumInternal( BodyInstancePointer *pBodyInstWrapper )
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.

		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("GetAngularMomentumInternal: Invalid body instance!\n");
			result.x = result.y = result.z = 666.0f;
			return &result;
		}

		NxVec3 angularmomentum = pActor->getAngularMomentum();
		result.x = angularmomentum.x;
		result.y = angularmomentum.y;
		result.z = angularmomentum.z;
		return &result;
	}
	

	// For debugging/information, print joint info.
	PHYSXPROXYDLL_API void PrintJointInfoInternal( BodyInstancePointer *pJointInstWrapper )
	{
		NxJoint *pJoint = GetJoint(pJointInstWrapper);
		if( !pJoint )
		{
			printf("PrintJointInfo: Invalid joint instance!\n");
			return;
		}

		NxRevoluteJoint *pRevJoint;
		NxD6Joint *pD6Joint;

		if( (pRevJoint = pJoint->isRevoluteJoint()) != NULL )
		{
			NxSpringDesc springdesc;
			pRevJoint->getSpring( springdesc );
			printf("Revolute joint: Spring: %f, Damper: %f\n", springdesc.spring, springdesc.damper );
		}
		else if( (pD6Joint = pJoint->isD6Joint()) != NULL )
		{
			NxD6JointDesc d6desc;
			pD6Joint->saveToDesc( d6desc );
			printf("D6 joint: Swing Spring: %f, Damper: %f, ForceLimit: %f | Twist Spring: %f, Damper: %f, ForceLimit: %f | useAccelerationSpring: %d \n", 
				d6desc.swingDrive.spring, d6desc.swingDrive.damping, d6desc.swingDrive.forceLimit,
				d6desc.twistDrive.spring, d6desc.twistDrive.damping, d6desc.twistDrive.forceLimit,
				d6desc.useAccelerationSpring );
		}
		else
		{
			printf("Unknown joint\n");
		}
	}
}
