------------------------------------------------------------------------------------------

Taylor Brent (NIST) and Stephen Carlson (NIST) version restructuring class hierarchy and using static meshes instead of skeletal meshes.

Notes: 
1. This version was verified with the UDK February-2011 release! 
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
1. Execute make.bat (might require Administrative privileges to run correctly)
2. Start usarsim using one of the map bat files located in USARRunMaps

Known issues:
1) Lots of warnings!
2) Can only put in a single robot.


