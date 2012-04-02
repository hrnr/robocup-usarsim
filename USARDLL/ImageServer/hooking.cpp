#include "hooking.h"
#include <tlhelp32.h>
#include <stdio.h>
#include <windows.h>

#ifdef _WIN64
	#pragma comment (lib, "easyhook64.lib")
#else
	#pragma comment (lib, "easyhook32.lib")
#endif // _WIN64

std::vector< Hook > g_HookRegistry;

bool Hook::m_bHooksActivated = false;

Hook::Hook( TRACED_HOOK_HANDLE hHook, bool bAddAllTheads )
	: m_hHook(hHook)
{
	if( bAddAllTheads )
	{
		AddAllThreads( GetCurrentProcessId() );
	}
	SetACL();
}

void Hook::ClearThreads()
{
	m_ThreadIDS.clear();
}

void Hook::AddThread( DWORD dwThreadID )
{
	m_ThreadIDS.push_back( dwThreadID );
}

void Hook::RemoveThread( DWORD dwThreadID )
{
	m_ThreadIDS.remove( dwThreadID );
}

void Hook::AddAllThreads( DWORD dwOwnerPID )
{
	HANDLE hThreadSnap = INVALID_HANDLE_VALUE; 
	THREADENTRY32 te32; 

	hThreadSnap = CreateToolhelp32Snapshot( TH32CS_SNAPTHREAD, 0 ); 
	if( hThreadSnap == INVALID_HANDLE_VALUE ) 
		return; 

	te32.dwSize = sizeof(THREADENTRY32 ); 

	if( !Thread32First( hThreadSnap, &te32 ) ) 
	{
		CloseHandle( hThreadSnap );
		return;
	}

	do 
	{ 
		if( te32.th32OwnerProcessID == dwOwnerPID )
		{
			AddThread( te32.th32ThreadID );
		}
		
	} while( Thread32Next(hThreadSnap, &te32 ) );

	CloseHandle( hThreadSnap );
	return;
}

void Hook::SetACL()
{
	unsigned int count;
	ULONG ACLEntries[MAX_ACE_COUNT];
	std::list<DWORD>::iterator it;
	
	m_ThreadIDS.unique();

	count = 0;
	for ( it=m_ThreadIDS.begin() ; it != m_ThreadIDS.end(); it++ )
	{
		ACLEntries[count++] = *it;
	}

	NTSTATUS rc = LhSetInclusiveACL(ACLEntries, count, m_hHook);
	if (!SUCCEEDED(rc)) {
	}

}

void Hook::ClearACL()
{
	NTSTATUS rc = LhSetInclusiveACL(NULL, 0, m_hHook);
}

void Hook::ActivateHooks()
{
	if( m_bHooksActivated )
		return;

	size_t i;
	for( i = 0; i < g_HookRegistry.size(); i++ )
		g_HookRegistry[i].SetACL();

	m_bHooksActivated = true;
}

void Hook::DeactivateHooks()
{
	if( !m_bHooksActivated )
		return;

	size_t i;
	for( i = 0; i < g_HookRegistry.size(); i++ )
		g_HookRegistry[i].ClearACL();

	m_bHooksActivated = false;
}

void Hook::AddActiveHooksToThread( DWORD dwThreadID )
{
	size_t i;
	for( i = 0; i < g_HookRegistry.size(); i++ )
	{
		g_HookRegistry[i].AddThread( dwThreadID );
		if( m_bHooksActivated )
			g_HookRegistry[i].SetACL();
	}
}

void Hook::RemoveActiveHooksFromThread( DWORD dwThreadID )
{
	size_t i;
	for( i = 0; i < g_HookRegistry.size(); i++ )
	{
		g_HookRegistry[i].RemoveThread( dwThreadID );
		if( m_bHooksActivated )
			g_HookRegistry[i].SetACL();
	}
}

void Hook::ClearHooks()
{
	g_HookRegistry.clear();
}


HANDLE g_hChildStd_IN_Rd = NULL;
HANDLE g_hChildStd_IN_Wr = NULL;
HANDLE g_hChildStd_OUT_Rd = NULL;
HANDLE g_hChildStd_OUT_Wr = NULL;

// Based on example from msdn: http://msdn.microsoft.com/en-us/library/windows/desktop/ms682499(v=vs.85).aspx
bool CreateChildProcess( int iType, int iFunction )
{ 
	wchar_t szCmdline[MAX_PATH];
	swprintf_s(szCmdline, MAX_PATH, L"gethookaddress.exe %d %d\0", iType, iFunction);
	PROCESS_INFORMATION piProcInfo; 
	STARTUPINFO siStartInfo;
	BOOL bSuccess = FALSE; 
 
	ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );

	ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
	siStartInfo.cb = sizeof(STARTUPINFO); 
	siStartInfo.hStdError = g_hChildStd_OUT_Wr;
	siStartInfo.hStdOutput = g_hChildStd_OUT_Wr;
	siStartInfo.hStdInput = g_hChildStd_IN_Rd;
	siStartInfo.dwFlags |= STARTF_USESTDHANDLES;
 
	bSuccess = CreateProcess(NULL, 
		szCmdline,     // command line 
		NULL,          // process security attributes 
		NULL,          // primary thread security attributes 
		TRUE,          // handles are inherited 
		0,             // creation flags 
		NULL,          // use parent's environment 
		NULL,          // use parent's current directory 
		&siStartInfo,  // STARTUPINFO pointer 
		&piProcInfo);  // receives PROCESS_INFORMATION 
   
	if ( ! bSuccess ) 
		return false;
	else 
	{
		CloseHandle(piProcInfo.hProcess);
		CloseHandle(piProcInfo.hThread);
	}
	return true;
}

uintptr_t GetHookingAddress( int iType, int iFunction )
{
	SECURITY_ATTRIBUTES saAttr; 
	saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
	saAttr.bInheritHandle = TRUE; 
	saAttr.lpSecurityDescriptor = NULL; 

	if( !CreatePipe(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0) )
	{
#ifdef _DEBUG
		printf("Failed to create pipe 1 (error: %d)\n", GetLastError());
#endif // _DEBUG
		return NULL;
	}
	
	if( !SetHandleInformation(g_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0) )
	{
#ifdef _DEBUG
		printf("Failed to set handle information 1\n");
#endif // _DEBUG
		return NULL;
	}

	if( !CreatePipe(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0) ) 
	{
#ifdef _DEBUG
		printf("Failed to create pipe 2 (error: %d)\n", GetLastError());
#endif // _DEBUG
		return NULL;
	}

	if( !SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0) )
	{
#ifdef _DEBUG
		printf("Failed to set handle information 2\n");
#endif // _DEBUG
		return NULL;
	}

	if( !CreateChildProcess( iType, iFunction ) )
	{
#ifdef _DEBUG
		printf("Failed to create hook process\n");
#endif // _DEBUG
		return NULL;
	}

	if( !CloseHandle(g_hChildStd_OUT_Wr) ) 
	{
#ifdef _DEBUG
		printf("Failed to close pipe\n");
#endif // _DEBUG
		return NULL;
	}

	DWORD dwRead;
	uintptr_t addr = 0;
	ReadFile( g_hChildStd_OUT_Rd, &addr, sizeof(uintptr_t), &dwRead, NULL);
	if( dwRead  != sizeof(uintptr_t) || addr == 0 )
	{
#ifdef _DEBUG
		printf("Invalid addr %X (%d/%d)\n", addr, dwRead, sizeof(uintptr_t));
#endif // _DEBUG
		return NULL;
	}
	return  addr;
}