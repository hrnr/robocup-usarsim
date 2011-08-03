package org.nist.worldgen;

import java.util.*;

/**
 * 3-D version of the java.awt.Dimension class
 *
 * @author Stephen Carlson (NIST)
 */
public class Dimension3D {
	/**
	 * Creates a Dimension3D object from its external form.
	 *
	 * @param input 3 comma delimited floating point values denoting depth, width, and height
	 * @return the Dimension3D matching these values, or NO_SIZE if not parseable
	 */
	public static Dimension3D fromExternalForm(final String input) {
		Dimension3D out;
		try {
			final StringTokenizer str = new StringTokenizer(input, ",");
			final double depth = Double.parseDouble(str.nextToken().trim());
			final double width = Double.parseDouble(str.nextToken().trim());
			final double height = Double.parseDouble(str.nextToken().trim());
			out = new Dimension3D(depth, width, height);
		} catch (RuntimeException e) {
			out = NO_SIZE;
		}
		return out;
	}
	/**
	 * The Dimension3D with no size.
	 */
	public static Dimension3D NO_SIZE = new Dimension3D();

	/**
	 * The dimension's depth (X coordinate).
	 */
	public double depth;
	/**
	 * The dimension's height (Z coordinate).
	 */
	public double height;
	/**
	 * The dimension's width (Y coordinate).
	 */
	public double width;

	/**
	 * Creates a new dimension with no size (0x0x0).
	 */
	public Dimension3D() {
		this(0.0, 0.0, 0.0);
	}
	/**
	 * Creates a new dimension.
	 *
	 * @param depth the x size
	 * @param width the y size
	 * @param height the z size
	 */
	public Dimension3D(final double depth, final double width, final double height) {
		this.depth = depth;
		this.width = width;
		this.height = height;
	}
	public boolean equals(Object other) {
		if (other instanceof Dimension3D) {
			Dimension3D dims = (Dimension3D)other;
			return Utils.doubleEquals(dims.depth, depth) && Utils.doubleEquals(dims.height,
				height) && Utils.doubleEquals(dims.width, width);
		}
		return false;
	}
	/**
	 * Gets the dimension depth (Unreal X)
	 *
	 * @return the depth of the dimension
	 */
	public double getDepth() {
		return depth;
	}
	/**
	 * Gets the dimension height (Unreal Z)
	 *
	 * @return the height of the dimension
	 */
	public double getHeight() {
		return height;
	}
	/**
	 * Creates a copy of this Dimension3D with the same size.
	 *
	 * @return a Dimension3D object with the same size as this one
	 */
	public Dimension3D getSize() {
		return new Dimension3D(depth, width, height);
	}
	/**
	 * Gets the dimension width (Unreal Y)
	 *
	 * @return the width of the dimension
	 */
	public double getWidth() {
		return width;
	}
	/**
	 * Changes the size of this dimension.
	 *
	 * @param depth the new depth
	 * @param width the new width
	 * @param height the new height
	 */
	public void setSize(final double depth, final double width, final double height) {
		this.width = width;
		this.height = height;
		this.depth = depth;
	}
	/**
	 * Converts this dimension to external form.
	 *
	 * @return the dimension in an easily parseable form
	 */
	public String toExternalForm() {
		return String.format("%.4f,%.4f,%.4f", depth, width, height);
	}
	public String toString() {
		return String.format("%.3f * %.3f * %.3f", depth, width, height);
	}
}