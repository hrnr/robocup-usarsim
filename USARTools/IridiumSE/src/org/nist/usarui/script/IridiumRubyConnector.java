/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.script;

import org.nist.usarui.*;
import java.io.*;
import java.util.*;

/**
 * A class which links IridiumConnector instances to Ruby-friendly code.
 *
 * @author Stephen Carlson (NIST)
 */
public class IridiumRubyConnector {
	private List<IridiumConnector> connectors;

	/**
	 * Creates an IridiumRubyConnector instance.
	 */
	public IridiumRubyConnector() {
		connectors = new ArrayList<IridiumConnector>(8);
	}
	/**
	 * Closes all opened connections, remove all listeners, and kill all scripts.
	 */
	protected void close() {
		for (IridiumConnector connector : connectors) {
			connector.disconnect();
			synchronized (connector.getIridiumListeners()) {
				for (IridiumListener listener : connector.getIridiumListeners())
					connector.removeIridiumListener(listener);
			}
		}
		connectors.clear();
	}
	/**
	 * Gets a new object that can be used to connect to USARSim.
	 *
	 * @return an IridiumConnector instance
	 */
	public IridiumConnector newIridiumConnector() {
		IridiumConnector newConn = new Iridium();
		connectors.add(newConn);
		return newConn;
	}
}