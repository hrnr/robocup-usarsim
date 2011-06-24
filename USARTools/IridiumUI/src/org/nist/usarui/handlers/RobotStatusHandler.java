/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

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
		String type, batt, key, deg; float value;
		boolean keep = true;
		if (packet.getType().equals("STA")) {
			// Status messages update battery and maybe joints
			type = packet.getParam("Type");
			batt = packet.getParam("Battery");
			if (batt != null)
				try {
					state.getUI().updateBattery(Integer.parseInt(batt));
				} catch (NumberFormatException ignore) { }
			// Joint selection list update
			if (type != null && type.equals("LeggedVehicle")) {
				state.getUI().updateJoints(packet);
				// Joint values update
				for (Map.Entry<String, String> entry : packet.getParams().entrySet()) {
					key = entry.getKey();
					if (!key.equalsIgnoreCase("Battery") && !key.equalsIgnoreCase("Type")) {
						// Show value on panel, in degrees if needed
						value = Float.parseFloat(entry.getValue());
						if (state.getUI().isInDegrees()) {
							value = (float)Math.toDegrees(value);
							deg = DEG_SIGN;
						} else
							deg = "";
						setInformation("Joints", key, String.format("%.2f%s", value, deg));
					}
				}
			}
			// Keep world controller status messages
			keep = type == null && packet.getParam("Name") != null;
		}
		return keep;
	}
}