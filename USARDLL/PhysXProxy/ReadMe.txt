This is a test project for accessing everything from the PhysX SDK in Unreal Engine using DllBind, 
instead of being restricted to the Unreal Engine 3 functions.

Additional information: http://udn.epicgames.com/Three/DLLBind.html

====== Setup =======
1. First you must download the PhysX SDK. You can get it from:
   http://supportcenteronline.com/ics/support/default.asp?deptID=1949
   You must sign up to download it.
   
2. Change the include path and additional link directories to reflect your installation:
   Configuration Properties -> C/C++ -> General -> Additional Include Directories
   Configuration Properties -> General -> Additional Library Directories
   
   The dll only requires the location of the PhysX headers and libs.
   If you copy the PhysX sdk folder into "usarsim/ThirdParty" you don't need to change anything.
   
3. Build the solution. The dll should now be placed in the correct directory (Binaries/Win32/usercode)

4. Copy PhysXProxy.u from the classes directory into your development directory.
   For example: "Development\Src\USARBase".
   
5. Compile the unrealscript code.

===== Usage ========
The PhysXProxy class exposes new functions that are not available in UnrealScript by default or at least I can't find them :).
Create a new instance of the PhysXProxy class and then call one of the functions to use it. 

===== Limitations ======
64 bit is not supported according to the (outdated) UDN DLLBind page.
It is possible to compile in 64 bit, but there seem to be several problems.
Pointers to structs seem to be mangled

Also see: http://forums.epicgames.com/showthread.php?t=771378

===== Additional details ======
Inside the dll you can simply access everything from the Physics Dll.
The only question is how to identify the PhysX actors to Unreal Actors. 
PhysX actors contain a field "userdata" that can be set to anything. 
In Unreal Engine this is set to the BodyInstance variable of the actors.
