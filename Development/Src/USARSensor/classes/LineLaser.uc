/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

//
// This class emulates a line laser.
// The basic principle of this sensor is based on traces along a given field of
// view and a given angular resolution originating from the center of the sensor.
// It makes use of the Trace() function which traces a given path and, in case of
// a collision, returns the object which has been hit as well as the location of the
// collision within the world. Whenever Trace() hits an object the sensor marks the
// location of the collision by drawing a square around it on the underlying surface
// considering its normal vector. Then it continues with the next trace. At the same
// time the sensor examines whether consecutive points lie on a line without any
// barrier in between which indicates that they are located on the same object.
// Whenever such a line gets interrupted by a new point the sensor draws the
// line by connecting its start- and endpoint using the DrawDebugLine()
// function. Of course this method only works as long as the angular resolution is
// high enough. When the angular difference between two consecutive traces is too
// large the sensor might connect points which lie on a line and on a surface with the
// same orientation within the world but are located on different objects. On the
// other hand the maximal resolution of the sensor is limited by the computational
// power of the hardware.
//

class LineLaser extends RangeSensor config (USAR);

var config float FOV;
var config int Resolution;
var config int squareSize;
var config float lineSpace;

var config float isPointOnLineVariance;

var String sensorData;
  
var float directionDifference;

var float firstBeamDirection;
var float lastBeamDirection;

var float currentBeamDirection;
var vector currentBeamDestination;

var vector currentLineStartPoint;
var vector currentLineEndPoint;

var vector currentLineStartPointHitNormal;
var vector currentLineEndPointHitNormal;

var array<vector> currentLineStartPointCorners;
var array<vector> currentLineEndPointCorners;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	sensorData = "";
	
	// Create the beam destinations.
	// The direction difference between the destinations will be FOV / Resolution.
	directionDifference = FOV / (float(Resolution - 1));
	firstBeamDirection = -float(Resolution - 1) / 2.0 * directionDifference;
	lastBeamDirection = float(Resolution - 1) / 2.0 * directionDifference;
	currentBeamDestination.Z = 0;
}

function bool pointIsOnLine(vector startPoint, vector endPoint, vector currentPoint)
{
	local float factor;
	local vector distanceVector, directionVector;

	directionVector = Normal(endPoint - startPoint);
	distanceVector = Normal(currentPoint - startPoint);

	// Either both or none of the components may have a zero value.
	if ((directionVector.X == 0) ^^ (distanceVector.X == 0))
		return false;
	else
	{
		// Avoid division by zero.
		if (directionVector.X != 0)
			factor = distanceVector.X / directionVector.X;
	}

	// Either both or none of the components may have a zero value.
	if ((directionVector.Y == 0) ^^ (distanceVector.Y == 0))
		return false;
	else
	{
		// Avoid division by zero.
		if (directionVector.Y != 0)
		{
			if (abs(factor - (distanceVector.Y / directionVector.Y)) > isPointOnLineVariance)
				return false;
		}
	}

	// Either both or none of the components may have a zero value.
	if ((directionVector.Z == 0) ^^ (distanceVector.Z == 0))
		return false;
	else
	{
		// Avoid division by zero.
		if (directionVector.Z != 0)
		{
			if (abs(factor - (distanceVector.Z / directionVector.Z)) > isPointOnLineVariance)
				return false;
		}
	}
	return true;
}

function drawSquare(vector leftUpperSquarePoint, vector leftLowerSquarePoint,
	vector rightUpperSquarePoint, float spaceBetweenLines)
{
	local vector lineStart, lineEnd, deltaHeight;
	local int lineCount;
	lineStart = leftUpperSquarePoint;
	lineEnd = rightUpperSquarePoint;

	// How many lines to draw?
	deltaHeight = leftLowerSquarePoint - leftUpperSquarePoint;
	lineCount = VSize(deltaHeight) / spaceBetweenLines;
	deltaHeight = Normal(deltaHeight) * spaceBetweenLines;

	// Draw the square
	while (VSize(lineStart - leftUpperSquarePoint) < VSize(deltaHeight * lineCount))
	{
		DrawDebugLine(lineStart, lineEnd, 255, 0, 0, true);
		lineStart = lineStart + deltaHeight;
		lineEnd = lineEnd + deltaHeight;
	}
	return;
}

function drawLine(vector leftUpperPoint, vector leftLowerPoint, vector rightUpperPoint,
	vector rightLowerPoint, float spaceBetweenLines)
{
	local vector lineStart, lineEnd;
	local vector leftDelta, rightDelta;

	leftDelta = leftLowerPoint - leftUpperPoint;
	leftDelta = Normal(leftDelta) * spaceBetweenLines;
	rightDelta = rightLowerPoint - rightUpperPoint;
	rightDelta = Normal(rightDelta) * spaceBetweenLines;

	lineStart = leftUpperPoint;
	lineEnd = rightUpperPoint;

	while (VSize(lineStart - leftUpperPoint) < VSize(leftLowerPoint - leftUpperPoint))
	{
		DrawDebugLine(lineStart, lineEnd, 255, 0, 0, true);
		lineStart = lineStart + leftDelta;
		lineEnd = lineEnd + rightDelta;
	}
}

function array<vector> calculateSquareCorners(vector locationVector, vector normalVector,
	vector horizontalVector, int sideLength)
{
	local vector verticalVector;
	local vector leftUpperSquarePoint, rightUpperSquarePoint, leftLowerSquarePoint, rightLowerSquarePoint;
	local array<vector> squareCorners;

	// Create the third basis vector using the cross product.
	verticalVector = horizontalVector Cross normalVector;

	// Normalize the basis vectors.
	horizontalVector = Normal(horizontalVector) * (sideLength / 2);
	verticalVector = Normal(verticalVector) * (sideLength / 2);

	// Now we will create a square around the location that we hit.
	leftUpperSquarePoint = locationVector + verticalVector - horizontalVector;
	rightUpperSquarePoint = locationVector + verticalVector + horizontalVector;
	leftLowerSquarePoint = locationVector - verticalVector - horizontalVector;
	rightLowerSquarePoint = locationVector - verticalVector + horizontalVector;

	squareCorners.Insert(0, 4);
	squareCorners[0] = leftUpperSquarePoint;
	squareCorners[1] = leftLowerSquarePoint;
	squareCorners[2] = rightUpperSquarePoint;
	squareCorners[3] = rightLowerSquarePoint;

	return squareCorners; 
}

// Scans for line laser hits.
function ScanLaser()
{
	local vector HitLocation, dummyHitLocation, HitNormal, dummyHitNormal;
	local vector sensorLocation;
	local rotator currentRotation;
	local quat rotationQuaternion;
	local bool isInRange;
	local float currentRange;
	local Actor HitTarget;

	currentRotation = Rotation;
	sensorLocation = Location;
	// For rotation of hit points expressed in world coordinates into sensor coordinates.
	rotationQuaternion = QuatFromRotator(currentRotation);

	// Ground truth data
	sensorData = "{Location " $ class'UnitsConverter'.static.Str_LengthVectorFromUU(sensorLocation,
		4) $ "} {Orientation " $ class'UnitsConverter'.static.Str_AngleVectorFromUU(currentRotation, 4) $ "}";
	sensorData = sensorData $ " {Points ";
	currentLineStartPoint = vect(0, 0, 0);
	currentLineEndPoint = vect(0, 0, 0);

	FlushPersistentDebugLines();
	currentBeamDirection = firstBeamDirection;

	while (currentBeamDirection < lastBeamDirection)
	{
		currentBeamDestination.X = Cos(currentBeamDirection) * MaxRange;
		currentBeamDestination.Y = Sin(currentBeamDirection) * MaxRange;
		currentBeamDestination.Z = 0;
		currentBeamDestination = class'UnitsConverter'.static.LengthVectorToUU(currentBeamDestination);

		// Search for collision with trace function
		hitTarget = Trace(HitLocation, HitNormal, sensorLocation + QuatRotateVector(
			rotationQuaternion, currentBeamDestination), sensorLocation, true);
		isInRange = false;
		if (hitTarget != None)
		{
			currentRange = VSize(HitLocation-sensorLocation);
			if (currentRange <= MaxRange)
				isInRange = true;
		}

		if (isInRange)
		{
			// Do we have a new line?
			if (VSize(currentLineStartPoint) == 0)
			{
				currentLineStartPoint = HitLocation;
				currentLineStartPointHitNormal = HitNormal;
			}
			else
			{
				// Do we have a current line?
				if (VSize(currentLineEndPoint) != 0)
				{
					// Check whether the current point is on the line and there is no barrier in between.
					if ((pointIsOnLine(currentLineStartPoint, currentLineEndPoint, HitLocation) == true) &&
						(Trace(dummyHitLocation, dummyHitNormal, currentLineEndPoint, HitLocation, true) == None))
					{
						// If that is the case the current point becomes the new end point of the line.
						currentLineEndPoint = HitLocation;
						currentLineEndPointHitNormal = HitNormal;
						// If this is the last beam during this iteration draw the line.
						if ((currentBeamDirection + directionDifference) >= lastBeamDirection)
						{
							currentLineStartPointCorners = calculateSquareCorners(currentLineStartPoint, currentLineStartPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
							drawSquare(currentLineStartPointCorners[0], currentLineStartPointCorners[1], currentLineStartPointCorners[2], lineSpace);
							currentLineEndPointCorners = calculateSquareCorners(currentLineEndPoint, currentLineEndPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
							drawSquare(currentLineEndPointCorners[0], currentLineEndPointCorners[1], currentLineEndPointCorners[2], lineSpace);
							drawLine(currentLineStartPointCorners[2], currentLineStartPointCorners[3], currentLineEndPointCorners[0], currentLineEndPointCorners[1], lineSpace);
						}
					}
					// The current point is not on the line or there is a barrier in between.
					else
					{
						// Draw the current line.
						currentLineStartPointCorners = calculateSquareCorners(currentLineStartPoint, currentLineStartPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
						drawSquare(currentLineStartPointCorners[0], currentLineStartPointCorners[1], currentLineStartPointCorners[2], lineSpace);
						currentLineEndPointCorners = calculateSquareCorners(currentLineEndPoint, currentLineEndPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
						drawSquare(currentLineEndPointCorners[0], currentLineEndPointCorners[1], currentLineEndPointCorners[2], lineSpace);
						drawLine(currentLineStartPointCorners[2], currentLineStartPointCorners[3], currentLineEndPointCorners[0], currentLineEndPointCorners[1], lineSpace);
						// The current point becomes the new start point.
						currentLineStartPoint = HitLocation;
						currentLineStartPointHitNormal = HitNormal;
						currentLineEndPoint = vect(0, 0, 0);
					}
				}
				else
				{
					// If there is a barrier between currentLineStartPoint and the current point draw currentLineStartPoint.
					if (Trace(dummyHitLocation, dummyHitNormal, currentLineStartPoint, HitLocation, true) != None)
					{
						currentLineStartPointCorners = calculateSquareCorners(currentLineStartPoint, currentLineStartPointHitNormal, HitLocation - currentLineStartPoint, squareSize);
						drawSquare(currentLineStartPointCorners[0], currentLineStartPointCorners[1], currentLineStartPointCorners[2], lineSpace);
						currentLineStartPoint = HitLocation;
					}
					else
					{
						currentLineEndPoint = HitLocation;
						currentLineEndPointHitNormal = HitNormal;
					}
				}
			}
		}
		else
		{
			if (VSize(currentLineStartPoint) != 0)
			{
				if (VSize(currentLineEndPoint) == 0)
				{
					currentLineStartPointCorners = calculateSquareCorners(currentLineStartPoint, currentLineStartPointHitNormal, HitLocation - currentLineStartPoint, squareSize);
					drawSquare(currentLineStartPointCorners[0], currentLineStartPointCorners[1], currentLineStartPointCorners[2], lineSpace);
					currentLineStartPoint = vect(0, 0, 0);
				}
				else
				{
					currentLineStartPointCorners = calculateSquareCorners(currentLineStartPoint, currentLineStartPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
					drawSquare(currentLineStartPointCorners[0], currentLineStartPointCorners[1], currentLineStartPointCorners[2], lineSpace);
					currentLineEndPointCorners = calculateSquareCorners(currentLineEndPoint, currentLineEndPointHitNormal, currentLineEndPoint - currentLineStartPoint, squareSize);
					drawSquare(currentLineEndPointCorners[0], currentLineEndPointCorners[1], currentLineEndPointCorners[2], lineSpace);
					drawLine(currentLineStartPointCorners[2], currentLineStartPointCorners[3], currentLineEndPointCorners[0], currentLineEndPointCorners[1], lineSpace);
					// There is no current line.
					currentLineStartPoint = vect(0, 0, 0);
					currentLineEndPoint = vect(0, 0, 0);
				}
			}
		}
		currentBeamDirection = currentBeamDirection + directionDifference;

		// Return measured ranges for comparisons
		sensorData = sensorData $ "[" $ class'UnitsConverter'.static.Str_LengthVectorFromUU(HitLocation, 3) $ "]";
	}
	sensorData = sensorData $ "}";
}

// Orders up a scan; returns data if it succeeded
function String GetData()
{
	if (sensorData == "")
	{
		ScanLaser();
		// Failed?
		if (sensorData == "")
			return "";
	}
	return "{Name " $ ItemName $ "} " $ sensorData;
}

function String GetConfData()
{
	local String outstring;
	outstring = super.GetConfData();
	outstring @= "{FOV " $ class'UnitsConverter'.static.FloatString(FOV) $ "}";
	outstring @= "{Resolution " $ Resolution $ "}";
	return outstring;
}

defaultproperties
{
	ItemType="LineLaser"
	DrawScale=0.4762
}
