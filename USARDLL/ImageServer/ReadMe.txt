====== Required libraries =======
- DirectX SDK

====== Setup and Compiling =======
1. Change the include path and additional link directories to reflect your installation:
   Configuration Properties -> C/C++ -> General -> Additional Include Directories
   Configuration Properties -> General -> Additional Library Directories
   
====== Debug =======
To run in debug mode you must edit the debug information:
1. Go to Configuration Properties -> Debugging
2. Change "Command" to: "..\..\Binaries\Win32\udk.exe"
3. Change "Command arguments" to: "EmptyRoom?game=USARBotAPI.BotDeathMatch -log"

In case of 64 bit change "Win32" to "Win64".

====== Potential problems =======
- Untested: DirectX10, there doesn't seems to be a switch to start UDK in this mode.

====== Description =======
The image server is initialized in from the unreal script in UsarBotAPI.BotDeatmatch.
This creates an instance of the unreal script class UsarBotAPI.UPISImageServer. This class
binds the Image Server dll and also reads out the configuration data from UDKUsar.ini.

The code for retrieving the backbuffer and sending frames to clients is the same as 
the old upis image server code and should be backwards compatible.