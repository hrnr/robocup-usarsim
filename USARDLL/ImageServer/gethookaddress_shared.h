#ifndef GETHOOKADDRESS_SHARED_H
#define GETHOOKADDRESS_SHARED_H

enum GetHookAddress_Type {
	GHA_DX9_DEVICE = 0, // IDirect3DDevice9
	GHA_DX10_SWAPCHAIN, // IDXGISwapChain
	GHA_DX11_SWAPCHAIN, // IDXGISwapChain
};

#endif // GETHOOKADDRESS_SHARED_H