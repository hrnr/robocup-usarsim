/* ToolChanger - Effector used as a placeholder to swap in other 
	actuators attached to it*/
	
class ToolChanger extends Effector placeable config(USAR);

var bool hasItem;
var int attachIndex;
var Item attachedItem;
//how far an effector can be from the toolchanger before the attachment fails
var config float positionTolerance;
//how far an item can be away from the toolchanger's rotation before the attachment fails
var config float angleTolerance;

function String Set(String opcode, String args)
{
	local Effector activeEffector;
	local float distance;
	
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
		//cast out a ray to see if there's something we can attach to
		traceActor = self.Trace(HitLocation, HitNormal, 
		self.Location + 2 * class'UnitsConverter'.static.LengthToUU(positionTolerance) * vector(self.Rotation), 
		self.Location, true);
		activeEffector = None;
		if(traceActor != None && traceActor.isA('Effector')) // make sure the trace hasn't hit a brush
		{
			if(bDebug)
				DrawDebugLine(self.Location, HitLocation, 0, 255, 0, true);
			activeEffector = Effector(traceActor);
		}
		else if(bDebug)
		{
			DrawDebugLine(self.Location, self.Location + 2 * class'UnitsConverter'.static.LengthToUU(positionTolerance) * 
			vector(self.Rotation), 255, 0, 0, true);
		}
		if(activeEffector != None) 
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
					Platform.Parts.AddItem(activeEffector);
					
					hasItem = true;
					attachedItem = activeEffector;
					return "OK";
				}
			}
		}
	} else if(Caps(opcode) == "OPEN" && hasItem)
	{
		//drop the attached item
		if(attachedItem != None)
		{
			//remove item from list of parts
			attachedItem.detachItem();
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
	super.AttachItem();
	CenterItem.SetHidden(!bDebug);
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