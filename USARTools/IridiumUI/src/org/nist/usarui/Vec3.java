package org.nist.usarui;

/**
 * A simple class that holds a 3-vector (position or rotation)
 *
 * @author Stephen Carlson (NIST)
 */
public class Vec3 {
	/**
	 * The vector's x component.
	 */
	private final float x;
	/**
	 * The vector's y component.
	 */
	private final float y;
	/**
	 * The vector's z component.
	 */
	private final float z;

	/**
	 * Creates a new 3-vector.
	 *
	 * @param x the X component
	 * @param y the Y component
	 * @param z the Z component
	 */
	public Vec3(float x, float y, float z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	/**
	 * Creates a new 3-vector.
	 *
	 * @param x the X component
	 * @param y the Y component
	 * @param z the Z component
	 */
	public Vec3(double x, double y, double z) {
		this.x = (float)x;
		this.y = (float)y;
		this.z = (float)z;
	}
	/**
	 * Converts the vector's components from degrees to radians.
	 *
	 * @param convert whether the conversion should occur
	 * @return this vector, if convert is false; otherwise, a new Vec3 with values converted
	 * to radians (* PI / 180)
	 */
	public Vec3 degToRad(boolean convert) {
		Vec3 converted = this;
		if (convert)
			converted = new Vec3(Math.toRadians(x), Math.toRadians(y), Math.toRadians(z));
		return converted;
	}
	/**
	 * Gets the X component.
	 *
	 * @return the X component
	 */
	public float getX() {
		return x;
	}
	/**
	 * Gets the Y component.
	 *
	 * @return the Y component
	 */
	public float getY() {
		return y;
	}
	/**
	 * Gets the Z component.
	 *
	 * @return the Z component
	 */
	public float getZ() {
		return z;
	}
	/**
	 * Converts the vector's components from radians to degrees.
	 *
	 * @param convert whether the conversion should occur
	 * @return this vector, if convert is false; otherwise, a new Vec3 with values converted
	 * to degrees (* 180 / PI)
	 */
	public Vec3 radToDeg(boolean convert) {
		Vec3 converted = this;
		if (convert)
			converted = new Vec3(Math.toDegrees(x), Math.toDegrees(y), Math.toDegrees(z));
		return converted;
	}
	/**
	 * Returns a higher-precision string representation of this vector.
	 *
	 * @return this vector as a string
	 */
	public String toPrecisionString() {
		return String.format("%.4f, %.4f, %.4f", x, y, z);
	}
	public String toString() {
		return String.format("%.2f, %.2f, %.2f", x, y, z);
	}
}