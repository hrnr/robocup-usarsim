/* ToolChanger - Effector used as a placeholder to swap in other 
	actuators attached to it*/
	
class ToolChanger extends Effector placeable config(USAR);

var bool hasItem;
var int attachIndex;
var Effector attachedEffector;
//how far an effector can be from the toolchanger before the attachment fails
var config float positionTolerance;
//how far an item can be away from the toolchanger's rotation before the attachment fails
var config float angleTolerance;

//the name of the item to start attached to the toolchanger, if it has one. This will ONLY work properly if the item to be attached 
//is listed before the toolchanger (or its parent) in the .ini file.
var config String defaultItem;

function String Set(String opcode, String args)
{
	local Effector activeEffector;
	local float distance;
	
	local vector rayAxis;
	local vector this_x;
	local vector this_y;
	local vector this_z;
	local vector attach_x;
	local vector attach_y;
	local vector attach_z;
	local float pointDiff;
	local float rollDiff;
	
	local vector HitLocation, HitNormal;
	local Actor traceActor;
	if(Caps(opcode) == "CLOSE" && !hasItem)
	{
		//cast out a ray along local z to see if there's something we can attach to
		rayAxis = vect(0, 0, 0); 
		rayAxis.Z = 2 * positionTolerance;
		rayAxis = class'UnitsConverter'.static.MeterVectorToUU(rayAxis);
		
		traceActor = self.Trace(HitLocation, HitNormal, 
		self.Location + rayAxis >> self.Rotation, 
		self.Location, true);
		activeEffector = None;
		if(traceActor != None && traceActor.isA('PhysicalItem')) // make sure the trace hasn't hit a brush
		{
			if(bDebug)
				DrawDebugLine(self.Location, HitLocation, 0, 255, 0, true);
		}
		else if(bDebug)
		{
			DrawDebugLine(self.Location, self.Location + rayAxis >> self.Rotation, 255, 0, 0, true);
		}
		//since the trace will hit a physical item, go through the actors based on it to find the actual effector item
		//if an effector has no parent, but is based on a physical item, then it will attach
		foreach traceActor.BasedActors(class 'Effector', activeEffector)
		{
			//find distance from toolchanger
			distance = VSize(self.Location - activeEffector.Location);
			distance = class'UnitsConverter'.static.LengthFromUU(distance); //convert to meters
			
			GetAxes(self.Rotation, this_x,this_y,this_z);
			GetAxes(activeEffector.Rotation, attach_x, attach_y, attach_z);
			
			pointDiff = acos(this_x dot attach_x);
			rollDiff = acos(this_y dot attach_y);
			if(bDebug)
			{
				LogInternal("Toolchanger direction difference: "$pointDiff);
				LogInternal("Toolchanger roll difference: "$rollDiff);
				LogInternal("Toolchanger distance: "$distance);
			}
			//attempt to attach item if distance is within tolerance
			if(pointDiff <= angleTolerance && rollDiff <= angleTolerance && 
			distance <= positionTolerance)
			{		
				if(activeEffector.reattachItem(CenterItem))
				{
					//add item to list of robot parts
					attachIndex = Platform.Parts.Length;
					activeEffector.directParent = self;
					Platform.Parts.AddItem(activeEffector);
					
					hasItem = true;
					attachedEffector = activeEffector;
					return "OK";
				}
			}
		}
	} else if(Caps(opcode) == "OPEN" && hasItem)
	{
		//drop the attached item
		if(attachedEffector != None)
		{
			//remove item from list of parts
			attachedEffector.detachItem();
			Platform.Parts.Remove(attachIndex, 1);
			
			hasItem = false;
			return "OK";
		}
	}
	return "FAILED";
}
//hide mounting item (called after setup)
simulated function AttachItem()
{
	local int partIndex;
	local Effector activeEffector;
	
	super.AttachItem();
	CenterItem.SetHidden(!bDebug);
	
	partIndex = Platform.getOffPartIndexByName(defaultItem);
	if(partIndex != -1)
	{
		activeEffector = Effector(Platform.offParts[partIndex]);
		if(activeEffector.reattachItem(CenterItem))
		{	
			//attach the item
			attachIndex = Platform.Parts.Length;
			activeEffector.directParent = self;
			Platform.Parts.AddItem(activeEffector);
			
			hasItem = true;
			attachedEffector = activeEffector;
		}
	}
}
// Gets configuration data from the gripper
function String GetConfData()
{
	local String outStr;
	
	outStr = super.GetConfData();
	return outStr $ "{PositionTolerance "$ positionTolerance $"} {AngleTolerance " $ angleTolerance $"} {Opcode Close} {Opcode Open}";
}
// Gets data from this gripper
function String GetData()
{
	if (!hasItem)
		return "{Status OPEN}";
	else
	{
		return "{Status CLOSED}" $ "{ToolType " $ attachedEffector.ItemType $"} {Tool " $ attachedEffector.ItemName $ "}";
	}
}

defaultproperties
{
	//phantom 'body' item to attach an actuator to
	Begin Object Class=Part name=BodyItem
		Mesh = StaticMesh'Basic.EmptyMesh'
		Collision = false
	End Object
	PartList.Add(BodyItem)
	Body=BodyItem
	
	hasItem = false
	ItemType="ToolChanger"
	
}