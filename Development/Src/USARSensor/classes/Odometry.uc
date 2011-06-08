/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/

/*
  * Odometry.uc
  * Odometry Sensor
  * author:  Stephen Balakirsky 
  * brief :  This sensor provides data that would typically be returned by an odometry sensor.
  */
class Odometry extends Sensor config (USAR);

var int LFTire; // left front tire
var int RFTire; // right rear tire
var float oldLeft; // old report on left position
var float oldRight; // old report on right position
var float oldTime; // time of last cycle
var float wheelRadius; // radius of wheel
var float lDist; // 2* distance of wheel from control point (wheel separation)
var float theta; // orientation of vehicle
var float xPos;  // x position of vehicle
var float yPos;  // y position of vehicle

replication
{
	if (bNetOwner && bNetDirty && ROLE == ROLE_Authority)
		wheelRadius, LFTire, RFTire;
}

simulated function AttachItem()
{
	FindTires();
}

simulated function FindTires()
{
	local BasicWheel wheel;
	local int i;
	LFTire = -1;
	RFTire = -1;
	
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("Odometer: Not attached to a SkidSteeredVehicle!");
		SetTimer(0, false);
		return;
	}
	
	for (i = 0; i < Platform.Joints.Length; i++)
		if (Platform.Joints[i].isA('BasicWheel')) {
			wheel = BasicWheel(Platform.Joints[i]);
			if (wheel.Side == SIDE_Left) {
				// Left side?
				if (lFTire == -1)
					lFTire = i;
				else if (wheel.Offset.X > Platform.Joints[lFTire].Offset.X)
					lFTire = i;
			} else if (wheel.Side == SIDE_Right) {
				// Right side!
				if (rFTire == -1)
					rFTire = i;
				else if (wheel.Offset.X > Platform.Joints[rFTire].Offset.X)
					rFTire = i;
			}
		}
	
	oldLeft = Platform.Joints[LFTire].CurAngle;
	oldRight = Platform.Joints[RFTire].CurAngle;
	oldTime = WorldInfo.TimeSeconds;
	wheelRadius = Platform.GetProperty("WheelRadius");
	lDist = Platform.Joints[RFTire].Offset.Y * 2;
	lDist = class'UnitsConverter'.static.LengthFromUU(lDist);
	wheelRadius = class'UnitsConverter'.static.LengthFromUU(wheelRadius);
}

simulated function ClientTimer()
{
	local String odometryData;
	local float diff;
	local float rollsOver;
	local float leftSpin, rightSpin; // will contain the spin speed of the wheels in rad/sec
	local float newTime;
	local float timeDiff;
	local float xVel, yVel, thetaVel;
	 
	super.ClientTimer();
	
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - oldTime;
	
	if (timeDiff < 0.000001)
		return;
		
	oldTime = newTime;
	
	diff = Platform.Joints[LFTire].CurAngle - oldLeft;
	if (diff < -180)
		rollsOver = 1;
	else if (diff > 180)
		rollsOver = -1;
	else
		rollsOver = 0;
	oldLeft = Platform.Joints[LFTire].CurAngle;
	leftSpin = degToRad * (rollsOver * 360. + diff) / timeDiff;

	diff = Platform.Joints[RFTire].CurAngle - oldRight;
	if (diff < -180)
		rollsOver = 1;
	else if (diff > 180)
		rollsOver = -1;
	else
		rollsOver = 0;
	oldRight = Platform.Joints[RFTire].CurAngle;
	rightSpin = degToRad * (rollsOver * 360. + diff) / timeDiff;
	
	xVel = cos(theta) * (wheelRadius * (rightSpin + leftSpin) / 2);
	yVel = sin(theta) * (wheelRadius * (rightSpin + leftSpin) / 2);
	thetaVel = wheelRadius * (leftSpin - rightSpin) / lDist;
	
	xPos += xVel * timeDiff;
	yPos += yVel * timeDiff;
	theta += thetaVel * timeDiff;
	
	odometryData = "{Name " $ ItemName $ "} {Pose " $ xPos $ "," $ yPos $ "," $ theta $ "}";
	MessageSendDelegate(getHead() @ odometryData);
}

simulated function String GetConfData()
{
    local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Odometry"

	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=false
	bCollideWorld=false
	DrawScale=1

	Begin Object Class=StaticMeshComponent Name=StMesh01
        StaticMesh=StaticMesh'INSIMUSensor.Sensor'
        CollideActors=false
        BlockActors=false   //Must be set to false for hard-attach
        BlockRigidBody=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
	End Object

	CollisionType=COLLIDE_BlockAll

	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
