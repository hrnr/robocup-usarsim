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
import org.nist.usarui.ui.IridiumUI;
import java.util.*;

/**
 * Suppresses STA messages and displays an info bar with the contents instead.
 *
 * @author Stephen Carlson (NIST)
 */
public class RobotStatusHandler extends AbstractStatusHandler {
	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public RobotStatusHandler(IridiumUI ui) {
		super(ui);
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
					ui.updateBattery(Integer.parseInt(batt));
				} catch (NumberFormatException ignore) { }
			// Joint selection list update
			if (type != null && type.equals("LeggedVehicle")) {
				final USARPacket newPacket = new USARPacket(packet);
				final Map<String, String> params = newPacket.getParams();
				params.remove("Time");
				params.remove("Type");
				params.remove("Battery");
				params.remove("LightIntensity");
				params.remove("LightToggle");
				ui.updateJoints(newPacket);
				// Joint values update
				for (Map.Entry<String, String> entry : params.entrySet()) {
					key = entry.getKey();
					try {
						// Show value on panel, in degrees if needed
						value = Float.parseFloat(entry.getValue());
						if (ui.isInDegrees()) {
							value = (float)Math.toDegrees(value);
							deg = DEG_SIGN;
						} else
							deg = "";
						setInformation("Joints", key, String.format("%.2f%s", value, deg));
					} catch (RuntimeException ignore) { }
				}
			}
			// Keep world controller status messages
			keep = type == null && packet.getParam("Name") != null;
		}
		return keep;
	}
}