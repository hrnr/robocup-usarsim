package org.nist.worldgen;

import java.awt.geom.Point2D;

/**
 * 3-D version of the java.awt.Point class
 *
 * @author Stephen Carlson (NIST)
 */
public class Point3D {
	/**
	 * The Point3D object at the origin.
	 */
	public static final Point3D ORIGIN = new Point3D();

	protected double x;
	protected double y;
	protected double z;

	/**
	 * Creates a new point at the origin.
	 */
	public Point3D() {
		this(0.0, 0.0, 0.0);
	}
	/**
	 * Creates a new point at the specified coordinate.
	 *
	 * @param x the x coordinate
	 * @param y the y coordinate
	 * @param z the z coordinate
	 */
	public Point3D(final double x, final double y, final double z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	/**
	 * Finds the distance squared to the specified point. <i>This method is much faster than
	 * distance(Point3D)</i>
	 *
	 * @param other the point to compute distance
	 * @return the distance squared between this point and the other
	 */
	public double distanceSq(final Point3D other) {
		final double xd = other.getX() - getX(), yd = other.getY() - getY(),
			zd = other.getZ() - getZ();
		return xd * xd + yd * yd + zd * zd;
	}
	/**
	 * Finds the distance to the specified point.
	 *
	 * @param other the point to compute distance
	 * @return the distance between this point and the other
	 */
	public double distance(final Point3D other) {
		return Math.sqrt(distanceSq(other));
	}
	public boolean equals(Object o) {
		if (!(o instanceof Point3D)) return false;
		final Point3D other = (Point3D)o;
		return Utils.doubleEquals(getX(), other.getX()) && Utils.doubleEquals(getY(),
			other.getY()) && Utils.doubleEquals(getZ(), other.getZ());
	}
	/**
	 * Creates a copy of this point.
	 *
	 * @return a new Point3D with the same location as this one
	 */
	public Point3D getLocation() {
		return new Point3D(getX(), getY(), getZ());
	}
	/**
	 * Gets the X coordinate of this point.
	 *
	 * @return the X coordinate
	 */
	public double getX() {
		return x;
	}
	/**
	 * Gets the Y coordinate of this point.
	 *
	 * @return the Y coordinate
	 */
	public double getY() {
		return y;
	}
	/**
	 * Gets the Z coordinate of this point.
	 *
	 * @return the Z coordinate
	 */
	public double getZ() {
		return z;
	}
	/**
	 * Changes the location of this point.
	 *
	 * @param x the new X coordinate
	 * @param y the new Y coordinate
	 * @param z the new Z coordinate
	 */
	public void setLocation(final double x, final double y, final double z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	/**
	 * Changes the location of this point.
	 *
	 * @param other the new location of this Point3D
	 */
	public void setLocation(final Point3D other) {
		setLocation(other.getX(), other.getY(), other.getZ());
	}
	/**
	 * Changes the X coordinate of this point.
	 *
	 * @param x the X coordinate
	 */
	public void setX(final double x) {
		this.x = x;
	}
	/**
	 * Changes the Y coordinate of this point.
	 *
	 * @param y the Y coordinate
	 */
	public void setY(final double y) {
		this.y = y;
	}
	/**
	 * Changes the Z coordinate of this point.
	 *
	 * @param z the Z coordinate
	 */
	public void setZ(final double z) {
		this.z = z;
	}
	/**
	 * Converts the Point3D to the form used in T3D polygons.
	 *
	 * @return the point in polygon coordinate output format
	 */
	public String toCoordinateForm() {
		return String.format("%+013.6f,%+013.6f,%+013.6f", x, y, z);
	}
	/**
	 * Converts the Point3D to an Unreal-type output coordinate.
	 *
	 * @return text which represents this point in Unreal T3D notation
	 */
	public String toExternalForm() {
		return String.format("(X=%.3f,Y=%.3f,Z=%.3f)", x, y, z);
	}
	public String toString() {
		return String.format("(%.3f, %.3f, %.3f)", x, y, z);
	}
}