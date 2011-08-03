package org.nist.worldgen;

/**
 * 3-D version of the java.awt.Rectangle class
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class Rectangle3D {
	/**
	 * Represents the empty rectangle at the origin
	 */
	public static final Rectangle3D EMPTY_RECT = new Rectangle3D();

	public double depth;
	public double height;
	public double width;
	public double x;
	public double y;
	public double z;

	/**
	 * Creates a new Rectangle3D with no size at the origin.
	 */
	public Rectangle3D() {
		this(Point3D.ORIGIN, Dimension3D.NO_SIZE);
	}
	/**
	 * Creates a new Rectangle3D with the specified center location and size.
	 *
	 * @param location the location of this Rectangle3D's center
	 * @param size the rectangle's size
	 */
	public Rectangle3D(final Point3D location, final Dimension3D size) {
		this(location.getX() - size.getDepth() / 2.0, location.getY() - size.getWidth() / 2.0,
			location.getZ() - size.getHeight() / 2.0, size.getDepth(), size.getWidth(),
			size.getHeight());
	}
	/**
	 * Creates a new Rectangle3D with the specified location and size.
	 *
	 * @param x the X coordinate
	 * @param y the Y coordinate
	 * @param z the Z coordinate
	 * @param depth the depth
	 * @param width the width
	 * @param height the height
	 */
	public Rectangle3D(final double x, final double y, final double z, final double depth,
			final double width, final double height) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.depth = depth;
		this.height = height;
		this.width = width;
	}
	/**
	 * Adds a point to this rectangle; the semantics are nearly identical to
	 * java.awt.Rectangle2D.add(java.awt.Point2D) except in 3D.
	 *
	 * @param point the point to add
	 */
	public void add(final Point3D point) {
		final double xmin = Math.min(point.getX(), getX()),
			xmax = Math.max(point.getX(), getMaxX());
		final double ymin = Math.min(point.getY(), getY()),
			ymax = Math.max(point.getY(), getMaxY());
		final double zmin = Math.min(point.getZ(), getZ()),
			zmax = Math.max(point.getZ(), getMaxZ());
		setX(xmin); setY(ymin); setZ(zmin);
		setDepth(xmax - xmin); setWidth(ymax - ymin); setHeight(zmax - zmin);
	}
	/**
	 * Adds another rectangle to this rectangle; the semantics are nearly identical to
	 * java.awt.Rectangle2D.add(java.awt.Rectangle2D) except in 3D.
	 *
	 * @param rect the point to add
	 */
	public void add(final Rectangle3D rect) {
		final double xmin = Math.min(rect.getX(), getX()),
			xmax = Math.max(rect.getMaxX(), getMaxX());
		final double ymin = Math.min(rect.getY(), getY()),
			ymax = Math.max(rect.getMaxY(), getMaxY());
		final double zmin = Math.min(rect.getZ(), getZ()),
			zmax = Math.max(rect.getMaxZ(), getMaxZ());
		setX(xmin); setY(ymin); setZ(zmin);
		setDepth(xmax - xmin); setWidth(ymax - ymin); setHeight(zmax - zmin);
	}
	/**
	 * Checks to see if this rectangle completely encloses the specified other rectangle.
	 *
	 * @param r the other rectangle
	 * @return whether this rectangle encloses the other one
	 */
	public boolean contains(final Rectangle3D r) {
		final double dt = Utils.DOUBLE_TOLERANCE;
		return getX() - dt <= r.getX() && getY() - dt <= r.getY() && getZ() - dt <= r.getZ() &&
			getMaxX() + dt >= r.getMaxX() && getMaxY() + dt >= r.getMaxY() && getMaxZ() + dt >=
			r.getMaxZ();
	}
	public boolean equals(Object o) {
		if (!(o instanceof Rectangle3D)) return false;
		final Rectangle3D other = (Rectangle3D)o;
		return Utils.doubleEquals(getX(), other.getX()) && Utils.doubleEquals(getY(),
			other.getY()) && Utils.doubleEquals(getZ(), other.getZ()) &&
			Utils.doubleEquals(getWidth(), other.getWidth()) && Utils.doubleEquals(getHeight(),
			other.getHeight()) && Utils.doubleEquals(getDepth(), other.getDepth());
	}
	/**
	 * Creates a copy of this rectangle.
	 *
	 * @return a copy of this rectangle
	 */
	public Rectangle3D getBounds() {
		return new Rectangle3D(getX(), getY(), getZ(), getDepth(), getWidth(), getHeight());
	}
	/**
	 * Gets the center X coordinate of this Rectangle3D.
	 *
	 * @return the middle X coordinate
	 */
	public double getCenterX() {
		return x + depth / 2.0;
	}
	/**
	 * Gets the center Y coordinate of this Rectangle3D.
	 *
	 * @return the middle Y coordinate
	 */
	public double getCenterY() {
		return y + width / 2.0;
	}
	/**
	 * Gets the center Z coordinate of this Rectangle3D.
	 *
	 * @return the middle Z coordinate
	 */
	public double getCenterZ() {
		return z + height / 2.0;
	}
	/**
	 * Gets the depth of this Rectangle3D.
	 *
	 * @return the depth (X)
	 */
	public double getDepth() {
		return depth;
	}
	/**
	 * Gets the height of this Rectangle3D.
	 *
	 * @return the height (Z)
	 */
	public double getHeight() {
		return height;
	}
	/**
	 * Gets the maximum X coordinate of this Rectangle3D.
	 *
	 * @return the maximum X coordinate (X + depth)
	 */
	public double getMaxX() {
		return x + depth;
	}
	/**
	 * Gets the maximum Y coordinate of this Rectangle3D.
	 *
	 * @return the maximum Y coordinate (Y + width)
	 */
	public double getMaxY() {
		return y + width;
	}
	/**
	 * Gets the maximum Z coordinate of this Rectangle3D.
	 *
	 * @return the maximum Z coordinate (Z + height)
	 */
	public double getMaxZ() {
		return z + height;
	}
	/**
	 * Gets the size of this Rectangle3D.
	 *
	 * @return the size of the rectangle's bounding box
	 */
	public Dimension3D getSize() {
		return new Dimension3D(depth, width, height);
	}
	/**
	 * Gets the depth of this Rectangle3D.
	 *
	 * @return the width (Y)
	 */
	public double getWidth() {
		return width;
	}
	/**
	 * Gets the X coordinate of this Rectangle3D.
	 *
	 * @return the X coordinate
	 */
	public double getX() {
		return x;
	}
	/**
	 * Gets the Y coordinate of this Rectangle3D.
	 *
	 * @return the Y coordinate
	 */
	public double getY() {
		return y;
	}
	/**
	 * Gets the Z coordinate of this Rectangle3D.
	 *
	 * @return the Z coordinate
	 */
	public double getZ() {
		return z;
	}
	/**
	 * Changes the depth of this Rectangle3D.
	 *
	 * @param depth the new depth (X)
	 */
	public void setDepth(final double depth) {
		this.depth = depth;
	}
	/**
	 * Changes the height of this Rectangle3D.
	 *
	 * @param height the new height (Z)
	 */
	public void setHeight(final double height) {
		this.height = height;
	}
	/**
	 * Changes the width of this Rectangle3D.
	 *
	 * @param width the new width (Y)
	 */
	public void setWidth(final double width) {
		this.width = width;
	}
	/**
	 * Changes the X coordinate of this Rectangle3D.
	 *
	 * @param x the new X coordinate
	 */
	public void setX(final double x) {
		this.x = x;
	}
	/**
	 * Changes the Y coordinate of this Rectangle3D.
	 *
	 * @param y the new Y coordinate
	 */
	public void setY(final double y) {
		this.y = y;
	}
	/**
	 * Changes the Z coordinate of this Rectangle3D.
	 *
	 * @param z the new Z coordinate
	 */
	public void setZ(final double z) {
		this.z = z;
	}
	public String toString() {
		return getClass().getSimpleName() + String.format("[x=%.3f,y=%.3f,z=%.3f," +
			"depth=%.3f,width=%.3f,height=%.3f]", x, y, z, depth, width, height);
	}
}