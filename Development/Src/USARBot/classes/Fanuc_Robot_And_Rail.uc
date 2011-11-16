/*****************************************************************************  DISCLAIMER:  This software was produced in part by the National Institute of Standards  and Technology (NIST), an agency of the U.S. government, and by statute is  not subject to copyright in the United States.  Recipients of this software  assume all responsibility associated with its operation, modification,  maintenance, and subsequent redistribution.*****************************************************************************//* * Parent static vehicle for the Fanuc M16iB20 actuator */class Fanuc_Robot_And_Rail extends USARVehicle config(USAR);// Returns configuration data of this robotfunction String GetConfData(){	return super.GetConfData() $ " {Type StaticPlatform} {SteeringType None} {Mass 0} ";}// Gets robot status (adds zero steer amounts)simulated function String GetStatus(){	return super.GetStatus() $ " {Type StaticPlatform}";}// Gets the robot's steering typesimulated function String GetSteeringType(){	return "None";}simulated function PostBeginPlay(){	super.PostBeginPlay();}defaultproperties{	Begin Object Class=Part Name=Rail		Mesh=StaticMesh'Fanuc.Fanuc_Rail'		Mass = 100.0		Offset=(x=0,y=0,z=0)		Direction=(x=0,y=0,z=3.1416)	End Object	PartList.Add(Rail)	Body=Rail	}