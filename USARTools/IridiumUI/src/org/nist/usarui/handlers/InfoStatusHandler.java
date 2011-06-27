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
 * Handles the NFO messages sent at level startup and when poses are requested.
 *
 * @author Stephen Carlson (NIST)
 */
public class InfoStatusHandler implements StatusHandler {
	private final IridiumUI ui;

	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public InfoStatusHandler(IridiumUI ui) {
		this.ui = ui;
	}
	public boolean statusReceived(USARPacket packet) {
		boolean keep = true;
		// If it's a startup message, update the UI
		if (packet.getType().equals("NFO")) {
			String lvl = packet.getParam("Level"), sp = packet.getParam("StartPoses");
			if (lvl != null)
				ui.updateLevel(lvl);
			if (sp != null)
				ui.updateStartPoses(packet);
			// Ignore it
			keep = (lvl == null && sp == null);
		}
		return keep;
	}
	public boolean statusSent(USARPacket packet) {
		// Nothing to do here. NFO can't be sent.
		return true;
	}
}