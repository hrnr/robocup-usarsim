/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

class Gripper extends Effector config (USAR);

var config bool IsOpen;

simulated function ClientTimer()
{ 
	if (IsOpen)
		MessageSendDelegate(getHead() @ "{Open}");
	else
		MessageSendDelegate(getHead() @ "{Closed}");
}

defaultproperties
{
	ItemType="Gripper";
	DrawScale=1;
	
	Begin Object Class=StaticMeshComponent Name=StMesh01
		StaticMesh=StaticMesh'INSIMUSensor.Sensor';
		CollideActors=false;
		BlockActors=false;
		BlockRigidBody=false;
		BlockZeroExtent=false;
		BlockNonZeroExtent=false;
	End Object
	
	Components(1)=StMesh01;
	CollisionComponent=StMesh01;
}
