package org.nist.worldgen.mif;

import java.awt.*;
import java.io.*;

/**
 * A class which parents all objects in a MIF file.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public abstract class MifObject {
	protected final String name;
	protected final String type;

	/**
	 * Creates a new MIF object.
	 *
	 * @param name the object name
	 * @param type the object type
	 */
	protected MifObject(final String name, final String type) {
		this.name = name;
		this.type = type;
	}
	/**
	 * Gets the geometry of this MIF object.
	 *
	 * @return the MIF object's geometry
	 */
	public abstract Shape getGeometry();
	/**
	 * Gets the name of this object.
	 *
	 * @return the object's name
	 */
	public String getName() {
		return name;
	}
	/**
	 * Gets the type of this object.
	 *
	 * @return the object's type
	 */
	public String getType() {
		return type;
	}
	/**
	 * Converts this MIF object to its MID file form.
	 *
	 * @param out the output stream to write the data
	 */
	public abstract void toMID(final PrintWriter out);
	/**
	 * Converts this MIF object to its MIF file form.
	 *
	 * @param out the output stream to write the data
	 */
	public abstract void toMIF(final PrintWriter out);
}