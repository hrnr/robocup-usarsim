package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import java.awt.Point;
import java.awt.Rectangle;
import java.io.*;
import java.util.*;

/**
 * Stores a room instance (namely, a room and its location + rotation) in a world
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class WGRoomInstance implements XMLSerializable {
	private final WGRoom room;
	private int rotation;
	private int x;
	private int y;

	/**
	 * Creates a new instance of the specified room.
	 *
	 * @param room the room to store
	 * @param x the room x coordinate
	 * @param y the room y coordinate
	 * @param rotation the room orientation
	 */
	public WGRoomInstance(final WGRoom room, final int x, final int y, final int rotation) {
		this.room = room;
		this.rotation = rotation;
		this.x = x;
		this.y = y;
	}
	/**
	 * Creates a duplicate of the specified room instance.
	 *
	 * @param other the object to copy
	 */
	public WGRoomInstance(final WGRoomInstance other) {
		this(other.getRoom(), other.getX(), other.getY(), other.getRotation());
	}
	public boolean equals(Object o) {
		if (!(o instanceof WGRoomInstance)) return false;
		final WGRoomInstance test = (WGRoomInstance)o;
		return room.equals(test.getRoom()) && x == test.getX() && y == test.getY() &&
			rotation == test.getRotation();
	}
	/**
	 * Gets this room's bounding box.
	 *
	 * @return the box which bounds this room
	 */
	public Rectangle getBounds() {
		return new Rectangle(x, y, getDepth(), getWidth());
	}
	/**
	 * Gets this room's depth, effective after rotation has been applied.
	 *
	 * @return the room depth
	 */
	public int getDepth() {
		final int result; final IntDimension3D size = room.getSize();
		if (rotation % 2 == 0)
			result = size.depth;
		else
			result = size.width;
		return result;
	}
	/**
	 * Gets this room's height (convenience method).
	 * 
	 * @return the room height
	 */
	public int getHeight() {
		return room.getSize().height;
	}
	/**
	 * Gets the location of this room.
	 *
	 * @return a Point describing the room's location
	 */
	public Point getLocation() {
		return new Point(x, y);
	}
	/**
	 * Gets the room contained in this instance.
	 *
	 * @return the contained room
	 */
	public WGRoom getRoom() {
		return room;
	}
	/**
	 * Gets the orientation of this room.
	 *
	 * @return the room orientation (# of 90 degree CW turns, see constants in this class)
	 */
	public int getRotation() {
		return rotation;
	}
	/**
	 * Gets this room's width, effective after rotation has been applied.
	 *
	 * @return the room width
	 */
	public int getWidth() {
		final int result; final IntDimension3D size = room.getSize();
		if (rotation % 2 == 0)
			result = size.width;
		else
			result = size.depth;
		return result;
	}
	/**
	 * Gets the X coordinate of this room's upper left corner.
	 *
	 * @return the room X coordinate (up/down)
	 */
	public int getX() {
		return x;
	}
	/**
	 * Gets the Y coordinate of this room's upper left corner.
	 *
	 * @return the room Y coordinate (left/right)
	 */
	public int getY() {
		return y;
	}
	public int hashCode() {
		return room.hashCode() ^ (x ^ (y << 16));
	}
	/**
	 * Changes the rotation of this object.
	 *
	 * @param rotation the new rotation (see constants above)
	 */
	public void setRotation(int rotation) {
		this.rotation = rotation;
	}
	/**
	 * Changes the location of this object.
	 *
	 * @param x the new X coordinate
	 * @param y the new Y coordinate
	 */
	public void setLocation(int x, int y) {
		this.x = x;
		this.y = y;
	}
	/**
	 * Changes the X coordinate of this object.
	 *
	 * @param x the new X coordinate
	 */
	public void setX(int x) {
		this.x = x;
	}
	/**
	 * Changes the Y coordinate of this object.
	 *
	 * @param y the new Y coordinate
	 */
	public void setY(int y) {
		this.y = y;
	}
	public String toString() {
		return getClass().getSimpleName() + String.format("[room=%s,x=%d,y=%d,theta=%d]",
			room.toString(), x, y, rotation);
	}
	public void toXML(PrintWriter out, int indent) {
		Utils.addTag(out, indent, "room", "name", Utils.xmlEncode(room.getFileName()), "x", x,
			"y", y, "theta", rotation, "/");
	}
}