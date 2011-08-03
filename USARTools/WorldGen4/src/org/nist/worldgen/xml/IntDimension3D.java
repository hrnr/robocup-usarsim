package org.nist.worldgen.xml;

import java.util.*;

/**
 * 3-D version of the java.awt.Dimension class
 *
 * @author Stephen Carlson (NIST)
 */
public class IntDimension3D {
	/**
	 * Creates a Dimension3D from the value output by toExternalForm().
	 *
	 * @param values 3 comma delimited integer values
	 * @return a Dimension3D using those values (depth, width, height)
	 */
	public static IntDimension3D fromExternalForm(final String values) {
		final StringTokenizer str = new StringTokenizer(values, ",");
		IntDimension3D output = null;
		try {
			int d = Integer.parseInt(str.nextToken().trim());
			int w = Integer.parseInt(str.nextToken().trim());
			int h = Integer.parseInt(str.nextToken().trim());
			output = new IntDimension3D(d, w, h);
		} catch (RuntimeException ignore) { }
		return output;
	}

	/**
	 * The dimension's depth (X coordinate).
	 */
	public int depth;
	/**
	 * The dimension's height (Z coordinate).
	 */
	public int height;
	/**
	 * The dimension's width (Y coordinate).
	 */
	public int width;

	/**
	 * Creates a new dimension.
	 *
	 * @param depth the x size
	 * @param width the y size
	 * @param height the z size
	 */
	public IntDimension3D(final int depth, final int width, final int height) {
		this.depth = depth;
		this.width = width;
		this.height = height;
	}
	public boolean equals(Object other) {
		if (other instanceof IntDimension3D) {
			IntDimension3D dims = (IntDimension3D)other;
			return dims.depth == depth && dims.height == height && dims.width == width;
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
	public IntDimension3D getSize() {
		return new IntDimension3D(depth, width, height);
	}
	/**
	 * Gets the dimension width (Unreal Y)
	 *
	 * @return the width of the dimension
	 */
	public double getWidth() {
		return width;
	}
	public int hashCode() {
		int sum = depth + width + height;
		return sum * (sum + 1) / 2 + width;
	}
	/**
	 * Converts this Dimension3D to serializable form.
	 *
	 * @return a simple representation (easy to parse) of this object: 3 integers, comma
	 * delimited, of the form depth, width, height
	 */
	public String toExternalForm() {
		return String.format("%d, %d, %d", depth, width, height);
	}
	public String toString() {
		return String.format("%d * %d * %d", depth, width, height);
	}
}