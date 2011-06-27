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
 * Basic status handler for receiver classes which show "information bars."
 *
 * @author Stephen Carlson (NIST)
 */
public abstract class AbstractStatusHandler implements StatusHandler {
	protected final IridiumUI ui;

	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	protected AbstractStatusHandler(IridiumUI ui) {
		this.ui = ui;
	}
	/**
	 * Gets the prefix appended to the panel labels to keep them unique.
	 *
	 * @return the prefix e.g. Sensor, MisPkg
	 */
	protected abstract String getPrefix();
	/**
	 * Sets the value displayed on the Information panel.
	 *
	 * @param group the panel group (object group)
	 * @param name the name of the panel to update
	 * @param value the new value
	 */
	protected void setInformation(String group, String name, String value) {
		String panel = getPrefix() + "_" + group;
		ui.getInfoPanel(panel, name, group).setValue(name, value);
	}
	public boolean statusSent(USARPacket packet) {
		return true;
	}
}
