/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Odometry Sensor
 * author:  Stephen Balakirsky 
 * brief :  This sensor provides data that would typically be returned by an odometry sensor.
 */
class Odometry extends Sensor config (USAR);

var JointItem lFTire; // left front tire
var JointItem rFTire; // right rear tire
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
		wheelRadius, lFTire, rFTire;
}

simulated function AttachItem()
{
	super.AttachItem();
	FindTires();
}

function FindTires()
{
	local int i;
	local JointItem ji;
	local WheelJoint jt;
	
	LFTire = None;
	RFTire = None;
	if (!Platform.IsA('SkidSteeredVehicle'))
	{
		LogInternal("Odometer: Not attached to a SkidSteeredVehicle");
		SetTimer(0, false);
		return;
	}
	
	// Search for wheels and find the LF and RR tires
	for (i = 0; i < Platform.Parts.Length; i++)
		if (Platform.Parts[i].IsJoint())
		{
			ji = JointItem(Platform.Parts[i]);
			if (ji.JointIsA('WheelJoint'))
			{
				jt = WheelJoint(ji.Spec);
				if (jt.Side == SIDE_Left)
				{
					// Left side?
					if (lFTire == None)
						lFTire = ji;
					else if (jt.Offset.X > lFTire.Spec.Offset.X)
						lFTire = ji;
				}
				else if (jt.Side == SIDE_Right)
				{
					// Right side!
					if (rFTire == None)
						rFTire = ji;
					else if (jt.Offset.X > rFTire.Spec.Offset.X)
						rFTire = ji;
				}
			}
		}
	
	if (lFTire == None || rFTire == None)
	{
		LogInternal("Odometry: Could not find wheels");
		SetTimer(0, false);
	}
	else
	{
		oldLeft = lFTire.CurValue;
		oldRight = rFTire.CurValue;
		oldTime = WorldInfo.TimeSeconds;
		wheelRadius = Platform.GetProperty("WheelRadius");
	}
	
	// FIXME Not properly computed
	lDist = rFTire.Spec.Offset.Y * 2;
}

function String GetData()
{
	local float diff, value;
	local float leftSpin, rightSpin; // will contain the spin speed of the wheels in rad/sec
	local float newTime;
	local float timeDiff;
	local float xVel, yVel, thetaVel;
	
	newTime = WorldInfo.TimeSeconds;
	timeDiff = newTime - oldTime;
	if (timeDiff < 0.000001 || lFTire == None || rFTire == None)
		return "";
	
	// Odometry on LF tire
	oldTime = newTime;
	value = LFTire.CurValue;
	diff = value - oldLeft;
	oldLeft = value;
	leftSpin = diff / timeDiff;
	
	// Odometry on RF tire
	value = RFTire.CurValue;
	diff = value - oldRight;
	oldRight = value;
	rightSpin = diff / timeDiff;
	
	// Compute changes in pose
	xVel = cos(theta) * (wheelRadius * (rightSpin + leftSpin) / 2);
	yVel = sin(theta) * (wheelRadius * (rightSpin + leftSpin) / 2);
	thetaVel = wheelRadius * (leftSpin - rightSpin) / lDist;
	xPos += xVel * timeDiff;
	yPos += yVel * timeDiff;
	theta += thetaVel * timeDiff;
	
	// Send the odometry data
	return "{Name " $ ItemName $ "} {Pose " $ xPos $ "," $ yPos $ "," $ theta $ "}";
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="Odometry"
}
