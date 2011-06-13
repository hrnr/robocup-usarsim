/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.	Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.


*****************************************************************************/

class AcousticArraySensor extends Sensor config (USAR);

// This is the distance away from the AcousticActor who calls the 
// HearSound function that our sensors relative volume will match 
// the initial loudness
var config float InitLoudnessRadius;

// Normal speed of sound in m/s
var config int SoundSpeed;

// Max distance in meters that a sound can be heard,
// based on normal range of hearing a gunshot
var config int HearThreshold;

// This struct will hold all information needed from a sound
// to calculate the sensor's output
struct soundInfo {
	var float volume; // A float to hold initial volume of the sound
	var vector location; // A vector to hold the location of the source of the sound
	var float duration; // A float to hold the duration of this sound in seconds
	var float timestamp; // A float to hold time stamps that this sound was initiated
};

// An array of soundInfo which holds all information needed from a sound
// to calculate the sensor's output
var array<soundInfo> sound;

// An int representing the current size of the sound array
var int arrayCnt;

// SI unit versions of UU unit var config intants above
var float InitLoudnessRadiusInv;
var float SoundSpeedInv;
var float Log10Inv;

// Convert all variables of this object read from the 
// UTUSAR.ini from SI to UU units
simulated function ConvertParam()
{
	super.ConvertParam(); // first convert parent object

	HearThreshold = class'UnitsConverter'.static.LengthToUU(HearThreshold);
	SoundSpeed = class'UnitsConverter'.static.SpeedToUU(SoundSpeed);
	InitLoudnessRadius = class'UnitsConverter'.static.LengthToUU(InitLoudnessRadius);

	// we pre-compute inverses once so that we can multiply (faster)
	// rather than divide (slower) repeatedly later on in the tick loop
	InitLoudnessRadiusInv = 1.0 / InitLoudnessRadius;
	SoundSpeedInv = 1.0 / SoundSpeed;
	Log10Inv = 1.0 / Loge(10);
}

function String GetData()
{	
	// A string that contains the output of this function
	local String AcousticData;

	// A float that holds the formulated distance to calculate sound drop-off and time delay
	local float distance;

	// The volume that the robot should play the sound (between 0 and 1)
	local float relativeVol;

	// The time the robot should delay playing this sound in seconds
	local float timeOff;

	// The absolute vector from the location of the sensor
	// to the location of the sound
	local vector absDirection;

	// A unit vector representing the direction to the sound from the sensor
	// relative to its current rotation
	local vector relDirection;

	// Sets AcousticData to hold normal sensor information
	AcousticData = "{Name " $ self $ "}";
	
	// Checks to see if an Actor has called the HearSound function
	if (arrayCnt == 0) 
		// No HearSound function has been called
		AcousticData @= "{None}";
	else
	{
		// At least one Actor has called the HearSound function
		// Go through each Actor that called the HearSound function
		// since last tick removing them each loop
		while (arrayCnt != 0)
		{
			// Calculating the distance between the sensor 
			// and the location of the sound
			distance = VSize(sound[0].location - Location);
			
			// Calculate time delay for sensor based on 
			// speed of sound through air
			timeOff = (distance * SoundSpeedInv + sound[0].timestamp) - WorldInfo.TimeSeconds;
			if (timeOff < 0)
				// Sound should have already played so play it immediately
				timeOff = 0;
			
			// Adjust distance so the sound appears to be muffled
			// if there is a wall between the sensor and the sound's
			// location (doubles the distance)
			if (self.FastTrace(sound[0].location))
				distance *= 2;
			
			// Checks to see if the sound is still within the hearing threshold
			// after modifying the distance
			if (distance > HearThreshold)
				AcousticData @= "{Far}";
			else
			{
				// Calculate relative loudness based on distance and sound attenuation
				if (distance > InitLoudnessRadius)
					RelativeVol = class'UnitsConverter'.static.SoundLevelFromUU(sound[0].volume) -
						20 * Loge(distance * InitLoudnessRadiusInv) * Log10Inv;
				else
					// Sensor is within InitLoudnessRadius meters of noiseMaker[i]
					// so the initial loudness is the same as the relative loudness
					RelativeVol = sound[0].volume;
				
				if (RelativeVol < 0)
					// The sound has dropped off so that it is no longer audible
					AcousticData @= "{Far}";
				else
				{
					// Calculating the relative direction of the sound's location
					// based on the location of the sound, the sensor, and the current
					// rotation of the sensor. Direction will hold the vector that
					// will point in the relative direction from the sensor to the
					// sound's location.
					// The vector from the sensor to the sound in world coordinates
					absDirection = sound[0].location - Location;
					
					// The vector from the sensor to the sound in sensor coordinates
					relDirection = QuatRotateVector(QuatInvert(QuatFromRotator(Rotation)),
						absDirection);
					
					// Making it a unit vector to only point one unit in the
					// direction of the sound relative to the sensor
					relDirection = Normal(relDirection);
					
					// Update AcousticData to hold newly calculated data
					AcousticData @= "{Direction " $ relDirection $ "} {Volume " $ RelativeVol $
						"} {Duration " $ sound[0].duration $ "} {Delay " $ timeOff $ "}";
				}
			}
			// Removing the information for this sound since we have already sent the sensors output
			sound.remove(0,1);
			arrayCnt--;
		}
	}
	return AcousticData;
}

// Is called by other AcousticActors to pass the sound information of the sound they just made
function HearSound(float volume, float duration, vector sourceLocation, float timestamp){
	sound.Add(1);
	sound[arrayCnt].volume = volume;
	sound[arrayCnt].duration = duration;
	sound[arrayCnt].location = sourceLocation;
	sound[arrayCnt].timestamp = timestamp;
	arrayCnt++;
}

function String Set(String opcode, String args)
{
	if (Caps(opcode) == "SCAN") {
		LogInternal("Set() received SCAN, scanning now");
		timer();
		return "OK";
	}
	return "Failed";
}

defaultproperties
{
	ItemType="Acoustic"
	OutputCurve=(Points=((InVal=0,OutVal=0),(InVal=1000,OutVal=1000)))
	DrawScale=10
}
