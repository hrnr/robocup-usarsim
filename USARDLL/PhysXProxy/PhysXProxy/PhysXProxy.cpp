// PhysXProxy.cpp : Defines the exported functions for the DLL application.

#include "stdafx.h"
#include <stdio.h>

#undef min
#undef max
#include "NxPhysics.h"

extern "C"
{
	struct FVector
	{
		FVector() {}
		FVector( float x, float y, float z) : x(x), y(y), z(z) {}
		float x,y,z;
	};

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

	struct BodyInstancePointer
	{
		void *pBodyInstance;
	};

	// General example to access PhysX information
	__declspec(dllexport) void GeneralPhysX()
	{
		NxU32 apiRev, descRev, branchId;
		NxU32 nbScenes, nbCompartments;

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

		// Get actors array and print number of actors
		NxU32 nbActors;
		NxActor **pActorArray;
		nbActors = pScene->getNbActors();
		pActorArray = pScene->getActors();
		printf("Number of actors: %u\n", nbActors);

		// Get Number of joints
		NxU32 nbJoints;
		nbJoints = pScene->getNbJoints();
		printf("Number of actors: %u\n", nbJoints);
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
		NxActor **pActorArray;
		NxActor *pActor;
		NxU32 i, nbActors;
		void *pObject;

		// Hax for 64 bit
#ifdef _WIN64
		pBodyInstanceWrapper = (BodyInstancePointer*)(int)pBodyInstanceWrapper;
#endif // _WIN64

		if( !pBodyInstanceWrapper )
		{
			return NULL;
		}

		pObject = pBodyInstanceWrapper->pBodyInstance;
		if( !pObject )
		{
			//printf("GetActor: No object\n");
			return NULL;
		}

		NxScene *pScene = GetScene();
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
	
	// Changes the iteration solver count of the specified actor
	__declspec(dllexport) void SetIterationSolverCountInternal( BodyInstancePointer *pBodyInstWrapper, int iterCount )
	{
		NxActor *pActor = GetActor(pBodyInstWrapper);
		if( !pActor )
		{
			printf("SetIterationSolverCountInternal: Invalid body instance!\n");
			return;
		}

		pActor->setSolverIterationCount( iterCount );
	}

	// Make two actors not generate contacts between each other
	__declspec(dllexport) void SetActorPairIgnoreInternal( BodyInstancePointer *pBodyInstWrapper1, 
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

	__declspec(dllexport) FVector* GetCMassLocalPositionInternal( BodyInstancePointer *pBodyInstWrapper )
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
}
