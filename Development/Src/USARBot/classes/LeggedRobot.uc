/*
 * Base class for USAR legged robots.
 */
class LeggedRobot extends USARVehicle config(USAR) abstract;

var vector SafedPosition;
var rotator SafedRotation;
var float MaxJointAngularSpeed; // In radians
var bool DebugCOM;
var bool DebugNotifyJointErrors;
var String DebugNotifySpecificJointError;

simulated function PostBeginPlay()
{
	local int i;
	local float HalfAngle;
	local PhysicalItem Part1, Part2;
	local Vector angle, OffsetInUU, SpawnLocation;
	local Rotator r, r3;
	local Matrix m;
	
	super.PostBeginPlay();
	
	// Initialize constraints
	for (i = 0; i < Joints.Length; i++)
	{
		Part1 = Joints[i].Parent;
		if (Part1.PartActor == None)
		{
			LogInternal("LeggedRobot: No parent specified!");
			continue;
		}
		Part2 = Joints[i].Child;
		if (Part2.PartActor == None)
		{
			LogInternal("LeggedRobot: No child specified!");
			continue;
		}

		// NOTE: Contraint limits are always symmetrical, however we can specify the joints asymmetrically
		//       Make the limits symmetrical here; when the joint angle is set, map it to the actual constraint limits
		HalfAngle = (Joints[i].LimitHigh - Joints[i].LimitLow) / 2.0;
		Joints[i].trueZero = class'UnitsConverter'.static.AngleToUU(
			class'UnitsConverter'.static.AngleFromDeg(HalfAngle - Joints[i].LimitHigh));
		Joints[i].CurAngularTarget = Joints[i].trueZero;

		angle.Y = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.X); // Pitch
		angle.Z = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.Y); // Yaw
		angle.X = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.Z); // Roll
		r = class'UnitsConverter'.static.AngleVectorToUU(angle);
		OffsetInUU = class'UnitsConverter'.static.MeterVectorToUU(Joints[i].offset);
		OffsetInUU.Z = -OffsetInUU.Z;
		
		// Get the constraint spawn location. Can be relative to part.
		if (Joints[i].RelativeTo != None)
			SpawnLocation = Joints[i].RelativeTo.PartActor.Location + OffsetInUU;
		else
			SpawnLocation = Location+OffsetInUU;
	
		Joints[i].Constraint = Spawn(class 'LeggedHinge', None, '', SpawnLocation, Rotation + r);
		r = rot(0, 0, 0);
		
		// Setup joint limits (depending on the joint type)
		if (Joints[i].jointType == JOINTTYPE_Pitch)
		{
			Joints[i].Constraint.ConstraintSetup.Swing2LimitAngle = HalfAngle;
			r.Pitch = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = true;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = Joints[i].IsOneDof;
		}
		else if (Joints[i].jointType == JOINTTYPE_Yaw)
		{
			Joints[i].Constraint.ConstraintSetup.Swing1LimitAngle = HalfAngle;
			r.Yaw = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = true;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = Joints[i].IsOneDof;		
		}
		else if (Joints[i].jointType == JOINTTYPE_Roll)
		{
			Joints[i].Constraint.ConstraintSetup.TwistLimitAngle = HalfAngle;
			r.Roll = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = Joints[i].IsOneDof;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = true;
		}
		else if (Joints[i].jointType == JOINTTYPE_Fixed)
		{
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = true;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = true;
		}

		Joints[i].Constraint.ConstraintSetup.LinearXSetup.LimitSize = 0.0;
		Joints[i].Constraint.ConstraintSetup.LinearYSetup.LimitSize = 0.0;
		Joints[i].Constraint.ConstraintSetup.LinearZSetup.LimitSize  = 0.0;
		Joints[i].Constraint.ConstraintSetup.bEnableProjection = true;

		// Because the joint limits must be symmetrical, we now temporary rotate one of the parts 
		// before initializing the constraint. After that we rotate it back to the "true" zero angle.
		TempRotatePart(Joints[i], Part2.PartActor, r);
		Joints[i].Constraint.InitConstraint(Part1.PartActor, Part2.PartActor, , , 6000.0);
		RestoreRotatePart(Part2.PartActor);

		// Joints can specify a rotation to modify the constraint axis
		// The constraint will be initialized again with the new axis.
		angle.Y = class'UnitsConverter'.static.AngleFromDeg(Joints[i].RotateAxis.X); // Pitch
		angle.Z = class'UnitsConverter'.static.AngleFromDeg(Joints[i].RotateAxis.Y); // Yaw
		angle.X = class'UnitsConverter'.static.AngleFromDeg(Joints[i].RotateAxis.Z); // Roll
		r3 = class'UnitsConverter'.static.AngleVectorToUU(angle);

		m = MakeRotationMatrix(r3);
		Joints[i].Constraint.ConstraintSetup.PriAxis1=TransformVector(m, Joints[i].Constraint.ConstraintSetup.PriAxis1);
		Joints[i].Constraint.ConstraintSetup.SecAxis1=TransformVector(m, Joints[i].Constraint.ConstraintSetup.SecAxis1);
		Joints[i].Constraint.ConstraintSetup.PriAxis2=TransformVector(m, Joints[i].Constraint.ConstraintSetup.PriAxis2);
		Joints[i].Constraint.ConstraintSetup.SecAxis2=TransformVector(m, Joints[i].Constraint.ConstraintSetup.SecAxis2);

		Joints[i].Constraint.ConstraintInstance.InitConstraint(
			Part1.PartActor.CollisionComponent,
			Part2.PartActor.CollisionComponent,
			Joints[i].Constraint.ConstraintSetup,
			1, self, Part1.PartActor.CollisionComponent, false);

		// Enable angular drive and set the initial drive parameters
		if (Joints[i].jointType == JOINTTYPE_Pitch || Joints[i].jointType == JOINTTYPE_Yaw)
		{
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(true, false);
			SetJointStiffness(i,1.0);
		}
		else if (Joints[i].jointType == JOINTTYPE_Roll)
		{
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(false, true);
			SetJointStiffness(i,1.0);
		}
		else
		{
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
		}
	}

	InitJoints();
}

simulated function ScaleMass(float ScaleMass)
{
	local int i;
	local PhysicalItem pitem;
	
	for (i = 0; i < ComponentList.Length; i++)
	{
		pitem = ComponentList[i];
		pitem.Mass = pitem.Mass * ScaleMass;
		SetMass(pitem, pitem.Mass);
	}
}

simulated function SetCenterOfMass(PhysicalItem Part1, Vector com)
{
	local RB_BodySetup bs;
	local Quat q;

	q = QuatFromRotator(part1.PartActor.Rotation);
	com = QuatRotateVector(q, com);

	// Change auto calculated mass to the desired mass
	bs = Part1.PartActor.StaticMeshComponent.StaticMesh.BodySetup;
	bs.COMNudge = com;
	Part1.PartActor.StaticMeshComponent.BodyInstance.UpdateMassProperties(bs);
}

// TempRotatePart and RestoreRotatePart are used to deal with the problem that the constraint 
// angle limits are specified symmetrical. The part is temporary rotated so the high and low 
// limits become symmetrical. 
simulated function TempRotatePart(Joint Joint1, Actor Part1, Rotator r)
{
	local Vector pos, jointpos, OffsetInUU;

	OffsetInUU = class'UnitsConverter'.static.MeterVectorToUU(Joint1.offset);
	OffsetInUU.Z = -1* OffsetInUU.Z;

	if (Joint1.RelativeTo != None)
		jointpos = Joint1.RelativeTo.PartActor.Location + OffsetInUU;
	else
		jointpos = Location+OffsetInUU;
	
	pos = TransformVectorByRotation(r, Part1.Location - jointpos);
	SafedPosition = Part1.Location;
	SafedRotation = Part1.Rotation;
	Part1.SetRotation(Part1.Rotation + r);
	Part1.SetLocation(pos + jointpos);
}

simulated function RestoreRotatePart(Actor Part1)
{
	Part1.SetRotation(SafedRotation);
	Part1.SetLocation(SafedPosition);
}

simulated function RobotPart CreateDummyActor(Vector loc, Rotator r)
{
	local RobotPart dummy;

	dummy = Spawn(class'RobotPart', self, , loc, r);
	dummy.SetPhysicalCollisionProperties();
	dummy.SetCollision(false, false);

	return dummy;
}

// Update a joint angle target if changed
simulated function SetJointAngle(string JointName, int UUAngle)
{
	local int i;

	for (i=0;i<Joints.length;i++)
	{
		if( String(Joints[i].Name) == JointName )
		{
			Joints[i].DesiredAngularTarget = UUAngle + Joints[i].TrueZero;

			break;
		}
	}
}

simulated function SetJointAngularTarget( Joint joint, int UUAngle )
{
	local Rotator r;

	r = rot(0,0,0);
	if( joint.jointType == JOINTTYPE_Pitch )
	{
		r.Pitch = joint.CurAngularTarget;
	}
	else if( joint.jointType == JOINTTYPE_Yaw )
	{
		r.Yaw = joint.CurAngularTarget;
	}
	else if( joint.jointType == JOINTTYPE_Roll )
	{
		r.Roll = joint.CurAngularTarget;
	}
	else
	{
	}

	SetAngularTarget(joint.Constraint, r);
}

// Set stiffness of a joint
simulated function SetJointStiffnessByName(name JointName, float stiffness)
{
	local int i;
	for (i = 0; i < Joints.Length; i++)
	{
		if (Joints[i].Name == JointName)
		{
			SetJointStiffness(i, stiffness);
			break;
		}
	}
}

simulated function SetJointStiffness(int i, float stiffness)
{
	Joints[i].Stiffness = stiffness;
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(Joints[i].MaxForce*stiffness, 0.25, Joints[i].MaxForce*stiffness);
}

simulated function SetJointMaxForce(int i, float force)
{
	Joints[i].MaxForce = force;
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(Joints[i].MaxForce*Joints[i].Stiffness, 0.25, Joints[i].MaxForce*Joints[i].Stiffness);
}

simulated function SetJointDamping(int i, float damping)
{
	Joints[i].Constraint.ConstraintInstance.SetAngularDriveParams(Joints[i].MaxForce*Joints[i].Stiffness, damping, Joints[i].MaxForce*Joints[i].Stiffness);
}

// Initializes all joints on the true zero's.
simulated function InitJoints()
{
	local int i;
	local Rotator r;

	for (i = 0; i < Joints.Length; i++)
	{
		r = rot(0,0,0);
		if (Joints[i].jointType == JOINTTYPE_Pitch)
		{
			r.Pitch = Joints[i].CurAngularTarget;
		}
		else if (Joints[i].jointType == JOINTTYPE_Yaw)
		{
			r.Yaw = Joints[i].CurAngularTarget;
		}
		else if (Joints[i].jointType == JOINTTYPE_Roll)
		{
			r.Roll = Joints[i].CurAngularTarget;
		}

		SetAngularTarget(Joints[i].Constraint, r);
	}
}

simulated function PrintRotator(Rotator r)
{
	local vector vec;
	vec = class'UnitsConverter'.static.AngleVectorFromUU(r);
	LogInternal("Pitch:" $ class'UnitsConverter'.static.AngleToDeg(vec.Z) $
				" Yaw:" $ class'UnitsConverter'.static.AngleToDeg(vec.X) $
				" Roll:" $ class'UnitsConverter'.static.AngleToDeg(vec.Y));
}

function rotator rTurn(rotator rHeading,rotator rTurnAngle)
{
    // Generate a turn in object coordinates 
    // This should handle any gymbal lock issues
 
    local vector vForward,vRight,vUpward;
    local vector vForward2,vRight2,vUpward2;
    local rotator T;
    local vector  V;
 
    GetAxes(rHeading,vForward,vRight,vUpward);
    // Rotate in plane that contains vForward&vRight
    T.Yaw=rTurnAngle.Yaw; V=vector(T);
    vForward2=V.X*vForward + V.Y*vRight;
    vRight2=V.X*vRight - V.Y*vForward;
    vUpward2=vUpward;
 
    // Rotate in plane that contains vForward&vUpward
    T.Yaw=rTurnAngle.Pitch; V=vector(T);
    vForward=V.X*vForward2 + V.Y*vUpward2;
    vRight=vRight2;
    vUpward=V.X*vUpward2 - V.Y*vForward2;
 
    // Rotate in plane that contains vUpward&vRight
    T.Yaw=rTurnAngle.Roll; V=vector(T);
    vForward2=vForward;
    vRight2=V.X*vRight + V.Y*vUpward;
    vUpward2=V.X*vUpward - V.Y*vRight;
 
    T=OrthoRotation(vForward2,vRight2,vUpward2);
 
	return(T);    
}

static function rotator GetRelativeRotation(rotator MyRotation, rotator BaseRotation)
{
	local vector X, Y, Z;
	
	GetAxes(MyRotation, X, Y, Z);
	return OrthoRotation(X << BaseRotation, Y << BaseRotation, Z << BaseRotation);
}

simulated function ClientTimer()
{
	local string status;
	local int i;
	local PhysicalItem Part1, Part2;
	local float r, r2;
	local Rotator RelRot, RotTemp;
	local Vector X1, Y1, Z1, X2, Y2, Z2;

	super.ClientTimer();

	// Set velocity to the velocity of the first part in our array
	// This velocity can then be used by some of the sensors.
	self.Velocity = Body.PartActor.StaticMeshComponent.BodyInstance.Velocity;
	if (DebugCOM)
		DrawCenterOfMass();

	// Send the state of all joints
	status="STA {Type LeggedRobot}";
	for (i = 0; i < Joints.Length; i++)
	{
		Part1 = Joints[i].Parent;
		if (Part1 == None || Part1.PartActor == None)
			continue;
		Part2 = Joints[i].Child;
		if (Part2 == None || Part2.PartActor == None)
			continue;
		if (Joints[i].InverseMeasure)
			RelRot = GetRelativeRotation(Part1.PartActor.Rotation, Part2.PartActor.Rotation);
		else 
			RelRot = GetRelativeRotation(Part2.PartActor.Rotation, Part1.PartActor.Rotation);
		
		if (Joints[i].measureType == EMEASURE_Pitch)
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Pitch);
		else if (Joints[i].measureType == EMEASURE_Yaw)
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Yaw);
		else if (Joints[i].measureType == EMEASURE_Roll)
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Roll);
		else if (Joints[i].measureType == EMEASURE_Pitch_RemoveYaw)
		{
			RotTemp = rot(0, 0, 0);
			RotTemp.Yaw = -RelRot.Yaw;
			RelRot = rTurn(RelRot, RotTemp);
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Pitch);
		}
		else if (Joints[i].measureType == EMEASURE_Yaw_RemovePitch)
		{
			RotTemp = rot(0, 0, 0);
			RotTemp.Pitch = -RelRot.Pitch;
			RelRot = rTurn(RelRot, RotTemp);
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Yaw);
		}
		else if (Joints[i].measureType == EMEASURE_Yaw_RemoveRoll)
		{
			RotTemp = rot(0, 0, 0);
			RotTemp.Roll = -RelRot.Roll;
			RelRot = rTurn(RelRot, RotTemp);
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Yaw);
		}
		else if (Joints[i].measureType == EMEASURE_Roll_RemoveYaw)
		{
			RotTemp = rot(0, 0, 0);
			RotTemp.Yaw = -RelRot.Yaw;
			RelRot = rTurn(RelRot, RotTemp);
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Roll);
		}
		else if (Joints[i].measureType == EMEASURE_Roll_RemovePitch)
		{
			RotTemp = rot(0, 0, 0);
			RotTemp.Pitch = -RelRot.Pitch;
			RelRot = rTurn(RelRot, RotTemp);
			r = class'UnitsConverter'.static.AngleFromUU(RelRot.Roll);
		}
		else if (Joints[i].measureType == EMEASURE_Axis)
		{
			GetAxes(Part1.PartActor.Rotation, X1, Y1, Z1);
			GetAxes(Part2.PartActor.Rotation, X2, Y2, Z2);
			r = acos(X1 dot X2);
			r2 = acos((Normal(X1 cross Z1)) dot X2);
			LogInternal("r2: " $ r2);
			if (r2 < 0.0)
				r = -r;
			
			// Assume X1 and X1 are within 90 degrees to the left or right
			// Then we still need to know if the angle is positive or negative
		}
		if (Joints[i].InverseMeasureAngle)
			r = -r;

		Joints[i].CurAngle = r;
		status @= "{" $ Joints[i].Name @ Joints[i].CurAngle $ "} ";
	}
	if (DebugNotifyJointErrors)
		CheckJointErrors();

	if (vehicleBattery != None)
		status @= "{Battery " $ vehicleBattery.expectedLifeTime() $ "}";
	else
		status @= "{Battery 99999}";
	MessageSendDelegate(status);
}

function Tick(float DeltaTime)
{
	local int i;
	local int TurnRate;

	super.Tick( DeltaTime );

	// Turn X radian per second
	TurnRate = MaxJointAngularSpeed * DeltaTime * 10430.3783505;

	// Update joints to their desired angular position
	for (i=0;i<Joints.length;i++)
	{
		if( Joints[i].CurAngularTarget != Joints[i].DesiredAngularTarget )
		{
			if( abs(Joints[i].DesiredAngularTarget - Joints[i].CurAngularTarget) < TurnRate )
				Joints[i].CurAngularTarget = Joints[i].DesiredAngularTarget;
			else if( Joints[i].DesiredAngularTarget < Joints[i].CurAngularTarget )
				Joints[i].CurAngularTarget -= TurnRate;
			else
				Joints[i].CurAngularTarget += TurnRate;
			SetJointAngularTarget( Joints[i], Joints[i].CurAngularTarget );
		}
	}
}

// Get a part by name.
function PhysicalItem GetPart(name PartName)
{
	local int i;
	
	for (i = 0; i < ComponentList.Length; i++)
		if (ComponentList[i].Name == PartName)
			return ComponentList[i];
	return None;
}

// Debug functions

// Center of mass
function DrawCenterOfMassPart(PhysicalItem part)
{
	local Vector pos;

	pos = Location + part.PartActor.StaticMeshComponent.StaticMesh.BodySetup.COMNudge;
	
	DrawDebugPoint(pos, 32.0, MakeLinearColor(255, 0, 0, 255), false);
}

function DrawCenterOfMass()
{
	local int i;
	local Vector pos;
	local float TotalMass;
	local PhysicalItem pitem;

	// Calculate the center of mass of all parts together (average of each com)
	// http://en.wikipedia.org/wiki/Center_of_mass#Definition
	pos = Vect(0,0,0);
	TotalMass = 0.0;
	for (i = 0; i < ComponentList.Length; i++)
	{
		pitem = ComponentList[i];
		TotalMass += pitem.PartActor.StaticMeshComponent.BodyInstance.GetBodyMass();
		pos += pitem.PartActor.StaticMeshComponent.BodyInstance.GetBodyMass() *
			(pitem.PartActor.Location + pitem.PartActor.StaticMeshComponent.
			StaticMesh.BodySetup.COMNudge);
	}
	pos /= TotalMass;

	FlushPersistentDebugLines();
	DrawDebugSphere(pos, 8.0, 128, 0, 255, 0, true);
}

function ToggleNotifyJointErrors()
{
	DebugNotifyJointErrors = !DebugNotifyJointErrors;
}

function CheckJointErrors()
{
	local float r;
	local int i;

	for (i = 0; i < Joints.Length; i++)
	{
		if (Len(DebugNotifySpecificJointError) != 0 && DebugNotifySpecificJointError != String(Joints[i].Name))
			continue;
		r = class'UnitsConverter'.static.AngleFromUU(Joints[i].CurAngularTarget - Joints[i].trueZero);
		if (abs(r - Joints[i].CurAngle) > 0.02)
			LogInternal("Joint " $ Joints[i].Name $ ", desired: " $ r $ ", cur: " $
			Joints[i].CurAngle $ ", error:" $ abs(r-Joints[i].CurAngle));
	}
}

function SetAllJointsMaxForce(float force)
{
	local int i;

	for (i = 0; i < Joints.Length; i++)
		SetJointMaxForce(i, force);
}

function SetAllJointsDamping(float damping)
{
	local int i;

	for (i = 0; i < Joints.Length; i++)
		SetJointDamping(i, damping);
}

defaultproperties
{
	DebugCOM=false;
	DebugNotifyJointErrors=false;
	DebugNotifySpecificJointError="";

	MaxJointAngularSpeed = 3.0;

	// Don't need physics, this actor only acts as an controller
	// However we do want to derive from the usarvehicle for the messages
	Physics=PHYS_None

	// Collision should really be disabled.
	// The robot class more acts like a controller
	// Leaving collision on causes problems when spawning parts
	// (due the default collision cylinder of the Pawn class)
	BlockRigidBody=false
	bBlockActors=false
	bCollideActors=false
	bCollideWorld=false
	bPathColliding=false
	bProjTarget=false
	bCollideWhenPlacing=false

	bStatic=false
	bNoDelete=false
}
