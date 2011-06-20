/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.handlers;

import org.nist.usarui.Iridium;
import org.nist.usarui.USARPacket;

import java.util.*;

/**
 * Suppresses MISSTA messages and displays an info bar with the positions instead.
 *
 * @author Stephen Carlson (NIST)
 */
public class PositionStatusHandler extends AbstractStatusHandler {
	public PositionStatusHandler(Iridium state) {
		super(state);
	}
	public String getPrefix() {
		return "Pos_";
	}
	public boolean statusReceived(USARPacket packet) {
		String name, deg, key, lastLink; float value;
		boolean keep = true;
		if (packet.getType().equals("MISSTA")) {
			name = packet.getParam("Name");
			lastLink = "0";
			// Positions update
			for (Map.Entry<String, String> entry : packet.getParams().entrySet()) {
				key = entry.getKey();
				if (key.equalsIgnoreCase(""))
					lastLink = entry.getValue();
				else if (key.equalsIgnoreCase("Value")) {
					// Show value on panel, in degrees if needed
					value = Float.parseFloat(entry.getValue());
					if (state.getUI().isInDegrees()) {
						value = (float)Math.toDegrees(value);
						deg = DEG_SIGN;
					} else
						deg = "";
					setInformation(name, lastLink, String.format("%.2f%s", value, deg));
				}
			}
			keep = false;
		}
		return keep;
	}
}