package org.nist.usarui.handlers;

import org.nist.usarui.*;

/**
 * Transparently intercepts GETCONF requests for "MisPkg" and loads the mission package names
 * into the UI.
 *
 * @author Stephen Carlson (NIST)
 */
public class MisPkgStatusHandler implements StatusHandler {
	private Iridium state;

	/**
	 * Creates a new instance.
	 *
	 * @param state the application managing this handler
	 */
	public MisPkgStatusHandler(Iridium state) {
		this.state = state;
	}
	public boolean statusReceived(USARPacket packet) {
		String type = packet.getParam("Type");
		// Intercept it and suppress only if useful information gleaned (1st time)
		return !(packet.getType().equals("CONF") && type.equals("MisPkg")) ||
			!state.getUI().updateMisPkg(packet);
	}
	public boolean statusSent(USARPacket packet) {
		// CONF can't be sent.
		return true;
	}
}