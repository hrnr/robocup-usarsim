package org.nist.worldgen.t3d;

import org.nist.worldgen.*;

/**
 * A class which renames all of the objects in a map to have unique names and optionally can
 * apply a translation or rotation to all actors.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTObjectModifier {
	private final UTMap map;
	private Point3D offset;
	private final String prefix;
	private Rotator3D rotation;
	private Point3D rotateAbout;

	/**
	 * Creates an object manager that will manage the given map.
	 *
	 * @param map the map containing objects to modify
	 */
	public UTObjectModifier(final UTMap map) {
		this(map, "");
	}
	/**
	 * Creates an object manager that will manage the given map.
	 *
	 * @param map the map containing objects to modify
	 * @param prefix the prefix to apply to generated names
	 */
	public UTObjectModifier(final UTMap map, final String prefix) {
		this.map = map;
		this.prefix = prefix;
		offset = Point3D.ORIGIN;
		rotation = Rotator3D.NO_ROTATION;
		rotateAbout = Point3D.ORIGIN;
	}
	/**
	 * Runs the renamer on every object in the map.
	 */
	public void run() {
		int id = 0;
		for (UTObject object : map.listObjects(UTObject.class)) {
			object.setName(String.format("%s%s_%d", prefix, object.getPrefix(), id++));
			object.transform(offset, rotation, rotateAbout);
		}
	}
	/**
	 * Changes the offset by which all items will be moved.
	 *
	 * @param offset the offset in UU to add to all items
	 */
	public void setOffset(final Point3D offset) {
		this.offset = offset;
	}
	/**
	 * Changes the rotation offset of this world. Rotation will occur around the origin.
	 *
	 * @param rotation the rotation amount to add to all items
	 */
	public void setRotation(final Rotator3D rotation) {
		setRotation(rotation, Point3D.ORIGIN);
	}
	/**
	 * Changes the rotation offset of this world.
	 *
	 * @param rotation the rotation amount to add to all items
	 * @param rotateAbout the point about which to rotate the objects
	 */
	public void setRotation(final Rotator3D rotation, final Point3D rotateAbout) {
		this.rotation = rotation;
		this.rotateAbout = rotateAbout;
	}
}