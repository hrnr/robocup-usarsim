------------------------------------------------------------------------------------------
PLEASE SEE NOTES BELOW!

Please use GIT repository (see below for instructions). SVN is no longer supported!

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Installation instructions from sourceforge files area:
1. Download and Install UDK February-2013 (http://www.udk.com/). Install this to a directory named UDK\UDK-yyyy-mm. 
   In this case 'yyyy' is the year of your UDK release and 'mm' is the month.
2. Retrieve the latest release of USARSim for UDK from the usarsim-UDK folder.
3. Unzip all of the files from the release into the directory specified in step 1.
4. Run "make" in the UDK-yyyy-mm folder.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Installation instructions from Git respository:
1. Download and Install UDK February-2013 (http://www.udk.com/). Install this to a directory named UDK\UDK-yyyy-mm. 
   In this case 'yyyy' is the year of your UDK release and 'mm' is the month.
2. Using a client such as Git Gui, open a bash window in the same directory that you specified in step 1 (UDK-yyyy-mm) and type:
      git clone ssh://yourUserName@git.code.sf.net/p/usarsim/code
3. Move all of the files (including the .git folder) from the code folder into the directory specified in step 1.
4. Run "make" in the UDK-yyyy-mm folder.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Running:
1. Execute make.bat (might require Administrative privileges to run correctly)
2. Start usarsim using one of the map bat files located in USARRunMaps

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Known issues:
1) Sensors need validation.
2) Many materials and models have yet to be imported.

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Notes: 
1. This version was verified with the UDK February-2013 release! 
2. Due to the fact that unreal needs a build order, we had to move the base class of USARVehicle, BaseVehicle,
   into the USARBase folder so there wouldn�t be any problems. 
3. The verified working example robots are BasicSkidRobot, CasterSkidRobot, and P3AT.
4. This code partially based off of constraint examples at http://svn.sandern.com/nao/trunk/UDKUSARSim/

	Textures by nobiax.deviantart.com
	Packed by dk2007.deviantart.com
	Thanks to them!
