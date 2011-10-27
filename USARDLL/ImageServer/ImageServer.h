#ifndef IMAGESERVER_H
#define IMAGESERVER_H

#include "hooking.h"
#include <windows.h>
#include <FreeImage.h>
#include "simevent.h"

#define IMAGESERVERDLL_API __declspec(dllexport)

// Bytes per pixel of a raw frame
const long DX9_RAW_VIDEO_BPP = 4;  


// Settings
extern bool g_bLegacy;
extern long g_lFrameSkip;
extern long g_lCurrentFrame;
extern int g_iImageType;
extern bool g_bCaptureImageOnRequest;

// State/data
extern SimEvent *g_pRequestEvent;
extern LONG g_lRequestFlag;
extern FIBITMAP *g_fiImage;
extern CRITICAL_SECTION g_CriticalSection;
extern bool g_bHasClientsConnected;

#endif // IMAGESERVER_H