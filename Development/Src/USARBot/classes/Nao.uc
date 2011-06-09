class Nao extends LeggedRobot config(USAR);

simulated function SetJointAngle( string JointName, int UUAngle )
{
	// Ignore RHipYawPitch
	if( JointName == "RHipYawPitch" )
		return;

	super.SetJointAngle( JointName, UUAngle );

	// LHipYawPitch also controls RHipYawPitch (physically one motor, see Nao documentation)
	if( JointName == "LHipYawPitch" )
		super.SetJointAngle( "RHipYawPitch", UUAngle );
}

defaultproperties
{
	// Create BodyItem part
	Begin Object Class=PhysicalItem Name=BodyItem
		Mesh=StaticMesh'Nao.naobody'
		Mass= 1039.48
	End Object
	Body=BodyItem
	ComponentList.Add(BodyItem)

	// Head + Joint
	Begin Object Class=PhysicalItem Name=Head
		Mesh=StaticMesh'Nao.naohead'
		Offset=(x=0,y=0,z=0.155)
		Mass= 520.65
	End Object
	ComponentList.Add(Head)

	Begin Object Class=Joint Name=HeadPitch
		Parent=Head
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Pitch_RemoveYaw
		Offset=(x=0,y=0,z=0.09)
		LimitLow=-38.5
		LimitHigh=29.5
		RotateAxis=(x=0,y=-90,z=180)
	End Object
	Joints.Add(HeadPitch)

	Begin Object Class=Joint Name=HeadYaw
		Parent=Head
		Child=BodyItem
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Yaw
		Offset=(x=0,y=0,z=0.09)
		LimitLow=-119.5
		LimitHigh=119.5
		RotateAxis=(x=0,y=-90,z=180)
	End Object
	Joints.Add(HeadYaw)

	// Create left and right arm parts
	Begin Object Class=PhysicalItem Name=LUpperArm
		Mesh=StaticMesh'Nao.naolupperarm'
		Offset=(x=0.02,y=-0.108,z=0.075)
		Mass=123.09
	End Object
	ComponentList.Add(LUpperArm)

	Begin Object Class=PhysicalItem Name=RUpperArm
		Mesh=StaticMesh'Nao.naorupperarm'
		Offset=(x=0.02,y=0.108,z=0.075)
		Mass=123.09
	End Object
	ComponentList.Add(RUpperArm)

	Begin Object Class=PhysicalItem Name=LElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.09,y=-0.108,z=0.075)
		Mass=123.09
	End Object
	ComponentList.Add(LElbow)

	Begin Object Class=PhysicalItem Name=RElbow
		Mesh=StaticMesh'Nao.naoelbow'
		Offset=(x=0.09,y=0.108,z=0.075)
		Mass=123.09
	End Object
	ComponentList.Add(RElbow)

	Begin Object Class=PhysicalItem Name=LLowerArm
		Mesh=StaticMesh'Nao.naollowerarm'
		Offset=(x=0.14,y=-0.098,z=0.084)
		Mass=200
	End Object
	ComponentList.Add(LLowerArm)

	Begin Object Class=PhysicalItem Name=RLowerArm
		Mesh=StaticMesh'Nao.naorlowerarm'
		Offset=(x=0.14,y=0.098,z=0.084)
		Mass=200
	End Object
	ComponentList.Add(RLowerArm)

	// Create shoulder
	Begin Object Class=Joint Name=LShoulderRoll
		Parent=LUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemovePitch
		Offset=(x=0,y=-0.098,z=0.075)
		LimitLow=0.5
		LimitHigh=94.5
		RotateAxis=(x=90,y=-180,z=0) 
	End Object
	Joints.Add(LShoulderRoll)

	
	Begin Object Class=Joint Name=LShoulderPitch
		Parent=LUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=0,y=-0.098,z=0.075) 
		LimitLow=-119.5
		LimitHigh=119.5
		RotateAxis=(x=90,y=-180,z=0)
	End Object
	Joints.Add(LShoulderPitch)

	Begin Object Class=Joint Name=RShoulderRoll
		Parent=RUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemovePitch
		Offset=(x=0,y=0.098,z=0.075)
		LimitLow=-94.5
		LimitHigh=-0.5
		RotateAxis=(x=90,y=-180,z=0)
	End Object
	Joints.Add(RShoulderRoll)

	Begin Object Class=Joint Name=RShoulderPitch
		Parent=RUpperArm
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=0,y=0.098,z=0.075) 
		LimitLow=-119.5
		LimitHigh=119.5
		RotateAxis=(x=90,y=-180,z=0)
	End Object
	Joints.Add(RShoulderPitch)

	// Create elbow
	Begin Object Class=Joint Name=LElbowYaw
		Parent=LUpperArm
		Child=LElBow
		IsOneDof=true;
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=0.09,y=-0.098,z=0.084)
		LimitLow=-119.5
		LimitHigh=119.5
		RotateAxis=(x=-90,y=-90,z=90)
	End Object
	Joints.Add(LElbowYaw)

	Begin Object Class=Joint Name=LElbowRoll
		Parent=LElBow
		Child=LLowerArm
		IsOneDof=true;
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemoveRoll
		Offset=(x=0.09,y=-0.098,z=0.084)
		LimitLow=-89.5
		LimitHigh=-0.5
		RotateAxis=(x=-90,y=-90,z=-90)
	End Object
	Joints.Add(LElbowRoll)

	Begin Object Class=Joint Name=RElbowYaw
		Parent=RUpperArm
		Child=RElbow
		IsOneDof=true;
		jointType=JOINTTYPE_Yaw
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=0.09,y=0.098,z=0.084)
		LimitLow=-119.5
		LimitHigh=119.5
		RotateAxis=(x=-90,y=-90,z=90)
	End Object
	Joints.Add(RElbowYaw)

	Begin Object Class=Joint Name=RElbowRoll
		Parent=RElbow
		Child=RLowerArm
		IsOneDof=true;
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Yaw_RemoveRoll
		Offset=(x=0.09,y=0.098,z=0.084)
		LimitLow=0.5
		LimitHigh=89.5
		RotateAxis=(x=-90,y=-90,z=-90)
	End Object
	Joints.Add(RElbowRoll)

	// Create leg parts
	Begin Object Class=PhysicalItem Name=LHip
		Mesh = StaticMesh'Nao.naohip'
		Offset=(x=-0.01,Y=-0.055,Z=-0.08)
		Mass=123.09
	End Object
	ComponentList.Add(LHip)

	Begin Object Class=PhysicalItem Name=RHip
		Mesh = StaticMesh'Nao.naohip'
		Offset=(x=-0.01,Y=0.055,Z=-0.08)
		Mass=123.09
	End Object
	ComponentList.Add(RHip)

	Begin Object Class=PhysicalItem Name=LThigh
		RelativeTo = BodyItem
		Mesh = StaticMesh'Nao.naolthigh'
		Offset=(x=-0.01,Y=-0.055,Z=-0.155)
		//Offset=(x=-0.020,Y=-0.055,Z=-0.155)
		Mass=394.21
	End Object
	ComponentList.Add(LThigh)

	Begin Object Class=PhysicalItem Name=RThigh
		RelativeTo=BodyItem
		Mesh=StaticMesh'Nao.naorthigh'
		Offset=(x=-0.01,y=0.055,z=-0.155)
		//Offset=(x=-0.020,y=0.055,z=-0.155)
		Mass=394.21
	End Object
	ComponentList.Add(RThigh)

	Begin Object Class=PhysicalItem Name=LShank
		RelativeTo=LThigh
		Mesh=StaticMesh'Nao.naolshank'
		Offset=(x=0.005,y=0,z=-0.125)
		Mass=291.59
	End Object
	ComponentList.Add(LShank)

	Begin Object Class=PhysicalItem Name=RShank
		RelativeTo=RThigh
		Mesh=StaticMesh'Nao.naorshank'
		Offset=(x=0.005,y=0,z=-0.125)
		Mass=291.59
	End Object
	ComponentList.Add(RShank)

	Begin Object Class=PhysicalItem Name=LFoot
		RelativeTo=LShank
		Mesh=StaticMesh'Nao.naolfoot'
		Offset=(x=0.02,y=0,z=-0.09)
		//Mass=161.75
		Mass=1500.0
	End Object
	ComponentList.Add(LFoot)

	Begin Object Class=PhysicalItem Name=RFoot
		RelativeTo=RShank
		Mesh=StaticMesh'Nao.naorfoot'
		Offset=(x=0.02,y=0,z=-0.09)
		//Mass = 161.75
		Mass=1500.0
	End Object
	ComponentList.Add(RFoot)

	// Create hip joint
	Begin Object Class=Joint Name=LHipYawPitch
		IsOneDof=true
		Parent=LHip
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=-0.055,z=-0.1)
		LimitLow=-65.62
		LimitHigh=42.44
		RotateAxis=(x=0,y=0,z=135)
	End Object
	Joints.Add(LHipYawPitch)

	Begin Object Class=Joint Name=RHipYawPitch
		IsOneDof=true
		Parent=RHip
		Child=BodyItem
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0.055,z=-0.1)
		LimitLow=-65.62
		LimitHigh=42.44
		RotateAxis=(x=0,y=0,z=-135)
	End Object
	Joints.Add(RHipYawPitch)

	Begin Object Class=Joint Name=LHipPitch
		Parent=LThigh
		Child=LHip
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=-0.055,z=-0.115)
		LimitLow=-101.54
		LimitHigh=27.82
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(LHipPitch)

	Begin Object Class=Joint Name=LHipRoll
		Parent=LThigh
		Child=LHip
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=-0.055,z=-0.115)   
		LimitLow=-42.30
		LimitHigh=23.76
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(LHipRoll)

	Begin Object Class=Joint Name=RHipPitch
		Parent=RThigh
		Child=RHip
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0.055,z=-0.115)
		LimitLow=-101.54
		LimitHigh=27.82
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(RHipPitch)

	Begin Object Class=Joint Name=RHipRoll
		Parent=RThigh
		Child=RHip
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0.055,z=-0.115)
		LimitLow=-42.30
		LimitHigh=23.76
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(RHipRoll)

	// Create knee joint
	Begin Object Class=Joint Name=LKneePitch
		RelativeTo=LShank
		IsOneDof=true;
		Parent=LShank
		Child=LThigh
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=0.045)
		LimitLow=-5.90
		LimitHigh=121.47
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(LKneePitch)

	Begin Object Class=Joint Name=RKneePitch
		RelativeTo=RShank
		IsOneDof=true;
		Parent=RShank
		Child=RThigh
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=0.045)
		LimitLow=-5.90
		LimitHigh=121.47
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(RKneePitch)

	// Create ankle joint
	Begin Object Class=Joint Name=LAnklePitch
		RelativeTo=LShank
		Parent=LFoot
		Child=LShank
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=-0.055)
		LimitLow=-67.96
		LimitHigh=53.40
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(LAnklePitch)

	Begin Object Class=Joint Name=LAnkleRoll
		RelativeTo=LShank
		Parent=LFoot
		Child=LShank
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=-0.055)
		LimitLow=-44.06
		LimitHigh=22.79
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(LAnkleRoll)

	Begin Object Class=Joint Name=RAnklePitch
		RelativeTo=RShank
		Parent=RFoot
		Child=RShank
		jointType=JOINTTYPE_Pitch
		measureType=EMEASURE_Pitch
		Offset=(x=-0.01,y=0,z=-0.055)
		LimitLow=-67.96
		LimitHigh=53.40
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(RAnklePitch)

	Begin Object Class=Joint Name=RAnkleRoll
		RelativeTo=RShank
		Parent=RFoot
		Child=RShank
		jointType=JOINTTYPE_Roll
		measureType=EMEASURE_Roll
		InverseMeasureAngle=true
		Offset=(x=-0.01,y=0,z=-0.055)
		LimitLow=-22.27
		LimitHigh=45.03
		RotateAxis=(x=180,y=-180,z=0)
	End Object
	Joints.Add(RAnkleRoll)
}
