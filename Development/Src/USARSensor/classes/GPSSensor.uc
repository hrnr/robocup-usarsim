/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

class GPSSensor extends Sensor config (USAR);

/*
   This class simluates a GPS sensor, returning Latitude and Longitude.
   The sensor simulates GGA GPS format, where the following are returned:
     1) The latitude and longitude, in degrees, minutes (can be a decimal), and cardinal position (N,S,E,W)
     2) Whether or not the GPS receiver has a fix (0=false, 1=true)
     3) The number of satellites seen by the GPS sensor
   Example Format is
     SEN {Type GPS} {Name GPS1} {Latitude 47,40.3323,N} {Longitude 122,18.5977,W} {Fix 1} {Satellites 8}

   The only parameter to set is a reference point inside the map giving the GPS coordinate of a location.
   This can be done by modifying the ZeroZeroLocation coordinate, thus giving the GPS coordinate of the
   (0,0) location of world. Alternatively, a GPSCoordinate object can be put into any map. This is done
   by opening a map in UnrealEd, opening USARBot.u within the class editor, and selecting 
   Actor->NavigationPoint->PathNode->ReferenceGPSCoordinate. Place it to the desired location on the map
   and change the GPS coordinate (inside the ReferenceGPSCoordinate property).
   A GPS reference point is acquired in this order:
     1) If a ReferenceGPSCoordinate is inside a map, it is used as the reference point
     2) Otherwise, the ZeroZeroLocation inside the GPSSensor section of USARBot.ini is used
     3) If there is no ZeroZeroLocation inside USARBot.ini, default ZeroZeroLocation is used
   
   Some part of this code is credited to Tyler Folsom.

   Ported from implementation of GPS Sensor in UT2004
   Authors: Souroush Moretazpour
 		   Behzad Tabibian
*/

struct GPSCoordinate
{
	var() int LatitudeDegree;
	var() float LatitudeMinute;
	var() int LongitudeDegree;
	var() float LongitudeMinute;
};

// Latitude and longitude corresonding to the (0,0) location of the world
var config GPSCoordinate ZeroZeroLocation;

// Scaling Factors
var float ScaleLatitude;
var float ScaleLongitude;
var float ScaleLonMinute;
var float ScaleLatMinute;
var SatelliteTracker Tracker;

// Noise Factors
var config float maxNoise;
var config float minNoise;
var int numSatellites;
var Utilities utils;

// Data structure to store the permutations of 4 satellites
struct PermutationData
{
	var int Satellite[4]; // Holds satellite numbers (we need four satellites to get GPS position)
};
var array<PermutationData> Permutations;  // Array to store all the possible satellite permutations

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Tracker = new class'SatelliteTracker';
	utils = new class'Utilities';
}

simulated function ConvertParam()
{
	super.ConvertParam();
	
	if (ScanInterval >= 0.1)
		SetTimer(ScanInterval, true);
}

simulated function AttachItem()
{
	local ReferenceGPSCoordinate reference;
	local bool gotReferenceFromWorld;
	gotReferenceFromWorld = false;
	
	// Calculate the scaling factor the latitude and longtiude minutes
	ScaleLonMinute = ScaleLongitude / 60;
	ScaleLatMinute = ScaleLatitude / 60;
	
	// Try to find a reference GPS coordinate inside the world
	foreach AllActors(class'ReferenceGPSCoordinate', Reference)
	{
		gotReferenceFromWorld = true;
		break;
	}
	
	// If a reference GPS coordinate was found within the world, then we set the (0,0) coordinate accordingly
	if (gotReferenceFromWorld)
	{
		// Correct incorrectly-entered reference locations where the degree is negative, but the minute is positive
		// They should both be negative
		if (Reference.LatitudeDegree < 0 && Reference.LatitudeMinute > 0)
			Reference.LatitudeMinute = -Reference.LatitudeMinute;
		if (Reference.LongitudeDegree < 0 && Reference.LongitudeMinute > 0)
			Reference.LongitudeMinute = -Reference.LongitudeMinute;
		
		ZeroZeroLocation.LatitudeDegree = Reference.LatitudeDegree;
		ZeroZeroLocation.LatitudeMinute = Reference.LatitudeMinute -
			class'UnitsConverter'.static.LengthFromUU(Reference.Location.X) / ScaleLatMinute;
		ZeroZeroLocation.LongitudeDegree = Reference.LongitudeDegree;
		ZeroZeroLocation.LongitudeMinute = Reference.LongitudeMinute -
			class'UnitsConverter'.static.LengthFromUU(Reference.Location.Y) / ScaleLonMinute;
		
		ZeroZeroLocation = FixGPSCoordinates(ZeroZeroLocation);
	}
	else
	// Otherwise, we use the default (0,0) GPS coordinate, as dictated by the USARBot.ini or defaultproperties
	{
		// Correct incorrectly-entered (0,0) locations where the degree is negative, but the minute is positive
		// They should both be negative
		if (ZeroZeroLocation.LatitudeDegree < 0 && ZeroZeroLocation.LatitudeMinute > 0)
			ZeroZeroLocation.LatitudeMinute = -ZeroZeroLocation.LatitudeMinute;
		if (ZeroZeroLocation.LongitudeDegree < 0 && ZeroZeroLocation.LongitudeMinute > 0)
			ZeroZeroLocation.LongitudeMinute = -ZeroZeroLocation.LongitudeMinute;
	}
	super.AttachItem();
}

function String GetGPS()
{
	local GPSCoordinate NewLocation;
	local int i, index;
	local float rLatitude, rLongitude, sLatitude, sLongitude, sAltitude, LatitudeMinutesDiff, LongitudeMinutesDiff;
	local array<int> satelliteSeen;
	local TraceHitInfo mtl;
	// Trace-Related Variables
	local Actor ActorHit;
	local vector TraceEnd, HitLocation, HitNormal;

	// Ground Truth
	NewLocation.LatitudeDegree = ZeroZeroLocation.LatitudeDegree;
	NewLocation.LatitudeMinute = ZeroZeroLocation.LatitudeMinute +
		class'UnitsConverter'.static.LengthFromUU(Location.X) / ScaleLatMinute;
	NewLocation.LongitudeDegree = ZeroZeroLocation.LongitudeDegree;
	NewLocation.LongitudeMinute = ZeroZeroLocation.LongitudeMinute +
		class'UnitsConverter'.static.LengthFromUU(Location.Y) / ScaleLonMinute;
	NewLocation = FixGPSCoordinates(NewLocation);
	
	// Convert latitude and longitude to degrees only
	rLatitude = NewLocation.LatitudeDegree + NewLocation.LatitudeMinute/60;
	rLongitude = NewLocation.LongitudeDegree + NewLocation.LongitudeMinute/60;
	index = Tracker.Satellite[0].Position.Length - 1;

	// Loop through all the GPS satellites
	for (i = 0; i < Tracker.Satellite.Length; i++)
	{
		// Store satellite position information
		sLatitude = Tracker.Satellite[i].Position[index].Latitude;
		sLongitude = Tracker.Satellite[i].Position[index].Longitude;
		sAltitude = Tracker.Satellite[i].Position[index].Altitude;

		// If we can "look up" towards the satellite
		if (Elevation(sLatitude, sLongitude, sAltitude, rLatitude, rLongitude) > 5)
			satelliteSeen[satelliteSeen.Length] = i;
	}

	for (i = 0; i < satelliteSeen.Length; i++)
	{
		LatitudeMinutesDiff = (Tracker.Satellite[satelliteSeen[i]].Position[index].Latitude -
			rLatitude) * 60;
		LongitudeMinutesDiff = (Tracker.Satellite[satelliteSeen[i]].Position[index].Longitude -
			rLongitude) * 60;

		TraceEnd.X = class'UnitsConverter'.static.LengthToUU((LatitudeMinutesDiff / 6) *
			11120) + Location.X;
		TraceEnd.Y = class'UnitsConverter'.static.LengthToUU((LongitudeMinutesDiff / 6) *
			7167) + Location.Y;
		TraceEnd.Z = class'UnitsConverter'.static.LengthToUU(Tracker.Satellite[
			satelliteSeen[i]].Position[index].Altitude * 1000) + Location.Z;

		// Get the actor hit and the location of the hit (location of the hit is TraceEnd if nothing was hit)
		ActorHit = Trace(HitLocation, HitNormal, TraceEnd, Location, true, , mtl);
		
		// If we have hit a brush, we have to check if it is the sky box
		if (InStr(String(ActorHit), "WorldInfo") > 0)
		{
			LogInternal(String(mtl.Material));
			// If the brush is not the sky box, we cannot see that satellite
			if (InStr(String(mtl.Material), "M_ASC_Floor") > 0)
			{
				// Remove satellite from list
				satelliteSeen.Remove(i,1);
				i--;
			}
		}
		// If we have not hit a brush (means we have it a static mesh), we cannot see that satellite
		else
		{
			// Remove satellite from list
			satelliteSeen.Remove(i,1);
			i--;
		}
	}

	// Save the number of satellites
	numSatellites = satelliteSeen.Length;

	// Noisy GPS Coordinate
	NewLocation.LatitudeDegree = ZeroZeroLocation.LatitudeDegree;
	NewLocation.LatitudeMinute = ZeroZeroLocation.LatitudeMinute +
		(class'UnitsConverter'.static.LengthFromUU(Location.X) +
		Noise(satelliteSeen.Length)) / ScaleLatMinute;
	NewLocation.LongitudeDegree = ZeroZeroLocation.LongitudeDegree;
	NewLocation.LongitudeMinute = ZeroZeroLocation.LongitudeMinute +
		(class'UnitsConverter'.static.LengthFromUU(Location.Y) +
		Noise(satelliteSeen.Length)) / ScaleLonMinute;
	NewLocation = FixGPSCoordinates(NewLocation);

	return GPSString(NewLocation);
}

function float Noise(int SatelliteNumber)
{
	local float sSigma;
	local float slope;
	local float b;
	slope = (maxNoise - minNoise) / -8;
	b = maxNoise - (4 * slope);
	sSigma = (slope * SatelliteNumber + b) / 3;
	return utils.gaussRand(0, sSigma);
}

function float Elevation(float sLat, float sLon, float Alt, float rLat, float rLon)
{
	local float R;
	local float b;
	local float d;
	local float a;
	local float elevation;

	R = 6378.137; // Radius of the earth
	b = acos(cos(class'UnitsConverter'.static.AngleFromDeg(90 - sLat)) *
		cos(class'UnitsConverter'.static.AngleFromDeg(90 - rLat)) +
		sin(class'UnitsConverter'.static.AngleFromDeg(90 - sLat)) *
		sin(class'UnitsConverter'.static.AngleFromDeg(90 - rLat)) *
		cos(class'UnitsConverter'.static.AngleFromDeg(sLon - rLon)));
	d = sqrt(R ** 2 + (R + Alt) ** 2 - 2 * R * (R + Alt) * cos(b));
	a = acos((d ** 2 + R ** 2 - (R + Alt) ** 2) / (2 * R * d));
	elevation = a * class'UnitsConverter'.static.getC_AngleToDegree() - 90;

	return elevation;
}

function GPSCoordinate FixGPSCoordinates(GPSCoordinate toFix)
{
	local GPSCoordinate fixedLatitude, fixedBoth;

	fixedLatitude = FixGPSCoordinate(toFix, true);
	fixedBoth = FixGPSCoordinate(fixedLatitude, false);

	return fixedBoth;
}

function GPSCoordinate FixGPSCoordinate(GPSCoordinate toFix, bool fixLatitude)
{
	local int Degree;
	local float Minute;
	local GPSCoordinate result;

	// Since we take care of latitude and longitude independetly, we copy the initial coordinate
	result = toFix;

	// Save the proper degree/minute that we are trying to fix
	if (fixLatitude)
	{
		Degree = toFix.LatitudeDegree;
		Minute = toFix.LatitudeMinute;
	}
	else
	{
		Degree = toFix.LongitudeDegree;
		Minute = toFix.LongitudeMinute;
	}

	// Make sure that the minute is between (-60, 60)
	while (Minute >= 60.0)
	{
		Degree++;
		Minute -= 60.0;
	}
	while (Minute <= -60.0)
	{
		Degree--;
		Minute += 60.0;
	}

	// Make sure that the degree is between [-90,90] for latitude
	if (fixLatitude)
	{
		Degree = Degree % 360;
		// If we are in the earth's second quadrant (clockwise) or fourth quadrant (counter-clockwise)
		if ((Degree >= 90 && Degree <= 179) || (Degree <= -270 && Degree >= -359))
		{
			Degree = 90 - abs(Degree % 90) - 1;
			Minute = 60.0 - abs(Minute);
			if (Minute == 60.0)
			{
				Degree++;
				Minute = 0;
			}
		}
		// If we are in the earth's third quadrant (clockwise) or third quadrant (counter-clockwise)
		else if ((Degree >= 180 && Degree <= 269) || (Degree <= -180 && Degree >= -269))
		{
			Degree = -(Degree % 90);
			Minute = -Minute;
		}
		// If we are in the earth's fourth quadrant (clockwise) or second quadrant (counter-clockwise)
		else if ((Degree >= 270 && Degree <= 359) || (Degree <= -90 && Degree >= -179))
		{
			Degree = -(90 - abs(Degree % 90) - 1);
			Minute = -(60.0 - abs(Minute));
			if (Minute == -60.0)
			{
				Degree--;
				Minute = 0;
			}
		}
	}
	// Make sure that the degree is between [-180,180] for longitude
	else
	{
		Degree = Degree % 360;
		// If we are in the earth's first hemisphere (clockwise)
		if (Degree >= 180 && Degree <= 359)
		{
			Degree = -(180 - abs(Degree % 180) - 1);
			Minute = -(60.0 - abs(Minute));
			if (Minute == -60.0)
			{
				Degree--;
				Minute = 0;
			}
		}
		// If we are in the earth's second hemisphere (counter-clockwise)
		if (Degree <= -180 && Degree >= -359)
		{
			Degree = 180 - abs(Degree) % 180 - 1;
			Minute = 60.0 - abs(Minute);
			if (Minute == 60.0)
			{
				Degree++;
				Minute = 0;
			}
		}
	}

	// Going South/West inside the North/East hemisphere
	if (Degree > 0 && Minute < 0)
	{
		Degree--;
		Minute += 60;
	}

	// Going North/East inside the South/West hemisphere
	if (Degree < 0 && Minute > 0)
	{
		Degree++;
		Minute -= 60;
	}

	// Store the proper degree/minute that we are trying to fix
	if (fixLatitude)
	{
		result.LatitudeDegree = Degree;
		result.LatitudeMinute = Minute;
	}
	else
	{
		result.LongitudeDegree = Degree;
		result.LongitudeMinute = Minute;
	}
	return result;
}

function String GPSString(GPSCoordinate toConvert)
{
	local String outstring;
	local String pos;

	// Here, we deal with the latitude component

	// Find out if we are in the North or South hemisphere
	if ((toConvert.LatitudeDegree < 0) || (toConvert.LatitudeDegree == 0 &&
			toConvert.LatitudeMinute < 0))
		pos = "S";
	else
		pos = "N";

	outstring = "{Latitude " $ int(abs(toConvert.LatitudeDegree)) $ "," $
		class'UnitsConverter'.static.FloatString(abs(toConvert.LatitudeMinute), 4) $ "," $
		pos $ "} ";
	
	// Here, we deal with the longitude component

	// Find out if we are in the East or West hemisphere
	if ((toConvert.LongitudeDegree < 0) || (toConvert.LongitudeDegree == 0 &&
			toConvert.LongitudeMinute < 0))
		pos = "W";
	else
		pos = "E";
	
	outstring = outstring $ "{Longitude " $ int(abs(toConvert.LongitudeDegree)) $ "," $
		class'UnitsConverter'.static.FloatString(abs(toConvert.LongitudeMinute), 4) $ "," $
		pos $ "} ";

	return outstring;
}

function FindPermutations(int n)
{
	local int r;
	local int i;
	local int k;
	local int count;
	local int end;
	r = 4;
	
	// We need to find all permutations of four satellites, out of n satellites
	// Make space in the dynamic array to add a left powered wheel
	Permutations.Insert(Permutations.Length, 1);
	end = Permutations.Length - 1;
	Permutations[end].Satellite[0] = 1;
	Permutations[end].Satellite[1] = 2;
	Permutations[end].Satellite[2] = 3;
	Permutations[end].Satellite[3] = 4;

	while (Permutations[end].Satellite[0] != n-r+1 || Permutations[end].Satellite[1] != n-r+2 ||
		Permutations[end].Satellite[2] != n-r+3 || Permutations[end].Satellite[3] != n-r+4)
	{
		count = 0;
		k = r;
		Permutations.Insert(Permutations.length, 1); // Make space for an additional permutation
		end = Permutations.Length - 1;
		while (Permutations[end - 1].Satellite[k - 1] >= n - r + k)
			k--;
		// Fill out new permutation
		for (i = 0; i < k - 1; i++)
			Permutations[end].Satellite[i] = Permutations[end - 1].Satellite[i];
		for (i = k - 1; i < r; i++)
		{
			count++;
			Permutations[end].Satellite[i] = Permutations[end - 1].Satellite[k - 1] + count;
		}
	}

	LogInternal("Permutations (#=" $ Permutations.length $ "):");
	for (i = 0; i < Permutations.length; i++)
		LogInternal(Permutations[i].Satellite[0] @ Permutations[i].Satellite[1] @
		Permutations[i].Satellite[2] @ Permutations[i].Satellite[3]);
	while (Permutations.Length != 0)
		Permutations.Remove(end, 1);
}

function String GetData()
{
	local String gpsData;
	local String outstring;

	gpsData = GetGPS();
	if (gpsData == "")
		return "";
	if (numSatellites < 4)
		outstring = "{Name " $ ItemName $ "} {Fix 0} {Satellites " $ numSatellites $ "}";
	else
		outstring = "{Name " $ ItemName $ "} " $ gpsData $ "{Fix 1} {Satellites " $ numSatellites $ "}";
	return outstring;
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{ScanInterval " $ ScanInterval $ "}";
	return outstring;
}

simulated function ClientTimer()
{
	MessageSendDelegate(getHead() @ GetData());
}

defaultproperties
{
	ItemType="GPS"
	DrawScale=0.2
	
	// Scale is meters per degree; for latitude, 111 km=1 degree
	ScaleLatitude=111200
	ScaleLongitude=71670
}
