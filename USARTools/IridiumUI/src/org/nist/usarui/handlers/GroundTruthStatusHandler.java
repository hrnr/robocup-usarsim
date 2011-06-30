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
import org.nist.usarui.ui.*;
import java.util.*;

/**
 * A handler which draws a map window for ground truth data. Do not install more than one
 * ground truth sensor on a robot!
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
		String sensor = packet.getParam("Type");
		if (packet.getType().equals("SEN") && sensor != null && (sensor.equals("GroundTruth") ||
				sensor.equals("RangeScanner"))) {
			// Plot point on the map view
			MapView view = (MapView)ui.getView("org.nist.usarui.ui.MapView",
				"Ground Truth");
			if (sensor.equals("GroundTruth")) {
				// But only if visible
				Vec3 loc = Utils.read3Vector(packet.getParam("Location"));
				Vec3 rot = Utils.read3Vector(packet.getParam("Orientation"));
				if (loc != null && rot != null)
					view.setPose(loc.getX(), loc.getY(), rot.getZ());
			} else {
				// Plot range scan
				StringTokenizer str = new StringTokenizer(packet.getParam("Range"), ",");
				float res = Float.parseFloat(packet.getParam("Resolution")),
					fov = Float.parseFloat(packet.getParam("FOV"));
				float[] data = new float[Math.round(fov / res) + 1]; int i = 0;
				// Find (unique) sensor name
				String name = packet.getParam("Name");
				if (name == null) name = sensor;
				try {
					while (str.hasMoreTokens())
						// Append to array
						data[i++] = Float.parseFloat(str.nextToken().trim());
					// Show on screen
					view.addRangeData(data, res, fov, name);
				} catch (NumberFormatException ignore) { }
			}
		}
		// Other classes can filter the message if they please
		return true;
	}
	public boolean statusSent(USARPacket packet) {
		return true;
	}
}
