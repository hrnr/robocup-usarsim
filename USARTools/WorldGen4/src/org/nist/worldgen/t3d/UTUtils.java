package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.PrintWriter;
import java.util.*;
import java.util.regex.*;

/**
 * Specialized utility class to handle complex parsing in T3D files.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class UTUtils implements Constants {
	private static final String INDENT_T3D = "   ";
	private static final Pattern ARRAY_ELEMENT = Pattern.compile("(.+)\\(([0-9]+)\\)");
	private static final Pattern PARSE_COLOR = Pattern.compile("[(]?B=([0-9]+),\\s*G=" +
		"([0-9]+),\\s*R=([0-9]+),\\s*A=([0-9]+)[)]?", Pattern.CASE_INSENSITIVE);
	private static final Pattern PARSE_LOCATION = Pattern.compile("[(]?X=([0-9.E+-]+),\\s*" +
		"Y=([0-9.E+-]+),\\s*Z=([0-9.E+-]+)[)]?", Pattern.CASE_INSENSITIVE);
	private static final Pattern PARSE_ROTATION = Pattern.compile("[(]?Pitch=([0-9.E+-]+)," +
		"\\s*Yaw=([0-9.E+-]+),\\s*Roll=([0-9.E+-]+)[)]?", Pattern.CASE_INSENSITIVE);

	/**
	 * Adds text to the output stream with the proper indentation.
	 *
	 * @param out the output stream to write (should NOT have autoflush on!)
	 * @param ind how many levels to indent
	 * @param args the string(s) to write
	 */
	public static void addIndent(final PrintWriter out, final int ind, final Object... args) {
		for (int i = 0; i < ind; i++)
			out.print(INDENT_T3D);
		for (Object arg : args)
			out.print(arg);
		out.println();
	}
	/**
	 * Adds Unreal type qualifier quotes to the specified reference.
	 *
	 * @param refType the reference type (StaticMesh, Brush, Model...)
	 * @param ref the reference to resolve
	 * @return the reference in Unreal form
	 */
	public static String asReference(final String refType, final String ref) {
		final String out;
		if (ref == null)
			out = nullAsNone(null);
		else
			out = refType + '\'' + ref + '\'';
		return out;
	}
	/**
	 * Extracts the array name and index from UT array references.
	 *
	 * @param ref the reference to decode
	 * @return a matcher object containing array key and value information
	 */
	public static Matcher extractArrayValues(final String ref) {
		return ARRAY_ELEMENT.matcher(ref);
	}
	/**
	 * Checks to see if the text matches the given glob pattern. No ? is allowed here!
	 *
	 * @param text the text to match
	 * @param glob the glob to match against
	 * @return whether the text matches the glob
	 */
	public static boolean globMatch(final String text, String glob) {
		String rest = null; boolean matches = false;
		final int pos = glob.indexOf('*');
		if (pos >= 0) {
			rest = glob.substring(pos + 1);
			glob = glob.substring(0, pos);
		}
		if (glob.length() <= text.length()) {
			// recurse for the part after the first *, if any
			if (rest == null)
				matches = glob.equals(text);
			else {
				for (int i = glob.length(); i <= text.length(); i++)
					if (globMatch(text.substring(i), rest)) {
						matches = true;
						break;
					}
			}
		}
		return matches;
	}
	/**
	 * Convert a generic UT object to a Java native type. Avoid use when the type could be
	 * known, as this method can be slow.
	 *
	 * @param in the object text
	 * @return a native Java representation for the type if available
	 */
	public static Object nativeType(final String in) {
		Object out;
		final int inLen, inIndex;
		if (in != null) {
			inLen = in.length();
			inIndex = in.indexOf('\'');
		} else
			inLen = inIndex = 0;
		if (in == null || inLen == 0 || in.equalsIgnoreCase("none"))
			out = null;
		else if (in.equalsIgnoreCase("true"))
			out = Boolean.TRUE;
		else if (in.equalsIgnoreCase("false"))
			out = Boolean.FALSE;
		else if (in.charAt(inLen - 1) == '\'' && inIndex > 0 && inIndex < inLen - 1)
			out = parseReference(in);
		else if (inLen > 1 && in.charAt(inLen - 1) == '"' && in.charAt(0) == '"')
			out = removeQuotes(in);
		else {
			try {
				out = Integer.parseInt(in);
			} catch (NumberFormatException e) {
				try {
					out = Double.parseDouble(in);
				} catch (NumberFormatException ex) {
					out = new UTConstant(in);
				}
			}
		}
		return out;
	}
	/**
	 * Returns the input string, or the Unreal "None" reference if it is null.
	 *
	 * @param in the string to parse
	 * @return a value more accurately representing the string
	 */
	public static String nullAsNone(final Object in) {
		final String out;
		if (in == null)
			out = "None";
		else
			out = in.toString();
		return out;
	}
	/**
	 * Returns the input string, or null if it is the Unreal "None" reference.
	 *
	 * @param in the string to parse
	 * @return a value more accurately representing the string
	 */
	public static String noneAsNull(final String in) {
		final String out;
		if (in == null || in.equalsIgnoreCase("none"))
			out = null;
		else
			out = in;
		return out;
	}
	/**
	 * Parses a color value from the specified string.
	 *
	 * @param in the stirng to parse
	 * @return a Color representing the location, or [R=0,G=0,B=0,A=0] if not parseable
	 */
	public static UTColor parseColor(final String in) {
		final Matcher m = PARSE_COLOR.matcher(in);
		UTColor ret;
		if (m.matches()) {
			try {
				final int b = Integer.parseInt(m.group(1));
				final int g = Integer.parseInt(m.group(2));
				final int r = Integer.parseInt(m.group(3));
				final int a = Integer.parseInt(m.group(4));
				ret = new UTColor(r, g, b, a);
			} catch (NumberFormatException e) {
				ret = UTColor.NO_COLOR;
			}
		} else
			ret = UTColor.NO_COLOR;
		return ret;
	}
	/**
	 * Parses a location value from the specified string.
	 *
	 * @param in the string to parse
	 * @return a Point3D representing the location, or the origin if not parseable
	 */
	public static Point3D parseLocation(final String in) {
		final Matcher m = PARSE_LOCATION.matcher(in);
		Point3D ret;
		if (m.matches())
			try {
				final double x = Double.parseDouble(m.group(1));
				final double y = Double.parseDouble(m.group(2));
				final double z = Double.parseDouble(m.group(3));
				ret = new Point3D(x, y, z);
			} catch (NumberFormatException e) {
				ret = Point3D.ORIGIN;
			}
		else
			ret = Point3D.ORIGIN;
		return ret;
	}
	/**
	 * Parse a Point3D from the form shown in Polygon objects.
	 *
	 * @param in the vector in Polygon form
	 * @return the vector as a Point3D object, or the origin if not parseable
	 */
	public static Point3D parsePolygon(final String in) {
		final StringTokenizer str = new StringTokenizer(in, ",");
		Point3D ret;
		if (str.countTokens() == 3)
			try {
				final double x = Double.parseDouble(str.nextToken());
				final double y = Double.parseDouble(str.nextToken());
				final double z = Double.parseDouble(str.nextToken());
				ret = new Point3D(x, y, z);
			} catch (NumberFormatException e) {
				ret = Point3D.ORIGIN;
			}
		else
			ret = Point3D.ORIGIN;
		return ret;
	}
	/**
	 * Parses a reference value from the specified string.
	 *
	 * @param in the string to parse
	 * @return a reference representing the string (may be null if it is None)
	 */
	public static UTReference parseReference(final String in) {
		UTReference out = null;
		if (in != null) {
			final int len = in.length(), index = in.indexOf('\'');
			if (index > 0 && in.charAt(len - 1) == '\'' && index < len - 1)
				out = new UTReference(in.substring(0, index),
					removeQuotes(in.substring(index)));
			else
				throw new IllegalArgumentException("Invalid reference: " + in);
		}
		return out;
	}
	/**
	 * Parses a rotation value from the specified string.
	 *
	 * @param in the string to parse
	 * @return a Rotator3D representing the rotation, or (0, 0, 0) if not parseable
	 */
	public static Rotator3D parseRotation(final String in) {
		final Matcher m = PARSE_ROTATION.matcher(in);
		Rotator3D ret;
		if (m.matches())
			try {
				final double pitch = Double.parseDouble(m.group(1));
				final double yaw = Double.parseDouble(m.group(2));
				final double roll = Double.parseDouble(m.group(3));
				ret = new Rotator3D(roll, pitch, yaw);
			} catch (NumberFormatException e) {
				ret = Rotator3D.NO_ROTATION;
			}
		else
			ret = Rotator3D.NO_ROTATION;
		return ret;
	}
	/**
	 * Outputs an array to the given stream.
	 *
	 * @param out the output stream to write
	 * @param indent how many levels to indent the <b>parent</b>!
	 * @param name the attribute name of the array
	 * @param array the array to write
	 */
	public static void putArray(final PrintWriter out, final int indent,
			final String name, final DynamicArray array) {
		Object item;
		for (int i = 0; i < array.length(); i++) {
			item = array.get(i);
			if (item != null)
				addIndent(out, indent + 1, name, '(', i, ")=", UTUtils.utType(item));
		}
	}
	/**
	 * Outputs a key-value pair to the given stream.
	 *
	 * @param out the output stream to write (should NOT have autoflush on!)
	 * @param indent how many levels to indent the <b>parent</b>!
	 * @param key the attribute name
	 * @param value the attribute value
	 */
	public static void putAttribute(final PrintWriter out, final int indent,
			final String key, final Object value) {
		addIndent(out, indent + 1, key, '=', value);
	}
	/**
	 * Outputs a key-value pair with surrounding double quotes to the given stream.
	 *
	 * @param out the output stream to write (should NOT have autoflush on!)
	 * @param indent how many levels to indent the <b>parent</b>!
	 * @param key the attribute name
	 * @param value the attribute value
	 */
	public static void putAttributeQ(final PrintWriter out, final int indent,
			final String key, final Object value) {
		final String str = value.toString();
		if (str.equalsIgnoreCase("None"))
			putAttribute(out, indent, key, "None");
		else
			addIndent(out, indent + 1, key, "=\"", str, '"');
	}
	/**
	 * Outputs the list of objects to the given stream.
	 *
	 * @param out the output stream to write
	 * @param indent how many levels to indent the <b>parent</b>!
	 * @param name the attribute name
	 * @param values the components to write
	 */
	public static void putObjectList(final PrintWriter out, final int indent,
			final String name, final Iterable<?> values) {
		int i = 0;
		for (Object value : values)
			if (value != null)
				addIndent(out, indent + 1, name, '(', i++, ")=", UTUtils.utType(value));
	}
	/**
	 * Strips quotes of the 3 major types (', ", `) from a string.
	 *
	 * @param in the string to strip
	 * @return the string with a single set of matching, bounding quotes removed if present
	 */
	public static String removeQuotes(final String in) {
		final int len = in.length(); String out = in;
		if (len > 1) {
			final char first = in.charAt(0), last = in.charAt(len - 1);
			if (first == last && (first == '\'' || first == '"' || first == '`'))
				out = in.substring(1, len - 1);
		}
		return out;
	}
	/**
	 * Rotates the point (vector) by the specified rotator.
	 *
	 * @param loc the point to rotate
	 * @param rot the amount to rotate it
	 * @return the point, rotated by that vector (caution: can be slow)
	 */
	public static Point3D rotateVector(final Point3D loc, final Rotator3D rot) {
		double x, y, z, cosT, sinT;
		final Point3D out = loc.getLocation();
		final Point3D adjRot = UnitsConverter.angleVectorFromUU(rot);
		// X (Roll)
		x = adjRot.getX();
		if (Math.abs(x) > Utils.DOUBLE_TOLERANCE) {
			cosT = Math.cos(x); sinT = Math.sin(x);
			y = out.getY() * cosT - out.getZ() * sinT;
			z = out.getY() * sinT + out.getZ() * cosT;
			out.setLocation(out.getX(), y, z);
		}
		// Y (Pitch)
		y = adjRot.getY();
		if (Math.abs(y) > Utils.DOUBLE_TOLERANCE) {
			cosT = Math.cos(y); sinT = Math.sin(y);
			x = out.getX() * cosT - out.getZ() * sinT;
			z = out.getX() * sinT + out.getZ() * cosT;
			out.setLocation(x, out.getY(), z);
		}
		// Z (Yaw)
		z = adjRot.getZ();
		if (Math.abs(z) > Utils.DOUBLE_TOLERANCE) {
			cosT = Math.cos(z); sinT = Math.sin(z);
			x = out.getX() * cosT - out.getY() * sinT;
			y = out.getX() * sinT + out.getY() * cosT;
			out.setLocation(x, y, out.getZ());
		}
		return out;
	}
	/**
	 * Stores an element into the array.
	 *
	 * @param key the attribute key
	 * @param value the attribute value
	 * @param list the list where elements should be stored
	 * @param defaultValue the value to install in empty locations of the array
	 * @param <T> makes everything convenient
	 * @return whether an element could actually be stored
	 */
	public static <T> boolean storeArray(final String key, final T value, final List<T> list,
			final T defaultValue) {
		final Matcher m = extractArrayValues(key);
		final boolean matched = m.matches();
		if (matched) {
			final int index = Integer.parseInt(m.group(2));
			if (index < list.size())
				list.set(index, value);
			else {
				for (int i = index; i < list.size(); i++)
					list.add(defaultValue);
				list.add(value);
			}
		}
		return matched;
	}
	/**
	 * Converts the object (a Java native type) to its Unreal equivalent.
	 *
	 * @param value the object to convert
	 * @return the object's representation as an Unreal type
	 */
	public static String utType(final Object value) {
		final String out;
		if (value == null)
			out = nullAsNone(value);
		else if (value instanceof String)
			out = "\"" + value + "\"";
		else if (value instanceof UTObject)
			out = ((UTObject)value).asReference().toString();
		else
			out = value.toString();
		return out;
	}
}