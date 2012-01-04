/* ToolChanger - Actuator used as a placeholder to swap in other 
	actuators attached to it*/
	
class ToolChanger extends Actuator placeable config(USAR);

var bool hasItem;
var String attachName;
//how far an effector can be from the toolchanger before the attachment fails
var config float attachmentThreshold;
//how far an item can be away from the toolchanger's rotation before the attachment fails
var config float angleThreshold;

function String Set(String opcode, String args)
{
	local int index;
	local Item activeItem;
	local float distance;
	
	local vector this_x;
	local vector this_y;
	local vector this_z;
	local vector attach_x;
	local vector attach_y;
	local vector attach_z;
	local float pointDiff;
	local float rollDiff;
	if(Caps(opcode) == "ATTACH" && !hasItem)
	{
		//pick up the item specified in 'args'
		index = Platform.GetOffPartIndexByName(args);
		if(index != -1)
		{
			activeItem = Platform.offParts[index];
			
			
			//if attachment is succesful
			if(activeItem != None)
			{
				//find distance from toolchanger
				distance = VSize(self.Location - activeItem.Location);
				distance = class'UnitsConverter'.static.LengthFromUU(distance); //convert to meters
				
				GetAxes(self.Rotation, this_x,this_y,this_z);
				GetAxes(activeItem.Rotation, attach_x, attach_y, attach_z);
				
				pointDiff = acos(this_x dot attach_x);
				rollDiff = acos(this_y dot attach_y);
				if(bDebug)
				{
					LogInternal("Toolchanger direction difference: "$pointDiff);
					LogInternal("Toolchanger roll difference: "$rollDiff);
					LogInternal("Toolchanger distance: "$distance);
				}
				//attempt to attach item if distance is within threshold
				if(pointDiff <= angleThreshold && rollDiff <= angleThreshold && 
				distance <= attachmentThreshold && activeItem.reattachItem(CenterItem))
				{		
					//swap item from 'offParts' to 'Parts'
					Platform.Parts.AddItem(activeItem);
					Platform.offParts.Remove(index, 1);
					
					hasItem = true;
					attachName = args;
					return "OK";
				}
			}
		}
	} else if(Caps(opcode) == "DROP" && hasItem)
	{
		//drop the attached item
		index = Platform.GetPartIndexByName(attachName);
		if(index != -1)
		{
			activeItem = Platform.Parts[index];
			if(activeItem != None)
			{
				//detach item and swap from 'Parts' to 'offParts'
				activeItem.detachItem();
				Platform.offParts.AddItem(activeItem);
				Platform.Parts.Remove(index, 1);
				
				hasItem = false;
				return "OK";
			}
		}
	}
	return "failed";
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