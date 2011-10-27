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

// Create a child process that uses the previously created pipes for STDIN and STDOUT.
bool CreateChildProcess( int iType, int iFunction )
{ 
	wchar_t szCmdline[MAX_PATH];
	swprintf_s(szCmdline, MAX_PATH, L"gethookaddress.exe %d %d\0", iType, iFunction);
	PROCESS_INFORMATION piProcInfo; 
	STARTUPINFO siStartInfo;
	BOOL bSuccess = FALSE; 
 
	// Set up members of the PROCESS_INFORMATION structure. 
	ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );
 
	// Set up members of the STARTUPINFO structure. 
	// This structure specifies the STDIN and STDOUT handles for redirection.
	ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
	siStartInfo.cb = sizeof(STARTUPINFO); 
	siStartInfo.hStdError = g_hChildStd_OUT_Wr;
	siStartInfo.hStdOutput = g_hChildStd_OUT_Wr;
	siStartInfo.hStdInput = g_hChildStd_IN_Rd;
	siStartInfo.dwFlags |= STARTF_USESTDHANDLES;
 
	// Create the child process. 
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
   
	// If an error occurs, exit the application. 
	if ( ! bSuccess ) 
		return false;
	else 
	{
		// Close handles to the child process and its primary thread.
		// Some applications might keep these handles to monitor the status
		// of the child process, for example. 
		CloseHandle(piProcInfo.hProcess);
		CloseHandle(piProcInfo.hThread);
	}
	return true;
}

uintptr_t GetHookingAddress( int iType, int iFunction )
{
	SECURITY_ATTRIBUTES saAttr; 
 
	// Set the bInheritHandle flag so pipe handles are inherited. 
	saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
	saAttr.bInheritHandle = TRUE; 
	saAttr.lpSecurityDescriptor = NULL; 

	// Create a pipe for the child process's STDOUT. 
	if( !CreatePipe(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0) ) 
		return -1;

	// Ensure the read handle to the pipe for STDOUT is not inherited.
	if( !SetHandleInformation(g_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0) )
		return -1;

	// Create a pipe for the child process's STDIN. 
	if( !CreatePipe(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0) ) 
		return -1;

	// Ensure the write handle to the pipe for STDIN is not inherited. 
	if( !SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0) )
		return -1;

	if( !CreateChildProcess( iType, iFunction ) )
	{
#ifdef _DEBUG
		printf("Failed to create hook process\n");
#endif // _DEBUG
		return -1;
	}

	if( !CloseHandle(g_hChildStd_OUT_Wr) ) 
		return -1;

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