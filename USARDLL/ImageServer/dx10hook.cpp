#include "dx10hook.h"
#include "hooking.h"
#include "ImageServer.h"

#include <d3dx10.h>
#include <stdio.h>

ID3D10Texture2D*	g_pBackBufferCopy10;

void DX10_GetBackBuffer( IDXGISwapChain *pSwapChain ){
	HRESULT hResult;
	ID3D10Texture2D* pBackBuffer;
	D3D10_TEXTURE2D_DESC surfaceDescription;
	D3D10_MAPPED_TEXTURE2D lockedRect;
	ID3D10Device *pDevice;

	// Get device
	pSwapChain->GetDevice( __uuidof( ID3D10Device ), (void**)&pDevice );
	if( !pDevice )
	{
		printf("DX10_GetBackBuffer: No device\n");
		return;
	}
	
	// Get back buffer
	hResult = pSwapChain->GetBuffer(0, IID_ID3D10Texture2D, (LPVOID*)&(pBackBuffer));
	if(hResult != S_OK){
		MessageBox(NULL, L"Could not capture back buffer (DX10)", L"USARSim Image Server", MB_OK);
		return;
	}
	
	// Change surface description to be staging buffer
	pBackBuffer->GetDesc(&surfaceDescription);
	surfaceDescription.MipLevels = 1;
    surfaceDescription.ArraySize = 1;
    surfaceDescription.SampleDesc.Count = 1;
    surfaceDescription.Usage = D3D10_USAGE_STAGING;
    surfaceDescription.BindFlags = 0;
	surfaceDescription.CPUAccessFlags = D3D10_CPU_ACCESS_READ;
    surfaceDescription.MiscFlags = 0;

	// Create staging buffer and copy backbuffer into it
	hResult = pDevice->CreateTexture2D(&surfaceDescription, NULL, &g_pBackBufferCopy10);
	if(FAILED(hResult)) MessageBox(NULL, L"CreateTexture2D failed", L"USARSim Image Server", MB_OK);
	pDevice->CopyResource((ID3D10Resource *)g_pBackBufferCopy10, (ID3D10Resource *)pBackBuffer);
	pBackBuffer->Release();

	// Lock the back buffer copy
	hResult = g_pBackBufferCopy10->Map(0, D3D10_MAP_READ, NULL, &lockedRect);
	if(hResult != S_OK){
		MessageBox(NULL, L"Could not lock backbuffer copy", L"USARSim Image Server", MB_OK);
		g_pBackBufferCopy10->Release();
	}

	// Allocate old and new FreeImage structure
	FIBITMAP * fiImageOld;
	FIBITMAP * fiImageNew = FreeImage_Allocate(surfaceDescription.Width, surfaceDescription.Height, 
												24, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK);
	
	// Copy image to FreeImage structure
	if (fiImageNew != NULL) {
		BYTE *bits = (BYTE *)lockedRect.pData;
		for (int rows = surfaceDescription.Height - 1; rows >= 0; rows--) {
			BYTE *source = bits;
			BYTE *target = FreeImage_GetScanLine(fiImageNew, rows);
			
			for (int cols = 0; cols < (int)surfaceDescription.Width; cols++) {
				target[FI_RGBA_BLUE] = source[FI_RGBA_RED];
				target[FI_RGBA_GREEN] = source[FI_RGBA_GREEN];
				target[FI_RGBA_RED] = source[FI_RGBA_BLUE];
				
				target += 3;
				source += 4;
			}
			bits += lockedRect.RowPitch;
		}
	}

	// Swap global image pointer and trigger image event
	EnterCriticalSection( &g_CriticalSection );
	{
		fiImageOld = g_fiImage;
		g_fiImage = fiImageNew;
	}
	LeaveCriticalSection( &g_CriticalSection );

	if( g_bCaptureImageOnRequest )
	{
		// Signal that new frame was captured
		InterlockedExchange( &g_lRequestFlag, FALSE );
		g_pRequestEvent->pulseEvent();
	}

	// Clean up old buffer
	FreeImage_Unload( fiImageOld );

	// Unlock the back buffer
	g_pBackBufferCopy10->Unmap(0);
	g_pBackBufferCopy10->Release();
	g_pBackBufferCopy10 = NULL;
}

typedef HRESULT (WINAPI* PresentDX10_t)( IDXGISwapChain *pSwapChain, UINT SyncInterval, UINT Flags );
PresentDX10_t g_pPresentDX10 = NULL;

extern void DX11_GetBackBuffer( IDXGISwapChain *pSwapChain );

HRESULT WINAPI PresentHookDX10( IDXGISwapChain *pSwapChain, UINT SyncInterval, UINT Flags )
{
	if( g_bHasClientsConnected )
	{
		if( !g_bCaptureImageOnRequest || InterlockedCompareExchange( &g_lRequestFlag, FALSE, FALSE ) ) 
		{
			if( g_lCurrentFrame >= g_lFrameSkip )
			{
				// Get device
				ID3D10Device *pDevice;
				pSwapChain->GetDevice( __uuidof( ID3D10Device ), reinterpret_cast<void**>(&pDevice) );
				if( !pDevice )
				{
					// Probably dx11
					DX11_GetBackBuffer( pSwapChain );
				}
				else
				{
					DX10_GetBackBuffer( pSwapChain );
				}

				g_lCurrentFrame = 0;
			} else {
				g_lCurrentFrame++;
			}
		}
	}
	
	HRESULT rc = g_pPresentDX10( pSwapChain, SyncInterval, Flags );
	return rc;
}

extern "C" IMAGESERVERDLL_API void HookDirectX10()
{
	uintptr_t addr = GetHookingAddress( GHA_DX10_SWAPCHAIN, 8 );
	if( addr )
	{
		InstallHook( PresentHookDX10, g_pPresentDX10, PresentDX10_t, addr );
#ifdef _DEBUG
		printf("HookDirectX10: Hooked Present (%X)\n", addr );
#endif // _DEBUG
	}
	else
	{
#ifdef _DEBUG
		printf("HookDirectX10: Failed to retrieve function address\n" );
#endif // _DEBUG
	}
}