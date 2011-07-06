------------------------------------------------------------------------------------------

Taylor Brent (NIST) and Stephen Carlson (NIST) version restructuring class hierarchy and using static meshes
instead of skeletal meshes.

Notes: 
1. This version was verified with the UDK June-2011 release! 
2. Due to the fact that unreal needs a build order, we had to move the base class of USARVehicle, BaseVehicle,
   into the USARBase folder so there wouldn’t be any problems. 
3. The verified working example robots are BasicSkidRobot, CasterSkidRobot, and P3AT.
4. This code partially based off of constraint examples at http://svn.sandern.com/nao/trunk/UDKUSARSim/

------------------------------------------------------------------------------------------

Installation instructions:
1. Download and Install UDK June-2011 (http://www.udk.com/)
2. Checkout this repository
3. Copy the entire repository on top of the udk installation. This should include the .git file.
 
Running:
1. Execute make.bat (might require Administrative privileges to run correctly)
2. Start usarsim using one of the map bat files located in USARRunMaps

Known issues:
1) Sensors need validation.
2) Many materials and models have yet to be imported.

-----------------------------------------------------------------------------------------

Note:
	Textures by nobiax.deviantart.com
	Packed by dk2007.deviantart.com
	Thanks to them!