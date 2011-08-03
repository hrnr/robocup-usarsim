package org.nist.worldgen.t3d;

import java.io.*;
import java.util.regex.*;

/**
 * Parses T3D files from streams and creates objects from the T3DRegistry matching the
 * imported object(s).
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class T3DParser {
	/**
	 * Allow splitting on runs of spaces.
	 */
	private static final Pattern SPACES = Pattern.compile("\\s+");
	/**
	 * Parses out the U and V pan values.
	 */
	private static final Pattern UVPAN = Pattern.compile("U=([0-9e+.-]+)\\s*V=([0-9e+.-]+)",
		Pattern.CASE_INSENSITIVE);

	protected static UTObject createObject(final BufferedReader br,
			final UTAttributeSet values) throws IOException {
		final UTObject newObject, parent = values.getParent();
		final String type = values.get("Begin"); boolean parse = true;
		// Object, Actor pass to T3DRegistry. Brush, Map goes directly to factory
		if (type.equalsIgnoreCase("Object"))
			newObject = T3DRegistry.getComponentRegistry().createObject(
				values.get("Class"), values);
		else if (type.equalsIgnoreCase("Actor"))
			newObject = T3DRegistry.getActorRegistry().createObject(
				values.get("Class"), values);
		else if (type.equalsIgnoreCase("Map"))
			newObject = new UTMap(values.get("Name", "Untitled"));
		else if (type.equalsIgnoreCase("Brush"))
			newObject = new Brush(values.get("Name"));
		// PolyList, Level, etc. are ignored
		else if (type.equalsIgnoreCase("PolyList") || type.equalsIgnoreCase("Surface") ||
				type.equalsIgnoreCase("Level"))
			newObject = parent;
		else if (type.equalsIgnoreCase("MapPackage")) {
			// Must die!
			removeMapPackage(br);
			newObject = parent;
			parse = false;
		} else if (type.equalsIgnoreCase("Polygon")) {
			// Polygons are parsed separately
			newObject = parsePolygon(br, values);
			parse = false;
		} else
			throw new IllegalArgumentException("Invalid object type: " + type);
		// Parse object off the queue
		if (parse)
			parse(br, newObject);
		return newObject;
	}
	/**
	 * Parse the specified input stream into a UT object.
	 *
	 * @param is the input stream to parse
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if a parse error occurs
	 * @return the parsed object
	 */
	public static UTObject parse(final InputStream is) throws IOException, T3DException {
		final BufferedReader br = new BufferedReader(new InputStreamReader(is));
		UTObject result;
		try {
			result = parse(br, null);
		} catch (RuntimeException e) {
			throw new T3DException("Error when parsing: " + e.getMessage(), e);
		} finally {
			br.close();
		}
		return result;
	}
	protected static UTObject parse(final BufferedReader br, UTObject into)
			throws IOException {
		String line; int index;
		while ((line = br.readLine()) != null && !(line = line.trim()).startsWith("End")) {
			index = line.indexOf("//");
			// Strip comment
			if (index >= 0)
				line = line.substring(0, index);
			// If currentObject == null, it should be a Begin... or cause exception
			if (line.startsWith("Begin")) {
				final UTAttributeSet values = new UTAttributeSet(into, line);
				final UTObject newObject = createObject(br, values);
				if (into != null && into != newObject)
					into.addComponent(newObject);
				else
					into = newObject;
			} else if (line.length() > 0) {
				// Parse key-value
				index = line.indexOf('=');
				if (index > 0) {
					final String key = line.substring(0, index);
					final String value = line.substring(index + 1);
					if (into == null)
						throw new IllegalStateException("Attribute outside of declaration");
					into.putAttributeParse(key, value);
				}
				// Else: exception?
			}
		}
		return into;
	}
	protected static Brush.Polygon parsePolygon(final BufferedReader br,
			final UTAttributeSet values) throws IOException {
		final int flags = Integer.parseInt(values.get("Flags"));
		final double res = Double.parseDouble(values.get("ShadowMapScale", "0.0"));
		final int link = Integer.parseInt(values.get("Link", "-1"));
		final String texture = UTUtils.noneAsNull(values.get("Texture", "None"));
		final UTReference tex;
		if (texture == null)
			tex = null;
		else
			tex = new UTReference(texture);
		final Brush.Polygon poly = new Brush.Polygon(tex, flags, res, link);
		String line, key, value; String[] kv; int index;
		while ((line = br.readLine()) != null && !(line = line.trim()).startsWith("End")) {
			index = line.indexOf("//");
			// Strip comment
			if (index >= 0)
				line = line.substring(0, index);
			if (line.length() > 0) {
				kv = SPACES.split(line, 2);
				if (kv.length < 2)
					throw new IllegalArgumentException("Invalid attribute in polygon");
				key = kv[0]; value = kv[1];
				if (key.equalsIgnoreCase("TextureU"))
					poly.setTexU(UTUtils.parsePolygon(value));
				else if (key.equalsIgnoreCase("TextureV"))
					poly.setTexV(UTUtils.parsePolygon(value));
				else if (key.equalsIgnoreCase("Pan")) {
					final Matcher m = UVPAN.matcher(value);
					if (m.find()) {
						final double u = Double.parseDouble(m.group(1));
						final double v = Double.parseDouble(m.group(2));
						poly.setPan(u, v);
					} else
						throw new IllegalArgumentException("Malformed U/V Pan argument");
				} else if (key.equalsIgnoreCase("Vertex"))
					poly.addVertex(UTUtils.parsePolygon(value));
				// Else: Normal, Origin, etc.
			}
		}
		return poly;
	}
	private static void removeMapPackage(final BufferedReader br) throws IOException {
		String line = br.readLine();
		while (line != null && !line.trim().startsWith("End MapPackage"))
			line = br.readLine();
	}
	/**
	 * Writes the specified Unreal object to an output stream.
	 *
	 * @param os the output stream to write the T3D text
	 * @param object the object to export
	 * @throws IOException if an I/O error occurs when writing
	 */
	public static void write(final OutputStream os, final UTObject object) throws IOException {
		final PrintWriter out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(os),
			1024));
		object.toUnrealText(out, 0, 0);
		out.flush();
		if (out.checkError())
			throw new IOException("Error when writing T3D file to stream");
	}
}