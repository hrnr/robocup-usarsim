class UPISImageServer extends Object config(USAR)
	DLLBind(ImageServer);

var config bool             bEnableImageServer;
var config int              ImageType;
var config int              FrameSkip;
var config bool             LegacyMode;

function Initialize()
{
	if( !bEnableImageServer )
		return;

	SetImageType( ImageType );
	SetFrameSkip( FrameSkip );
	SetLegacyMode( int(LegacyMode) );

	InitializeImageServer();
}

function Shutdown()
{
	if( !bEnableImageServer )
		return;

	ShutdownImageServer();
}

dllimport final function InitializeImageServer();
dllimport final function ShutdownImageServer();

dllimport final function SetImageType( int Type );
dllimport final function SetFrameSkip( int iFrameSkip );
dllimport final function SetLegacyMode( int Mode );
dllimport final function SetCaptureOnRequest( int Mode );

dllimport final function HookDirectX9();
dllimport final function HookDirectX10();
dllimport final function HookDirectX11();

defaultproperties
{

};