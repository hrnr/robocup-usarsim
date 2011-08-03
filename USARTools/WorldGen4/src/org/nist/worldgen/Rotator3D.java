package org.nist.worldgen;

/**
 * Slightly modified Point3D class to handle an Unreal rotator object.
 *
 * @author Stephen Carlson (NIST)
 */
public class Rotator3D {
	/**
	 * A rotator with no rotation.
	 */
	public static final Rotator3D NO_ROTATION = new Rotator3D();

	protected int pitch;
	protected int roll;
	protected int yaw;

	/**
	 * Creates a new rotator with no rotation.
	 */
	public Rotator3D() {
		this(0, 0, 0);
	}
	/**
	 * Creates a new rotator with the specified rotation amounts in UU.
	 *
	 * @param roll the x rotation
	 * @param pitch the y rotation
	 * @param yaw the z rotation
	 */
	public Rotator3D(final int roll, final int pitch, final int yaw) {
		this.roll = roll;
		this.pitch = pitch;
		this.yaw = yaw;
	}
	/**
	 * Creates a new rotator with the specified rotation amounts in UU.
	 *
	 * @param roll the x rotation
	 * @param pitch the y rotation
	 * @param yaw the z rotation
	 */
	public Rotator3D(final double roll, final double pitch, final double yaw) {
		this.roll = (int)Math.round(roll);
		this.pitch = (int)Math.round(pitch);
		this.yaw = (int)Math.round(yaw);
	}
	public boolean equals(Object o) {
		if (!(o instanceof Rotator3D)) return false;
		final Rotator3D other = (Rotator3D)o;
		return Utils.doubleEquals(getRoll(), other.getRoll()) && Utils.doubleEquals(getPitch(),
			other.getPitch()) && Utils.doubleEquals(getYaw(), other.getYaw());
	}
	/**
	 * Gets the Y rotation.
	 *
	 * @return the rotation around the Y axis
	 */
	public int getPitch() {
		return pitch;
	}
	/**
	 * Gets the X rotation.
	 *
	 * @return the rotation around the X axis
	 */
	public int getRoll() {
		return roll;
	}
	/**
	 * Creates a copy of this rotator.
	 *
	 * @return a new Rotator3D with the same angles as this one
	 */
	public Rotator3D getRotation() {
		return new Rotator3D(getRoll(), getPitch(), getYaw());
	}
	/**
	 * Gets the Z rotation.
	 *
	 * @return the rotation around the Z axis
	 */
	public int getYaw() {
		return yaw;
	}
	/**
	 * Changes the rotation of this rotator.
	 *
	 * @param roll the new X rotation
	 * @param pitch the new Y rotation
	 * @param yaw the new Z rotation
	 */
	public void setRotation(final int roll, final int pitch, final int yaw) {
		this.roll = roll;
		this.pitch = pitch;
		this.yaw = yaw;
	}
	/**
	 * Changes the rotation of this rotator.
	 *
	 * @param other the new rotator of this Rotator3D
	 */
	public void setRotation(final Rotator3D other) {
		setRotation(other.getRoll(), other.getPitch(), other.getYaw());
	}
	/**
	 * Changes the Y rotation of this rotator.
	 *
	 * @param pitch the new Y rotation
	 */
	public void setPitch(final int pitch) {
		this.pitch = pitch;
	}
	/**
	 * Changes the X rotation of this rotator.
	 *
	 * @param roll the new X rotation
	 */
	public void setRoll(final int roll) {
		this.roll = roll;
	}
	/**
	 * Changes the Z rotation of this rotator.
	 *
	 * @param yaw the new Z rotation
	 */
	public void setYaw(final int yaw) {
		this.yaw = yaw;
	}
	/**
	 * Converts the Rotator3D to an Unreal-type output rotation.
	 *
	 * @return text which represents this rotator in Unreal T3D notation
	 */
	public String toExternalForm() {
		return String.format("(Pitch=%d,Yaw=%d,Roll=%d)", pitch, yaw, roll);
	}
	public String toString() {
		return String.format("(Roll=%d, Pitch=%d, Yaw=%d)", roll, pitch, yaw);
	}
}