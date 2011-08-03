package org.nist.worldgen.t3d;

import java.util.*;
import java.util.regex.*;

/**
 * Represents a set of attributes passed when creating UT objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTAttributeSet implements Iterable<Map.Entry<String, String>> {
	private static final Pattern ATTR_SPLIT = Pattern.compile("[ \t=]");

	private final UTObject parent;
	private final Map<String, String> values;

	/**
	 * Creates a UTAttributeSet based off of the specified parse line.
	 *
	 * @param parent the parent object of this one, or null if there is no parent
	 * @param data the data read from the T3D file in the format "Class=Actor Name=Actor_1"
	 */
	public UTAttributeSet(final UTObject parent, final String data) {
		final String[] line = ATTR_SPLIT.split(data);
		if (line.length % 2 != 0)
			throw new IllegalArgumentException("Invalid T3D creation line");
		this.parent = parent;
		values = new LinkedHashMap<String, String>(16);
		for (int i = 0; i < line.length; i += 2)
			values.put(line[i], line[i + 1]);
	}
	/**
	 * Gets the value of the specified attribute.
	 *
	 * @param key the attribute to look up
	 * @return that attribute's value
	 * @throws NoSuchElementException if the specified key does not exist
	 */
	public String get(final String key) {
		final String value = values.get(key);
		if (value == null)
			throw new NoSuchElementException("Missing required attribute: " + key);
		return value;
	}
	/**
	 * Gets the value of the specified optional attribute.
	 *
	 * @param key the attribute to look up
	 * @param defaultValue the value to substitute if undefined
	 * @return the attribute's value
	 */
	public String get(final String key, final String defaultValue) {
		String value = values.get(key);
		if (value == null)
			value = defaultValue;
		return value;
	}
	/**
	 * Gets the parent object.
	 *
	 * @return the parent object of this one
	 */
	public UTObject getParent() {
		return parent;
	}
	public Iterator<Map.Entry<String, String>> iterator() {
		return values.entrySet().iterator();
	}
	/**
	 * Gets the number of attributes in this map.
	 *
	 * @return the number of key-value pairs in this object
	 */
	public int size() {
		return values.size();
	}
	public String toString() {
		return values.toString();
	}
}