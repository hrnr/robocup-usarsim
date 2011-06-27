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
import org.nist.usarui.ui.MapView;

/**
 * A handler which draws a map window for ground truth data. If multiple ground truth sensors
 * are installed, one map will be shown for each, but they will start on top of each other!
 *
 * @author Stephen Carlson
 */
public class GroundTruthStatusHandler implements StatusHandler {
	private final IridiumUI ui;

	/**
	 * Creates a new instance.
	 *
	 * @param ui the application managing this handler
	 */
	public GroundTruthStatusHandler(IridiumUI ui) {
		this.ui = ui;
	}
	public boolean statusReceived(USARPacket packet) {
		if (packet.getType().equals("SEN")) {
			String sensor = packet.getParam("Type"), name = packet.getParam("Name");
			if (sensor != null && sensor.equals("GroundTruth")) {
				// Plot point on the map view
				if (name == null) name = "Unnamed";
				MapView view = (MapView)ui.getView("org.nist.usarui.ui.MapView",
					"Ground Truth - " + name);
				if (view.isVisible()) {
					// But only if visible
					Vec3 loc = Utils.read3Vector(packet.getParam("Location"));
					Vec3 rot = Utils.read3Vector(packet.getParam("Orientation"));
					if (loc != null && rot != null)
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
