/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.handlers;

import org.nist.usarui.ui.IridiumUI;
import org.nist.usarui.USARPacket;

import java.util.*;

/**
 * Suppresses MISSTA messages and displays an info bar with the positions instead.
 *
 * @author Stephen Carlson (NIST)
 */
public class PositionStatusHandler extends AbstractStatusHandler {
	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public PositionStatusHandler(IridiumUI ui) {
		super(ui);
	}
	public String getPrefix() {
		return "Pos_";
	}
	public boolean statusReceived(USARPacket packet) {
		String name, deg, key; int lastLink; float value;
		boolean keep = true;
		if (packet.getType().equals("MISSTA")) {
			name = packet.getParam("Name");
			lastLink = 0;
			// Positions update (use MISSTA and -1 for compatibility with UT3)
			for (Map.Entry<String, String> entry : packet.getParams().entrySet()) {
				key = entry.getKey().toLowerCase();
				if (key.startsWith("link"))
					try {
						lastLink = Integer.parseInt(entry.getValue()) - 1;
					} catch (NumberFormatException ignore) { }
				else if (key.startsWith("value")) {
					// Show value on panel, in degrees if needed
					value = Float.parseFloat(entry.getValue());
					if (ui.isInDegrees()) {
						value = (float)Math.toDegrees(value);
						deg = DEG_SIGN;
					} else
						deg = "";
					setInformation(name, Integer.toString(lastLink),
						String.format("%.2f%s", value, deg));
				}
			}
			keep = false;
		} else if (packet.getType().equals("ASTA"))
			keep = false;
		return keep;
	}
}