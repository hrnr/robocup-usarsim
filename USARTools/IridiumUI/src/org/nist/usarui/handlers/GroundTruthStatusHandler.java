package org.nist.usarui.handlers;

import org.nist.usarui.*;

/**
 * A handler which draws a map window for ground truth data. If multiple ground truth sensors
 * are installed, one map will be shown for each, but they will start on top of each other!
 *
 * @author Stephen Carlson
 */
public class GroundTruthStatusHandler implements StatusHandler {
	private final Iridium state;

	/**
	 * Creates a new instance.
	 *
	 * @param state the application managing this handler
	 */
	public GroundTruthStatusHandler(Iridium state) {
		this.state = state;
	}
	public boolean statusReceived(USARPacket packet) {
		if (packet.getType().equals("SEN")) {
			String sensor = packet.getParam("Type"), name = packet.getParam("Name");
			if (sensor != null && sensor.equals("GroundTruth")) {
				// Plot point on the map view
				MapView view = state.getUI().getView("Ground Truth - " + name);
				if (view.isVisible()) {
					// But only if visible
					Vec3 loc = Utils.read3Vector(packet.getParam("Location"));
					Vec3 rot = Utils.read3Vector(packet.getParam("Orientation"));
					view.setPose(loc.getX(), loc.getY(), rot.getZ());
				}
			}
		}
		// Other classes can filter the message if they please
		return true;
	}
	public boolean statusSent(USARPacket packet) {
		return true;
	}
}
