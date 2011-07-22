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
import org.nist.usarui.ui.*;

/**
 * Suppresses EFF messages and displays an info bar with the contents instead.
 *
 * @author Stephen Carlson (NIST)
 */
public class EffectorStatusHandler extends AbstractStatusHandler {
	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public EffectorStatusHandler(IridiumUI ui) {
		super(ui);
	}
	public String getPrefix() {
		return "Eff_";
	}
	public boolean statusReceived(USARPacket packet) {
		String name, value;
		boolean keep = true;
		if (packet.getType().equals("EFF")) {
			name = packet.getParam("Name");
			if (name == null || name.length() < 1)
				name = packet.getParam("Type");
			// Any key (Open, Closed, On, Off) could be a status!
			value = packet.getParam("Other");
			if (value != null && value.length() > 0)
				setInformation(name, "Status", value);
			keep = false;
		}
		return keep;
	}
}