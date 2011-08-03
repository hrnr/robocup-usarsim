package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import org.nist.worldgen.t3d.*;
import java.awt.*;

/**
 * Represents an item (door, victim, etc.) that can be added to the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class WGItem implements XMLSerializable {
	/*
	 * These coordinates are in World (upper left = 0, 0; grid = 1), not Unreal!
	 */
	protected double x;
	protected double y;

	/**
	 * Creates a new world generator item.
	 *
	 * @param x the X coordinate
	 * @param y the Y coordinate
	 */
	protected WGItem(final double x, final double y) {
		this.x = x;
		this.y = y;
	}
	/**
	 * Creates the T3D representation of this object.
	 *
	 * @param origin the location of (0, 0) in Unreal coordinates
	 * @param id a unique ID number useful for renaming objects cleanly
	 * @return the T3D representation of this object
	 */
	public abstract UTObject createT3D(final Point3D origin, final int id);
	/**
	 * Gets the bounds of this object in screen coordinates to check for selection.
	 *
	 * @return the object's bounds
	 */
	public abstract Rectangle getSelectionBounds();
	/**
	 * Gets the X coordinate.
	 *
	 * @return the world X coordinate
	 */
	public double getX() {
		return x;
	}
	/**
	 * Gets the Y coordinate.
	 *
	 * @return the world Y coordinate
	 */
	public double getY() {
		return y;
	}
	/**
	 * Draws this item on the screen.
	 *
	 * @param g the graphics context on which to paint
	 * @param selected whether the object is selected
	 */
	public abstract void paint(final Graphics2D g, final boolean selected);
}