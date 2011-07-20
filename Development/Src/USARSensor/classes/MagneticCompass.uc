// Magnetic Compass sensor
// it provides the center item's angle displacement wrt the north in rad

class MagneticCompass extends Sensor config (USAR);

var float N; // the north in world frame of reference in rad

simulated function AttachItem()
{
	local StaticMeshActor MC;
	local bool foundCompass;
	
	// search in the map for a static mesh with tag "sundial" and retrieve its orientation
	// the yaw of this object is assumed as the north direction's angle wrt the 0,0,0 location
	foundCompass = false;
	foreach AllActors(class 'StaticMeshActor', MC)
	{		
		if (inStr(MC.Tag, "Sundial")>=0)
		{
			N = class'UnitsConverter'.static.AngleFromUU(MC.Rotation.yaw);
			foundCompass = true;
		}
	}
	if(!foundCompass){
		loginternal("Unable to find a compass in the map. Setting the North to zero.");
		N = 0;
	}
	
	super.AttachItem();
} 

// Returns sensor data
function String GetData()
{
	local String outstring;
	local vector curRot;
	local float curYaw;
	local int magneticAngle;
	
	curRot =  class'UnitsConverter'.static.AngleVectorFromUU(Platform.CenterItem.Rotation); // current rotation in rad

	// convert to rad and compute difference between the two angles
	curYaw = class'UnitsConverter'.static.AngleFromUU(curRot.z);	
	magneticAngle = class'UnitsConverter'.static.diffAngle(N,curYaw);
	
	outstring = "{Name " $ ItemName $ "} {MagneticAngle " $ String(class'UnitsConverter'.static.AngleFromUU(magneticAngle)) $ "}";
	
	return outstring;
}

defaultproperties
{
	ItemType="MagneticCompass"
}