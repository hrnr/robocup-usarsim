/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
 * Base class for USAR wheeled vehicles.
 */
class WheeledVehicle extends USARVehicle config(USAR) abstract;

// Wheel radius (must be set in config to mimic old api)
var float WheelRadius;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetupJoints();
}

function String GetGeoData()
{
	local int i;
	local int lFTire;
	local int rRTire;
	local BasicWheel wheel;
	local vector COMOffset;
	
	// Initialize to something known
	lFTire = -1; 
	rRTire = -1;
	
	for (i = 0; i < Joints.Length; i++)
		if (Joints[i].isA('BasicWheel')) {
			wheel = BasicWheel(Joints[i]);
			if (wheel.Side == SIDE_Left) {
				// Left side?
				if (lFTire == -1)
					lFTire = i;
				else if (wheel.Offset.X > Joints[lFTire].Offset.X)
					lFTire = i;
			} else if (wheel.Side == SIDE_Right) {
				// Right side!
				if (rRTire == -1)
					rRTire = i;
				else if (wheel.Offset.X < Joints[rRTire].Offset.X)
					rRTire = i;
			}
		}
	
	// FIXME How do we get this now?
	COMOffset.X = 0;
	COMOffset.Y = 0;
	COMOffset.Z = 0;
	
	return "GEO {Type GroundVehicle} {Name " $ self.Class $ "} {Dimensions " $ 
		class'UnitsConverter'.static.Str_LengthVectorFromUU(Dimensions) $ "} {COG " $
		class'UnitsConverter'.static.Str_LengthVectorFromUU(COMOffset) $ "} {WheelRadius " $
		class'UnitsConverter'.static.Str_LengthFromUU(WheelRadius) $ "} {WheelSeparation " $
		class'UnitsConverter'.static.Str_LengthFromUU(Joints[rRTire].Offset.Y -
		Joints[lFTire].Offset.Y) $ "} {WheelBase " $
		class'UnitsConverter'.static.Str_LengthFromUU(Joints[lFTire].Offset.X -
		Joints[rRTire].Offset.X) $ "}";
}

// Initializes joints and constraints
simulated function SetupJoints()
{
	local int i;
	local PhysicalItem Part1, Part2;
	local Vector angle, OffsetInUU, SpawnLocation;
	local Rotator r, r3;
	local Matrix m;
	
	for (i = 0; i < Joints.Length; i++)
	{
		Part1 = Joints[i].Parent;
		if (Part1.PartActor == None)
		{
			LogInternal("WheeledVehicle: No parent specified!");
			continue;
		}
		Part2 = Joints[i].Child;
		if (Part2.PartActor == None)
		{
			LogInternal("WheeledVehicle: No child specified!");
			continue;
		}

		Joints[i].CurAngularTarget = 0;
		
		angle.Y = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.X); // Pitch
		angle.Z = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.Y); // Yaw
		angle.X = class'UnitsConverter'.static.AngleFromDeg(Joints[i].Angle.Z); // Roll
		r = class'UnitsConverter'.static.AngleVectorToUU(angle);
		OffsetInUU = class'UnitsConverter'.static.MeterVectorToUU(Joints[i].offset);
		OffsetInUU.Z = -OffsetInUU.Z;
		
		// Get the constraint spawn location (can be relative to part)
		if (Joints[i].RelativeTo != None)
			SpawnLocation = Joints[i].RelativeTo.PartActor.Location + OffsetInUU;
		else
			SpawnLocation = OriginalLocation + OffsetInUU;
	
		Joints[i].Constraint = Spawn(class'BasicHinge', None, '', SpawnLocation, Rotation + r);

		r = rot(0, 0, 0);
		
		// Setup joint limits (depending on the joint type)
		if (Joints[i].jointType == JOINTTYPE_Pitch)
		{
			r.Pitch = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = false;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = true;
		}
		else if (Joints[i].jointType == JOINTTYPE_Yaw)
		{
			r.Yaw = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = false;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = true;
		}
		else if (Joints[i].jointType == JOINTTYPE_Roll)
		{
			r.Roll = Joints[i].trueZero;
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = true;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = false;
		}
		else if (Joints[i].jointType == JOINTTYPE_Fixed)
		{
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = true;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = true;
		}
		else if (Joints[i].jointType == JOINTTYPE_FREE)
		{
			Joints[i].Constraint.ConstraintSetup.bSwingLimited = false;
			Joints[i].Constraint.ConstraintSetup.bTwistLimited = false;
		}
		
		Joints[i].Constraint.ConstraintSetup.LinearXSetup.LimitSize = 0.0;
		Joints[i].Constraint.ConstraintSetup.LinearYSetup.LimitSize = 0.0;
		Joints[i].Constraint.ConstraintSetup.LinearZSetup.LimitSize  = 0.0;
		Joints[i].Constraint.ConstraintSetup.bEnableProjection = true;
		Joints[i].Constraint.InitConstraint(Part1.PartActor, Part2.PartActor, , , 6000.0);

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
			SetJointStiffness(i, 1.0);
		}
		else if (Joints[i].jointType == JOINTTYPE_Roll)
		{
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(false, true);
			SetJointStiffness(i, 1.0);
		}
		else if (Joints[i].jointType == JOINTTYPE_Fixed)
		{
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
			SetJointStiffness(i, 1.0);
		}
		else
			Joints[i].Constraint.ConstraintInstance.SetAngularPositionDrive(false, false);
	}
	InitJoints();
}

// Workaround for wheel radius in build-order
function float GetProperty(String key)
{
	if (key == "WheelRadius")
		return WheelRadius;
	return super.getProperty(key);
}

defaultproperties
{
	bStatic=false
	bNoDelete=false
	WheelRadius=0.0;
	
	// Don't need physics, this actor only acts as an controller
	// However we do want to derive from the USARVehicle for the messages
	Physics=PHYS_None	
}
