/*
 * Possible example on how to use RevoluteJoints. However, this class needs to be remade to
 * take the new changes into account.
 * 
 * - All joints now revolve around their Z axis. Remove RotateAxis and use Direction to
 *   transform the joint in the desired direction.
 * - Use gearing equations instead of measurement types if custom measurements are needed.
 * 
 * TODO Remove this comment once changes are made
 */
class Nao extends LeggedVehicle config(USAR);

// Special case for the Nao
// LHipYawPitch and RHipYawPitch are physically one motor
// LHipYawPitch also controls RHipYawPitch
function SetJointTargetByName(String jointName, float target)
{
	if( JointName == "RHipYawPitch" )
		return;

	super.SetJointTargetByName(JointName, target);

	if( JointName == "LHipYawPitch" )
		super.SetJointTargetByName("RHipYawPitch", target);
}

// Gearing equation example to replace measurement types
simulated function float JointTransform(JointItem ji, float value)
{
	local rotator relRot, rotTemp;
	local RevoluteJoint jt;
	
	jt = RevoluteJoint(ji.Spec);
	if (jt == None) return value;
	if (jt.InverseMeasure)
		relRot = jt.GetRelativeRotation(ji.Parent.Rotation, ji.Child.Rotation);
	else 
		relRot = jt.GetRelativeRotation(ji.Child.Rotation, ji.Parent.Rotation);
	if (ji.GetJointName() == 'HeadPitch')
	{
		rotTemp = rot(0, 0, 0);
		rotTemp.Yaw = -relRot.Yaw;
		relRot = class'Utilities'.static.rTurn(relRot, rotTemp);
		value = class'UnitsConverter'.static.AngleFromUU(relRot.Pitch);
	}
	return value;
}

defaultproperties
{
	// Create BodyItem part
/*	Begin Object Class=Part Name=BodyItem
		Mesh=StaticMesh'Nao.naobody'
		Mass=1.03948
	End Object
	Body=BodyItem
	PartList.Add(BodyItem)

	// Head + Joint
	Begin Object Class=Part Name=Head
		Mesh=StaticMesh'Nao.naohead'
		Offset=(x=0,y=0,z=-0.155)
		Mass=0.52065
	End Object
	PartList.Add(Head)

	Begin Object Class=RevoluteJoint Name=HeadPitch
		Parent=Head
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Pitch_RemoveYaw
		Offset=(x=0,y=0,z=-0.09)
		LimitLow=-.672 // -38.5
		LimitHigh=.515 // 29.5
		RotateAxis=(x=3.14,y=0,z=-1.57)
	End Object
	Joints.Add(HeadPitch)

	Begin Object Class=RevoluteJoint Name=HeadYaw
		Parent=Head
		Child=BodyItem
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Yaw
		Offset=(x=0,y=0,z=-0.09)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		RotateAxis=(x=3.14,y=0,z=-1.57)
	End Object
	Joints.Add(HeadYaw)

	// Create left and right arm parts
	Begin Object Class=Part Name=LUpperArm
		Mesh=StaticMesh'Nao.naolupperarm'
		Offset=(x=0.02,y=-0.108,z=-0.075)
		Mass=0.12309
	End Object
	PartList.Add(LUpperArm)

	Begin Object Class=Part Name=RUpperArm
		Mesh=StaticMesh'Nao.naorupperarm'
		Offset=(x=0.02,y=0.108,z=-0.075)
		Mass=0.12309
	End Object
	PartList.Add(RUpperArm)

	Begin Object Class=Part Name=LElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.09,y=-0.108,z=-0.075)
		Mass=0.12309
	End Object
	PartList.Add(LElbow)

	Begin Object Class=Part Name=RElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.09,y=0.108,z=-0.075)
		Mass=0.12309
	End Object
	PartList.Add(RElbow)

	Begin Object Class=Part Name=LLowerArm
		Mesh=StaticMesh'Nao.naollowerarm'
		Offset=(x=0.14,y=-0.098,z=-0.084)
		Mass=0.200
	End Object
	PartList.Add(LLowerArm)

	Begin Object Class=Part Name=RLowerArm
		Mesh=StaticMesh'Nao.naorlowerarm'
		Offset=(x=0.14,y=0.098,z=-0.084)
		Mass=0.200
	End Object
	PartList.Add(RLowerArm)

	// Create shoulder
	Begin Object Class=RevoluteJoint Name=LShoulderRoll
		Parent=LUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemovePitch
		Offset=(x=0,y=-0.098,z=-0.075)
		LimitLow=.0087 // 0.5
		LimitHigh=1.649 // 94.5
		RotateAxis=(x=0,y=1.57,z=-3.14)
	End Object
	Joints.Add(LShoulderRoll)

	Begin Object Class=RevoluteJoint Name=LShoulderPitch
		Parent=LUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=0,y=-0.098,z=-0.075)
		LimitLow=-2.086 // -199.5
		LimitHigh=2.086 // 119.5
		RotateAxis=(x=0,y=1.57,z=-3.14)
	End Object
	Joints.Add(LShoulderPitch)

	Begin Object Class=RevoluteJoint Name=RShoulderRoll
		Parent=RUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemovePitch
		Offset=(x=0,y=0.098,z=-0.075)
		LimitLow=-1.649 // -94.5
		LimitHigh=-.0087 // -0.5
		RotateAxis=(x=0,y=1.57,z=-3.14)
	End Object
	Joints.Add(RShoulderRoll)

	Begin Object Class=RevoluteJoint Name=RShoulderPitch
		Parent=RUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=0,y=0.098,z=-0.075) 
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		RotateAxis=(x=0,y=1.57,z=-3.14)
	End Object
	Joints.Add(RShoulderPitch)

	// Create elbow
	Begin Object Class=RevoluteJoint Name=LElbowYaw
		Parent=LUpperArm
		Child=LElBow
		IsOneDof=true;
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=0.09,y=-0.098,z=-0.084)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		RotateAxis=(x=1.57,y=-1.57,z=-1.57)
	End Object
	Joints.Add(LElbowYaw)

	Begin Object Class=RevoluteJoint Name=LElbowRoll
		Parent=LElBow
		Child=LLowerArm
		IsOneDof=true;
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemoveRoll
		Offset=(x=0.09,y=-0.098,z=-0.084)
		LimitLow=-1.56 // -89.5
		LimitHigh=-.0087 // -0.5
		RotateAxis=(x=-1.57,y=-1.57,z=-1.57)
	End Object
	Joints.Add(LElbowRoll)

	Begin Object Class=RevoluteJoint Name=RElbowYaw
		Parent=RUpperArm
		Child=RElbow
		IsOneDof=true;
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=0.09,y=0.098,z=-0.084)
		LimitLow=-2.086 // -119.5
		LimitHigh=2.086 // 119.5
		RotateAxis=(x=1.57,y=-1.57,z=-1.57)
	End Object
	Joints.Add(RElbowYaw)

	Begin Object Class=RevoluteJoint Name=RElbowRoll
		Parent=RElbow
		Child=RLowerArm
		IsOneDof=true;
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemoveRoll
		Offset=(x=0.09,y=0.098,z=-0.084)
		LimitLow=-.0087 // -0.5
		LimitHigh=1.56 // 89.5
		RotateAxis=(x=-1.57,y=-1.57,z=-1.57)
	End Object
	Joints.Add(RElbowRoll)

	// Create leg parts
	Begin Object Class=Part Name=LHip
		Mesh = StaticMesh'Nao.naohip'
		Offset=(x=-0.01,Y=-0.055,Z=0.08)
		Mass=0.12309
	End Object
	PartList.Add(LHip)

	Begin Object Class=Part Name=RHip
		Mesh = StaticMesh'Nao.naohip'
		Offset=(x=-0.01,Y=0.055,Z=0.08)
		Mass=0.12309
	End Object
	PartList.Add(RHip)

	Begin Object Class=Part Name=LThigh
		RelativeTo=BodyItem
		Mesh=StaticMesh'Nao.naolthigh'
		Offset=(x=-0.01,Y=-0.055,Z=0.155)
		Mass=0.39421
	End Object
	PartList.Add(LThigh)

	Begin Object Class=Part Name=RThigh
		RelativeTo=BodyItem
		Mesh=StaticMesh'Nao.naorthigh'
		Offset=(x=-0.01,y=0.055,z=0.155)
		Mass=0.39421
	End Object
	PartList.Add(RThigh)

	Begin Object Class=Part Name=LShank
		RelativeTo=LThigh
		Mesh=StaticMesh'Nao.naolshank'
		Offset=(x=0.005,y=0,z=0.125)
		Mass=0.29159
	End Object
	PartList.Add(LShank)

	Begin Object Class=Part Name=RShank
		RelativeTo=RThigh
		Mesh=StaticMesh'Nao.naorshank'
		Offset=(x=0.005,y=0,z=0.125)
		Mass=0.29159
	End Object
	PartList.Add(RShank)

	Begin Object Class=Part Name=LFoot
		RelativeTo=LShank
		Mesh=StaticMesh'Nao.naolfoot'
		Offset=(x=0.02,y=0,z=0.09)
		Mass=1.5000
	End Object
	PartList.Add(LFoot)

	Begin Object Class=Part Name=RFoot
		RelativeTo=RShank
		Mesh=StaticMesh'Nao.naorfoot'
		Offset=(x=0.02,y=0,z=0.09)
		Mass=1.5000
	End Object
	PartList.Add(RFoot)

	// Create hip joint
	Begin Object Class=RevoluteJoint Name=LHipYawPitch
		IsOneDof=true
		Parent=LHip
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=-0.055,z=0.1)
		LimitLow=-1.1452 // -65.62
		LimitHigh=0.7407 // 42.44
		RotateAxis=(x=2.3562,y=0,z=0)
	End Object
	Joints.Add(LHipYawPitch)

	Begin Object Class=RevoluteJoint Name=RHipYawPitch
		IsOneDof=true
		Parent=RHip
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0.055,z=0.1)
		LimitLow=-1.1452 // -65.62
		LimitHigh=0.7407 // 42.44
		RotateAxis=(x=2.3562,y=0,z=0)
	End Object
	Joints.Add(RHipYawPitch)

	Begin Object Class=RevoluteJoint Name=LHipPitch
		Parent=LThigh
		Child=LHip
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=-0.055,z=0.115)
		LimitLow=-1.772 // -101.54
		LimitHigh=.4855 // 27.82
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(LHipPitch)

	Begin Object Class=RevoluteJoint Name=LHipRoll
		Parent=LThigh
		Child=LHip
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=-0.055,z=0.115)   
		LimitLow=-.738 // -42.30
		LimitHigh=.4147 // 23.76
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(LHipRoll)

	Begin Object Class=RevoluteJoint Name=RHipPitch
		Parent=RThigh
		Child=RHip
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0.055,z=0.115)
		LimitLow=-1.772 // -101.54
		LimitHigh=.4855 // 27.82
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(RHipPitch)

	Begin Object Class=RevoluteJoint Name=RHipRoll
		Parent=RThigh
		Child=RHip
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0.055,z=0.115)
		LimitLow=-.7382 // -42.30
		LimitHigh=.4147 // 23.76
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(RHipRoll)

	// Create knee joint
	Begin Object Class=RevoluteJoint Name=LKneePitch
		RelativeTo=LShank
		IsOneDof=true;
		Parent=LShank
		Child=LThigh
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=-0.045)
		LimitLow=-.1029 // -5.90
		LimitHigh=2.120 // 121.47
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(LKneePitch)

	Begin Object Class=RevoluteJoint Name=RKneePitch
		RelativeTo=RShank
		IsOneDof=true;
		Parent=RShank
		Child=RThigh
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=-0.045)
		LimitLow=-.1029 // -5.90
		LimitHigh=2.120 // 121.47
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(RKneePitch)

	// Create ankle joint
	Begin Object Class=RevoluteJoint Name=LAnklePitch
		RelativeTo=LShank
		Parent=LFoot
		Child=LShank
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=0.055)
		LimitLow=-1.185 // -67.96
		LimitHigh=.9844 // 53.40
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(LAnklePitch)

	Begin Object Class=RevoluteJoint Name=LAnkleRoll
		RelativeTo=LShank
		Parent=LFoot
		Child=LShank
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=0.055)
		LimitLow=-.7689 // -44.06
		LimitHigh=.3978 // 22.79
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(LAnkleRoll)

	Begin Object Class=RevoluteJoint Name=RAnklePitch
		RelativeTo=RShank
		Parent=RFoot
		Child=RShank
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=0.055)
		LimitLow=-1.1861 // -67.96
		LimitHigh=.9320 // 53.40
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(RAnklePitch)

	Begin Object Class=RevoluteJoint Name=RAnkleRoll
		RelativeTo=RShank
		Parent=RFoot
		Child=RShank
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=0.055)
		LimitLow=-.3887 // -22.27
		LimitHigh=.7859 // 45.03
		RotateAxis=(x=0,y=1.57,z=-1.57)
	End Object
	Joints.Add(RAnkleRoll) */
}
