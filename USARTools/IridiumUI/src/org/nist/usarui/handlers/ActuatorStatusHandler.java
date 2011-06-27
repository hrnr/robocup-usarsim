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

/**
 * Transparently intercepts GETCONF requests for "MisPkg" or "Actuator" and loads the actuator
 * names into the UI.
 *
 * @author Stephen Carlson (NIST)
 */
public class ActuatorStatusHandler implements StatusHandler {
	private final IridiumUI ui;

	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public ActuatorStatusHandler(IridiumUI ui) {
		this.ui = ui;
	}
	public boolean statusReceived(USARPacket packet) {
		String type = packet.getParam("Type");
		if (type == null) type = "";
		// Intercept it and suppress only if useful information gleaned (1st time)
		return !(packet.getType().equals("CONF") && (type.equals("MisPkg")) ||
			type.equals("Actuator")) || !ui.updateActuators(packet);
	}
	public boolean statusSent(USARPacket packet) {
		// CONF can't be sent.
		return true;
	}
}