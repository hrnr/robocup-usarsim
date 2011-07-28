/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

/**
 * Specifies a class which can listen for Iridium events.
 *
 * @author Stephen Carlson (NIST)
 */
public interface IridiumListener {
	/**
	 * Processes an Iridium system event.
	 *
	 * @param eventName the event that occurred
	 */
	public void processEvent(String eventName);
	/**
	 * Processes the send or receive of a server message.
	 *
	 * @param packet the parsed server message sent or received
	 */
	public void processPacket(USARPacket packet);
}