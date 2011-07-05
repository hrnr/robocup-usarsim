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
1. Download and Install UDK June-2011 (http://www.udk.com/). Install this to a directory named UDK\UDK-yyyy-mm. 
   In this case 'yyyy' is the year of your UDK release and 'mm' is the month.
2. Using a client such as Git Gui, open a bash window in the same directory that you specified in step 1 (UDK-yyyy-mm) and type:
      git clone ssh://yourUserName@usarsim.git.sourceforge.net/gitroot/usarsim/usarsim
3. Move all of the files (including the .git folder) from the usarsim folder into the directory specified in step 1.
4. Run "make" in the UDK-yyyy-mm folder.
 
Running:
1. Execute make.bat (might require Administrative privileges to run correctly)
2. Start usarsim using one of the map bat files located in USARRunMaps

Known issues:
1) Sensors need validation.
2) Many materials and models have yet to be imported.
