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

/**
 * Interface implemented by all status handlers which can manipulate messages received or
 * sent.
 *
 * @author Stephen Carlson (NIST)
 */
public interface StatusHandler {
	/**
	 * The degree sign. Useful for angles in degrees.
	 */
	public static final String DEG_SIGN = "\u00b0";

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