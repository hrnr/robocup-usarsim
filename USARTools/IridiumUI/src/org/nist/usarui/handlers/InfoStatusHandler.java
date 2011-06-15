package org.nist.usarui.handlers;

import org.nist.usarui.*;

/**
 * Handles the NFO messages sent at level startup and when poses are requested.
 *
 * @author Stephen Carlson (NIST)
 */
public class InfoStatusHandler implements StatusHandler {
	private final Iridium state;

	/**
	 * Creates a new instance.
	 *
	 * @param state the application managing this handler
	 */
	public InfoStatusHandler(Iridium state) {
		this.state = state;
	}
	public boolean statusReceived(USARPacket packet) {
		boolean keep = true;
		// If it's a startup message, update the UI
		if (packet.getType().equals("NFO")) {
			String lvl = packet.getParam("Level"), sp = packet.getParam("StartPoses");
			if (lvl != null)
				state.getUI().updateLevel(lvl);
			if (sp != null)
				state.getUI().updateStartPoses(packet);
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