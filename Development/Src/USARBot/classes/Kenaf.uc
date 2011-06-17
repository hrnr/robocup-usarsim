class Kenaf extends SkidSteeredVehicle config(USAR);

// Macro to define a flipper joint, so we don't need to repeat code
`define CreateFlipper(FlipperName, PosX, PosY, FlipperDirection, FlipperJointDirection, WheelJointDirection, Side, IsRear) \
	Begin Object Class=Part Name=`{FlipperName}Part\n \
		Mesh=StaticMesh'Kenaf.Kenaf_Flipper'\n \
		Offset=(X=`{PosX},Y=`{PosY},Z=0)\n \
		Mass=0.1\n \
		Direction=`{FlipperDirection}\n \
	End Object\n \
	PartList.Add(`{FlipperName}Part)\n \
	\
	Begin Object Class=RevoluteJoint Name=`{FlipperName}\n \
		Parent=ChassisMiddle\n \
		Child=`{FlipperName}Part\n \
		Offset=(X=`{PosX},Y=`{PosY},Z=0)\n \
		LimitLow=-2.086\n \
		LimitHigh=2.086\n \
		Direction=`{FlipperJointDirection}\n \
		MaxForce=`FlipperMaxForce\n \
	End Object\n \
	Joints.Add(`{FlipperName})\n \
	\
	Begin Object Class=Part Name=`{FlipperName}Wheel\n \
		RelativeTo=`{FlipperName}Part\n \
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'\n \
		Offset=(X=0,Y=0,Z=0)\n \
		Mass=0.1\n \
	End Object\n \
	PartList.Add(`{FlipperName}Wheel)\n \
	\
	Begin Object Class=WheelJoint Name=`{FlipperName}WheelJoint\n \
		RelativeTo=`{FlipperName}Part\n \
		Parent=`{FlipperName}Part\n \
		Child=`{FlipperName}Wheel\n \
		Side=`{Side}\n \
		Offset=(X=0,Y=0,Z=0)\n \
		Direction=`{WheelJointDirection}\n \
	End Object\n \
	Joints.Add(`{FlipperName}WheelJoint)\n \
	\
	Begin Object Class=Part Name=`{FlipperName}LargeWheel\n \
		RelativeTo=`{FlipperName}Part\n \
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'\n \
`if(`IsRear) \
		Offset=(X=-0.065,Y=0,Z=0)\n \
`else \
		Offset=(X=0.065,Y=0,Z=0)\n \
`endif \
		Mass=0.1\n \
	End Object\n \
	PartList.Add(`{FlipperName}LargeWheel)\n \
	\
	Begin Object Class=WheelJoint Name=`{FlipperName}LargeWheelJoint\n \
		RelativeTo=`{FlipperName}Part\n \
		Parent=`{FlipperName}Part\n \
		Child=`{FlipperName}LargeWheel\n \
		Side=`{Side}\n \
`if(`IsRear) \
		Offset=(X=-0.065,Y=0,Z=0)\n \
`else \
		Offset=(X=0.065,Y=0,Z=0)\n \
`endif \
		Direction=`{WheelJointDirection}\n \
	End Object\n \
	Joints.Add(`{FlipperName}LargeWheelJoint)\n \

defaultproperties
{
	// Variables used for setting up the Kenaf
	`define WheelFrontX 0.145
	`define WheelRightY 0.076
	`define FlipperFrontX 0.185
	`define FlipperRightY 0.110
	`define FlipperMaxForce 4

	// Create body part
	Begin Object Class=Part Name=ChassisMiddle
		Mesh=StaticMesh'Kenaf.Kenaf_Body'
		Mass=1.0
		Offset=(X=0,Y=0,Z=0)
	End Object
	Body=ChassisMiddle
	PartList.Add(ChassisMiddle)

	// Front Right Wheel
	Begin Object Class=Part Name=FRWheel
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'
		Offset=(X=`WheelFrontX,Y=`WheelRightY,Z=0)
		// 180 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.142)
		Mass=0.1
	End Object
	PartList.Add(FRWheel)

	// Front Left Wheel
	Begin Object Class=Part Name=FLWheel
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'
		Offset=(X=`WheelFrontX,Y=-`WheelRightY,Z=0)
		Mass=0.1
	End Object
	PartList.Add(FLWheel)

	// Back Right Wheel
	Begin Object Class=Part Name=BRWheel
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'
		Offset=(X=-`WheelFrontX,Y=`WheelRightY,Z=0)
		// 180 degree rotation about Z axis
		Direction=(X=0,Y=0,Z=3.142)
		Mass=0.1
	End Object
	PartList.Add(BRWheel)

	// Back Left Wheel
	Begin Object Class=Part Name=BLWheel
		Mesh=StaticMesh'Kenaf.Kenaf_Wheel'
		Offset=(X=-`WheelFrontX,Y=-`WheelRightY,Z=0)
		Mass=0.1
	End Object
	PartList.Add(BLWheel)

	// Connect wheels to chassis
	Begin Object Class=WheelJoint Name=FRWheelRoll
		Parent=ChassisMiddle
		Child=FRWheel
		Side=SIDE_Right
		Offset=(X=`WheelFrontX,Y=`WheelRightY,Z=0)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(FRWheelRoll)

	Begin Object Class=WheelJoint Name=FLWheelRoll
		Parent=ChassisMiddle
		Child=FLWheel
		Side=SIDE_Left
		Offset=(X=`WheelFrontX,Y=-`WheelRightY,Z=0)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(FLWheelRoll)

	Begin Object Class=WheelJoint Name=BRWheelRoll
		Parent=ChassisMiddle
		Child=BRWheel
		Side=SIDE_Right
		Offset=(X=-`WheelFrontX,Y=`WheelRightY,Z=0)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(BRWheelRoll)

	Begin Object Class=WheelJoint Name=BLWheelRoll
		Parent=ChassisMiddle
		Child=BLWheel
		Side=SIDE_Left
		Offset=(X=-`WheelFrontX,Y=-`WheelRightY,Z=0)
		Direction=(X=1.571,Y=0,Z=0)
	End Object
	Joints.Add(BLWheelRoll)

	// Construct flippers
	// Naming scheme
	//	{F} At the front of the vehicle (R for rear)
	//	{L} On the left hand side (R for right)
	
	// Front right flipper
	`CreateFlipper(FRFlipper, `{FlipperFrontX}, `{FlipperRightY}, (x=0,y=0,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Right)
	`CreateFlipper(FLFlipper, `{FlipperFrontX}, -`{FlipperRightY}, (x=0,y=0,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Left)
	`CreateFlipper(RRFlipper, -`{FlipperFrontX}, `{FlipperRightY}, (x=0,y=3.14,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Right,"1")
	`CreateFlipper(RLFlipper, -`{FlipperFrontX}, -`{FlipperRightY}, (x=0,y=3.14,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Left,"1")
}	