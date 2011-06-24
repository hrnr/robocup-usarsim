/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * GripperArm - parents a large quantity of actuators
 */
class GripperArm extends Actuator placeable config (USAR);

var Part End;
var Item EndItem;
var Hinge GripCons;
var float SuctionLength;

// Assign the End part as necessary (the End part must be a small part exactly where the grip
// must apply; if no part on the package fits the bill, declare another small one and fix
// joint it to the nearest available part; it must be facing with the +Z axis outward!)
simulated function AttachItem()
{
	super.AttachItem();
	// Look for end item, make it able to fix other objects to it
	if (End != None)
	{
		EndItem = GetPartByName(End.Name);
		EndItem.SetCollision(false, false);
		EndItem.SetPhysics(PHYS_None);
		if (bDebug)
			LogInternal("krArm: Found end part " $ End.Name);
	}
	else
		LogInternal("krArm: No end part specified, will not be able to grip");
}

simulated function ConvertParam()
{
	super.ConvertParam();
	suctionLength = -class'UnitsConverter'.static.LengthToUU(suctionLength);
}

reliable server function RunSequence(int sequence)
{
	switch (sequence)
	{
	case 1:
		bDebug = true;
		break;
	case 0:
		bDebug = false;
		break;
	default:
	}
}

function gripObject(Actor target)
{
	// TODO validate that this behavior is acceptably similar to UT3's
	if (GripCons == None && EndItem != None)
	{
		target.SetLocation(EndItem.Location);
		GripCons = class'FixedJoint'.static.CreateFixJoint(EndItem, target);
	}
}

function ungripObject()
{
	if (GripCons != None)
	{
		GripCons.Destroy();
		GripCons = None;
	}
}

reliable server function SetGripper(int gripper)
{
	local Actor hit;
	local vector hitLocation, hitNormal;
	local vector rayAxis, rayEnd;
	
	switch (gripper)
	{
		case 0:
			ungripObject();
			break;
		case 1:
			if (EndItem != None)
			{
				// Find axis along which to trace
				rayAxis = vect(0, 0, 0);
				rayAxis.Z = suctionLength;
				// Find where how far away the box can be
				rayEnd = EndItem.Location + (rayAxis >> EndItem.Rotation);
				// Look for actors within the specified length to grab
				hit = Trace(hitLocation, hitNormal, rayEnd, EndItem.Location, true);
				if (hit != None)
					gripObject(hit);
			}
			break;
		default:
	}
}

defaultproperties
{
	gripCons=None
	suctionLength=.25
	DrawScale=0.3
	
	// Joint Max Limit (rad), Joint Min Limit (rad), Joint Max Speed (m/s or rad/s), Init Speed, Joint Max Torque
	/*JointSpecs[0]=( MaxLimit=0, MinLimit=0, MaxSpeed=0, MaxTorque=20 )
	JointSpecs[1]=( MaxLimit=-3.228, MinLimit=3.228, MaxSpeed=1.57, MaxTorque=20 ) // -185 to 185
	JointSpecs[2]=( MaxLimit=-0.61, MinLimit=2.356, MaxSpeed=1.57, MaxTorque=20 ) // -35 to 135
	JointSpecs[3]=( MaxLimit=-2.757, MinLimit=2.094, MaxSpeed=1.57, MaxTorque=20 ) // -158 to 120
	JointSpecs[4]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, MaxTorque=20 ) // -350 to 350
	JointSpecs[5]=( MaxLimit=-2.076, MinLimit=2.076, MaxSpeed=1.57, MaxTorque=20 ) // -119 to 119
	JointSpecs[6]=( MaxLimit=-6.108, MinLimit=6.108, MaxSpeed=1.57, MaxTorque=20 ) // -350 to 350*/
}
