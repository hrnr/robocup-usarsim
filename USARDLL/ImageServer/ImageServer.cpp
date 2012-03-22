// ImageServer.cpp : Defines the exported functions for the DLL application.

#include <winsock2.h>
#include "ImageServer.h"
#include <stdio.h>
#include <process.h>
#include "dx9hook.h"
#include "dx10hook.h"
#include "dx11hook.h"

#pragma comment(lib, "Ws2_32.lib")
#pragma comment(lib, "FreeImage.lib")

class Event
{
public:
    Event ()
    {
        // start in non-signaled state (red light)
        // auto reset after every Wait
        _handle = CreateEvent (0, FALSE, FALSE, 0);
    }

    ~Event ()
    {
        CloseHandle (_handle);
    }

    // put into signaled state
    void Release () { SetEvent (_handle); }
    void Wait ()
    {
        // Wait until event is in signaled (green) state
        WaitForSingleObject (_handle, INFINITE);
    }
    operator HANDLE () { return _handle; }

public:
    HANDLE _handle;
};

static bool g_bImageServerRunning = false;
bool g_bHasClientsConnected = false;
static HANDLE g_hServerThread;
static Event g_hServerStopEvent;

SimEvent *g_pRequestEvent = NULL;
LONG g_lRequestFlag = FALSE;
FIBITMAP *g_fiImage = NULL;
CRITICAL_SECTION g_CriticalSection;

// Global server constants
int g_nListenPort = 5003;
bool g_bLegacy = false;
long g_lFrameSkip = 1;
long g_lCurrentFrame = 0;
int g_iImageType = 0;
bool g_bCaptureImageOnRequest = false;

// Display an error message if FreeImage fails for some reason
void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char *message) 
{
	wchar_t errmsg[1024];
	
	if(fif != FIF_UNKNOWN) {
		swprintf_s(errmsg, 1024, L"FreeImage: %s Format, %s", FreeImage_GetFormatFromFIF(fif), message);
	} else { 
		swprintf_s(errmsg, 1024, L"FreeImage: %s", message);
	}	

	MessageBox(NULL, errmsg, L"USARSim Image Server", MB_OK);
}

// Convert from image type to JPEG compression
inline int convertToJpegFlag(int flag) 
{
	switch (flag)
	{
		case 1: return JPEG_QUALITYSUPERB;
		case 2: return JPEG_QUALITYGOOD;
		case 3: return JPEG_QUALITYNORMAL;
		case 4: return JPEG_QUALITYAVERAGE;
		case 5: return JPEG_QUALITYBAD;
		default: return JPEG_QUALITYGOOD;
	}
}

// Takes an image from the frame buffer and compresses it
int writeFrame(FIMEMORY *fiBuffer, FIBITMAP *fiImage, unsigned char imageType) 
{
	int errStatus = 1;
	u_short imageWidth, imageHeight;

	unsigned width, height, pitch, line;
	BYTE *bits;

	// Package image using correct compression
	switch(imageType) {
	case 0: // Send a raw frame
		// Get image characteristics
		width = FreeImage_GetWidth(fiImage);
		height = FreeImage_GetHeight(fiImage);
		pitch = FreeImage_GetPitch(fiImage);
		line = FreeImage_GetLine(fiImage);

		// Write out width and height
		errStatus = FreeImage_SeekMemory(fiBuffer, 0, SEEK_SET);
		if (errStatus != 1) break;

		imageWidth = htons(width);
		errStatus = FreeImage_WriteMemory( &imageWidth, 2, 1, fiBuffer );
		if (errStatus != 1) break;
		
		imageHeight = htons(height);
		errStatus = FreeImage_WriteMemory( &imageHeight, 2, 1, fiBuffer );
		if (errStatus != 1) break;

		// Write out image (convert the bitmap to raw bits, top-left pixel first)
		bits = (BYTE*)malloc(height * pitch);
		FreeImage_ConvertToRawBits(bits, fiImage, pitch, 24, 
			FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, TRUE);
		errStatus = FreeImage_WriteMemory( bits, height*pitch*sizeof(BYTE), 1, fiBuffer );
		free(bits);
		if (errStatus != 1) break;
		
		break;
	default: // Send a jpg frame
		errStatus = FreeImage_SeekMemory(fiBuffer, 0, SEEK_SET);
		if (errStatus != 1) break;

		errStatus = FreeImage_SaveToMemory(FIF_JPEG, fiImage, fiBuffer, convertToJpegFlag(imageType));
		if (errStatus != 1) break;
		break;
	}
	
	// Clean up and exit
	return errStatus;
}

// Sends an ImageServer frame
// [ImageType(1 byte) ImageSize(4 bytes) ImageData(n bytes)]
int transmitFrame(FIMEMORY *fiBuffer, SOCKET &clientSocket, unsigned char imageType) 
{
	int socketStatus;
	u_long imageSize;
	BYTE *fiBufferPtr = NULL;
	DWORD fiBufferSize = 0;

	// Get pointer to buffer memory
	socketStatus = FreeImage_AcquireMemory(fiBuffer, &fiBufferPtr, &fiBufferSize);
	if (socketStatus != 1) return SOCKET_ERROR;

	// Send the image type
	socketStatus = send(clientSocket, (char*)&imageType, 1, 0);
	if (socketStatus != 1) return socketStatus;

	// Send the image size (in bytes)
	imageSize = htonl((u_long)fiBufferSize);
	socketStatus = send(clientSocket, (char*)&imageSize, 4, 0);
	if (socketStatus != 4) return socketStatus;

	// Send the image
	socketStatus = send(clientSocket, (char*)fiBufferPtr, fiBufferSize, 0);
	if (socketStatus != fiBufferSize) return socketStatus;

	return socketStatus;
}

// Transmits a partial frame of imagery to the client
int sendPartialFrame(SOCKET &clientSocket,
			  unsigned int x, unsigned int y, unsigned int width, unsigned int height) 
{
	int status = 0;
	FIBITMAP *fiImage;
	FIBITMAP *fiImage24;
	FIMEMORY *fiBuffer;
	
	if( g_bCaptureImageOnRequest )
	{
		// Signal that a new frame is required and wait for frame
		InterlockedExchange( &g_lRequestFlag, TRUE );
		g_pRequestEvent->waitFor();
	}

	// Enter critical section for frame buffer from UT2004
	// and copy new raw image to local buffer
	EnterCriticalSection( &g_CriticalSection );
	{
		fiImage = FreeImage_Copy(g_fiImage, x, y, x + width, y + height);
	} 
	LeaveCriticalSection( &g_CriticalSection );

	// Convert new image to 24 bits
	fiImage24 = FreeImage_ConvertTo24Bits(fiImage);

	// Create memory reference
	fiBuffer = FreeImage_OpenMemory();
	
	// Convert a raw frame to a useful image
	status = writeFrame( fiBuffer, fiImage24, g_iImageType );
	if (status != 1) status = 0; // TODO: handle error here
	
	// Transmit frame over socket
	status = transmitFrame( fiBuffer, clientSocket, g_iImageType );

	// Delete memory references
	FreeImage_Unload( fiImage );
	FreeImage_Unload( fiImage24 );
	FreeImage_CloseMemory( fiBuffer );

	return status;
}
			
// Transmits an entire frame of imagery to the client
int sendFullFrame(SOCKET &clientSocket) 
{
	int status = 0;
	FIBITMAP *fiImage;
	FIMEMORY *fiBuffer;

	if( g_bCaptureImageOnRequest )
	{
		// Signal that a new frame is required and wait for frame
		InterlockedExchange( &g_lRequestFlag, TRUE );
		g_pRequestEvent->waitFor();
	}
	
	// Enter critical section for frame buffer from UT2004
	// and copy new raw image to local buffer
	EnterCriticalSection( &g_CriticalSection );
	{
		fiImage = FreeImage_ConvertTo24Bits(g_fiImage);
	} 
	LeaveCriticalSection( &g_CriticalSection );

	// Create memory reference
	fiBuffer = FreeImage_OpenMemory();

	// Convert a raw frame to a useful image
	status = writeFrame( fiBuffer, fiImage, g_iImageType );
	if (status != 1) status = 0; // TODO: handle error here
	
	// Transmit frame over socket
	status = transmitFrame( fiBuffer, clientSocket, g_iImageType );

	// Delete memory references
	FreeImage_Unload( fiImage );
	FreeImage_CloseMemory( fiBuffer );

	return status;
}

// This function is used to create a new thread to handle a new client
void HandleClientThreadFunction(void * parameters)
{
	SOCKET clientSocket = (SOCKET)parameters;
	
	char receivedByte;
	bool done = false;
	
	// Error reporting variables
	int status;
	wchar_t msg[1024];

	// If legacy mode, send an image at startup
	if (g_bLegacy) {
		status = sendFullFrame(clientSocket);
		if (status == SOCKET_ERROR) done = true;
	}
	
	// Loop until the socket has been closed (recv returned 0) or an error occured (recv returned SOCKET_ERROR)
	while( !done && g_bImageServerRunning )
	{
		// Get the first byte from the client		
		status = recv(clientSocket, &receivedByte, 1, 0);
		if(status != 1) break;

		// Determine the type of request from the first byte
		switch(receivedByte) 
		{

		case 'O':
			// Confirm that this is part of 'OK'
			if (recv(clientSocket, &receivedByte, sizeof(char), 0) != sizeof(char)) break;
			if (receivedByte != 'K') break;

			// Send entire frame to client
			status = sendFullFrame(clientSocket);
			if (status == SOCKET_ERROR) done = true;

			// Flush any queued requests
			break;

		case 'U':
			// Get requested rectangle bounds
			u_long reqX, reqY, reqWidth, reqHeight;
			if(recv(clientSocket, (char*)&reqX, sizeof(u_long), 0) != sizeof(u_long)) break;
			if(recv(clientSocket, (char*)&reqY, sizeof(u_long), 0) != sizeof(u_long)) break;
			if(recv(clientSocket, (char*)&reqWidth, sizeof(u_long), 0) != sizeof(u_long)) break;
			if(recv(clientSocket, (char*)&reqHeight, sizeof(u_long), 0) != sizeof(u_long)) break;

			// Send partial frame to client
			status = sendPartialFrame( clientSocket,
				ntohl(reqX), ntohl(reqY), ntohl(reqWidth), ntohl(reqHeight) );
			if (status == SOCKET_ERROR) done = true;

			// Flush any queued requests
			break;

		default:
			continue;
		}
	}

#if 1
	// Display an error message if the socket failed
	if(status == SOCKET_ERROR)
	{
		if(WSAGetLastError() != WSAECONNABORTED && WSAGetLastError() != WSAECONNRESET)
		{ 
			swprintf_s(msg, 1023, L"WinSock Error: %i", WSAGetLastError());
			MessageBox(NULL, msg, L"USARSim Image Server", MB_OK);
		}
	}
#endif // 0

	// Thread clean-up
	shutdown(clientSocket, SD_SEND);
	closesocket(clientSocket);
	_endthread();
}

// This is the main server thread function.  As clients connect to the server,
// the HandleClientThreadFunction is called (within a new thread) to handle the
// new client.
typedef struct ClientSocketInfo_t
{
	SOCKET clientSocket;
	HANDLE clientThread;
} ClientSocketInfo;
std::list<ClientSocketInfo_t> g_ClientHandleThreads;

unsigned __stdcall ServerThreadFunction(void * parameters)
{
	WSADATA winsock;
	SOCKET listenSocket, clientSocket;
	sockaddr_in socketAddress;
	BOOL bReuseAddr = TRUE;
	std::list<ClientSocketInfo_t>::iterator it1;
	int rc;
	FD_SET Reader;

	// Configure FreeImage error handler
	FreeImage_SetOutputMessage( FreeImageErrorHandler );
	
	// Setup WinSock
	if(WSAStartup (0x0202, &winsock) != 0) 
	{
		_endthreadex( 0 );
		return 0;
	}

	if (winsock.wVersion != 0x0202)
	{
		MessageBox(NULL, L"Incorrect Winsock version", L"USARSim Image Server", MB_OK);	
		WSACleanup();
		_endthreadex( 0 );
		return 0;
	}

	// Configure the socket for TCP
	listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(listenSocket == INVALID_SOCKET)
	{
		MessageBox(NULL, L"Socket failed", L"USARSim Image Server", MB_OK);	
		WSACleanup();
		_endthreadex( 0 );
		return 0;
	}

	if (setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, (char*)&bReuseAddr, sizeof(bReuseAddr)) == SOCKET_ERROR) 
	{
		MessageBox(NULL, L"SetSockOpt failed", L"USARSim Image Server", MB_OK);
		WSACleanup();
		_endthreadex( 0 );
		return 0;
	}

	// Bind to port g_nListenPort
	memset(&socketAddress, 0, sizeof(sockaddr_in));
	socketAddress.sin_family = AF_INET;
	socketAddress.sin_port = htons(g_nListenPort);
	socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
	if (bind(listenSocket, (LPSOCKADDR)&socketAddress, sizeof(socketAddress)) == SOCKET_ERROR)
	{
		MessageBox(NULL, L"Bind Failed", L"USARSim Image Server", MB_OK);
		WSACleanup();
		_endthreadex( 0 );
		return 0;
	}

	// Listen on the socket for new clients
	if (listen(listenSocket, 732) == SOCKET_ERROR)
	{
		MessageBox(NULL, L"Listen failed", L"USARSim Image Server", MB_OK);	
		WSACleanup();
		_endthreadex( 0 );
		return 0;
	}

	timeval tv;
	tv.tv_sec = 0;
	tv.tv_usec = 100000;

	FD_ZERO(&Reader);
	
	for(;;)
	{
		if( ::WaitForSingleObject(g_hServerStopEvent._handle, 0) == WAIT_OBJECT_0 )
		{
			break;
		}

		FD_SET(listenSocket, &Reader);

		rc = select((int)listenSocket+1, &Reader, NULL, NULL, &tv);
		if( rc > 0 )
		{
			// Wait for a new client
			clientSocket = accept(listenSocket, NULL, NULL);

			// Check if new client is valid
			if(clientSocket == INVALID_SOCKET)
			{
				MessageBox(NULL, L"Accept failed", L"USARSim Image Server", MB_OK);
				closesocket(listenSocket);
				break;
			}

			// Start a new thread to handle the new client
			HANDLE clientThread = (HANDLE)_beginthread(HandleClientThreadFunction, 0, (void*)clientSocket);

			g_ClientHandleThreads.push_back( ClientSocketInfo_t() );
			g_ClientHandleThreads.back().clientSocket = clientSocket;
			g_ClientHandleThreads.back().clientThread = clientThread;

			if( !g_bHasClientsConnected )
			{
				printf("Client connected to Image Server, enabling capturing frames...\n");
				g_bHasClientsConnected = true;
				Hook::ActivateHooks();
			}
		}
		else if( rc < 0 )
		{
			printf("Error: %d\n", WSAGetLastError());
			MessageBox(NULL, L"Select failed", L"USARSim Image Server", MB_OK);
			break;
		}
		else
		{ 
			// Test if any of the client threads exited
			for( it1 = g_ClientHandleThreads.begin(); it1 != g_ClientHandleThreads.end(); )
			{
				DWORD rs2 = WaitForSingleObject( (*it1).clientThread, 0 );
				if( rs2 == WAIT_OBJECT_0 )
				{
					printf("Client exited\n");
					it1 = g_ClientHandleThreads.erase( it1 );
				}
				else
				{
					it1++;
				}
			}

			if( g_bHasClientsConnected && g_ClientHandleThreads.size() == 0 )
			{
				printf("ImageServer has no clients connected, disabling capturing frames...\n");
				g_bHasClientsConnected = false;
				Hook::DeactivateHooks();
			}
		}
	}

	for( it1 = g_ClientHandleThreads.begin(); it1 != g_ClientHandleThreads.end(); ++it1 )
	{
		closesocket( (*it1).clientSocket );
		WaitForSingleObject( (*it1).clientThread, INFINITE );
	}
	g_ClientHandleThreads.clear();
	
	// Process cleanup
	WSACleanup();
	_endthreadex( 0 );
	return 0;
}

extern "C"
{
	struct FVector
	{
		FVector() {}
		FVector( float x, float y, float z) : x(x), y(y), z(z) {}
		float x,y,z;
	};

#if 0
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
#endif // 0

#ifdef _WIN64
	// Fix for 64 bit dll. 64 bit dll bind is not very well supported.
	void *Fix64Bit( void * pPointer )
	{
		return (void*)(int)pPointer;;
	}
#endif // _WIN64

	// See UPISImageServer.uc for the meaning of the return codes.
	IMAGESERVERDLL_API int InitializeImageServer()
	{
		if( g_bImageServerRunning )
			return -1;
		g_bImageServerRunning = true;

		unsigned threadID;

		if( !HookDirectX9() )
			return -2;
		if( !HookDirectX10() )
			return -3;
		if( !HookDirectX11() )
			return -4;

		InitializeCriticalSection(&g_CriticalSection);
		if( g_bCaptureImageOnRequest )
			g_pRequestEvent = new SimEvent(false);

		// Allocate initial image
		EnterCriticalSection( &g_CriticalSection );
		{
			g_fiImage = FreeImage_Allocate(1280, 720, 3);
		}
		LeaveCriticalSection( &g_CriticalSection );

		g_hServerThread = (HANDLE)_beginthreadex( NULL, 0, &ServerThreadFunction, NULL, 0, &threadID );

		return 0;
	}

	IMAGESERVERDLL_API void ShutdownImageServer()
	{
		if( !g_bImageServerRunning )
			return;
		g_bImageServerRunning = false;

		if( g_bCaptureImageOnRequest )
		{
			// Signal that new frame was captured, so the client threads can exit
			InterlockedExchange( &g_lRequestFlag, FALSE );
			g_pRequestEvent->pulseEvent();
		}
		g_hServerStopEvent.Release();
		WaitForSingleObject( g_hServerThread, INFINITE );
		CloseHandle( g_hServerThread );

		delete g_pRequestEvent;
		DeleteCriticalSection(&g_CriticalSection);
	}

	IMAGESERVERDLL_API void SetListenPort( int nListenPort )
	{
		if( g_bImageServerRunning )
		{
			printf("SetListenPort: Can't change while running the image server.\n");
			return;
		}
		g_nListenPort = nListenPort;
	}
	
	IMAGESERVERDLL_API void SetImageType( int iImageType )
	{
		g_iImageType = iImageType;
	}

	IMAGESERVERDLL_API void SetFrameSkip( int lFrameSkip )
	{
		g_lFrameSkip = lFrameSkip;
	}
	
	IMAGESERVERDLL_API void SetLegacyMode( int bMode )
	{
		g_bLegacy = bMode > 0 ? true : false;
	}

	IMAGESERVERDLL_API void SetCaptureOnRequest( int bMode )
	{
		if( g_bImageServerRunning )
		{
			printf("SetCaptureOnRequest: Can't change while running the image server.\n");
			return;
		}
		g_bCaptureImageOnRequest = bMode > 0 ? true : false;
	}
}
