package org.nist.usarui.handlers;

import org.nist.usarui.*;

import java.util.*;

/**
 * Suppresses STA messages and displays an info bar with the contents instead.
 *
 * @author Stephen Carlson (NIST)
 */
public class RobotStatusHandler extends AbstractStatusHandler {
	public RobotStatusHandler(Iridium state) {
		super(state);
	}
	public String getPrefix() {
		return "Sta_";
	}
	public boolean statusReceived(USARPacket packet) {
		String type, batt, key;
		if (packet.getType().equals("STA")) {
			// Status messages update battery and maybe joints
			type = packet.getParam("Type");
			batt = packet.getParam("Battery");
			if (batt != null)
				try {
					state.getUI().updateBattery(Integer.parseInt(batt));
				} catch (NumberFormatException ignore) { }
			// Joint selection list update
			if (type.equals("LeggedVehicle")) {
				state.getUI().updateJoints(packet);
				// Joint values update
				for (Map.Entry<String, String> entry : packet.getParams().entrySet()) {
					key = entry.getKey();
					if (!key.equalsIgnoreCase("Battery") && !key.equalsIgnoreCase("Type"))
						// Show value on panel
						setInformation("Joints", key, entry.getValue());
				}
			}
			return false;
		}
		return true;
	}
}