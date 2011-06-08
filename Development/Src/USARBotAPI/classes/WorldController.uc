/*****************************************************************************
  DISCLAIMER:
  This software was produced by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.

  See NIST Administration Manual 4.09.07 b and Appendix I. 
*****************************************************************************/
/*
    World controller.
    Controller allows to create, destroy and move objects in the world.

    Commands:

    CONTROL {Type Create} {ClassName class} {Name name} {location x,y,z} {rotation x,y,z} {sclae x,y,z} {Physics None/Ground/Falling/RigidBody/Walking} {Permanent true/false}
    CONTROL {Type Kill} {Name name}
    CONTROL {Type KillAll} {MinPos x,y,z} {MaxPos x,y,z} // note that MinPos and MaxPos are optional.
																// if specified, then non-permanent objects in the defined
																// volume are removed. If not specified, then all objects
																// are killed.
    CONTROL {Type AbsMove} {Name name} {location x,y,z} {rotation x,y,z}
    CONTROL {Type RelMove} {Name name} {location x,y,z} {rotation x,y,z}

    CONTROL {Type Rotate} {Name name} {Speed x,y,z}

    CONTROL {Type SetWP} {Name name} [{Speed s}|{Time t}] [{Move <true/false>}]
            [{Autoalign <true/false>}] [{Show <true/false>}] [{Loop <true/false>}]
            [{ResetOnClear <true/false>}] [{WP x,y,z;x,y,z;...}]
    CONTROL {Type AddWP} {Name name} {WP x,y,z;x,y,z;...}
    CONTROL {Type ClearWP} {Name name}
	CONTROL {Type GetSTA} {Name name} {ClassName class} - get all objects, or just ones named name or of class class



    Port and additions by Stephen Balakirsky
	based on code by Marco Zaratti - marco.zaratti@gmail.com
*/

class WorldController extends Pawn config(USAR);
var config bool logData; // should log files be created on significant events?
var int logPostfix;      // file number appended to log file name
enum wcPhysics
{
	wcPhysics_None,
	wcPhysics_Falling,
	wcPhysics_Ground,
	wcPhysics_RigidBody,
	wcPhysics_Walking,
};

var string wpdelim; //Waypoint list delimiter.
var array<texture> traceTexture;
var config bool cleanOnClose;   // If WC should destroy its objects before exiting.
var int cmdIdx;                 // Used to loop through all WC enqueued commands

// This struct holds all the controlled objects.
struct ControlledObject
{
    var WCObject wcoActor;                // A reference to the object.
    var vector startLoc;
    var rotator startRot;

    // Animation state is controlles by these 2 bools
    // Rotation and waypoints movement can be activated independently.
    var bool bMoving;
    var bool bRotating;

    var array<vector> aWayPoints;   // Waypoints used to move the object across a path.
    var array<float> aSegLengths;   // aSegLength[i] = distance from point [0] to [i+1]
// sbb    var array<Tracing> aTracings;   // Tracing vector.
    var float fSpeed;           // Movement speed.
    var bool bLoop;             // Should waypoints travel be looped.
    var bool bAlign;            // If the object is aligned to the path.
    var bool bShow;             // Show tracings.
    var bool bResetOnClear;     // Resets its start posistion and rotation on clearWaypoints.
    var float fTotalDistance;   // Total path length.
    var float fCurrentDistance;  // Current point in the path.
    var int nCurrentPoint;       // Current waypoint.
    var rotator rRotSpeed;    // A constant angular speed for rotation.
	var EPhysics objPhysics;     // what kind of physics should we use?
};
var array<ControlledObject> controlledObjects;

////////////////////////////////////////////////////////////////////////////////

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	logPostfix = 1;
}

simulated event Destroyed()
{
	local int id, len;
	local vector trash;

	len = controlledObjects.Length;
	for(id=0; id < len; id++)
	{
        ShowTracesOf(id, false);
        ClearWaypointsOf(id);
		/*
        if(cleanOnClose)
            controlledObjects[id].wcoActor.Destroy();
			*/
	}
	if(cleanOnClose)
	{
		trash.x = 0;
		trash.y = 0;
		trash.z = 0;
		KillAll(trash, trash);
	}
	Super.Destroyed();
}


/*
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
}
*/

// Returns the index of the object 'getName', -1 if not found.
simulated function int GetObject(string getName)
{
    local int i;

   for(i=0; i < controlledObjects.length; i++)
       if(controlledObjects[i].wcoActor.wcoName == getName)
            return i;
    return -1;
}

// Returns the reference of the robot 'getName', none if not found in the map.
simulated function BotController GetController(string getName)
{
    local int i;
   local BotDeathMatch UsarGame; 
   UsarGame = BotDeathMatch(WorldInfo.Game);

    for(i=0; i < UsarGame.botList.length; i++)
        if(UsarGame.botList[i].PlayerReplicationInfo.PlayerName == getName)
            return UsarGame.botList[i];
    return none;
}

//////////////////////////////////////////////////////////////////////////////////
// Commands to world controller
//
/*
   Create - Create an object at a given location with a given name
   NOTE: ScaleIn currently does not do anything! This is because of problems with collision scaling.
 */
 function Create( String ClassToMake, String NameIn, String MemoryIn, Vector LocationIn, Vector RotationIn, Vector ScaleIn, String PhysicsToUse, bool permanentIn )
 {
	local int id;
	local Vector newLocation;
	local Rotator newRotation;
    local class<WCObject> objectClass;
    local WCObject wcoActor; 
	
	id = GetObject(NameIn);
	if( id != -1 )
	{
		LogInternal("WorldController:Create: Object of name " $ NameIn $ " already exists!");
		return;
	}
	
	newLocation = class'UnitsConverter'.static.LengthVectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AngleVectorToUU(RotationIn);

	objectClass = class<WCObject>(DynamicLoadObject(ClassToMake, class'Class'));
	if( objectClass == None )
		return;

	wcoActor = Spawn(objectClass, , , newLocation, newRotation);

		if(wcoActor != none)
    {
        id = controlledObjects.length;
        controlledObjects.Insert(id,1);
		controlledObjects[id].wcoActor = wcoActor;
//		LogInternal( "Setting scale to " $ ScaleIn );
//		wcoActor.SetDrawScale3D(ScaleIn);

    }
	else
	{
		LogInternal("WorldController: Error adding bot");
		return;
	}

	LogInternal( "WorldController: Spawned robot model named " $ NameIn $ " at: " $newLocation $ " memory: " $ MemoryIn );
	
    controlledObjects[id].wcoActor.wcoName = NameIn;
	controlledObjects[id].wcoActor.wcoMemory = MemoryIn;
	controlledObjects[id].wcoActor.wcoClass = ClassToMake;
    controlledObjects[id].startLoc = newLocation;
    controlledObjects[id].startRot = newRotation;
    controlledObjects[id].bResetOnClear = true;
	controlledObjects[id].wcoActor.permanent = permanentIn;
	if(PhysicsToUse == "None" )
	{
		controlledObjects[id].objPhysics = PHYS_None;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
	}

	if(PhysicsToUse == "Falling" )
	{
		controlledObjects[id].objPhysics = PHYS_Falling; // was PHYS_Falling
		controlledObjects[id].wcoActor.SetPhysics(PHYS_Falling);
	}
	else if(PhysicsToUse == "RigidBody")
	{
		controlledObjects[id].objPhysics = PHYS_RigidBody;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_RigidBody);
	}
	else if(PhysicsToUse == "Walking")
	{
		controlledObjects[id].objPhysics = PHYS_Walking;
		controlledObjects[id].wcoActor.SetPhysics(PHYS_Walking);
	}
	/*
	else if(PhysicsToUse == "Ground")
	{
		controlledObjects[id].objPhysics = PHYS_Ground;

			controlledObjects[id].wcoActor.boundary.X = 
			   class'UnitsConverter'.static.LengthToUU(controlledObjects[id].wcoActor.boundary.X);
			controlledObjects[id].wcoActor.boundary.Y = 
			   class'UnitsConverter'.static.LengthToUU(controlledObjects[id].wcoActor.boundary.Y);
			controlledObjects[id].wcoActor.boundary.Z = 
			   class'UnitsConverter'.static.LengthToUU(controlledObjects[id].wcoActor.boundary.Z);


		controlledObjects[id].startLoc = setElevationPose(newLocation, id);
		newLocation.Z = controlledObjects[id].startLoc.Z;
		newRotation.Roll = controlledObjects[id].startLoc.X;
		newRotation.Pitch = controlledObjects[id].startLoc.Y;
		LogInternal("WorldController: Placing object at: " $ newLocation );
		controlledObjects[id].wcoActor.SetLocation(newLocation);
		controlledObjects[id].wcoActor.SetRotation(newRotation);
		LogInternal( "Object actually at: " $ controlledObjects[id].wcoActor.Location );
	}
	*/
	else
		controlledObjects[id].objPhysics = PHYS_None;
 }

 /* 
 SetZoneVel - Set Zone Velocity 
 */
 function SetZoneVel( String NameIn, float velocityIn )
 {
 	local ConveyorVolume A;
	local int count;
	local MaterialInstance myMaterial;

//	LogInternal( "Looking for ConveyorVolume: " $ NameIn );
	foreach AllActors( Class'ConveyorVolume', A )
	{
		if(A.conveyorTag == NameIn )
		{
//			LogInternal( "Found ConveyorVolume! " $A.Name );
			A.ZoneVelocity.X = A.defaultSpeed.X * velocityIn;
			A.ZoneVelocity.Y = A.defaultSpeed.Y * velocityIn;
			A.ZoneVelocity.Z = A.defaultSpeed.Z * velocityIn;
			
			/* Would be nice to change the material to make it stand still. But is it worth it? */
			for( count=0; count<A.Conveyors.Length; count++ )
			{
				myMaterial = A.SpeedMaterial.MatInst;
//				myMaterial.SetScalarParameterValue('Conveyor Speed', velocityIn);
				myMaterial.SetScalarParameterValue(A.SpeedParameter, velocityIn);
				A.Conveyors[count].StaticMeshComponent.SetMaterial(1, myMaterial);				
			/*
				if( velocityIn != 0 )
					A.Conveyors[count].StaticMeshComponent.SetMaterial(1, A.PositiveSpeedMat);
					//Material'LT_Floors.SM.Materials.M_LT_Floors_SM_Conveyor01_Belt_still';
				else
					A.Conveyors[count].StaticMeshComponent.SetMaterial(1, A.ZeroSpeedMat);
					//Material'LT_Floors.SM.Materials.M_LT_Floors_SM_Conveyor01_Belt';
			*/
			}
		}
		/*
		else
			LogInternal( "Found another ConveyorVolume! " $A.ConveyorTag );
			*/
	}
	return;
}

 /*
   GetSTA - Get the status of objects. If class is specified, only return objects of that class, if name is specified, only that name
 */
 function String GetSTA( String ClassIn, String NameIn )
 {
	local int len, id;
	local string OutStr;
	local vector OutSize;

	OutStr = "STA ";
	
    len = controlledObjects.Length;
    if(len > 0)
    {
        for(id=0; id < len; id++)
        {
			if( ClassIn != "" )
			{
				if( ClassIn != controlledObjects[id].wcoActor.wcoClass )
					continue;
			}
			if( NameIn != "" )
			{
				if( NameIn != controlledObjects[id].wcoActor.wcoName )
					continue;
			}
//			LogInternal( "Boundary: " $controlledObjects[id].wcoActor.boundary $ " DrawScale: " $ controlledObjects[id].wcoActor.DrawScale $ " 3d: " $ controlledObjects[id].wcoActor.DrawScale3D);
			OutSize.x = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.x * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.x; 
			OutSize.y = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.y * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.y; 
			OutSize.z = class'UnitsConverter'.static.LengthFromUU(controlledObjects[id].wcoActor.boundary.z * 2.) *
						controlledObjects[id].wcoActor.DrawScale * controlledObjects[id].wcoActor.DrawScale3D.z; 
			
			OutStr = OutStr $ "{Name " $ controlledObjects[id].wcoActor.wcoName $"}" ;
			OutStr = OutStr $ "{Memory " $ controlledObjects[id].wcoActor.wcoMemory $"}" ;
			OutStr = OutStr $ "{Size " $ OutSize $"}";
			OutStr = OutStr $ "{Location " $ class'UnitsConverter'.static.Str_LengthVectorFromUU(controlledObjects[id].wcoActor.Location) $"}";
			OutStr = OutStr $ "{Rotation " $ class'UnitsConverter'.static.Str_AngleVectorFromUU(controlledObjects[id].wcoActor.Rotation) $"}";
        } 
	}
//	LogInternal( OutStr );
	return OutStr;
 }
 
/* 
   RelMove - moves an object or a robot by a relative amount
   Currently only supports the movement of a mesh
 */
function RelMove( String NameIn, Vector LocationIn, Vector RotationIn )
{
	local BotController mover;
	local Vector newLocation;
	local Rotator newRotation;
	local int id;
//	local Vector tempLocation;
	local bool result;
	
	newLocation = class'UnitsConverter'.static.LengthVectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AngleVectorToUU(RotationIn);

	id = GetObject(NameIn);
	if( id != -1 )
	{
//		LogInternal("WorldController: Moving object " $ controlledObjects[id].wcoActor.wcoName);
//		LogInternal("   From: " $controlledObjects[id].wcoActor.location$ " " $controlledObjects[id].wcoActor.Rotation);
//		LogInternal("   to relative:" $ newLocation $ " " $ newRotation);
//		LogInternal("WorldController:Current physics: " $controlledObjects[id].wcoActor.Physics);
		newLocation += controlledObjects[id].wcoActor.Location;
/*		
		if( controlledObjects[id].objPhysics == PHYS_Ground ) // move the object to the ground!
		{
			tempLocation = setElevationPose(newLocation, id);
			newLocation.Z = tempLocation.Z;
			newRotation.Roll = tempLocation.X;
			newRotation.Pitch = tempLocation.Y;
		}
		*/
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
		controlledObjects[id].wcoActor.SetLocation(newLocation);
		newRotation = controlledObjects[id].wcoActor.Rotation + newRotation;
		controlledObjects[id].wcoActor.SetRotation(newRotation);
		controlledObjects[id].wcoActor.SetPhysics(controlledObjects[id].objPhysics);
	}
	else if( GetController(NameIn) != none )
	{
			mover = GetController(NameIn);
			LogInternal("WorldController: Working with mover");
//			mover.bPreparingMove = true;
//			mover.pawn.SetPhysics(PHYS_None);
			result = mover.pawn.Move(newLocation);
//			result = mover.pawn.SetRelativeLocation(newLocation);
//			mover.pawn.SetPhysics(PHYS_Falling);
			LogInternal("WorldController:Current physics: " $mover.pawn.Physics);
			LogInternal("WorldController: Moving robot located at: " $ mover.pawn.Location);
			LogInternal("	by " $ newLocation $ " " $ newRotation );
//			newLocation = mover.pawn.Location + newLocation;
			LogInternal("   to " $ newLocation );
//			result = mover.pawn.SetLocation(newLocation);
//			robot = mover.pawn.GetBaseMost();
//			result = robot.Move(newLocation);
//			mover.pawn.ClientSetLocation(newLocation, newRotation);
//			mover.pawn.ForceNetRelevant();
//			mover.pawn.bUpdateSimulatedPosition = true;
			LogInternal( "Result of move: " $ result );
//	        vLoc = robot.Location + USARRemoteBot(Controller).WC[cmdIdx].objLoc;
//	        robot.MoveRobot(vLoc);
			
	
	}
	else
	{
		LogInternal("WorldController:RelMove: unable to find robot named: " $ NameIn);
	}	
}	
 
/* 
   AbsMove - moves an object or a robot to an absolute position
   Currently only supports the movement of a mesh
 */
function AbsMove( String NameIn, Vector LocationIn, Vector RotationIn )
{
	local Vector newLocation;
	local Rotator newRotation;
	local int id;
//	local Vector tempLocation;

	newLocation = class'UnitsConverter'.static.LengthVectorToUU(LocationIn);
	newRotation = class'UnitsConverter'.static.AngleVectorToUU(RotationIn);

	id = GetObject(NameIn);
	if( id != -1 )
	{
		LogInternal("WorldController: Moving object " $ controlledObjects[id].wcoActor.wcoName);
		LogInternal("   From: " $controlledObjects[id].wcoActor.location$ " " $controlledObjects[id].wcoActor.Rotation);
		LogInternal("   to relative:" $ newLocation $ " " $ newRotation);
		/*
		if( controlledObjects[id].objPhysics == PHYS_Ground ) // move the object to the ground!
		{
			tempLocation = setElevationPose(newLocation, id);
			newLocation.Z = tempLocation.Z;
			newRotation.Roll = tempLocation.X;
			newRotation.Pitch = tempLocation.Y;
		}
		*/
		controlledObjects[id].wcoActor.SetPhysics(PHYS_None);
		controlledObjects[id].wcoActor.dirty = 2;

		controlledObjects[id].wcoActor.SetLocation(newLocation);
		controlledObjects[id].wcoActor.SetRotation(newRotation);
		controlledObjects[id].wcoActor.ForceUpdateComponents();
//		controlledObjects[id].wcoActor.SetPhysics(controlledObjects[id].objPhysics);
	}
	else
	{
		LogInternal("WorldController:AbsMove: unable to find robot named: " $ NameIn);
	}
	/*else 
	{
		mover = GetController(NameIn);
	    if(mover != none)
	    {
			LogInternal("WorldController: Moving robot located at: " $ mover.pawn.Location);
			LogInternal("	by " $ newLocation $ " " $ newRotation );
			mover.pawn.Move(newLocation);
//			newLocation = mover.pawn.Location + newLocation;
//			mover.SetLocation(newLocation);
//			mover.pawn.ClientSetLocation(newLocation, newRotation);
			
	        vLoc = robot.Location + USARRemoteBot(Controller).WC[cmdIdx].objLoc;
	        robot.MoveRobot(vLoc);
			
		}
	} */
}	

/* 
 Kill - remove controlled object from world	
 */
 function Kill( String NameIn )
 {
	local int id;
 
	LogInternal("WorldController killing object named: " $ NameIn);
	id = GetObject(NameIn);
    if(id == -1)
	{
		LogInternal( "WorldController: unable to remove actor " $ NameIn );
		return;
	}
    ShowTracesOf(id, false);
    ClearWaypointsOf(id);
    controlledObjects[id].wcoActor.Destroy();
    controlledObjects.Remove(id,1);
}

/* 
 KillAll - remove all controlled objects from world	
 */
 function KillAll(Vector MinPos, Vector MaxPos)
 {
	local int len, id;
	local WCObject wco;
	local Vector currentLoc;
	local string fileName;
	local FileLog myLog;
	local Vector posVector, palletVector;

	myLog = None;
	palletVector.x = 0;
	palletVector.y = 0;
	palletVector.z = 0;
	
	if( MinPos != MaxPos )
	{
		MinPos = class'UnitsConverter'.static.LengthVectorToUU(MinPos);
		MaxPos = class'UnitsConverter'.static.LengthVectorToUU(MaxPos);
		LogInternal( "MinPos: " $ MinPos $ " MaxPos: " $ MaxPos );
	}
	if( logData )
	{
		myLog = spawn(class'FileLog');
        if(myLog != None) 
		{
			fileName = "killLog" $ logPostfix;
			myLog.OpenLog( fileName ); // will default to adding .txt to end
            myLog.Logf("name, class, memory, x, y, z, roll, pitch, yaw");
			logPostfix += 1;
        } 
	}
    len = controlledObjects.Length;
	LogInternal("WorldController killing " $len$ " Objects" );
    if(len > 0)
    {
		for(id=0; id < len; id++)
		{
			if( myLog != None )
				{
					posVector = controlledObjects[id].wcoActor.location;
					if( controlledObjects[id].wcoActor.wcoMemory == "Pallet" )
						{
							palletVector = posVector;
							palletVector.x -= controlledObjects[id].wcoActor.boundary.x;
							palletVector.y += controlledObjects[id].wcoActor.boundary.y;
							palletVector.z -= controlledObjects[id].wcoActor.boundary.z;
							palletVector.z *= -1;
							palletVector.y *= -1;
						}
					posVector.z -= controlledObjects[id].wcoActor.boundary.Z;
					posVector.z *= -1; // convention of log file has z positive up
					posVector.y *= -1.;
					
					myLog.Logf(controlledObjects[id].wcoActor.wcoName $ "," $ 
							   controlledObjects[id].wcoActor.wcoClass $ "," $
							   controlledObjects[id].wcoActor.wcoMemory $ "," $
							   class'UnitsConverter'.static.Str_LengthVectorFromUU(posVector-palletVector) $ "," $
							   class'UnitsConverter'.static.Str_AngleVectorFromUU(controlledObjects[id].wcoActor.rotation) );

				}
		}
        for(id=0; id < len; id++)
        {
			currentLoc = controlledObjects[id].wcoActor.Location;
			LogInternal( "Package Location: " $ currentLoc );
			/*
			if( MinPos==MaxPos )
			{
				LogInternal( "MinPos equals MaxPos" );
			}
			*/
			if( MinPos==MaxPos || (currentLoc.x>MinPos.x && currentLoc.y>MinPos.y && currentLoc.z>MinPos.z &&
			                                     currentLoc.x<MaxPos.x && currentLoc.y<MaxPos.y && currentLoc.z<MaxPos.z) )
			{
				ShowTracesOf(id, false);
				ClearWaypointsOf(id);
				if( controlledObjects[id].wcoActor.permanent != true )
				{
					controlledObjects[id].wcoActor.Destroy();
					controlledObjects.Remove(id,1);
					// need to adjust the array since we deleted some of it!
					id--;
					len--;
				}
			}
        }
    }
	if( logData )
	{
		myLog.CloseLog();
	}
    // Then cycle through all the other WC objects in the map, if any. You can
    // find these objects when a previous WorldController created them and
    // then quit without removing them. You can for example create a WC, then
    // use it to populate the map and quit the WC leaving all the objects in the map.
    // When you want to remove these objects you create another WC and issue a KillAll.
	if( MinPos==MaxPos )
		foreach AllActors(class'WCObject',wco)
			wco.Destroy();
}

 
/////////////////////////////////////////////////////////////////////////////////////////////////	
/* note that we overload the vector here:
 * x - roll value of object
 * y - pitch value of object
 * z - elevation of object
 */
function Vector setElevationPose(Vector locationIn, int idIn)
{
	local Vector HitLocation,HitNormal;
    local Vector range;
	local Vector testTrace;
	local float maxElevation;
	local Vector myReturn;
	local float rangeMeters;
		
	range.x = 0;
	range.y = 0;
	rangeMeters = 0;
	while( rangeMeters < 2 )
	{
		rangeMeters += 1;
		
		range.z = class'UnitsConverter'.static.LengthToUU(rangeMeters); // move objects that are up to 1 meter above the ground to the ground 
	
	// lets get trace information!
	// try points around object to find highest elevation
	testTrace = locationIn;
	testTrace.x += controlledObjects[idIn].wcoActor.boundary.X;
	if( Trace(HitLocation, HitNormal, testTrace - 2*range, testTrace+range)!=NONE)
	{
//		LogInternal( "Trace(x+" $controlledObjects[idIn].wcoActor.boundary.X $") from:"$ (testTrace+range) $ " to:" $ testTrace - 2*range $ " hit at: "$HitLocation);
		maxElevation = HitLocation.z;
	} else
		maxElevation = -100000;
	testTrace.x -= 2 * controlledObjects[idIn].wcoActor.boundary.X;
	if( Trace(HitLocation, HitNormal, testTrace - 2*range, testTrace+range)!=NONE)
	{
//		LogInternal( "Trace(x-" $controlledObjects[idIn].wcoActor.boundaryX. $") from:"$ (testTrace+range) $ " to:" $ testTrace - 2*range $ " hit at: "$HitLocation);
		if( maxElevation < HitLocation.z )
			maxElevation = HitLocation.z;
	}
	testTrace.x += controlledObjects[idIn].wcoActor.boundary.X;
	testTrace.y += controlledObjects[idIn].wcoActor.boundary.Y;
	if( Trace(HitLocation, HitNormal, testTrace - 2*range, testTrace+range)!=NONE)
	{
//		LogInternal( "Trace(y+" $controlledObjects[idIn].wcoActor.boundary.Y $") from:"$ (testTrace+range) $ " to:" $ testTrace - 2*range $ " hit at: "$HitLocation);
		if( maxElevation < HitLocation.z )
			maxElevation = HitLocation.z;
	}
	testTrace.y -= 2 * controlledObjects[idIn].wcoActor.boundary.Y;
	if( Trace(HitLocation, HitNormal, testTrace - 2*range, testTrace+range)!=NONE)
	{
//		LogInternal( "Trace(y-" $controlledObjects[idIn].wcoActor.boundary.Y$ ") from:"$ (testTrace+range) $ " to:" $ testTrace - 2*range $ " hit at: "$HitLocation);
		if( maxElevation < HitLocation.z )
			maxElevation = HitLocation.z;
	}
	if( maxElevation > -90000 )
	{
		myReturn.z = maxElevation + controlledObjects[idIn].wcoActor.boundary.Z;
		return myReturn;
	}
	else
	{
		LogInternal( "WorldController: Unable to set object elevation" );
		myReturn.z = locationIn.z;
	}
	}
	return myReturn;
}		

simulated function bool IsVectNull(vector v)
{
    if(v.X ~= 0 && v.Y ~= 0 && v.Z ~= 0)
        return true;

    return false;
}

simulated function bool IsRotNull(rotator r)
{
    if(r.Roll ~= 0 && r.Pitch ~= 0 && r.Yaw ~= 0)
        return true;

    return false;
}

// Adds the USARRemoteBot(Controller).WC[cmdIdx].wpList to the 'id' object.
// Returns the number of waypoints added.
simulated function int AddWPListTo(int id)
{
	/* function commented because points is unassigned
    local int i;
    local int wplen;
    local int points;
    local array<string> tokens;
    local vector wp;

    //WP list is in the form x,y,z;x,y,z;... (also x,y,z ; x,y,z ...)
    //points = Split(USARRemoteBot(Controller).WC[cmdIdx].wpList, wpdelim, tokens);

    wplen = controlledObjects[id].aWayPoints.Length;
    controlledObjects[id].aWayPoints.Insert(wplen, points);
    controlledObjects[id].aSegLengths.Insert(wplen, points);

    for(i=0; i < points; i++)
    {
		//wp=class'Utilities'.static.ParseVector(class'Utilities'.static.Trim(tokens[i]));
		wp=class'UnitsConverter'.static.LengthVectorToUU(wp);
        controlledObjects[id].aWayPoints[wplen++] = wp;
    }
    return points;
	*/
	
	return 0; // add as stub, remove when function is restored
}

// Shows or hides (deleting) the waypoint trace for the 'id' object.
// This func will always destroy all previous traces, if any. This
// assures that, even if you change waypoints, the traces will be
// correctly drawn.
simulated function ShowTracesOf(int id, bool show)
{
//    local int i, len, traceColor;
	local int len;
// sbb   local Tracing T;

    // delete all traces
/* sbb
    len = controlledObjects[id].aTracings.Length;
    for(i=0; i < len; i++)
        controlledObjects[id].aTracings[i].Destroy();
    controlledObjects[id].aTracings.Remove(0,len);
*/

    if(show)
    {
        len = controlledObjects[id].aWayPoints.Length;
        if(len > 0)
        {
/* sbb
            controlledObjects[id].aTracings.Insert(0,len);
            traceColor = id % traceTexture.Length;
            for(i=0; i <len; i++)
            {
                T = spawn(class'USARBot.Tracing',,,controlledObjects[id].aWayPoints[i]);
                T.Texture = traceTexture[traceColor];
                controlledObjects[id].aTracings[i] = T;\
            }
*/
        }
    }
}

// Clears all waypoints data of object 'id'.
// That means that all arrays are cleared
// (aWayPoints, aSegLengths, ATracings) and
// the objects is moved to its starting position.
simulated function ClearWaypointsOf(int id)
{
    local int numNodes;
//    local rotator rRot;
//    local vector vLoc;

    numNodes = controlledObjects[id].aWayPoints.Length;
    if(numNodes > 0)
    {
        // Deletes aWayPoints array
        controlledObjects[id].aWayPoints.Remove(0, numNodes);
        // Deletes aSegLength array
        controlledObjects[id].aSegLengths.Remove(0,numNodes);

        controlledObjects[id].fCurrentDistance = 0.0;
        controlledObjects[id].nCurrentPoint = 0;
        controlledObjects[id].fTotalDistance = 0.0;
        controlledObjects[id].bMoving = false;

        // Resets the starting position if requested
        if(controlledObjects[id].bResetOnClear)
        {
            // Resets location
// sbb            vLoc = controlledObjects[id].startLoc - controlledObjects[id].wcoActor.Location;
// sbb            controlledObjects[id].wcoActor.Move(vLoc);
            // Resets rotation
// sbb            rRot = controlledObjects[id].startRot;
// sbb            controlledObjects[id].wcoActor.SetRotation(rRot);
        }
    }
}

// Calculates the toal distance of the waypints path of the 'id' object.
// closedLoop specify if the path must be considered closed
// or open. Closed path is always longer than open.
// It also calculates the length of each segment and store it in aSegLengths.
// aSegLength[i] = distance from point [0] to [i+1].
simulated function float CalculateWPDistanceOf(int id, bool closedLoop)
{
    local int i;
    local int numPoints;
    local vector segment;
    local float segLen, dist;

    numPoints = controlledObjects[id].aWayPoints.Length -1;

    if(numPoints >= 0)
    {
        // First find the open path length (points = num of wp -1)
        while(i < numPoints)
        {
            segment = controlledObjects[id].aWayPoints[i + 1] - controlledObjects[id].aWayPoints[i];
            dist += VSize(segment);
            controlledObjects[id].aSegLengths[i] = dist;
            i++;
        }

        segment = controlledObjects[id].aWayPoints[0] - controlledObjects[id].aWayPoints[i];
        segLen = dist + VSize(segment);
        // We always fill completely the segment length array (as if it were looped).
        controlledObjects[id].aSegLengths[i] = segLen;

        if(closedLoop)
            dist = segLen;
    }
    else
        dist = 0;

    return dist;
}

//Returns the vector [node] ->[node +1] of the object 'id'.
simulated function vector GetSegmentVect(int id, int node)
{
    local int maxNode;

    maxNode = controlledObjects[id].aWayPoints.Length -1;
    if(node < maxNode)
        // The object is moving from: [node] -> [node +1]
        return (controlledObjects[id].aWayPoints[node +1] - controlledObjects[id].aWayPoints[node]);
    else// We're closing the loop: [lastNode] -> [0].
        return (controlledObjects[id].aWayPoints[0] - controlledObjects[id].aWayPoints[node]);
}
//Returns:
// segSize: the size of the vector [node] ->[node +1].
// segPos: the position inthe curent segment.
simulated function GetSegmentPos(int id, int node, out float segSize, out float segPos)
{
    // aSegLengths[node] is the distance that the object will cover at the end of the current segment.
    // So, the current segment size can be obtained this way:
    // aSegLengths[node] - aSegLengths[node -1].
    if(node == 0)
    {
        segSize = controlledObjects[id].aSegLengths[0];
        segPos = controlledObjects[id].fCurrentDistance;
    }
    else
    {
        segSize = controlledObjects[id].aSegLengths[node] - controlledObjects[id].aSegLengths[node -1];
        segPos = controlledObjects[id].fCurrentDistance - controlledObjects[id].aSegLengths[node -1];
    }
}

// This function sets the object 'id' at a specified position in the path.
simulated function SetTheObjectTo(int id, float dist)
{
    local int node;
    local vector segVect, newPos;
    local float segSize;    // Current segment size
    local float segPos;     // Relative position in the current segment

    if(dist < 0)
        dist = 0;
    else if (dist > controlledObjects[id].fTotalDistance)
        dist = controlledObjects[id].fTotalDistance;

    controlledObjects[id].fCurrentDistance = dist;
    node = controlledObjects[id].nCurrentPoint;

    // Finds the node where we are (last node we passed).
    // 'node' cannot become bigger than the size of waypoints array
    // because we have limited dist at the beginning of this function.
    while(dist >= controlledObjects[id].aSegLengths[node])
        node++;

    // Updates the current node
    controlledObjects[id].nCurrentPoint = node;

    GetSegmentPos(id, node, segSize, segPos);
    segVect = GetSegmentVect(id, node);

// sbb    if(controlledObjects[id].bAlign)
// sbb        controlledObjects[id].wcoActor.SetRotation(rotator(segVect));

    // Performs linear interpolation.
//    newPos = controlledObjects[id].aWayPoints[node] + segVect*(segPos/segSize);
	LogInternal( "WorldController: newPos="$class'UnitsConverter'.static.VectorString(newPos));
	
    // Now calculate the new object position. We must use Move(), that is a
    // relative movement function. We're also reusing segVect var.
   segVect = newPos - controlledObjects[id].wcoActor.Location;
   controlledObjects[id].wcoActor.Move(segVect);
}

/** Here we process the CONTROL commands.
 *  It's done only on server as commands are received only on server. */
 /* sbb each of these now needs to be its own routine!
function ProcessControls()
{
    local class<WCObject> objectClass;
    local ControlledObject objData;
    local WCObject wco;
    local int id;
    local bool showBit, loopBit, alignBit;
    local int i, len;      // General purpose variables
    local float avSpeed;
    local vector vLoc;  // General purpose variable
    local rotator rRot; // General purpose variable
    local USARVehicle robot;

    for(cmdIdx=0; cmdIdx < USARRemoteBot(Controller).WC.Length; cmdIdx++)
    {
        //All commands require a named object, so we take its reference here.
        id = GetObject(USARRemoteBot(Controller).WC[cmdIdx].objName);

    	switch(USARRemoteBot(Controller).WC[cmdIdx].cmd)
    	{
    	////////////////////////////////////////////////////////////////////////////
    	// CONTROL {Type Create} {ClassName class} {Name name} {location x,y,z} {rotation x,y,z}
    	case 1:
            // Check if already exists an object with that name
            if(id != -1) break;

            if(USARRemoteBot(Controller).WC[cmdIdx].isObjLoc)
                vLoc = USARRemoteBot(Controller).WC[cmdIdx].objLoc;
            if(USARRemoteBot(Controller).WC[cmdIdx].isObjRot)
                rRot = USARRemoteBot(Controller).WC[cmdIdx].objRot;

        	objectClass = class<WCObject>(DynamicLoadObject(USARRemoteBot(Controller).WC[cmdIdx].objClassName, class'Class'));
    	    objData.wcoActor = Spawn(objectClass,,,vLoc,rRot);
        	objData.wcoActor.wcoName = USARRemoteBot(Controller).WC[cmdIdx].objName;
    	    objData.startLoc = vLoc;
    	    objData.startRot = rRot;
    	    objData.bResetOnClear = true;

    	    if(objData.wcoActor != none)
            {
                id = controlledObjects.length;
            	controlledObjects.Insert(id,1);
                controlledObjects[id]=objData;
            }
        	break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type Kill} {Name name}
    	case 2:
            if(id == -1) break;
            ShowTracesOf(id, false);
            ClearWaypointsOf(id);
            controlledObjects[id].wcoActor.Destroy();
            controlledObjects.Remove(id,1);
        	break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type RelMove} {Name name} {location x,y,z} {rotation x,y,z}
    	case 3:
        	if(id != -1)
        	{
                if(USARRemoteBot(Controller).WC[cmdIdx].isObjLoc)
             	   controlledObjects[id].wcoActor.Move(USARRemoteBot(Controller).WC[cmdIdx].objLoc);
                if(USARRemoteBot(Controller).WC[cmdIdx].isObjRot)
                {
                    rRot = controlledObjects[id].wcoActor.Rotation;
                    rRot += USARRemoteBot(Controller).WC[cmdIdx].objRot;
                    controlledObjects[id].wcoActor.SetRotation(rRot);
                }
        	}
        	else
        	{
                robot = GetController(USARRemoteBot(Controller).WC[cmdIdx].objName);
                if(robot != none)
                {
                    vLoc = robot.Location + USARRemoteBot(Controller).WC[cmdIdx].objLoc;
                    robot.MoveRobot(vLoc);
                }
        	}
        	break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type AbsMove} {Name name} {location x,y,z} {rotation x,y,z}
        case 4:
        	if(id != -1)
        	{
                if(USARRemoteBot(Controller).WC[cmdIdx].isObjLoc)
                {
                    vLoc = controlledObjects[id].wcoActor.Location;
                    vLoc = USARRemoteBot(Controller).WC[cmdIdx].objLoc - vLoc;
                    controlledObjects[id].wcoActor.Move(vLoc);
                }
                if(USARRemoteBot(Controller).WC[cmdIdx].isObjRot)
                    controlledObjects[id].wcoActor.SetRotation(USARRemoteBot(Controller).WC[cmdIdx].objRot);
        	}
            else
        	{
                robot = GetController(USARRemoteBot(Controller).WC[cmdIdx].objName);
                if(robot != none)
                    robot.MoveRobot(USARRemoteBot(Controller).WC[cmdIdx].objLoc);
        	}
            break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type SetWP} {Name name} [{Speed s}|{Time t}] [{Move <true/false>}] [{Loop <true/false>}]
        //         [{Autoalign <true/false>}] [{Show <true/false>}] [{ResetOnClean <true/false>}]
        //         [{WP x,y,z;x,y,z;...}]
        case 5:
            if(id == -1) break;

            if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 2) > 0)
            {
                loopBit = controlledObjects[id].bLoop ^^ USARRemoteBot(Controller).WC[cmdIdx].wpLoop;
                controlledObjects[id].bLoop = USARRemoteBot(Controller).WC[cmdIdx].wpLoop;
            }

            if(USARRemoteBot(Controller).WC[cmdIdx].wpList != "")
            {
                ClearWaypointsOf(id);
                AddWPListTo(id);

                // Always recalculate distance because we have changed waypoints
                controlledObjects[id].fTotalDistance = CalculateWPDistanceOf(id, controlledObjects[id].bLoop);

                // Sets the robot to the first point.
                SetTheObjectTo(id, 0);

                // We process Show command here because what should be done
                // depends on whether waypoints was chenged or not.
                if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 8) > 0)
                {
                    // Show command was issued.
                    showBit = controlledObjects[id].bShow || USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                    if(showBit)
                    {
                        controlledObjects[id].bShow = USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                        ShowTracesOf(id, controlledObjects[id].bShow);
                        if(bDebug) log("# SetWP - Tracing new WPs by cmd...");
                    }
                }
                else
                {
                    // Show command was not issued, so we redraw the new traces or not
                    // depending on the state of the bShow flag.
                    if(controlledObjects[id].bShow)
                    {
                        ShowTracesOf(id, true);
                        if(bDebug) log("# SetWP - Tracing new WPs by state...");
                    }
                }
            }
            else //No new waypoints.
            {
                // Recalculate distance if loop flag has changed.
                // Note: we already have distances for open and closed loop. They are
                // stored in the aSegLengths array. So we must only update fTotalDistance
                // with the correct value.
                if(loopBit)
                {
                    len = controlledObjects[id].aSegLengths.Length;
                    if(len > 1)
                    {
                        if(controlledObjects[id].bLoop)
                            controlledObjects[id].fTotalDistance = controlledObjects[id].aSegLengths[len-1];
                        else
                            controlledObjects[id].fTotalDistance = controlledObjects[id].aSegLengths[len-2];
                    }
                    else
                        controlledObjects[id].fTotalDistance = 0.0;
                }

                // Manages SHOW status when WP have not changed.
                if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 8) > 0)
                {
                    // As the WP have not changed, we only care about a change in show status.
                    showBit = controlledObjects[id].bShow ^^ USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                    if(showBit)
                    {
                        controlledObjects[id].bShow = USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                        ShowTracesOf(id, controlledObjects[id].bShow);
                        if(bDebug) log("# SetWP - Tracing old WPs...");
                    }
                }
            }

            if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 1) > 0)
                controlledObjects[id].bMoving = USARRemoteBot(Controller).WC[cmdIdx].wpMove;

            if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 16) > 0)
                controlledObjects[id].bResetOnClear = USARRemoteBot(Controller).WC[cmdIdx].wpResetOnClean;

            if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 4) > 0)
            {
                alignBit = controlledObjects[id].bAlign ^^ USARRemoteBot(Controller).WC[cmdIdx].wpAlign;
                if(alignBit)
                {
                    controlledObjects[id].bAlign = USARRemoteBot(Controller).WC[cmdIdx].wpAlign;
                    if(controlledObjects[id].bAlign)
                    {
                        //We need at least 2 waypoints to define an alignement
                        if(controlledObjects[id].aWayPoints.Length > 1)
                        {
                            vLoc = GetSegmentVect(id, controlledObjects[id].nCurrentPoint);
                            controlledObjects[id].wcoActor.SetRotation(rotator(vLoc));
                        }
                    }
                    else
                    {
                        // If not aligned resets the starting rotation.
                        rRot = controlledObjects[id].startRot;
                        controlledObjects[id].wcoActor.SetRotation(rRot);
                    }
                }
            }

            // Now processes time & speed.
            // You can use speed to specify travel speed, or time to specify total
            // travel time. If you use both, then speed is assumed as maximum
            // speed. If fTotalDistance / time > speed then speed will be used.

            if(USARRemoteBot(Controller).WC[cmdIdx].wpSpeed > 0)
            {
                controlledObjects[id].fSpeed = USARRemoteBot(Controller).WC[cmdIdx].wpSpeed;

                if(USARRemoteBot(Controller).WC[cmdIdx].wpTime > 0)
                {
                    avSpeed = controlledObjects[id].fTotalDistance / USARRemoteBot(Controller).WC[cmdIdx].wpTime;
                    if(avSpeed < controlledObjects[id].fSpeed)
                        controlledObjects[id].fSpeed = avSpeed;
                }
            }
            else
            {
                if(USARRemoteBot(Controller).WC[cmdIdx].wpTime > 0)
                    controlledObjects[id].fSpeed = controlledObjects[id].fTotalDistance / USARRemoteBot(Controller).WC[cmdIdx].wpTime;
            }

            // Set moving state to false if speed is 0 or there are no waypoints.
            if((controlledObjects[id].fSpeed == 0) || (controlledObjects[id].aWayPoints.Length == 0))
                controlledObjects[id].bMoving = false;

            if(bDebug)
            {
                log("# Moving: "$controlledObjects[id].bMoving);
                log("# Loop: "$controlledObjects[id].bLoop);
                log("# Align: "$controlledObjects[id].bAlign);
                log("# Show: "$controlledObjects[id].bShow);
                log("# Distance: "$controlledObjects[id].fTotalDistance);
                log("# Speed: "$controlledObjects[id].fSpeed);
                log("# ResetOnClear: "$controlledObjects[id].bResetOnClear);
                len = controlledObjects[id].aWayPoints.Length;
                for(i=0; i < len; i++)
                    log("# WP["$i$"] - Len : "$controlledObjects[id].aWayPoints[i].X$","$
                                         controlledObjects[id].aWayPoints[i].Y$","$
                                         controlledObjects[id].aWayPoints[i].Z$" - "$
                                         controlledObjects[id].aSegLengths[i]);
            }
            break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type AddWP} {Name name} {WP x,y,z;x,y,z;...}
        case 6:
            if(id == -1) break;

            if(USARRemoteBot(Controller).WC[cmdIdx].wpList != "")
            {
                i = controlledObjects[id].aWayPoints.Length;

                // Adds the new WP list.
                AddWPListTo(id);

                // Recalculate distance
                controlledObjects[id].fTotalDistance = CalculateWPDistanceOf(id, controlledObjects[id].bLoop);

                // Positions the robot to the first point if there were no waypoints
                // before the current add.
                if(i == 0)
                    SetTheObjectTo(id, 0);

                // Manages SHOW status because WP have changed.
                if((USARRemoteBot(Controller).WC[cmdIdx].wpFlags & 8) > 0)
                {
                    showBit = controlledObjects[id].bShow || USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                    if(showBit)
                    {
                        controlledObjects[id].bShow = USARRemoteBot(Controller).WC[cmdIdx].wpShow;
                        ShowTracesOf(id, controlledObjects[id].bShow);
                        if(bDebug) log("# AddWP - Tracing new WPs by cmd...");
                    }
                }
                else
                {
                    // Draw the new traces, if show is on.
                    if(controlledObjects[id].bShow)
                    {
                        ShowTracesOf(id, true);
                        if(bDebug) log("# AddWP - Tracing new WPs by state...");
                    }
                }

                if(bDebug)
                {
                    log("# Moving: "$controlledObjects[id].bMoving);
                    log("# Loop: "$controlledObjects[id].bLoop);
                    log("# Align: "$controlledObjects[id].bAlign);
                    log("# Show: "$controlledObjects[id].bShow);
                    log("# Distance: "$controlledObjects[id].fTotalDistance);
                    log("# Speed: "$controlledObjects[id].fSpeed);
                    log("# ResetOnClear: "$controlledObjects[id].bResetOnClear);
                    len = controlledObjects[id].aWayPoints.Length;
                    for(i=0; i < len; i++)
                        log("# WP["$i$"] - Len : "$controlledObjects[id].aWayPoints[i].X$","$
                                             controlledObjects[id].aWayPoints[i].Y$","$
                                             controlledObjects[id].aWayPoints[i].Z$" - "$
                                             controlledObjects[id].aSegLengths[i]);
                }
            }
            break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type ClearWP} {Name name}
        case 7:
            if(id == -1) break;
            ShowTracesOf(id, false);
            ClearWaypointsOf(id);
            break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type Rotate} {Name name} {Speed x,y,z}
        case 8:
            if(id == -1) break;

            controlledObjects[id].rRotSpeed = USARRemoteBot(Controller).WC[cmdIdx].rotSpeed;
            // Turn off rotation if rotation speed is zero.
            if(IsRotNull(controlledObjects[id].rRotSpeed))
                controlledObjects[id].bRotating = false;
            else
                controlledObjects[id].bRotating = true;

            break;

        ////////////////////////////////////////////////////////////////////////////
        // CONTROL {Type KillAll}
        case 9:
            // First destroy all the objects controlled by this WorldController (if any).
        	len = controlledObjects.Length;
        	if(len > 0)
        	{
            	for(id=0; id < len; id++)
            	{
                    ShowTracesOf(id, false);
                    ClearWaypointsOf(id);
                    controlledObjects[id].wcoActor.Destroy();
            	}
            	controlledObjects.Remove(0,len);
            }
            // Then cycle through all the other WC objects in the map, if any. You can
            // find these objects when a previous WorldController created them and
            // then quitted without removing them. You can for example create a WC, then
            // use it to populate the map and quit the WC leaving all the objects in the map.
            // When you want to remove these objects you create another WC and issue a KillAll.
            foreach AllActors(class'WCObject',wco)
                wco.Destroy();

            break;
       }//ends switch
    }//ends for loop

    //Empty command queue
    USARRemoteBot(Controller).WC.Remove(0,cmdIdx);
}
*/

simulated function Tick(float Delta)
{
    local int i;
//    local rotator rRot;
	local int len, id;
	
    len = controlledObjects.Length;
    for(id=0; id < len; id++)
    {
		if(controlledObjects[id].wcoActor.dirty==1)
		{
			controlledObjects[id].wcoActor.dirty = 0;
			controlledObjects[id].wcoActor.SetPhysics(controlledObjects[id].objPhysics);
			controlledObjects[id].wcoActor.ForceUpdateComponents();
		}
		else if(controlledObjects[id].wcoActor.dirty>1)
			controlledObjects[id].wcoActor.dirty--;
    }
//	LogInternal("Tick");
	
	/* sbb
    if(Role == ROLE_Authority)
        ProcessControls();
		*/

    // Animate all the objects
    for(i=0; i < controlledObjects.length; i++)
    {
        // Waypoint animation
        if(controlledObjects[i].bMoving)
        {
            // Moves the objec along the path.
            controlledObjects[i].fCurrentDistance += controlledObjects[i].fSpeed*Delta;

            //See if we have reached the end of the path.
            if(controlledObjects[i].fCurrentDistance >= controlledObjects[i].fTotalDistance)
            {
                if(controlledObjects[i].bLoop)
                    controlledObjects[i].fCurrentDistance -= controlledObjects[i].fTotalDistance;
                else
                {
                    controlledObjects[i].fCurrentDistance = 0;
                    controlledObjects[i].bMoving = false;
                }
                controlledObjects[i].nCurrentPoint = 0;
            }

            if(controlledObjects[i].bMoving)
                SetTheObjectTo(i, controlledObjects[i].fCurrentDistance);
        }
        // Rotation animation
        if(controlledObjects[i].bRotating)
        {
// sbb            rRot = controlledObjects[i].wcoActor.Rotation;
// sbb            rRot += controlledObjects[i].rRotSpeed * Delta;
// sbb            controlledObjects[i].wcoActor.SetRotation(rRot);
        }
    }
	super.Tick(Delta);
}

function SendLine(string outstring)
{
 // sbb   USARRemoteBot(Controller).myConnection.SendLine(outstring);
}

defaultproperties
{
	//logData=true         // log killall data for post analysis // Moved to config file
    bDebug=false         // Activates debug logs.
    //cleanOnClose=true   // Tells if the objects must be removed when the controller is destroyed. // Moved to config file
    wpdelim=";"         // Delimiter for waypoints coordinates.
/* Warning: invalid property value
    traceTexture(0)=Texture'USARSim_Objects_Textures.Trace.Red'
    traceTexture(1)=Texture'USARSim_Objects_Textures.Trace.Yellow'
    traceTexture(2)=Texture'USARSim_Objects_Textures.Trace.Green'
    traceTexture(3)=Texture'USARSim_Objects_Textures.Trace.Cyan'
    traceTexture(4)=Texture'USARSim_Objects_Textures.Trace.White'
    traceTexture(5)=Texture'USARSim_Objects_Textures.Trace.Blue'
    traceTexture(6)=Texture'USARSim_Objects_Textures.Trace.Purple'
*/
	DrawScale=1
    bNoDelete=false
    bStatic=false
    //bStasis=false // Deprecated
    bBlockActors=false
	bCollideActors=false
	bAlwaysRelevant=true
}
