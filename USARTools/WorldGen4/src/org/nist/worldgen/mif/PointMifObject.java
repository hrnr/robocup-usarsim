package org.nist.worldgen.mif;

import org.nist.worldgen.*;

import java.awt.*;
import java.awt.geom.*;
import java.io.*;

/**
 * Represents an object that has no area (a point) in the MIF file.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class PointMifObject extends MifObject implements Constants {
	private final Point2D location;

	/**
	 * Creates a new point MIF object.
	 *
	 * @param name the name of the object
	 * @param type the object's type (used in the "Description" MID field)
	 * @param location the object's location
	 */
	public PointMifObject(final String name, final String type, final Point2D location) {
		super(name, type);
		this.location = location;
	}
	public Shape getGeometry() {
		return new Line2D.Double(location.getX(), location.getY(), location.getX(),
			location.getY());
	}
	/**
	 * Gets the location of this object.
	 *
	 * @return the object's location
	 */
	public Point2D getLocation() {
		return location;
	}
	public void toMID(final PrintWriter out) {
		MifUtils.putObject(out, getName(), getType());
	}
	public void toMIF(final PrintWriter out) {
		final Point2D loc = getLocation();
		out.format("Point %.3f, %.3f", loc.getX(), loc.getY());
		out.println();
		out.print("   ");
		out.println(M_SM_SYMBOL);
	}
}