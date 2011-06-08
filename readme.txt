------------------------------------------------------------------------------------------

Taylor Brent (NIST) and Stephen Carlson (NIST) version restructuring class hierarchy and using static meshes instead of skeletal meshes.

Notes: 
0. This version was verified with the UDK February-2011 release!
1. You have to make twice due to an ordering problem that we can’t seem to figure out. 
   You’ll get an error the first time that will disappear the second time. Just run everything.bat to do it for you. 
2. Due to the fact that unreal needs a build order, we had to move the base class of USARVehicle, BaseVehicle, 
   into the USARBase folder so there wouldn’t be any problems. 
3. The verified working example robots are BasicSkidRobot, CasterSkidRobot, and P3AT_static. 
4. This code based off of http://svn.sandern.com/nao/trunk/UDKUSARSim/

------------------------------------------------------------------------------------------

Installation instructions:
1. Download and Install UDK February-2011 (http://www.udk.com/)
2. Checkout this repository
3. Copy the entire repository on top of the udk installation. This should include the .git file.
 
Running:
1. Execute everything.bat (might require Administrative privileges to run correctly)
2. Start usarsim using one of the map bat files located in USARRunMaps

Known issues:
1) Lots of warnings!
2) Can only put in a single robot.


