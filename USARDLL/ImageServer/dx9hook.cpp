#include "dx9hook.h"
#include "hooking.h"
#include "ImageServer.h"

#include <windows.h>
#include <d3dx9.h>
#include <stdio.h>

IDirect3DSurface9* g_pBackBufferCopy9 = NULL;

// Private function used to save the backbuffer
void DX9_GetBackBuffer( LPDIRECT3DDEVICE9 pDevice )
{
	HRESULT hResult;
	IDirect3DSurface9* pBackBuffer;
	D3DSURFACE_DESC surfaceDescription;
	D3DLOCKED_RECT lockedRect;

	// Get back buffer
	hResult = pDevice->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, &pBackBuffer);
	if(hResult != D3D_OK){
		MessageBox(NULL, L"Could not capture back buffer", L"USARSim Image Server", MB_OK);
		return;
	}
	
	hResult = pBackBuffer->GetDesc(&surfaceDescription);
	if(hResult != D3D_OK){
		MessageBox(NULL, L"Could not get description of the back buffer", L"USARSim Image Server", MB_OK);
		pBackBuffer->Release();
	}

	hResult = pDevice->CreateOffscreenPlainSurface(surfaceDescription.Width, surfaceDescription.Height, surfaceDescription.Format, D3DPOOL_SYSTEMMEM, &g_pBackBufferCopy9, NULL);
	if(FAILED(hResult)) MessageBox(NULL, L"CreateOffscreenPlainSurface failed", L"USARSim Image Server", MB_OK);
	hResult = pDevice->GetRenderTargetData(pBackBuffer, g_pBackBufferCopy9);
	if ( FAILED(hResult) ) 
	{
		// This fails if you run in fullscreen mode and alt tab to your desktop. The message is rather annoying, so disabled it.
		//MessageBox(NULL, L"GetRenderTargetData failed", L"USARSim Image Server", MB_OK);
		pBackBuffer->Release();
		g_pBackBufferCopy9->Release();
		return;
	}
	pBackBuffer->Release();

	// Lock the back buffer copy
	hResult = g_pBackBufferCopy9->LockRect(&lockedRect, NULL, D3DLOCK_READONLY);
	if(hResult != D3D_OK){
		MessageBox(NULL, L"Could not lock backbuffer copy", L"USARSim Image Server", MB_OK);
		g_pBackBufferCopy9->Release();
	}

	// Load image in FreeImage structure
	FIBITMAP * fiImageOld;
	FIBITMAP * fiImageNew = FreeImage_ConvertFromRawBits((BYTE *)lockedRect.pBits, 
									surfaceDescription.Width, surfaceDescription.Height, 
									lockedRect.Pitch, 8*DX9_RAW_VIDEO_BPP,
									FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, true);
	// Swap global image pointer and trigger image event
	EnterCriticalSection( &g_CriticalSection );
	{
		fiImageOld = g_fiImage;
		g_fiImage = fiImageNew;
	}
	LeaveCriticalSection( &g_CriticalSection );

	// Signal that new frame was captured
	if( g_bCaptureImageOnRequest )
	{
		InterlockedExchange( &g_lRequestFlag, FALSE );
		g_pRequestEvent->pulseEvent();
	}

	// Clean up old buffer
	FreeImage_Unload( fiImageOld );

	// Unlock the back buffer
	hResult = g_pBackBufferCopy9->UnlockRect();
	if(hResult != D3D_OK){
		MessageBox(NULL, L"Could not unlock backbuffer copy", L"USARSim Image Server", MB_OK);
		pBackBuffer->Release();
	}	

	g_pBackBufferCopy9->Release();
	g_pBackBufferCopy9 = NULL;
}

// Function hook types
typedef HRESULT (WINAPI* CreateDevice_t)( LPDIRECT3D9, UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow,
										 DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters,
										 IDirect3DDevice9** ppReturnedDeviceInterface);

typedef HRESULT (WINAPI* CreateDeviceEx_t)( LPDIRECT3D9, UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,
										   DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, 
										   D3DDISPLAYMODEEX* pFullscreenDisplayMode, IDirect3DDevice9Ex** ppReturnedDeviceInterface);

typedef HRESULT (WINAPI* Present_t)(LPDIRECT3DDEVICE9 pDevice, CONST RECT* pSourceRect,CONST RECT* pDestRect,
									HWND hDestWindowOverride,CONST RGNDATA* pDirtyRegion );

typedef HRESULT (WINAPI* Reset_t)(LPDIRECT3DDEVICE9 pDevice, D3DPRESENT_PARAMETERS* pPresentationParameters);

typedef HRESULT (WINAPI* EndScene_t)(LPDIRECT3DDEVICE9 pDevice);

// Pointers to the original functions
CreateDevice_t g_pCreateDevice = NULL;
CreateDeviceEx_t g_pCreateDeviceEx = NULL;
Present_t g_pPresent = NULL;
Reset_t g_pReset = NULL;
EndScene_t g_pEndScene = NULL;

// Hooks
HRESULT WINAPI CreateDeviceHook( LPDIRECT3D9 pD3D, UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow,DWORD BehaviorFlags,
							D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DDevice9** ppReturnedDeviceInterface)
{
	return g_pCreateDevice( pD3D, Adapter, DeviceType, hFocusWindow, BehaviorFlags, pPresentationParameters, ppReturnedDeviceInterface );
}

HRESULT WINAPI CreateDeviceExHook( LPDIRECT3D9 pD3D, UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,D3DDISPLAYMODEEX* pFullscreenDisplayMode,IDirect3DDevice9Ex** ppReturnedDeviceInterface )
{
	return g_pCreateDeviceEx( pD3D, Adapter, DeviceType, hFocusWindow, BehaviorFlags, pPresentationParameters, pFullscreenDisplayMode, ppReturnedDeviceInterface );
}

HRESULT WINAPI PresentHook(LPDIRECT3DDEVICE9 pDevice, CONST RECT* pSourceRect,CONST RECT* pDestRect,HWND hDestWindowOverride,CONST RGNDATA* pDirtyRegion)
{
	if( g_bHasClientsConnected )
	{
		if( !g_bCaptureImageOnRequest || InterlockedCompareExchange( &g_lRequestFlag, FALSE, FALSE ) ) 
		{
			if( g_lCurrentFrame >= g_lFrameSkip )
			{
				DX9_GetBackBuffer( pDevice );
				g_lCurrentFrame = 0;
			} else {
				g_lCurrentFrame++;
			}
		}
	}

	HRESULT rc = g_pPresent( pDevice, pSourceRect, pDestRect, hDestWindowOverride, pDirtyRegion );
	return rc;
}

HRESULT WINAPI ResetHook(LPDIRECT3DDEVICE9 pDevice, D3DPRESENT_PARAMETERS* pPresentationParameters)
{
	HRESULT rc = g_pReset( pDevice, pPresentationParameters );
	return rc;
}

HRESULT WINAPI EndSceneHook( LPDIRECT3DDEVICE9 pDevice )
{
	HRESULT rc = g_pEndScene(pDevice);
	return rc;
}

// Installer for Create Device Hook
void InstallCreateDeviceHook()
{
	IDirect3D9 *pD3D;

	// Create the temporary D3D object
	if( NULL == ( pD3D = Direct3DCreate9( D3D_SDK_VERSION ) ) )
	{
#ifdef _DEBUG
		printf("InstallCreateDeviceHook: fail Direct3DCreate9\n");
#endif // _DEBUG
		return;
	}

	// Hook functions
	void* pCreateDevice = (*reinterpret_cast<void***>(pD3D))[12];
	void* pCreateDeviceEx = (*reinterpret_cast<void***>(pD3D))[16];
	InstallHook( CreateDeviceHook, g_pCreateDevice, CreateDevice_t, pCreateDevice );
	InstallHook( CreateDeviceExHook, g_pCreateDeviceEx, CreateDeviceEx_t, pCreateDeviceEx );

	// Release device
	pD3D->Release();
}

// Main function for hooking dx9
extern "C" IMAGESERVERDLL_API int HookDirectX9()
{
	uintptr_t addr = GetHookingAddress( GHA_DX9_DEVICE, 17 );
	if( addr == NULL )
	{
#ifdef _DEBUG
		printf("HookDirectX9: Failed to retrieve function address (%X)\n", addr );
#endif // _DEBUG
		return 0;
	}

	InstallHook( PresentHook, g_pPresent, Present_t, addr );
#ifdef _DEBUG
	printf("HookDirectX9: Hooked Present (%X)\n", addr );
#endif // _DEBUG
	return 1;
}