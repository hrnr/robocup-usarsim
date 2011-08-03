package org.nist.worldgen;

import java.io.*;
import java.util.*;

/**
 * Configuration file manager for the world generator.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class WGConfig {
	private static final Properties DEFAULT = new Properties();
	private static final Properties PROPERTIES = new Properties(DEFAULT);
	private static volatile boolean loaded;

	/**
	 * Gets the specified world generation property.
	 *
	 * @param key the property to look up
	 * @return the property value
	 */
	public static String getProperty(final String key) {
		loadConfig();
		return PROPERTIES.getProperty(key, "").trim();
	}
	/**
	 * Gets the specified world generation property.
	 *
	 * @param key the property to look up
	 * @return the property value as a dimension
	 */
	public static Dimension3D getDimension(final String key) {
		return Dimension3D.fromExternalForm(getProperty(key));
	}
	/**
	 * Gets the specified world generation property.
	 *
	 * @param key the property to look up
	 * @return the property value as a floating point number
	 */
	public static double getDouble(final String key) {
		return Double.parseDouble(getProperty(key));
	}
	/**
	 * Gets the specified world generation property.
	 *
	 * @param key the property to look up
	 * @return the property value as a number
	 */
	public static int getInteger(final String key) {
		return Integer.parseInt(getProperty(key));
	}
	private static void loadConfig() {
		synchronized (DEFAULT) {
			if (!loaded) {
				try {
					final InputStream jis = WGConfig.class.getResourceAsStream(
						"/WorldGen.properties");
					DEFAULT.load(jis);
					jis.close();
					final InputStream is = new BufferedInputStream(new FileInputStream(
						"WorldGen.properties"), 1024);
					PROPERTIES.load(is);
					is.close();
				} catch (IOException ignore) { }
				loaded = true;
			}
		}
	}
}