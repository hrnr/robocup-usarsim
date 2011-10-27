#ifndef HOOKING_H
#define HOOKING_H

#include "easyhook.h"
#include <vector>
#include <list>
#include "gethookaddress_shared.h"

class Hook
{
public:
	Hook( TRACED_HOOK_HANDLE hHook, bool bAddAllTheads=true );

	void ClearThreads();
	void AddThread( DWORD dwThreadID );
	void RemoveThread( DWORD dwThreadID );
	void AddAllThreads( DWORD dwOwnerPID );
	
	void SetACL();
	void ClearACL();

	static void ActivateHooks();
	static void DeactivateHooks();

	static void AddActiveHooksToThread( DWORD dwThreadID ); 
	static void RemoveActiveHooksFromThread( DWORD dwThreadID );
	static void ClearHooks();

private:
	TRACED_HOOK_HANDLE m_hHook;
	std::list< DWORD > m_ThreadIDS;

	static bool m_bHooksActivated;
};

extern std::vector< Hook > g_HookRegistry;

#define InstallHook( HookFunction, OrigFunction, OriginFunctionType, DeviceAddress ) \
	{ \
		TRACED_HOOK_HANDLE hHook = NULL; \
		NTSTATUS rc; \
		void* pFunction = (void *)DeviceAddress; \
		OrigFunction = (OriginFunctionType)pFunction; \
		hHook = (TRACED_HOOK_HANDLE) VirtualAlloc(NULL, sizeof(HOOK_TRACE_INFO), MEM_COMMIT, PAGE_EXECUTE_READWRITE); \
		rc = LhInstallHook( (void *)pFunction, HookFunction, NULL, hHook); \
		if ( SUCCEEDED(rc)) { \
			g_HookRegistry.push_back( Hook( hHook ) ); \
		} \
	} 

uintptr_t GetHookingAddress( int iType, int iFunction );

#endif // HOOKING_H