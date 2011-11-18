class UPISImageServer extends Object config(USAR)
	DLLBind(ImageServer);

var config bool             bEnableImageServer;
var config int              ListenPort;
var config string           ImageType;
var config int              FrameSkip;
var config bool             LegacyMode;

function Initialize( PlayerController PC = none )
{
	local int rc, nImageType;
	local String FailureReason;

	if( !bEnableImageServer )
		return;

	// Set listen port to 5003 as default if not configured
	if( ListenPort == 0 )
		ListenPort = 5003;

	// Parse image type option. Either specified as tag or directly as a number
	if( ImageType == "" ) nImageType = 3;
	else if( Caps(ImageType) == "RAW" ) nImageType = 0;
	else if( Caps(ImageType) == "SUPER" ) nImageType = 1;
	else if( Caps(ImageType) == "GOOD" ) nImageType = 2;
	else if( Caps(ImageType) == "NORMAL" ) nImageType = 3;
	else if( Caps(ImageType) == "FAIR" ) nImageType = 4;
	else if( Caps(ImageType) == "BAD" ) nImageType = 5;
	else nImageType = int(ImageType); // Assume specified as number

	// Apply the options
	SetListenPort( ListenPort );
	SetImageType( nImageType );
	SetFrameSkip( FrameSkip );
	SetLegacyMode( int(LegacyMode) );

	// Initialize the image server and show status
	rc = InitializeImageServer();
	if( rc < 0 )
	{
		FailureReason = "Failed to initialize the image server due the following reason: ";
		switch( rc )
		{
		case -1:
			FailureReason $= "image server already running";
			break;
		case -2:
			FailureReason $= "failed to hook directx 9";
			break;
		case -3:
			FailureReason $= "failed to hook directx 10";
			break;
		case -4:
			FailureReason $= "failed to hook directx 11";
			break;
		default:
			FailureReason $= "unknown return code " $ rc;
			break;
		}
		`log(FailureReason);
		if( PC != None )
			PC.ClientMessage( FailureReason );
	}
	else
	{
		`log("Image Server Running (ListenPort: " $ ListenPort $ ", ImageType: " $ nImageType $ 
			 ", FrameSkip: " $ FrameSkip $ ", LegacyMode: " $ LegacyMode $ ")" );
		if( PC != None )
			PC.ClientMessage( "Image Server Running" );
	}
}

function Shutdown()
{
	if( !bEnableImageServer )
		return;

	ShutdownImageServer();
	`log("Image Server Shutdown");
}

dllimport final function int InitializeImageServer();
dllimport final function ShutdownImageServer();

dllimport final function SetListenPort( int NewListenPort );
dllimport final function SetImageType( int Type );
dllimport final function SetFrameSkip( int iFrameSkip );
dllimport final function SetLegacyMode( int Mode );
dllimport final function SetCaptureOnRequest( int Mode );

dllimport final function int HookDirectX9();
dllimport final function int HookDirectX10();
dllimport final function int HookDirectX11();

defaultproperties
{

};