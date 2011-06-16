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
		boolean keep = true, deg = state.getUI().isInDegrees();
		if (packet.getType().equals("SEN")) {
			// Update time
			String tm = packet.getParam("Time"), value, test, type, name;
			if (tm != null)
				try {
					state.getUI().updateTime(Float.parseFloat(tm));
				} catch (NumberFormatException ignore) { }
			// Update value, using typical names (this is for the simple sensors)
			type = packet.getParam("Type");
			if (type == null) type = "Sensor";
			name = packet.getParam("Name");
			if (name == null) name = type;
			// Default bulk data
			value = packet.getParam("");
			if (value != null) value = Utils.asHTML(floatString(value, false));
			// Accelerometer
			test = packet.getParam("Acceleration");
			if (test != null) value = Utils.asHTML(floatString(test, false));
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
			if (test != null) value = Utils.asHTML(floatString(test, false));
			// Odometer
			test = packet.getParam("Pose");
			if (test != null) value = odoString(test, deg);
			// Tachometer
			test = packet.getParam("Pos");
			if (test != null)
				value = Utils.asHTML("<b>Rotation</b> (" + floatString(test, deg) +
					"), <b>Velocity</b> (" + floatString(packet.getParam("Vel"), deg) + ")");
			// GroundTruth, INS
			test = packet.getParam("Location");
			if (test != null)
				value = Utils.asHTML("<b>At</b> (" + color3Vector(test, false) +
					"), <b>facing</b> (" + color3Vector(packet.getParam("Orientation"), deg) +
					")");
			// Send whatever we got
			if (value != null)
				setInformation(type, name, value);
			keep = false;
		}
		return keep;
	}
	/**
	 * Returns the 3-vector with colors.
	 *
	 * @param vec the string value
	 * @param convert whether radian to degree conversion will be applied
	 * @return the value reformatted for display
	 */
	private static String color3Vector(String vec, boolean convert) {
		Vec3 vector = Utils.read3Vector(vec); String deg = "";
		vector = vector.radToDeg(convert);
		if (convert)
			deg = DEG_SIGN;
		return String.format("<font color=\"#990000\">%.2f</font>%s <font color=\"#009900\">" +
			"%.2f</font>%s <font color=\"#000099\">%.2f</font>%s", vector.getX(), deg,
			vector.getY(), deg, vector.getZ(), deg);
	}
	/**
	 * Converts the floating point value to a sensible screen value.
	 *
	 * @param value the string value
	 * @param convert whether radian to degree conversion will be applied
	 * @return the value reformatted for display
	 */
	private static String floatString(String value, boolean convert) {
		String out = null, token, deg; int index = 0; float f;
		if (value != null)
			try {
				StringTokenizer str = new StringTokenizer(value, ",");
				StringBuilder output = new StringBuilder(3 * value.length() / 2);
				// Convert comma delimited to screen (if there is only one value, this works too)
				while (str.hasMoreTokens() && index < MAX_ENTRIES) {
					token = str.nextToken().trim();
					f = Float.parseFloat(token);
					// Apply conversion to degrees if necessary
					if (convert) {
						f = (float)Math.toDegrees(f);
						deg = DEG_SIGN;
					} else
						deg = "";
					output.append(String.format("%.2f%s", f, deg));
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
				value += String.format("%d%s %d' <i>%s</i>, %d%s %d' <i>%s</i>",
					latDeg, DEG_SIGN, latMin, lat, longDeg, DEG_SIGN, longMin, lon);
			} catch (RuntimeException ignore) { }
		return Utils.asHTML(value);
	}
	/**
	 * Converts the odometer value to a sensible screen value.
	 *
	 * @param vec the string value
	 * @param convert whether radian to degree conversion will be applied
	 * @return the value reformatted for display
	 */
	private static String odoString(String vec, boolean convert) {
		Vec3 vector = Utils.read3Vector(vec); String deg = "";
		if (convert) {
			// Convert only Z (heading)
			vector = new Vec3(vector.getX(), vector.getY(),
				(float)Math.toDegrees(vector.getZ()));
			deg = DEG_SIGN;
		}
		return Utils.asHTML(String.format("<b>X</b> %.2f, <b>Y</b> %.2f, <b>T</b> %.2f%s",
			vector.getX(),vector.getY(), vector.getZ(), deg));
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