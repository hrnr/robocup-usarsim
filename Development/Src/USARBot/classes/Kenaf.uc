class Kenaf extends SkidSteeredVehicle config(USAR);

// Macro to define a flipper joint, so we don't need to repeat code
`define CreateFlipper(FlipperName, PosX, PosY, FlipperDirection, FlipperJointDirection, WheelJointDirection, Side, IsRear) \
	Begin Object Class=Part Name=`{FlipperName}Part\n \
		Mesh=StaticMesh'Kenaf_static.Flipper'\n \
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
		LimitLow=-3.14\n \
		LimitHigh=3.14\n \
		Direction=`{FlipperJointDirection}\n \
		MaxForce=`FlipperMaxForce\n \
	End Object\n \
	Joints.Add(`{FlipperName})\n \
	\
	Begin Object Class=Part Name=`{FlipperName}Wheel\n \
		RelativeTo=`{FlipperName}Part\n \
		Mesh=StaticMesh'Kenaf_static.SmallTire'\n \
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
		Mesh=StaticMesh'Kenaf_static.LargeTire'\n \
`if(`IsRear) \
		Offset=(X=-0.145,Y=0,Z=0)\n \
`else \
		Offset=(X=0.145,Y=0,Z=0)\n \
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
		Offset=(X=-0.14,Y=0,Z=0)\n \
`else \
		Offset=(X=0.14,Y=0,Z=0)\n \
`endif \
		Direction=`{WheelJointDirection}\n \
	End Object\n \
	Joints.Add(`{FlipperName}LargeWheelJoint)\n \

// Macro to define a main wheel
`define CreateMainWheel(WheelName, PosX, PosY, WheelDirection, Side) \
	Begin Object Class=Part Name=`{WheelName}\n \
		Mesh=StaticMesh'Kenaf_static.TrackTireLarge'\n \
		Offset=(X=`PosX,Y=`PosY,Z=0.0)\n \
		Direction=`{WheelDirection}\n \
		Mass=0.1\n \
	End Object\n \
	PartList.Add(`{WheelName})\n \
	Begin Object Class=WheelJoint Name=`{WheelName}Roll\n \
		Parent=ChassisMiddle\n \
		Child=`{WheelName}\n \
		Side=`Side\n \
		Offset=(X=`PosX,Y=`PosY,Z=0.0)\n \
		Direction=(X=1.571,Y=0,Z=0)\n \
	End Object\n \
	Joints.Add(`{WheelName}Roll)\n \

defaultproperties
{
	// Kenaf dimensions:
	// Length: 0.6 meter
	// Width: 0.4 meter
	// Height: 0.18 meter

	// Variables used for setting up the Kenaf
	`define WheelFrontX 0.20
	`define WheelFrontHalfX 0.065
	`define WheelRightY 0.11
	`define FlipperFrontX 0.225
	`define FlipperRightY 0.23
	`define FlipperMaxForce 5

	// Create body part
	Begin Object Class=Part Name=ChassisMiddle
		Mesh=StaticMesh'Kenaf_Static.Body'
		Mass=1.0
		Offset=(X=0,Y=0,Z=0)
	End Object
	Body=ChassisMiddle
	PartList.Add(ChassisMiddle)

	`CreateMainWheel(FRWheel, `WheelFrontX, `WheelRightY, (X=0,Y=0,Z=3.142), SIDE_Right)
	`CreateMainWheel(FLWheel, `WheelFrontX, -`WheelRightY, (X=0,Y=0,Z=0), SIDE_Left)
	`CreateMainWheel(BRWheel, -`WheelFrontX, `WheelRightY, (X=0,Y=0,Z=3.142), SIDE_Right)
	`CreateMainWheel(BLWheel, -`WheelFrontX, -`WheelRightY, (X=0,Y=0,Z=0), SIDE_Left)

	`CreateMainWheel(BMRWheel, 0.0, `WheelRightY, (X=0,Y=0,Z=3.142), SIDE_Right)
	`CreateMainWheel(BMLWheel, 0.0, -`WheelRightY, (X=0,Y=0,Z=0.0), SIDE_Left)

	// Would like to add more wheels like this, but there is not enough space for 4 wheels on each side
	// Need to disable collision between the wheels then
	//`CreateMainWheel(FMRWheel, `WheelFrontHalfX, `WheelRightY, (X=0,Y=0,Z=3.142), SIDE_Right)
	//`CreateMainWheel(FMLWheel, `WheelFrontHalfX, -`WheelRightY, (X=0,Y=0,Z=0), SIDE_Left)
	//`CreateMainWheel(BMRWheel, -`WheelFrontHalfX, `WheelRightY, (X=0,Y=0,Z=3.142), SIDE_Right)
	//`CreateMainWheel(BMLWheel, -`WheelFrontHalfX, -`WheelRightY, (X=0,Y=0,Z=0), SIDE_Left)


	// Construct flippers
	// Naming scheme
	//	{F} At the front of the vehicle (R for rear)
	//	{L} On the left hand side (R for right)
	`CreateFlipper(FRFlipper, `{FlipperFrontX}, `{FlipperRightY}, (x=0,y=0,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Right)
	`CreateFlipper(FLFlipper, `{FlipperFrontX}, -`{FlipperRightY}, (x=0,y=0,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Left)
	`CreateFlipper(RRFlipper, -`{FlipperFrontX}, `{FlipperRightY}, (x=0,y=3.14,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Right,"1")
	`CreateFlipper(RLFlipper, -`{FlipperFrontX}, -`{FlipperRightY}, (x=0,y=3.14,z=0), (x=1.57,y=0,z=0), (x=1.571,y=0,z=0), SIDE_Left,"1")
}	