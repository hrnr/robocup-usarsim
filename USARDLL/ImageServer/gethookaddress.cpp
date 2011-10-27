/* Small helper process. Retrieves a function address from the specified
 * DirectX device or swawpchain. The resulting address is written to the
 * parent process.
 * 
 * This is separate process because doing this in the same process as Unreal Engine
 * causes problems. 
 */

#include "gethookaddress_shared.h"
#include <stdio.h>

#include <d3dx9.h>
#include <d3d10_1.h>
#include <d3d11.h>

#define WINDOW_WIDTH 640
#define WINDOW_HEIGHT 480
#define WINDOW_CLASSNAME L"TempWindowClass"

HWND g_hWnd = NULL;
WNDCLASSEX wcex;

bool CreateTempWindow( HINSTANCE hInstance )
{
	// Register class
    wcex.cbSize = sizeof( WNDCLASSEX );
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = DefWindowProc;
    wcex.cbClsExtra = 0;
    wcex.cbWndExtra = 0;
    wcex.hInstance = hInstance;
    wcex.hIcon = NULL;
    wcex.hCursor = LoadCursor( NULL, IDC_ARROW );
    wcex.hbrBackground = ( HBRUSH )( COLOR_WINDOW + 1 );
    wcex.lpszMenuName = NULL;
    wcex.lpszClassName = WINDOW_CLASSNAME;
    wcex.hIconSm = NULL;
    if( !RegisterClassEx( &wcex ) )
        return false;

    // Create window
    RECT rc = { 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT };
    AdjustWindowRect( &rc, WS_OVERLAPPEDWINDOW, FALSE );
    g_hWnd = CreateWindow( WINDOW_CLASSNAME, L"TempWindow", WS_OVERLAPPEDWINDOW,
                           CW_USEDEFAULT, CW_USEDEFAULT, rc.right - rc.left, rc.bottom - rc.top, NULL, NULL, hInstance,
                           NULL );
    if( !g_hWnd )
        return false;

    //ShowWindow( g_hWnd, 1 );
	return true;
}

void DestroyTempWindow()
{
	if( g_hWnd != NULL )
		DestroyWindow( g_hWnd );

	UnregisterClass( WINDOW_CLASSNAME, wcex.hInstance );
}

// ============================================== DIRECTX9 ==============================================
IDirect3D9 *g_pD3D = NULL;
IDirect3DDevice9 *g_pd3dDevice = NULL;
bool DX9_Init3d()
{
	// Create the D3D object, which is needed to create the D3DDevice.
	if( NULL == ( g_pD3D = Direct3DCreate9( D3D_SDK_VERSION ) ) )
	{
		printf("fail Direct3DCreate9\n");
		return false;
	}

    D3DDISPLAYMODE d3ddm;
	HRESULT hRes = g_pD3D->GetAdapterDisplayMode(D3DADAPTER_DEFAULT, &d3ddm );
    if ( FAILED(hRes) )  
		return false;

	// Set up the structure used to create the D3DDevice. 
	D3DPRESENT_PARAMETERS d3dpp;
	ZeroMemory( &d3dpp, sizeof( d3dpp ) );
	d3dpp.Windowed = TRUE;
	d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
	d3dpp.BackBufferWidth = WINDOW_WIDTH;
	d3dpp.BackBufferHeight = WINDOW_HEIGHT;
	d3dpp.BackBufferFormat = d3ddm.Format;

	// Create the Direct3D device. 
	if( FAILED( g_pD3D->CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, g_hWnd,
									  D3DCREATE_SOFTWARE_VERTEXPROCESSING ,
									  &d3dpp, &g_pd3dDevice ) ) )
	{
		printf("fail CreateDevice %d\n", g_pd3dDevice);
		g_pD3D->Release();
		return false;
	}

	return true;
}

void DX9_Shutdown3d()
{
	if( g_pd3dDevice != NULL )
		g_pd3dDevice->Release();

	if( g_pD3D != NULL )
		g_pD3D->Release();
}

void* DX9_GetFunction( int iFunction )
{
	if( !DX9_Init3d() )
		return NULL;
	void* pFunction =(*reinterpret_cast<void***>(g_pd3dDevice))[iFunction];
	DX9_Shutdown3d();
	return pFunction;
}

// ============================================== DIRECTX10 ==============================================
D3D10_DRIVER_TYPE g_driverType = D3D10_DRIVER_TYPE_NULL;
ID3D10Device* g_pd3dDeviceDX10 = NULL;
IDXGISwapChain* g_pSwapChainDX10 = NULL;

bool DX10_Init3d()
{
	HRESULT hr = S_OK;

    RECT rc;
    GetClientRect( g_hWnd, &rc );
    UINT width = rc.right - rc.left;
    UINT height = rc.bottom - rc.top;

    UINT createDeviceFlags = 0;

    D3D10_DRIVER_TYPE driverTypes[] =
    {
        D3D10_DRIVER_TYPE_HARDWARE,
        D3D10_DRIVER_TYPE_REFERENCE,
    };
    UINT numDriverTypes = sizeof( driverTypes ) / sizeof( driverTypes[0] );

    DXGI_SWAP_CHAIN_DESC sd;
    ZeroMemory( &sd, sizeof( sd ) );
    sd.BufferCount = 1;
    sd.BufferDesc.Width = width;
    sd.BufferDesc.Height = height;
    sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    sd.BufferDesc.RefreshRate.Numerator = 60;
    sd.BufferDesc.RefreshRate.Denominator = 1;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    sd.OutputWindow = g_hWnd;
    sd.SampleDesc.Count = 1;
    sd.SampleDesc.Quality = 0;
    sd.Windowed = TRUE;

    for( UINT driverTypeIndex = 0; driverTypeIndex < numDriverTypes; driverTypeIndex++ )
    {
        g_driverType = driverTypes[driverTypeIndex];
        hr = D3D10CreateDeviceAndSwapChain( NULL, g_driverType, NULL, createDeviceFlags,
                                            D3D10_SDK_VERSION, &sd, &g_pSwapChainDX10, &g_pd3dDeviceDX10 );
        if( SUCCEEDED( hr ) )
            break;
    }
    if( FAILED( hr ) )
        return false;

	return true;
}

void DX10_Shutdown3d()
{
	if( g_pd3dDeviceDX10 )
		g_pd3dDeviceDX10->Release();
	if( g_pSwapChainDX10 )
		g_pSwapChainDX10->Release();
}

void* DX10_GetFunction( int iFunction )
{
	if( !DX10_Init3d() )
		return NULL;

	void* pFunction =(*reinterpret_cast<void***>(g_pSwapChainDX10))[iFunction];
	DX10_Shutdown3d();
	return pFunction;
}

// ============================================== DIRECTX11 ==============================================
D3D_DRIVER_TYPE         g_driverTypeDX11 = D3D_DRIVER_TYPE_NULL;
D3D_FEATURE_LEVEL       g_featureLevelDX11 = D3D_FEATURE_LEVEL_11_0;
ID3D11Device*			g_pd3dDeviceDX11 = NULL;
ID3D11DeviceContext*    g_pImmediateContextDX11 = NULL;
IDXGISwapChain*			g_pSwapChainDX11 = NULL;

bool DX11_Init3d()
{
    HRESULT hr = S_OK;

    RECT rc;
    GetClientRect( g_hWnd, &rc );
    UINT width = rc.right - rc.left;
    UINT height = rc.bottom - rc.top;

    UINT createDeviceFlags = 0;

    D3D_DRIVER_TYPE driverTypes[] =
    {
        D3D_DRIVER_TYPE_HARDWARE,
        D3D_DRIVER_TYPE_WARP,
        D3D_DRIVER_TYPE_REFERENCE,
    };
    UINT numDriverTypes = ARRAYSIZE( driverTypes );

    D3D_FEATURE_LEVEL featureLevels[] =
    {
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
    };
	UINT numFeatureLevels = ARRAYSIZE( featureLevels );

    DXGI_SWAP_CHAIN_DESC sd;
    ZeroMemory( &sd, sizeof( sd ) );
    sd.BufferCount = 1;
    sd.BufferDesc.Width = width;
    sd.BufferDesc.Height = height;
    sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    sd.BufferDesc.RefreshRate.Numerator = 60;
    sd.BufferDesc.RefreshRate.Denominator = 1;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    sd.OutputWindow = g_hWnd;
    sd.SampleDesc.Count = 1;
    sd.SampleDesc.Quality = 0;
    sd.Windowed = TRUE;

    for( UINT driverTypeIndex = 0; driverTypeIndex < numDriverTypes; driverTypeIndex++ )
    {
        g_driverTypeDX11 = driverTypes[driverTypeIndex];
        hr = D3D11CreateDeviceAndSwapChain( NULL, g_driverTypeDX11, NULL, createDeviceFlags, featureLevels, numFeatureLevels,
                                            D3D11_SDK_VERSION, &sd, &g_pSwapChainDX11, &g_pd3dDeviceDX11, &g_featureLevelDX11, &g_pImmediateContextDX11 );
        if( SUCCEEDED( hr ) )
            break;
    }
    if( FAILED( hr ) )
        return false;

	return true;
}

void DX11_Shutdown3d()
{
	if( g_pd3dDeviceDX11 )
		g_pd3dDeviceDX11->Release();
	if( g_pSwapChainDX11 )
		g_pSwapChainDX11->Release();
}

void* DX11_GetFunction( int iFunction )
{
	if( !DX11_Init3d() )
		return NULL;

	void* pFunction =(*reinterpret_cast<void***>(g_pSwapChainDX11))[iFunction];
	DX11_Shutdown3d();
	return pFunction;
}

// ============================================== MAIN ==============================================
int main( int argc, char *argv[] )
{
	if( argc < 3 )
	{
		printf(	"gethookaddress requires two argument (type) (function)\n"
				"Where type is:\n"
				"\t0 - DirectX9 Device\n"
				"\t1 - DirectX10 SwapChain\n"
				"\t2 - DirectX11 SwapChain\n");
		return -1;
	}
	int iType = atoi( argv[1] );
	int iFunction = atoi( argv[2] );

	HINSTANCE hInstance = (HINSTANCE)GetModuleHandle(NULL); 

	if( !CreateTempWindow(hInstance) )
	{
		printf("Failed to create window\n");
		return 0;
	}

	void* pFunction = NULL;
	switch( iType )
	{
	case GHA_DX9_DEVICE:
		pFunction = DX9_GetFunction( iFunction );
		break;
	case GHA_DX10_SWAPCHAIN:
		pFunction = DX10_GetFunction( iFunction );
		break;
	case GHA_DX11_SWAPCHAIN:
		pFunction = DX11_GetFunction( iFunction );
		break;
	default:
		printf("Unknown type %d\n", iType);
		break;
	}

	// Write function to parent 
	HANDLE hStdin, hStdout; 
	hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 
	hStdin = GetStdHandle(STD_INPUT_HANDLE); 

	if ( (hStdout == INVALID_HANDLE_VALUE) || (hStdin == INVALID_HANDLE_VALUE) )
	{
		DestroyTempWindow();
		return -1;
	}

	uintptr_t addr = (uintptr_t)pFunction;
	DWORD dwWritten;

	if( !pFunction )
	{
		WriteFile(hStdout, &addr, sizeof(uintptr_t), &dwWritten, NULL); 
		printf("Failed to retrieve function\n");
		DestroyTempWindow();
		return -1;
	}

	WriteFile(hStdout, &addr, sizeof(uintptr_t), &dwWritten, NULL); 
	if( dwWritten != sizeof(uintptr_t) )
	{
		printf("Failed to write pointer (%d/%d)\n", dwWritten, sizeof(uintptr_t));
	}
	return 0;
}