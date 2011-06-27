/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

import java.io.IOException;
import java.util.*;

/**
 * Describes a class that can handle connections to and from the USAR server.
 *
 * @author Stephen Carlson (NIST)
 */
public interface IridiumConnector {
	/**
	 * Registers an IridiumListener for events.
	 *
	 * @param listener the listener to register
	 */
	public void addIridiumListener(IridiumListener listener);
	/**
	 * Connects to the specified server.
	 * 
	 * @param host Either "server" or "server:port"
	 * @throws IOException if an I/O error occurs when connecting
	 */
	public void connect(String host) throws IOException;
	/**
	 * Disconnects from the server.
	 */
	public void disconnect();
	/**
	 * Gets the Iridium configuration data.
	 *
	 * @return the Iridium options
	 */
	public Properties getConfig();
	/**
	 * Gets whether the program is connected to USARSim.
	 *
	 * @return whether the program is currently connected
	 */
	public boolean isConnected();
	/**
	 * Unregisters an IridiumListener from events.
	 *
	 * @param listener the listener to unregister
	 */
	public void removeIridiumListener(IridiumListener listener);
	/**
	 * Sends a message to the server.
	 *
	 * @param message the message to send
	 * @throws IOException if an I/O error occurs
	 */
	public void sendMessage(String message) throws IOException;
}