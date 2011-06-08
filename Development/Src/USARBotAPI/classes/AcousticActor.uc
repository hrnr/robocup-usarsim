class AcousticActor extends UTPawn config(USAR);

// Plays a sound that an array of acoustic sensors will give a direction on
function PlayAcousticSound(SoundCue sound, float time){
	local AcousticArraySensor sensor;

	// Looking for all AcousticArraySensors and calling their function with the sounds information
	foreach AllActors(class'AcousticArraySensor', sensor){
		sensor.HearSound(sound.VolumeMultiplier, sound.Duration, Location, time);
	}
	
	// Plays the sound
	PlaySound(sound);
}
