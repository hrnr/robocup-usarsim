/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class FanucCarriage extends Actuator placeable config (USAR);

simulated function AttachItem()
{
	super.AttachItem();
	GetPartByName('BaseEmptyMesh').SetHidden(true);
}

defaultproperties
{
	Begin Object Class=Part Name=BaseEmptyMesh
		Mesh=StaticMesh'Basic.EmptyMesh'
		Mass=1
		Offset=(X=0,Y=0,Z=0)
	End Object
	PartList.Add(BaseEmptyMesh)
	Body=BaseEmptyMesh
		
	Begin Object Class=Part Name=Carriage
		Mesh=StaticMesh'Fanuc.carriage'
		Mass = 2;
		Offset=(X=0,Y=0,Z=0)
	End Object
	PartList.Add(Carriage)

	
	Begin Object Class=PrismaticJoint Name=Body_Carriage
		Parent=BaseEmptyMesh
		Child=Carriage
		Damping=10
		MaxForce=30
		LimitLow=-1.5
		LimitHigh=1.5
		Offset=(x=0,y=0,z=0)
		Direction=(x=0,y=1.5707,z=0)
	End Object
	Joints.Add(Body_Carriage)
}
