#include "hooking.h"
#include <windows.h>
#include "ImageServer.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		break;
	case DLL_THREAD_ATTACH:
		Hook::AddActiveHooksToThread( GetCurrentThreadId() );
		break;
	case DLL_THREAD_DETACH:
		Hook::RemoveActiveHooksFromThread( GetCurrentThreadId() );
		break;
	case DLL_PROCESS_DETACH:
		Hook::ClearHooks();
		break;
	}
	return TRUE;
}

