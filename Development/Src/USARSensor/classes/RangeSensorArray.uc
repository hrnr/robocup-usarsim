/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class RangeSensorArray extends Sensor config(USAR);

var array<RangeSensor> Sensors;
var int NumberOfSensors;
var String PclData;
var config bool bSendPoints;
delegate PointSendDelegate(Actor a, vector pt);

simulated function addRangeSensor(class<RangeSensor> sensorClass, vector pos, rotator rot,
	int maxRange, optional float scanRate = 0.0)
{
	// Ranges are in Unreal units
	local RangeSensor s;
	pos = pos >> Rotation;
	s = Spawn(sensorClass, self, , Location + pos);
	s.setHardAttach(true);
	s.setBase(self);
	s.setRelativeRotation(rot);
	s.maxRange = maxRange;
	s.bSendRange = true;
	s.RangeSendDelegate = getPoint;	
	if (scanRate > 0.0)
		s.setTimer(scanRate, true);
	Sensors.AddItem(s);
}

function getPoint(Actor a, float range)
{
	local vector forward;
	local vector pt;
	
	forward.x = 1;
	range = class 'UnitsConverter'.static.LengthToUU(range);
	pt = ((forward * range) >> a.Rotation) + a.Location; //global position of pt
	pt = (pt - Location) << Rotation; // in sensor coordinates
	pt = class'UnitsConverter'.static.LengthVectorFromUU(pt); // in meters
	if (bSendPoints)
		PointSendDelegate(self, pt);
	else
	{
		if (PclData == "")
			PclData = class'UnitsConverter'.static.VectorString(pt);
		else
			PclData = PclData $ " " $ class'UnitsConverter'.static.VectorString(pt);
	}
}

// Don't call parent to avoid sending excess data if bSendRange is true
simulated function ClientTimer()
{
	local String data;
	
	if (!bSendPoints && pclData != "")
	{
		data = pclData;
		pclData = "";
		MessageSendDelegate(getHead() $ "{Name " $ ItemName $ "}" $ "{" $ data $ "}");
	}
}

simulated event Destroyed()
{
	local int i;
	super.Destroyed();
	for (i = 0; i < Sensors.Length; i++)
		Sensors[i].Destroy();
}

defaultproperties
{
}
