/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States. Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

/*
 * Gripper - effector class for simple binary grippers
 */
class Gripper extends Effector abstract config (USAR);

// Gets configuration data from the gripper
function String GetConfData()
{
	local String outStr;
	
	outStr = super.GetConfData();
	return outStr $ " {Opcode Grip} {MaxVal 1} {MinVal 0} {Opcode Close} {Opcode Open}";
}

// Gets data from this gripper
function String GetData()
{
	if (IsOn == 0)
		return "{Status OPEN}";
	else
		return "{Status CLOSED}";
}

// Sets a client parameter of this Item
function String Set(String opcode, String args)
{
	if (Caps(opcode) == "GRIP")
		SetGripper(int(args));
	if (Caps(opcode) == "CLOSE")
		SetGripper(1);
	else if (Caps(opcode) == "OPEN")
		SetGripper(0);
	else
		return "Failed";
	return "OK";
}

// Respond to both EFF and ACT gripper commands
reliable server function SetGripper(int Gripper)
{
	IsOn = Gripper;
	if (Gripper != 0)
		Operate(true);
	else
		Operate(false);
}

defaultproperties
{
	ItemType="Gripper"
}
