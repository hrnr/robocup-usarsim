#include "dx11hook.h"
#include "hooking.h"
#include "ImageServer.h"

#include <d3dx11.h>
#include <stdio.h>

ID3D11Texture2D*	g_pBackBufferCopy11;

void DX11_GetBackBuffer( IDXGISwapChain *pSwapChain ){
	HRESULT hResult;
	ID3D11Texture2D* pBackBuffer;
	D3D11_TEXTURE2D_DESC surfaceDescription;
	D3D11_MAPPED_SUBRESOURCE lockedRect;
	ID3D11Device *pDevice;
	ID3D11DeviceContext *pDeviceContext;

	// Get device
	pSwapChain->GetDevice( __uuidof( ID3D11Device ), reinterpret_cast<void**>(&pDevice) );
	if( !pDevice )
	{
		printf("DX11_GetBackBuffer: No device\n");
		return;
	}

	// Get immediate context
	pDevice->GetImmediateContext( &pDeviceContext );

	// Get back buffer
	hResult = pSwapChain->GetBuffer(0, __uuidof(pBackBuffer), reinterpret_cast<void**>(&pBackBuffer));
	if(hResult != S_OK){
		MessageBox(NULL, L"Could not capture back buffer (DX11)", L"USARSim Image Server", MB_OK);
		return;
	}
	
	// Change surface description to be staging buffer
	pBackBuffer->GetDesc(&surfaceDescription);
	surfaceDescription.MipLevels = 1;
    surfaceDescription.ArraySize = 1;
    surfaceDescription.SampleDesc.Count = 1;
    surfaceDescription.Usage = D3D11_USAGE_STAGING;
    surfaceDescription.BindFlags = 0;
	surfaceDescription.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    surfaceDescription.MiscFlags = 0;

	// Create staging buffer and copy backbuffer into it
	hResult = pDevice->CreateTexture2D(&surfaceDescription, NULL, &g_pBackBufferCopy11);
	if(FAILED(hResult)) MessageBox(NULL, L"CreateTexture2D failed", L"USARSim Image Server", MB_OK);
	pDeviceContext->CopyResource((ID3D11Resource *)g_pBackBufferCopy11, (ID3D11Resource *)pBackBuffer);
	pBackBuffer->Release();
	

	// Lock the back buffer copy
	pDeviceContext->Map( g_pBackBufferCopy11, 0, D3D11_MAP_READ , 0, &lockedRect );
	if(hResult != S_OK){
		MessageBox(NULL, L"Could not lock backbuffer copy", L"USARSim Image Server", MB_OK);
		g_pBackBufferCopy11->Release();
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

	// Signal that new frame was captured
	if( g_bCaptureImageOnRequest )
	{
		InterlockedExchange( &g_lRequestFlag, FALSE );
		g_pRequestEvent->pulseEvent();
	}

	// Clean up old buffer
	FreeImage_Unload( fiImageOld );

	// Unlock the back buffer
	pDeviceContext->Unmap( g_pBackBufferCopy11, 0 );
	g_pBackBufferCopy11->Release();
	g_pBackBufferCopy11 = NULL;
}

typedef HRESULT (WINAPI* PresentDX11_t)( IDXGISwapChain *pSwapChain, UINT SyncInterval, UINT Flags );
PresentDX11_t g_pPresentDX11 = NULL;

HRESULT WINAPI PresentHookDX11( IDXGISwapChain *pSwapChain, UINT SyncInterval, UINT Flags )
{
	if( g_bHasClientsConnected )
	{
		if( !g_bCaptureImageOnRequest || InterlockedCompareExchange( &g_lRequestFlag, FALSE, FALSE ) ) 
		{
			if( g_lCurrentFrame >= g_lFrameSkip )
			{
				DX11_GetBackBuffer( pSwapChain );
				g_lCurrentFrame = 0;
			} else {
				g_lCurrentFrame++;
			}
		}
	}

	HRESULT rc = g_pPresentDX11( pSwapChain, SyncInterval, Flags );
	return rc;
}

extern "C" IMAGESERVERDLL_API void HookDirectX11()
{
	// This hooks the same function as dx10.
#if 0
	uintptr_t addr = GetHookingAddress( GHA_DX11_SWAPCHAIN, 8 );
	if( addr )
	{
		InstallHook( PresentHookDX11, g_pPresentDX11, PresentDX11_t, addr );
#ifdef _DEBUG
		printf("HookDirectX11: Hooked Present (%X)\n", addr );
#endif // _DEBUG
	}
	else
	{
#ifdef _DEBUG
		printf("HookDirectX11: Failed to retrieve function address\n" );
#endif // _DEBUG
	}
#endif // 0
}