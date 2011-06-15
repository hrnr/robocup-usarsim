package org.nist.usarui.handlers;

import org.nist.usarui.*;

import java.util.*;

/**
 * Suppresses sensor messages and displays an info bar with the contents instead.
 * Handles most sensors!
 *
 * @author Stephen Carlson (NIST)
 */
public class SensorStatusHandler extends AbstractStatusHandler {
	/**
	 * The maximum number of entries shown in long data sets before truncation.
	 */
	public static final int MAX_ENTRIES = 10;

	public SensorStatusHandler(Iridium state) {
		super(state);
	}
	public String getPrefix() {
		return "Sen_";
	}
	public boolean statusReceived(USARPacket packet) {
		boolean keep = false;
		if (packet.getType().equals("SEN")) {
			// Update time
			String tm = packet.getParam("Time"), value, test, type;
			if (tm != null)
				try {
					state.getUI().updateTime(Float.parseFloat(tm));
				} catch (NumberFormatException ignore) { }
			// Update value, using typical names (this is for the simple sensors)
			type = packet.getParam("Type");
			if (type == null) type = "Sensor";
			value = packet.getParam("");
			if (value != null) value = Utils.asHTML(floatString(value));
			// Accelerometer
			test = packet.getParam("Acceleration");
			if (test != null) value = Utils.asHTML(floatString(test));
			// Bumper
			test = packet.getParam("Touch");
			if (test != null) value = touchString(test);
			// Encoder
			test = packet.getParam("Tick");
			if (test != null) value = test;
			// GPS
			test = packet.getParam("Fix");
			if (test != null) value = getGPSData(packet);
			// IR2Sensor, IRSensor, RangeSensor, RangeScanner, Sonar, and subclasses
			test = packet.getParam("Range");
			if (test != null) value = Utils.asHTML(floatString(test));
			// Odometer
			test = packet.getParam("Pose");
			if (test != null) value = odoString(test);
			// Tachometer
			test = packet.getParam("Pos");
			if (test != null)
				value = Utils.asHTML("<b>Position</b> " + floatString(test) +
					", <b>Velocity</b> " + floatString(packet.getParam("Vel")));
			// GroundTruth, INS
			test = packet.getParam("Location");
			if (test != null)
				value = Utils.asHTML("<b>At</b> (" + color3Vector(test) + "), <b>Facing</b> " +
					"(" + color3Vector(packet.getParam("Orientation")) + ")");
			// Send whatever we got
			if (value != null)
				setInformation(type, packet.getParam("Name"), value);
			keep = (value == null && !type.equals("Camera"));
		}
		return keep;
	}
	/**
	 * Returns the 3-vector with colors.
	 *
	 * @param vec the string value
	 * @return the value reformatted for display
	 */
	private static String color3Vector(String vec) {
		Vec3 vector = Utils.read3Vector(vec);
		return String.format("<font color=\"#990000\">%.2f</font> <font color=\"#009900\">" +
			"%.2f</font> <font color=\"#000099\">%.2f</font>", vector.getX(), vector.getY(),
			vector.getZ());
	}
	/**
	 * Converts the floating point value to a sensible screen value.
	 *
	 * @param value the string value
	 * @return the value reformatted for display
	 */
	private static String floatString(String value) {
		String out = null, token; int index = 0;
		if (value != null)
			try {
				StringTokenizer str = new StringTokenizer(value, ",");
				StringBuilder output = new StringBuilder(3 * value.length() / 2);
				// Convert comma delimited to screen (if there is only one value, this works too)
				while (str.hasMoreTokens() && index < MAX_ENTRIES) {
					token = str.nextToken().trim();
					output.append(String.format("%.2f", Float.parseFloat(token)));
					if (str.hasMoreTokens())
						output.append(", ");
					index++;
				}
				if (str.hasMoreTokens())
					output.append("...");
				out = output.toString();
			} catch (NumberFormatException e) {
				// Trim down long data sets to size
				if (value.length() >= 40)
					out = value.substring(0, 40);
				else
					out = value;
			}
		return out;
	}
	/**
	 * Gets the GPS data representation from the packet.
	 *
	 * @param packet the packet to parse
	 * @return the GPS data reformatted for display
	 */
	private static String getGPSData(USARPacket packet) {
		int latDeg, latMin, longDeg, longMin;
		String value, lat, lon; StringTokenizer str;
		if (packet.getParam("Fix").equals("1"))
			value = "<font color=\"#009900\">Fix";
		else
			value = "<font color=\"#990000\">Loss";
		value += "</font>(<b>" + packet.getParam("Satellites") + "</b>) ";
		// GPS data: Latitude 39,20 Longitude -78,30
		if (packet.getParam("Latitude") != null)
			try {
				// Parse latitude
				str = new StringTokenizer(packet.getParam("Latitude"), ",");
				latDeg = Integer.parseInt(str.nextToken().trim());
				latMin = Integer.parseInt(str.nextToken().trim());
				lat = str.nextToken().trim().toUpperCase();
				// Parse longitude
				str = new StringTokenizer(packet.getParam("Longitude"), ",");
				longDeg = Integer.parseInt(str.nextToken().trim());
				longMin = Integer.parseInt(str.nextToken().trim());
				lon = str.nextToken().trim().toUpperCase();
				// Output
				value += String.format("%d\u00b0 %d' <i>%s</i>, %d\u00b0 %d' <i>%s</i>",
					latDeg, latMin, lat, longDeg, longMin, lon);
			} catch (RuntimeException ignore) { }
		return Utils.asHTML(value);
	}
	/**
	 * Converts the odometer value to a sensible screen value.
	 *
	 * @param vec the string value
	 * @return the value reformatted for display
	 */
	private static String odoString(String vec) {
		Vec3 vector = Utils.read3Vector(vec);
		return Utils.asHTML(String.format("<b>X</b> %.2f, <b>Y</b> %.2f, <b>T</b> %.2f",
			vector.getX(),vector.getY(), vector.getZ()));
	}
	/**
	 * Converts the touch sensor value to a sensible screen value.
	 *
	 * @param touch the string value
	 * @return the value reformatted for display
	 */
	private static String touchString(String touch) {
		String out;
		touch = touch.trim().toLowerCase();
		if (touch.equals("1") || touch.equals("true"))
			out = "<font color=\"990000\">Touch</font>";
		else
			out = "<font color=\"009900\">No Touch</font>";
		return Utils.asHTML(out);
	}
}