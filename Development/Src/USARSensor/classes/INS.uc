/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
  * INS.uc
  * Inertial Navigation System
  * author:  Chris Scrapper
  * ported by:Behzad Tabibian
  * brief :  Simulates an INS sensor by using angular velocities
  *          and distance traveled.
  *
  *          This sensor uses gaussian random number generator to
  *          add noise to angular velocities. This sensor uses this
  *          information to update the sensor's current prediction of
  *          orientation. The total distance traveled in one time
  *          step is computed, again adding gaussian noise, and is
  *          decomposed into distance vectors using polar coordinates.
  *          This is added to estimates of location. All noise is
  *          proportional to rate of change, more change causes
  *          more error.
  */

class INS extends Sensor config (USAR);

var config bool Drifting;
var config float Precision;

var vector rotEst;   // Sensor data, estimated Orientation
var vector xyzEst;   // Sensor data, estimated Location
var vector rotPrev;  // Previous ground truth Orientation
var vector xyzPrev;  // Previous ground truth Location
var bool go;         // variable set to begin sensor calculation
var Utilities utils;
var float MeanX;
var float MeanY;
var float MeanZ;
var float MeanRotX;
var float MeanRotY;
var float MeanRotZ;
var float driftX;
var float driftY;
var float driftZ;
var float driftRotX;
var float driftRotY;
var float driftRotZ;

simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	utils = new class'Utilities';
}

simulated function AttachItem()
{
	super.AttachItem();
	rotEst = class'UnitsConverter'.static.AngleVectorFromUU(Rotation);
	// Normalize orientation between [0,2PI]
	rotEst.x = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.x);
	rotEst.y = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.y);
	rotEst.z = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.z);
	xyzEst = class'UnitsConverter'.static.LengthVectorFromUU(Location);
	rotPrev = rotEst;
	xyzPrev = xyzEst;
	go = false;
	
	MeanX = 0;
	MeanY = 0;	
	MeanZ = 0;	
	MeanRotX = 0;
	MeanRotY = 0;
	MeanRotZ = 0;
	
	if (Drifting)
	{
		MeanRotX = (FRand() - 0.5) / (Precision * Precision);
		MeanRotY = (FRand() - 0.5) / (Precision * Precision);
		MeanRotZ = (FRand() - 0.5) / (Precision * Precision);
		MeanX = (FRand() - 0.5) / Precision;
		MeanY = (FRand() - 0.5) / Precision;
		MeanZ = (FRand() - 0.5) / Precision;
	}
	else
	{
		driftRotX = 0;
		driftRotY = 0;
		driftRotZ = 0;
		driftX = 0;
		driftY = 0;
		driftZ = 0;
	}
}

function String GetData()
{
	local vector rotTrue;
	local vector xyzTrue;
	local vector rotRate;
	local float dist;
	local vector deltaLoc;

	// Get rate of change from ground truth
	xyzTrue = class'UnitsConverter'.static.LengthVectorFromUU(Platform.CenterItem.Location);
	rotTrue = class'UnitsConverter'.static.AngleVectorFromUU(Platform.CenterItem.Rotation);

	// Calculate rate of change for time step
	rotRate.x = class'UnitsConverter'.static.diffAngle(rotTrue.x, rotPrev.x);
	rotRate.y = class'UnitsConverter'.static.diffAngle(rotTrue.y, rotPrev.y);
	rotRate.z = class'UnitsConverter'.static.diffAngle(rotTrue.z, rotPrev.z);
	if (go)
	{
		// Add gaussian noise and update orientation estimate
		rotEst.x += rotRate.x + (rotRate.x * utils.gaussRand(MeanRotX, Sigma));
		rotEst.y += rotRate.y + (rotRate.y * utils.gaussRand(MeanRotY, Sigma));
		rotEst.z += rotRate.z + (rotRate.z * utils.gaussRand(MeanRotZ, Sigma));
		// Normalize orientation between [0,2PI]
		rotEst.x = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.x);
		rotEst.y = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.y);
		rotEst.z = class'UnitsConverter'.static.normRad_ZeroTo2PI(rotEst.z);

		deltaLoc.x = xyzTrue.x - xyzPrev.x;
		deltaLoc.y = xyzTrue.y - xyzPrev.y;
		deltaLoc.z = xyzTrue.z - xyzPrev.z;  
		dist = sqrt(  (deltaLoc.x * deltaLoc.x) +
				   (deltaLoc.y * deltaLoc.y) +
				   (deltaLoc.z * deltaLoc.z) );
		xyzEst.x +=  deltaLoc.x + dist*utils.gaussRand(MeanX, Sigma);
		xyzEst.y +=  deltaLoc.y + dist*utils.gaussRand(MeanY, Sigma);
		xyzEst.z +=  deltaLoc.z + dist*utils.gaussRand(MeanZ, Sigma);
	}
	else
	{
		// make sure vehicle is at rest before starting INS
		if (rotRate.x == 0 && rotRate.y == 0 && rotRate.z == 0)
			go = true;
	}
	rotPrev = rotTrue;
	xyzPrev = xyzTrue;
	return "{Name " $ ItemName $ "} {Location " $ xyzEst $ "} {Orientation " $ rotEst $ "}";
}

function String Set(String opcode, String args)
{
	local String rVal;
	local array<String> toks;

	if (Caps(opcode) == "POSE")
	{
		// Parse string into tokens
		toks = utils.tokenizer(args, ",");
		if (toks.Length == 6)
		{
			// Block, don't know if need but never hurts
			go = false;
			// Set Estimates
			xyzEst.x = Float(toks[0]);
			xyzEst.y = Float(toks[1]);
			xyzEst.z = Float(toks[2]);
			rotEst.x = Float(toks[3]);
			rotEst.y = Float(toks[4]);
			rotEst.z = Float(toks[5]);
			meanX = 0;
			meanY = 0;
			meanZ = 0;
			meanRotX = 0;
			meanRotY = 0;
			meanRotZ = 0;
			// UnBlock
			go = true;
			rVal = "OK";
		}
	}
	else
		rVal = "Failed";
	return rVal;
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring = outstring @ "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="INS"
	BlockRigidBody=false
	bCollideActors=false
	bBlockActors=false
	bProjTarget=true
	bCollideWhenPlacing=false
	bCollideWorld=false
	DrawScale=0.9524

	Begin Object Class=StaticMeshComponent Name=StKMesh01
		StaticMesh=StaticMesh'INSIMUSensor.Sensor'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object

	Components(1)=StMesh01
	CollisionComponent=StMesh01
}
