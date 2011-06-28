/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * WheeledVehicle - Base class for USAR wheeled vehicles.
 */
class WheeledVehicle extends USARVehicle config(USAR) abstract;

// Wheel radius (must be set in properties to mimic old api)
var float WheelRadius;

// Returns geometric configuration data related to this robot
function String GetGeoData()
{
	local int i;
	local JointItem ji, lFTire, rRTire;
	local WheelJoint jt;
	local vector COMOffset, dimensions;
	
	// Initialize to something known
	lFTire = None; 
	rRTire = None;
	// Search for wheels and find the LF and RR tires
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].isJoint())
		{
			ji = JointItem(Parts[i]);
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
					if (rRTire == None)
						rRTire = ji;
					else if (jt.Offset.X < rRTire.Spec.Offset.X)
						rRTire = ji;
				}
			}
		}
	// TODO This still does not work as intended
	COMOffset = CenterItem.StaticMeshComponent.StaticMesh.BodySetup.COMNudge;
	// TODO Unsure if this is how dimensions were calculated in UT3
	// If not, it may have to go in config per robot
	dimensions.X = lFTire.Spec.Offset.X - rRTire.Spec.Offset.X;
	dimensions.Y = rRTire.Spec.Offset.Y - lFTire.Spec.Offset.Y;
	dimensions.Z = 0;
	return "GEO {Type GroundVehicle} {Name " $ self.Class $ "} {Dimensions " $ 
		class'UnitsConverter'.static.VectorString(dimensions) $ "} {COG " $
		class'UnitsConverter'.static.Str_LengthVectorFromUU(COMOffset) $ "} {WheelRadius " $
		class'UnitsConverter'.static.FloatString(WheelRadius) $ "} {WheelSeparation " $
		class'UnitsConverter'.static.FloatString(dimensions.Y) $ "} {WheelBase " $
		class'UnitsConverter'.static.FloatString(dimensions.X) $ "}";
}

// Workaround for wheel radius in build-order
simulated function float GetProperty(String key)
{
	if (key == "WheelRadius")
		return WheelRadius;
	return super.getProperty(key);
}

// Gets robot status (adds the ground vehicle type)
simulated function String GetStatus()
{
	return super.GetStatus() $ " {Type GroundVehicle} {Battery " $ GetBatteryLife() $ "}";
}

// Changes the maximum torque of the wheels
function SetMaxTorque(float maxTorque)
{
	local int i;
	local JointItem ji;
	
	for (i = 0; i < Parts.Length; i++)
		if (Parts[i].IsJoint())
		{
			ji = JointItem(Parts[i]);
			// TODO validate that no scalar conversion is needed here
			if (ji.JointIsA('WheelJoint') && WheelJoint(ji.Spec).bIsDriven)
				ji.SetMaxForce(maxTorque);
		}
	if (bDebug)
		LogInternal("WheeledVehicle: Set maximum torque of '" $ String(self.Name) $ "' to " $
			class'UnitsConverter'.static.FloatString(maxTorque));
}

defaultproperties
{
	WheelRadius=0.2
}
