package org.nist.worldgen;

/**
 * Denotes an object with an Unreal location and rotation.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface Locatable {
	/**
	 * Gets the location of this object.
	 *
	 * @return the object's location using Unreal (<b>not</b> USAR) coordinate system
	 */
	public Point3D getLocation();
	/**
	 * Gets the rotation of this object.
	 *
	 * @return the object's rotation using Unreal coordinate system
	 */
	public Rotator3D getRotation();
	/**
	 * Changes the location of this object.
	 *
	 * @param location the new location of this object
	 */
	public void setLocation(Point3D location);
	/**
	 * Changes the rotation of this object.
	 *
	 * @param rotation the new rotation of this object
	 */
	public void setRotation(Rotator3D rotation);
}