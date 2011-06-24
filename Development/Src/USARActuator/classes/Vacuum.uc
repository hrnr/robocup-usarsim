/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Vacuum - a device that can attach onto the end of an arm and pick up objects like a vacuum
 * Use the INI file to attach this actuator and parent it to the end part of the arm
 */
class Vacuum extends Actuator placeable config (USAR);

// Constraint that causes gripping to occur
var Hinge GripCons;
// The physics this object used to have before grabbing
var EPhysics GripPhys;
// Position of the grabbed object relative to Body when first grabbed
// If this position changes too much, the object is dropped
var vector GripPos;
// The object currently grabbed
var Actor GripTarget;
// How far away the object can be while still being held
var float SuctionLength;
// How much force the vacuum can exert
var config float VacuumForce;

simulated function ConvertParam()
{
	super.ConvertParam();
	SuctionLength = class'UnitsConverter'.static.LengthToUU(SuctionLength);
}

// Grips an object by fixing it to the end of the arm
function GripObject(Actor target)
{
	if (GripCons == None && GripTarget == None)
	{
		GripCons = class'FixedJoint'.static.CreateFixJoint(CenterItem, target);
		if (GripCons == None)
			LogInternal("Vacuum: Error creating grip constraint, is object blocked?");
		else
		{
			// Save physics and set to rigidbody so joint works
			GripTarget = target;
			GripPhys = target.Physics;
			GripPos = (target.Location - CenterItem.Location) << CenterItem.Rotation;
			target.SetPhysics(PHYS_RigidBody);
			// Allow some motion
			GripCons.ConstraintSetup.LinearXSetup.LimitSize = SuctionLength;
			GripCons.ConstraintSetup.LinearYSetup.LimitSize = SuctionLength;
			GripCons.ConstraintSetup.LinearZSetup.LimitSize = SuctionLength;
			GripCons.ConstraintInstance.SetAngularDriveParams(VacuumForce, 0.8, VacuumForce);
			GripCons.ConstraintInstance.SetLinearDriveParams(VacuumForce, 0.8, VacuumForce);
			// Init again (2nd time!)
			GripCons.ConstraintInstance.InitConstraint(CenterItem.CollisionComponent,
				target.CollisionComponent, GripCons.ConstraintSetup, 1, CenterItem,
				CenterItem.CollisionComponent, false);
			GripCons.ConstraintInstance.SetLinearPositionDrive(true, true, true);
		}
	}
}

// Ungrips the object by killing its hinge
function UngripObject()
{
	if (GripCons != None && GripTarget != None)
	{
		GripCons.Destroy();
		GripCons = None;
		GripTarget.SetPhysics(GripPhys);
		GripTarget = None;
	}
}

// Fired every tic to check for a drop
event Tick(float DT)
{
	local vector newPos;
	
	if (GripTarget != None)
	{
		// Check for an auto drop
		newPos = (GripTarget.Location - CenterItem.Location) << CenterItem.Rotation;
		if (VSize(newPos - GripPos) > SuctionLength)
		{
			LogInternal("Vacuum: Suction lost");
			UngripObject();
		}
	}
}

// Opens or closes the gripper as necessary
reliable server function SetGripper(int gripper)
{
	local Actor hit;
	local vector hitLocation, hitNormal;
	local vector rayAxis, rayEnd;
	
	switch (gripper)
	{
		case 0:
			UngripObject();
			break;
		case 1:
			if (GripCons == None && GripTarget == None)
			{
				// Find axis along which to trace
				rayAxis = vect(0, 0, 0);
				rayAxis.Z = suctionLength;
				// Find where how far away the box can be
				rayEnd = CenterItem.Location + (rayAxis >> CenterItem.Rotation);
				// Look for actors within the specified length to grab; cannot grab a brush!
				hit = Trace(hitLocation, hitNormal, rayEnd, CenterItem.Location, true);
				if (hit != None && !hit.isA('Brush'))
				{
					LogInternal("Vacuum: Picking up " $ String(hit.Name));
					GripObject(hit);
				}
			}
			break;
		default:
	}
}

defaultproperties
{
	GripCons=None
	GripTarget=None
	GripPhys=PHYS_None
	SuctionLength=0.125
	
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Basic.EmptyMesh'
		Collision=false
	End Object
	PartList.Add(BodyItem)
	
	Body=BodyItem
}
