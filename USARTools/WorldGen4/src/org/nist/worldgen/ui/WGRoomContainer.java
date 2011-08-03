package org.nist.worldgen.ui;

import org.nist.worldgen.xml.*;
import java.util.*;

/**
 * Acts as a tree container of WGRoom objects to ease inheritance problems of JTrees.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class WGRoomContainer implements Comparable<WGRoomContainer> {
	/**
	 * Whether the room cannot be removed from the tree.
	 */
	private final boolean noDelete;
	/**
	 * The room contained, or null if a room group.
	 */
	private final WGRoom room;
	/**
	 * The room (or room group)'s size. Only the X and Y are valid for room groups.
	 */
	private final IntDimension3D size;
	/**
	 * Rooms contained by this object.
	 */
	private final List<WGRoomContainer> subRooms;

	/**
	 * Creates a new room container object.
	 *
	 * @param size the size of the contained room or rooms
	 */
	public WGRoomContainer(final IntDimension3D size) {
		this(size, null, true);
	}
	/**
	 * Creates a new room container object.
	 *
	 * @param contained the room that can be placed from this object
	 */
	public WGRoomContainer(final WGRoom contained) {
		this(contained, false);
	}
	/**
	 * Creates a new room container object.
	 *
	 * @param contained the room that can be placed from this object
	 * @param noDelete whether the room can be deleted
	 */
	public WGRoomContainer(final WGRoom contained, final boolean noDelete) {
		this(contained.getSize(), contained, noDelete);
	}
	private WGRoomContainer(final IntDimension3D size, final WGRoom room,
			final boolean noDelete) {
		this.noDelete = noDelete;
		this.room = room;
		this.size = size;
		if (room == null)
			subRooms = new ArrayList<WGRoomContainer>(32);
		else
			subRooms = null;
	}
	/**
	 * Adds the specified room as a subroom. Only works if this is not placeable.
	 *
	 * @param subroom the room container to add
	 */
	public void addSubroom(final WGRoomContainer subroom) {
		if (subRooms != null)
			subRooms.add(subroom);
	}
	/**
	 * Whether the room can be deleted.
	 *
	 * @return whether the room can be removed
	 */
	public boolean canDelete() {
		return !noDelete;
	}
	/**
	 * Deletes all subrooms.
	 */
	public void	clearSubrooms() {
		if (subRooms != null)
			subRooms.clear();
	}
	public int compareTo(WGRoomContainer o) {
		final IntDimension3D osize = o.getSize();
		final int answer;
		if (osize.depth > size.depth)
			answer = -1;
		else if (osize.depth < size.depth)
			answer = 1;
		else if (osize.width > size.width)
			answer = -1;
		else if (osize.width < size.width)
			answer = 1;
		else
			answer = 0;
		return answer;
	}
	/**
	 * Counts the number of subrooms stored under this node.
	 *
	 * @return the number of subrooms
	 */
	public int countRooms() {
		final int num;
		if (subRooms == null)
			num = 0;
		else
			num = subRooms.size();
		return num;
	}
	public boolean equals(Object other) {
		return other instanceof WGRoomContainer && compareTo((WGRoomContainer)other) == 0;
	}
	/**
	 * Gets the display name of this room container.
	 *
	 * @return the displayed text
	 */
	public String getName() {
		final String name;
		if (isPlaceable())
			name = room.getName();
		else
			name = size.depth + "x" + size.width;
		return name;
	}
	/**
	 * Gets the room this object contains.
	 *
	 * @return the room contained by this object, or null if it is a group
	 */
	public WGRoom getRoom() {
		return room;
	}
	/**
	 * Gets the subroom at the specified index.
	 *
	 * @param index the room index
	 * @return the sub-room stored at the given index, or null if this is a leaf
	 */
	public WGRoomContainer getRoomAt(final int index) {
		final WGRoomContainer out;
		if (subRooms == null)
			out = null;
		else
			out = subRooms.get(index);
		return out;
	}
	/**
	 * Gets a list of the subrooms contained in this container.
	 *
	 * @return the subroom list, or null if none are stored
	 */
	public List<WGRoomContainer> getRoomList() {
		return subRooms;
	}
	/**
	 * Gets the size of this object.
	 *
	 * @return the size of the described room or rooms
	 */
	public IntDimension3D getSize() {
		return size;
	}
	/**
	 * Finds the index of the specified room (for tree api compat)
	 *
	 * @param subroom the sub-room to look up
	 * @return the index, or -1 if not found / no list
	 */
	public int indexOf(final WGRoomContainer subroom) {
		final int index;
		if (subRooms == null)
			index = -1;
		else
			index = subRooms.indexOf(subroom);
		return index;
	}
	/**
	 * Determines whether this object can be placed on the map.
	 *
	 * @return whether the object can be placed
	 */
	public boolean isPlaceable() {
		return room != null;
	}
	public String toString() {
		return getClass().getSimpleName() + "[size=" + size + "]";
	}
}