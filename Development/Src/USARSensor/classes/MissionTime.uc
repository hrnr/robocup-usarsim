// Mission Time sensor: reports the mission duration in minutes (from the spawn instant)
class MissionTime extends Sensor config (USAR);

var int minutes; // total number of elapsed minutes

simulated function AttachItem()
{
	SetTimer(60, true, 'minElapsed');
	super.AttachItem();
}

function String GetData()
{	
	return "{Name " $ ItemName $ "} {Minutes " $ String(minutes) $ "}";
}

function minElapsed()
{
	minutes++;
}

defaultproperties
{
	ItemType="MissionTime"
}