package org.nist.usarui.handlers;

import org.nist.usarui.*;

/**
 * Basic status handler for receiver classes which show "information bars."
 *
 * @author Stephen Carlson (NIST)
 */
public abstract class AbstractStatusHandler implements StatusHandler {
	protected final Iridium state;

	/**
	 * Creates a new instance.
	 *
	 * @param state the application managing this handler
	 */
	protected AbstractStatusHandler(Iridium state) {
		this.state = state;
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
		state.getUI().getInfoPanel(panel, name, group).setValue(name, value);
	}
	public boolean statusSent(USARPacket packet) {
		return true;
	}
}
