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
 * For UDK-2013-02:
 * Make sure that this part (and its subclasses) are NOT mounted on the arm at an orientation of (0, 1.5708, 0): due to
 * a UDK bug, the vacuum will not rotate properly if the pitch is too close to exactly pi/2
 */
class Vacuum extends Gripper abstract config (USAR);

// Item used for attachment (use self if no parent found)
var Actor AttachTo;
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
//where the vacuum ray cast starts
var vector suctionFrom;
//how often the vacuum checks to see if the target object is still close enough to be attached
var config int dropCheckFrequency;
//how many frames it's been since the last distance check was performed
var int lastChecked;
// Hide the black object for now
simulated function AttachItem()
{
	super.AttachItem();
	CenterItem.SetHidden(!bDebug);
	//do NOT attach to parent, because this will foul up the vacuum constraint when the toolchanger is used
	/*if (Base != None)
	{
		LogInternal("Vacuum: Attaching to " $ String(Base.Name) $ " for greater stability");
		AttachTo = Base;
	}
	else*/
	AttachTo = CenterItem;
}

simulated function ConvertParam()
{
	super.ConvertParam();
	// the following negative signs are necessary due to changes in the UDK since July 2012.
	// they seem to have changed the direction of the z-axis. Not exactly sure what is going on here.
	SuctionLength = class'UnitsConverter'.static.LengthToUU(SuctionLength);
	SuctionFrom = class'UnitsConverter'.static.MeterVectorToUU(TipOffset);
}

// Grips an object by fixing it to the end of the arm
function GripObject(Actor target)
{
	if (GripCons == None && GripTarget == None)
	{
		GripCons = class'FixedJoint'.static.CreateFixJoint(AttachTo, target);
		if (GripCons == None)
			LogInternal("Vacuum: Error creating grip constraint, is object blocked?");
		else
		{
			// Save physics and set to rigidbody so joint works
			GripTarget = target;
			GripPhys = target.Physics;
			GripPos = (target.Location - (CenterItem.Location + (SuctionFrom >> CenterItem.Rotation))) << CenterItem.Rotation;
			target.SetPhysics(PHYS_RigidBody);
			// Allow some motion
			GripCons.ConstraintSetup.LinearXSetup.LimitSize = SuctionLength;
			GripCons.ConstraintSetup.LinearYSetup.LimitSize = SuctionLength;
			GripCons.ConstraintSetup.LinearZSetup.LimitSize = 0;
			GripCons.ConstraintSetup.bLinearBreakable = true;
			GripCons.ConstraintSetup.LinearBreakThreshold = VacuumForce;
			// Init again (2nd time!)
			GripCons.ConstraintInstance.InitConstraint(AttachTo.CollisionComponent,
				target.CollisionComponent, GripCons.ConstraintSetup, 1, AttachTo,
				AttachTo.CollisionComponent, false);
			// Set the force high but leave the restitution low so that it imitates real vacuum
			GripCons.ConstraintInstance.SetLinearDriveParams(100, 5, VacuumForce);
			GripCons.ConstraintInstance.SetLinearPositionDrive(true, true, false);
			LogInternal("gripcons set");
		}
	}
}

// Ungrips the object by killing its hinge
function UngripObject()
{
	if (GripCons != None && GripTarget != None)
	{
		GripTarget.SetPhysics(GripPhys);
		GripTarget = None;
		GripCons.Destroy();
		GripCons = None;
	}
}

// Fired every tic to check for a drop
event Tick(float DT)
{
	local vector newPos;
	lastChecked += 1;
	//only check for a drop every few frames (not a constant amount of time)
	if (GripTarget != None && lastChecked > dropCheckFrequency)
	{
		lastChecked = 0;
		// Check for an auto drop
		newPos = (GripTarget.Location - (CenterItem.Location + (SuctionFrom >> CenterItem.Rotation))) << CenterItem.Rotation;
		if (VSize(newPos - GripPos) > abs(SuctionLength))
		{
			LogInternal("Vacuum: Suction lost");
			UngripObject();
			IsOn = 0;
		}
	}
}
// Opens or closes the gripper as necessary
function Operate(bool gripper)
{
	local Actor hit;
	local vector hitLocation, hitNormal;
	local vector rayAxis, rayEnd;
	
	if (!gripper)
		UngripObject();
	else if (GripCons == None && GripTarget == None)
	{
		// Find axis along which to trace
		hitLocation = CenterItem.Location;
		rayAxis = vect(0, 0, 0); 
		rayAxis.Z = class'UnitsConverter'.static.LengthFromUU(suctionLength);
		rayAxis = class'UnitsConverter'.static.MeterVectorToUU(rayAxis);
		// Find where how far away the box can be
		rayEnd = (rayAxis >> CenterItem.Rotation) + CenterItem.Location + (suctionFrom >> CenterItem.Rotation);
		hit = Trace(hitLocation, hitNormal, rayEnd, CenterItem.Location + (suctionFrom >> CenterItem.Rotation), true);
		// Cannot grab base or self
		if (hit == CenterItem || hit == Base)
			LogInternal("Vacuum: Not placed or oriented properly; can only see self");
		// Look for actors within the specified length; cannot grab a brush!
		else if (hit != None && !hit.isA('Brush'))
		{
			// Cannot pick up self or base
			LogInternal("Vacuum: Picking up " $ String(hit.Name));
			GripObject(hit);
		}
		if(bDebug)
		{
			FlushPersistentDebugLines();
			DrawDebugLine(CenterItem.Location, CenterItem.Location + (suctionFrom>> CenterItem.Rotation), 0, 255, 0, True);
			DrawDebugLine(CenterItem.Location + (suctionFrom>> CenterItem.Rotation), rayEnd, 255, 0, 0, true);
		}
	}
}

defaultproperties
{
	bDebug=true
	GripCons=None
	GripTarget=None
	GripPhys=PHYS_None
	SuctionLength=0.125
}
