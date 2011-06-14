package org.nist.usarui.handlers;

import org.nist.usarui.*;

/**
 * Interface implemented by all status handlers which can manipulate messages received or
 * sent.
 *
 * @author Stephen Carlson (NIST)
 */
public interface StatusHandler {
	/**
	 * Called whenever a message is received.
	 *
	 * @param packet the message received
	 * @return whether the message should be added to the log window
	 */
	public boolean statusReceived(USARPacket packet);
	/**
	 * Called whenever a message is sent.
	 *
	 * @param packet the message sent
	 * @return whether the message should be added to the log window
	 */
	public boolean statusSent(USARPacket packet);
}