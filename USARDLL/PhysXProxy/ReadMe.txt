This is a test project for accessing everything from the PhysX SDK in Unreal Engine using DllBind, 
instead of being restricted to the Unreal Engine 3 functions.

Additional information: http://udn.epicgames.com/Three/DLLBind.html

====== Required libraries =======
-  PhysX 2.8.4 SDK. You can retrieve the SDK from the following url:
   http://supportcenteronline.com/ics/support/default.asp?deptID=1949
   You must sign up to download the SDK.
   
====== Setup and Compiling =======
1. Change the include path and additional link directories to reflect your installation:
   Configuration Properties -> C/C++ -> General -> Additional Include Directories
   Configuration Properties -> General -> Additional Library Directories
   
   The dll only requires the location of the PhysX headers and libs.
   If you copy the PhysX sdk folder into "usarsim/ThirdParty" you don't need to change anything.
   
2. Build the solution. The compiled dll will be copied to "Binaries/Win32/usercode".
   In case of 64 bit the dll is copied into "Binaries/Win64/usercode".
   
3. Compile UsarSim.

====== Debug =======
To run in debug mode you must edit the debug information:
1. Go to Configuration Properties -> Debugging
2. Change "Command" to: "..\..\Binaries\Win32\udk.exe"
3. Change "Command arguments" to: "EmptyRoom?game=USARBotAPI.BotDeathMatch -log"

In case of 64 bit change "Win32" to "Win64".

===== Limitations ======
64 bit is not supported according to the (outdated) UDN DLLBind page.
It is possible to compile in 64 bit, but there seem to be several problems.
Pointers to structs seem to be mangled.

Also see: http://forums.epicgames.com/showthread.php?t=771378

===== Additional details ======
Inside the dll you can access everything from the PhysX Dll.
You can identify PhysX actors by comparing the "userdata"
variable to the BodyInstance pointer of an Unreal Actor.
Similar PhysX joints can be identified by comparing "userdata"
to the ConstraintInstance variable.