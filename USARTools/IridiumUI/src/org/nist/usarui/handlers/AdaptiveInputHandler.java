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
 * Updates the UI in response to inputs. Note that the ACT e/d and the
 *
 * @author Stephen Carlson
 */
public class AdaptiveInputHandler implements StatusHandler {
	private final IridiumUI ui;

	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public AdaptiveInputHandler(IridiumUI ui) {
		this.ui = ui;
	}
	public boolean statusReceived(USARPacket packet) {
		// Not a handler for output
		return true;
	}
	public boolean statusSent(USARPacket packet) {
		String type = packet.getParam("ClassName");
		if (packet.getType().equals("INIT") && type != null)
			ui.updateInitComplete(type.equalsIgnoreCase("USARBotAPI.WorldController"));
		return true;
	}
}
