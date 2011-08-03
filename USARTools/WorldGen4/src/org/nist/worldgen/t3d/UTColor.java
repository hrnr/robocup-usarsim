package org.nist.worldgen.t3d;

import java.awt.*;

/**
 * Represents a Color structure from a T3D file.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTColor {
	/**
	 * Color representing a colorless (black) object.
	 */
	public static final UTColor NO_COLOR = new UTColor(0, 0, 0, 0);
	/**
	 * Color representing a white object.
	 */
	public static final UTColor WHITE = new UTColor(255, 255, 255, 255);

	private final int a;
	private final int b;
	private final int g;
	private final int r;

	/**
	 * Creates a new color with the specified values from 0-255.
	 *
	 * @param r the red channel
	 * @param g the green channel
	 * @param b the blue channel
	 * @param a the alpha channel
	 */
	public UTColor(final int r, final int g, final int b, final int a) {
		this.a = a;
		this.b = b;
		this.g = g;
		this.r = r;
	}
	/**
	 * Creates a copy of another UTColor object.
	 *
	 * @param other the UTColor to duplicate
	 */
	public UTColor(final UTColor other) {
		this(other.getRed(), other.getGreen(), other.getBlue(), other.getAlpha());
	}
	/**
	 * Creates a color representing an AWT color.
	 *
	 * @param color the AWT color to match when creating this object
	 */
	public UTColor(final Color color) {
		this(color.getRed(), color.getGreen(), color.getBlue(), color.getAlpha());
	}
	/**
	 * Converts this UTColor to an AWT color.
	 *
	 * @return an AWT color representing this color
	 */
	public Color asAWTColor() {
		return new Color(r, g, b, a);
	}
	public boolean equals(Object o) {
		if (!(o instanceof UTColor)) return false;
		final UTColor other = (UTColor)o;
		return a == other.getAlpha() && r == other.getRed() && g == other.getGreen() &&
			b == other.getBlue();
	}
	/**
	 * Gets the alpha channel of this color. Note that 0 is opaque and 255 is transparent!
	 *
	 * @return the value of the alpha channel
	 */
	public int getAlpha() {
		return a;
	}
	/**
	 * Gets the blue channel of this color.
	 *
	 * @return the value of the blue channel from 0-255
	 */
	public int getBlue() {
		return b;
	}
	/**
	 * Gets the green channel of this color.
	 *
	 * @return the value of the green channel from 0-255
	 */
	public int getGreen() {
		return g;
	}
	/**
	 * Gets the red channel of this color.
	 *
	 * @return the value of the red channel from 0-255
	 */
	public int getRed() {
		return r;
	}
	public int hashCode() {
		return (a << 24) + (r << 16) + (g << 8) + b;
	}
	public String toExternalForm() {
		return String.format("(B=%d,G=%d,R=%d,A=%d)", getBlue(), getGreen(), getRed(),
			getAlpha());
	}
	public String toString() {
		return String.format("#%02x%02x%02x", getRed(), getGreen(), getBlue());
	}
}