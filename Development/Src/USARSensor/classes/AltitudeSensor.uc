// Altitude sensor
// it provides the following center intem's data
// relative altitude in m (altitude with respect to initial spawn location)
// absolute altitute in m (relative altitude + above sea level)

class AltitudeSensor extends Sensor config (USAR);

var vector initialLocation; // initial spawn location
var float ASL; // above sea level (meters)

simulated function AttachItem()
{
	initialLocation = Platform.CenterItem.Location; // in uu
	super.AttachItem();
} 

// Returns sensor data
function String GetData()
{
	local float relative_altitude, absolute_altitude, curAltitude;
	local Vector curLocation;
	local String outstring;
	
	curLocation = Platform.CenterItem.Location; // current location in uu
	curAltitude = curLocation.z; // current altitude in uu
	relative_altitude = curAltitude - initialLocation.z;	
	absolute_altitude = class'UnitsConverter'.static.LengthToUU(ASL) + relative_altitude;
	if (absolute_altitude < 0) absolute_altitude = 0;
	
	// conversion from uu to meters
	relative_altitude = class'UnitsConverter'.static.LengthFromUU(relative_altitude);
	absolute_altitude = class'UnitsConverter'.static.LengthFromUU(absolute_altitude);
	
	outstring = 
	"{Name " $ ItemName $ 
	"} {relativeAltitude " $ class'UnitsConverter'.static.FloatString(relative_altitude) $ 
	"} {absoluteAltitude "  $ class'UnitsConverter'.static.FloatString(absolute_altitude) $ 
	"}";
	
	return outstring;
}

defaultproperties
{
	ItemType="AltitudeSensor"
	ASL=111; // todo: this should be a world property (perhaps the ASL of the 0,0,0 location in the world) to be retrieved by the AttachItem() function (some convention might be established)
}
