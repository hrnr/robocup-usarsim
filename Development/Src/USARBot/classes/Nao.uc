/*
 * Aldebaran Nao robot.
 * 
 * Joint information: 
 * http://users.aldebaran-robotics.com/docs/site_en/reddoc/hardware/joints-names.html
 * 
 * TODO: Implemented missing sensors
 * - Bumpers
 * - Gyrometer
 * - LEDS
 * - Microphones
 * - Loudspeakers
 * - (Optional) Laser sensor.
 * 
 */
class Nao extends LeggedVehicle config(USAR);

var Bool DebugNotifyJointErrors;
var String DebugNotifySpecificJointError;

// Special case for the Nao
// LHipYawPitch and RHipYawPitch are physically one motor
// LHipYawPitch controls RHipYawPitch
function SetJointTargetByName(String jointName, float target)
{
	if( JointName == "RHipYawPitch" )
		return;

	super.SetJointTargetByName(JointName, target);

	if( JointName == "LHipYawPitch" )
		super.SetJointTargetByName("RHipYawPitch", target);
}

// Temporary debug code
// Might be nice to integrate into the RevoluteJoint?
function ToggleNotifyJointErrors()
{
	DebugNotifyJointErrors = !DebugNotifyJointErrors;
}

function CheckJointErrors()
{
	local float r;
	local int i;
	local JointItem ji;
	local Rotator Target;

	for (i = 0; i < Parts.Length; i++)
	{
		if (!Parts[i].IsJoint())
			continue;
		ji = JointItem(Parts[i]);

		if( Len(DebugNotifySpecificJointError) != 0 && DebugNotifySpecificJointError != String(ji.GetJointName()) )
			continue;
		Target = QuatToRotator( ji.Constraint.ConstraintInstance.AngularPositionTarget );
		r = class'UnitsConverter'.static.AngleFromUU(Target.Roll-ji.TrueZero);
		if( abs(r-ji.CurValue) > 0.02 )
		{
			LogInternal("Joint " $ ji.GetJointName() $ ", desired: " $ r $ ", cur: " $ ji.CurValue $ ", error:" $ abs(r-ji.CurValue) );
		}
	} 
}

simulated function PostBeginPlay()
{
	//local int i, j;
	local Vector Tensor, CMass;
	local PhysicalItem pcopy, pdest;

	local int i;
	local JointItem ji;

	super.PostBeginPlay();


	for (i = 0; i < Parts.Length; i++)
	{
		if (!Parts[i].IsJoint())
			continue;
		ji = JointItem(Parts[i]);
		class'Utilities'.static.SetSolverExtrapolationFactor( ji.Constraint.ConstraintInstance, 1.75 );
	}
	
	// Temporary test code. Sometimes parts collide when they shouldn't collide, 
	// causing movements to fail.
	/*for (i = 0; i < Parts.Length; i++)
	{
		pcopy = PhysicalItem(Parts[i]);
		if( pcopy == none )
			continue;

		for (j = 0; j < Parts.Length; j++)
		{
			pdest = PhysicalItem(Parts[j]);
			if( pdest == none )
				continue;

			class'Utilities'.static.SetActorPairIgnore(pcopy.StaticMeshComponent.BodyInstance,
				pdest.StaticMeshComponent.BodyInstance, true);
		}
	}*/
	
	
	CMass.X = 0.04 * 5;
	CMass.Y = 0.0;
	CMass.Z = 0.0;
	pcopy = PhysicalItem( GetPartByName('BodyItem') );
	class'Utilities'.default.PhysXProxyInstance.SetCMassOffsetLocalPosition( pcopy.StaticMeshComponent.BodyInstance, CMass );

	// Bit of an hack here. The mass inertia tensor is calculated 
	// using the shape + mass of the part. However the Nao contains 
	// special small parts. We will copy the inertia tensor from the normal
	// parts, otherwise these parts become too floppy in behavior.

	// Copy mass inertia tensor from LThigh to LHip and LHipThigh
	pcopy = PhysicalItem( GetPartByName('LThigh') );
	Tensor = class'Utilities'.static.GetMassSpaceInertiaTensor( pcopy.StaticMeshComponent.BodyInstance );
	pdest = PhysicalItem( GetPartByName('LHipThigh') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );
	pdest = PhysicalItem( GetPartByName('LHip') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );

	// Copy mass inertia tensor from RThigh to RHip and RHipThigh
	pcopy = PhysicalItem( GetPartByName('RThigh') );
	Tensor = class'Utilities'.static.GetMassSpaceInertiaTensor( pcopy.StaticMeshComponent.BodyInstance );
	pdest = PhysicalItem( GetPartByName('RHipThigh') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );
	pdest = PhysicalItem( GetPartByName('RHip') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );

	// Copy mass inertia tensor from Foot to Ankle
	pcopy = PhysicalItem( GetPartByName('LShank') );
	Tensor = class'Utilities'.static.GetMassSpaceInertiaTensor( pcopy.StaticMeshComponent.BodyInstance );
	pdest = PhysicalItem( GetPartByName('LAnkle') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );
	pdest = PhysicalItem( GetPartByName('RAnkle') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );

	// Copy mass inertia tensor from upperarm to shoulder
	pcopy = PhysicalItem( GetPartByName('LUpperArm') );
	Tensor = class'Utilities'.static.GetMassSpaceInertiaTensor( pcopy.StaticMeshComponent.BodyInstance );
	pdest = PhysicalItem( GetPartByName('LShoulder') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );
	pdest = PhysicalItem( GetPartByName('RShoulder') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );

	// Copy mass inertia tensor from lowerarm to elbow
	pcopy = PhysicalItem( GetPartByName('LLowerArm') );
	Tensor = class'Utilities'.static.GetMassSpaceInertiaTensor( pcopy.StaticMeshComponent.BodyInstance );
	pdest = PhysicalItem( GetPartByName('LElbow') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );
	pdest = PhysicalItem( GetPartByName('RElbow') ); 
	class'Utilities'.static.SetMassSpaceInertiaTensor( pdest.StaticMeshComponent.BodyInstance, Tensor );

}

function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( DebugNotifyJointErrors )
		CheckJointErrors();
}


defaultproperties
{
	DebugNotifyJointErrors = false;
	DebugNotifySpecificJointError = "";

	// The Nao has two different motor types
	// Type 1 is used in the legs, type 2 in the arms and head.
	`define MaxForceMotorType1 2.25
	`define MaxForceMotorType2 2.25
	`define DampingMotorType1 0.00025
	`define DampingMotorType2 0.00025

	`define NaoSolverIterationCount 128

	// Create BodyItem part
	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Nao.naobody'
		Mass=1.03948
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Head + Joint
	Begin Object Class=Part Name=Head
		Mesh=StaticMesh'Nao.naohead'
		Offset=(x=0,y=0,z=-0.155)
		Mass=0.52065
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(Head)

	Begin Object Class=Part Name=Neck
		Mesh=StaticMesh'Nao.naohip'
		Offset=(x=0,y=0,z=-0.09)
		Mass=0.05930
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(Neck)

	DisableContacts.Add((Part1=BodyItem,Part2=Head))

	Begin Object Class=RevoluteJoint Name=HeadYaw
		Parent=Neck
		Child=BodyItem
		Offset=(x=0,y=0,z=-0.09)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		Direction=(x=0,y=0,z=0)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(HeadYaw)

	Begin Object Class=RevoluteJoint Name=HeadPitch
		Parent=Head
		Child=Neck
		Offset=(x=0,y=0,z=-0.09)
		LimitLow=-.672 // -38.5
		LimitHigh=.515 // 29.5
		Direction=(x=1.57,y=0,z=3.14)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(HeadPitch)

	// Create left and right shoulder
	Begin Object Class=Part Name=LUpperArm
		Mesh=StaticMesh'Nao.naolupperarm'
		Offset=(x=0.02,y=-0.108,z=-0.075)
		Mass=0.12309
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LUpperArm)

	Begin Object Class=Part Name=RUpperArm
		Mesh=StaticMesh'Nao.naorupperarm'
		Offset=(x=0.02,y=0.108,z=-0.075)
		Mass=0.12309
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RUpperArm)

	Begin Object Class=Part Name=LShoulder
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0,y=-0.098,z=-0.075)
		Mass=0.015
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LShoulder)

	Begin Object Class=Part Name=RShoulder
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0,y=0.098,z=-0.075)
		Mass=0.015
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RShoulder)

	DisableContacts.Add((Part1=LUpperArm,Part2=BodyItem))
	DisableContacts.Add((Part1=RUpperArm,Part2=BodyItem))

	// TODO: Might want to tweak the collision model 
	//       of the upper arm, so we don't need to do this.
	DisableContacts.Add((Part1=LUpperArm,Part2=Head))
	DisableContacts.Add((Part1=RUpperArm,Part2=Head))
	DisableContacts.Add((Part1=LShoulder,Part2=Head))
	DisableContacts.Add((Part1=RShoulder,Part2=Head))

	Begin Object Class=RevoluteJoint Name=LShoulderPitch
		Parent=BodyItem
		Child=LShoulder
		Offset=(x=0,y=-0.090,z=-0.075)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		Direction=(x=-1.57,y=0,z=3.14)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(LShoulderPitch)

	Begin Object Class=RevoluteJoint Name=LShoulderRoll
		Parent=LShoulder 
		Child=LUpperArm
		Offset=(x=0.01,y=-0.098,z=-0.075)
		LimitLow=.0087 // 0.5
		LimitHigh=1.649 // 94.5
		Direction=(x=3.14,y=0,z=1.57)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(LShoulderRoll)

	Begin Object Class=RevoluteJoint Name=RShoulderPitch
		Parent=BodyItem
		Child=RShoulder
		Offset=(x=0,y=0.098,z=-0.075) 
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		Direction=(x=-1.57,y=0,z=3.14)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(RShoulderPitch)

	Begin Object Class=RevoluteJoint Name=RShoulderRoll
		Parent=RShoulder 
		Child=RUpperArm
		Offset=(x=0,y=0.098,z=-0.075)
		LimitLow=-1.649 // -94.5
		LimitHigh=-.0087 // -0.5
		Direction=(x=3.14,y=0,z=1.57)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(RShoulderRoll)

	// Lower arm + elbow joint
	Begin Object Class=Part Name=LElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.10,y=-0.102,z=-0.075)
		Mass=0.040
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LElbow)

	Begin Object Class=Part Name=RElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.10,y=0.102,z=-0.075)
		Mass=0.040
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RElbow)

	Begin Object Class=Part Name=LLowerArm
		Mesh=StaticMesh'Nao.naollowerarm'
		Offset=(x=0.165,y=-0.098,z=-0.075)
		Mass=0.225
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LLowerArm)

	Begin Object Class=Part Name=RLowerArm
		Mesh=StaticMesh'Nao.naorlowerarm'
		Offset=(x=0.165,y=0.098,z=-0.075)
		Mass=0.225
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RLowerArm)

	DisableContacts.Add((Part1=LUpperArm,Part2=LLowerArm))
	DisableContacts.Add((Part1=RUpperArm,Part2=RLowerArm))

	Begin Object Class=RevoluteJoint Name=LElbowYaw
		Parent=LUpperArm
		Child=LElBow
		InverseMeasureAngle=true
		Offset=(x=0.10,y=-0.098,z=-0.075)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		Direction=(x=-1.57,y=-1.57,z=-1.57)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(LElbowYaw)

	Begin Object Class=RevoluteJoint Name=LElbowRoll
		Parent=LElBow
		Child=LLowerArm
		Offset=(x=0.10,y=-0.098,z=-0.075)
		LimitLow=-1.56 // -89.5
		LimitHigh=-.0087 // -0.5
		Direction=(x=-3.14,y=0,z=-3.14)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(LElbowRoll)

	Begin Object Class=RevoluteJoint Name=RElbowYaw
		Parent=RUpperArm
		Child=RElbow
		InverseMeasureAngle=true
		Offset=(x=0.10,y=0.098,z=-0.075)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		Direction=(x=-1.57,y=-1.57,z=-1.57)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(RElbowYaw)

	Begin Object Class=RevoluteJoint Name=RElbowRoll
		Parent=RElbow
		Child=RLowerArm
		Offset=(x=0.10,y=0.098,z=-0.075)
		LimitLow=-.0087 // -0.5
		LimitHigh=1.56 // 89.5
		Direction=(x=-3.14,y=0,z=-3.14)
		MaxForce=`MaxForceMotorType2
		Damping=`DampingMotorType2
	End Object
	Joints.Add(RElbowRoll)

	// Create HipYawPitch joints
	Begin Object Class=Part Name=LHip
		RelativeTo=BodyItem
		Mesh = StaticMesh'Nao.naoelbow'
		Offset=(x=-0.02,Y=-0.040,Z=0.065)
		Mass=0.025
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LHip)

	Begin Object Class=Part Name=RHip
		RelativeTo=BodyItem
		Mesh = StaticMesh'Nao.naoelbow'
		Offset=(x=-0.02,Y=0.040,Z=0.065)
		Mass=0.025
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RHip)

	Begin Object Class=RevoluteJoint Name=LHipYawPitch
		RelativeTo=LHip
		Parent=BodyItem 
		Child=LHip
		Offset=(x=0,y=0,z=0.02)
		LimitLow=-1.1452 // -65.62
		LimitHigh=0.7407 // 42.44
		Direction=(x=-0.79,y=0,z=3.14)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LHipYawPitch)

	Begin Object Class=RevoluteJoint Name=RHipYawPitch
		RelativeTo=RHip
		Parent=BodyItem 
		Child=RHip
		Offset=(x=0,y=0,z=0.02)
		LimitLow=-1.1452 // -65.62
		LimitHigh=0.7407 // 42.44
		Direction=(x=-2.36,y=0,z=3.14)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RHipYawPitch)


	// Thigh + hip joints
	Begin Object Class=Part Name=LHipThigh
		RelativeTo=LHip
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0,Y=-0.015,Z=0.04)
		Mass=0.015
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LHipThigh)

	Begin Object Class=Part Name=RHipThigh
		RelativeTo=RHip
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0,y=0.015,z=0.04)
		Mass=0.015
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RHipThigh)

	DisableContacts.Add((Part1=BodyItem,Part2=LHipThigh))
	DisableContacts.Add((Part1=BodyItem,Part2=RHipThigh))
	DisableContacts.Add((Part1=LHip,Part2=LHipThigh))
	DisableContacts.Add((Part1=RHip,Part2=RHipThigh))

	Begin Object Class=Part Name=LThigh
		RelativeTo=LHipThigh
		Mesh=StaticMesh'Nao.naolthigh'
		Offset=(x=0,Y=0,Z=0.035)
		Mass=0.39421
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LThigh)

	Begin Object Class=Part Name=RThigh
		RelativeTo=RHipThigh
		Mesh=StaticMesh'Nao.naorthigh'
		Offset=(x=0,y=0,z=0.035)
		Mass=0.39421
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RThigh)

	DisableContacts.Add((Part1=BodyItem,Part2=LThigh))
	DisableContacts.Add((Part1=BodyItem,Part2=RThigh))
	DisableContacts.Add((Part1=LHip,Part2=LThigh))
	DisableContacts.Add((Part1=RHip,Part2=RThigh))

	Begin Object Class=RevoluteJoint Name=LHipRoll
		RelativeTo=LHip
		Parent=LHip
		Child=LHipThigh
		InverseMeasureAngle=true
		Offset=(x=0,y=0,z=0.035)   
		LimitLow=-.3794 // -21.74
		LimitHigh=.7905 // 45.29
		Direction=(x=0,y=1.57,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LHipRoll)

	Begin Object Class=RevoluteJoint Name=LHipPitch
		RelativeTo=LHip
		Parent=LHipThigh
		Child=LThigh
		Offset=(x=0,y=0,z=0.035)
		LimitLow=-1.772 // -101.54
		LimitHigh=.4855 // 27.82
		Direction=(x=-1.57,y=0,z=3.14)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LHipPitch)

	Begin Object Class=RevoluteJoint Name=RHipRoll
		RelativeTo=RHip
		Parent=Rhip
		Child=RHipThigh
		InverseMeasureAngle=true
		Offset=(x=0,y=0,z=0.035)
		LimitLow=-.7382 // -42.30
		LimitHigh=.4147 // 23.76
		Direction=(x=0,y=1.57,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RHipRoll)

	Begin Object Class=RevoluteJoint Name=RHipPitch
		RelativeTo=RHip
		Parent=RHipThigh
		Child=RThigh
		Offset=(x=0,y=0,z=0.035)
		LimitLow=-1.772 // -101.54
		LimitHigh=.4855 // 27.82
		Direction=(x=-1.57,y=0,z=3.14)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RHipPitch)

	// Knee
	Begin Object Class=Part Name=LShank
		RelativeTo=LThigh
		Mesh=StaticMesh'Nao.naolshank'
		Offset=(x=0.005,y=0,z=0.12)
		Mass=0.29159
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LShank)

	Begin Object Class=Part Name=RShank
		RelativeTo=RThigh
		Mesh=StaticMesh'Nao.naorshank'
		Offset=(x=0.005,y=0,z=0.12)
		Mass=0.29159
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RShank)

	Begin Object Class=RevoluteJoint Name=LKneePitch
		RelativeTo=LShank
		Parent=LThigh
		Child=LShank
		Offset=(x=-0.01,y=0,z=-0.05)
		LimitLow=-.1029 // -5.90
		LimitHigh=2.120 // 121.47
		Direction=(x=1.57,y=0,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LKneePitch)

	Begin Object Class=RevoluteJoint Name=RKneePitch
		RelativeTo=RShank
		Parent=RThigh
		Child=RShank
		Offset=(x=-0.01,y=0,z=-0.05)
		LimitLow=-.1029 // -5.90
		LimitHigh=2.120 // 121.47
		Direction=(x=1.57,y=0,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RKneePitch)

	// Feet + ankle joint
	Begin Object Class=Part Name=LFoot
		RelativeTo=LShank
		Mesh=StaticMesh'Nao.naolfoot'
		Offset=(x=0.02,y=0,z=0.08)
		Mass=0.200
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LFoot)

	Begin Object Class=Part Name=RFoot
		RelativeTo=RShank
		Mesh=StaticMesh'Nao.naorfoot'
		Offset=(x=0.02,y=0,z=0.08)
		Mass=0.200
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RFoot)

	Begin Object Class=Part Name=LAnkle
		RelativeTo=LShank
		Mesh=StaticMesh'Nao.naohip'
		Offset=(x=0,Y=0,Z=0.035)
		Mass=0.138
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(LAnkle)

	Begin Object Class=Part Name=RAnkle
		RelativeTo=RShank
		Mesh=StaticMesh'Nao.naohip'
		Offset=(x=0,y=0,z=0.035)
		Mass=0.138
		SolverIterationCount=`NaoSolverIterationCount
	End Object
	PartList.Add(RAnkle)

	DisableContacts.Add((Part1=LFoot,Part2=LShank))
	DisableContacts.Add((Part1=RFoot,Part2=RShank))

	Begin Object Class=RevoluteJoint Name=LAnklePitch
		RelativeTo=LShank
		Parent=LShank
		Child=LAnkle
		Offset=(x=-0.01,y=0,z=0.03)
		LimitLow=-1.185 // -67.96
		LimitHigh=.9844 // 53.40
		Direction=(x=1.57,y=0,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LAnklePitch)

	Begin Object Class=RevoluteJoint Name=LAnkleRoll
		RelativeTo=LShank
		Parent=LAnkle
		Child=LFoot
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=0.04)
		LimitLow=-.7689 // -44.06
		LimitHigh=.3978 // 22.79
		Direction=(x=0,y=1.57,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(LAnkleRoll)

	Begin Object Class=RevoluteJoint Name=RAnklePitch
		RelativeTo=RShank
		Parent=RShank
		Child=RAnkle
		Offset=(x=-0.01,y=0,z=0.03)
		LimitLow=-1.1861 // -67.96
		LimitHigh=.9320 // 53.40
		Direction=(x=1.57,y=0,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RAnklePitch)

	Begin Object Class=RevoluteJoint Name=RAnkleRoll
		RelativeTo=RShank
		Parent=RAnkle
		Child=RFoot
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=0.04)
		LimitLow=-.3887 // -22.27
		LimitHigh=.7859 // 45.03
		Direction=(x=0,y=1.57,z=0)
		MaxForce=`MaxForceMotorType1
		Damping=`DampingMotorType1
	End Object
	Joints.Add(RAnkleRoll)


	// These parts shouldn't collide with the arms
	DisableContacts.Add((Part1=LHip,Part2=LLowerArm))
	DisableContacts.Add((Part1=RHip,Part2=RLowerArm))
	DisableContacts.Add((Part1=LHipThigh,Part2=LLowerArm))
	DisableContacts.Add((Part1=RHipThigh,Part2=RLowerArm))
	DisableContacts.Add((Part1=LThigh,Part2=LLowerArm))
	DisableContacts.Add((Part1=RThigh,Part2=RLowerArm))

	/*
	DisableContacts.Add((Part1=LThigh,Part2=RHip))
	DisableContacts.Add((Part1=LThigh,Part2=RHipThigh))
	DisableContacts.Add((Part1=RThigh,Part2=LHip))
	DisableContacts.Add((Part1=RThigh,Part2=LHipThigh))

	DisableContacts.Add((Part1=LHip,Part2=RHipThigh))
	DisableContacts.Add((Part1=LHipThigh,Part2=RHip))
	DisableContacts.Add((Part1=LHip,Part2=RHip))
	DisableContacts.Add((Part1=LHipThigh,Part2=RHipThigh))
	DisableContacts.Add((Part1=LThigh,Part2=RThigh))
	*/

	DisableContacts.Add((Part1=LShank,Part2=LLowerArm))
	DisableContacts.Add((Part1=RShank,Part2=RLowerArm))
	DisableContacts.Add((Part1=LShank,Part2=LElbow))
	DisableContacts.Add((Part1=RShank,Part2=RElbow))
	DisableContacts.Add((Part1=LThigh,Part2=LElbow))
	DisableContacts.Add((Part1=RThigh,Part2=RElbow))
	DisableContacts.Add((Part1=LHip,Part2=LElbow))
	DisableContacts.Add((Part1=RHip,Part2=RElbow))
	DisableContacts.Add((Part1=LHipThigh,Part2=LElbow))
	DisableContacts.Add((Part1=RHipThigh,Part2=RElbow))
}
