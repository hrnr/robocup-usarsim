package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import org.nist.worldgen.addons.*;
import org.nist.worldgen.t3d.*;
import org.xml.sax.*;
import java.awt.*;
import java.io.*;
import java.util.*;
import java.util.List;

/**
 * Class representing a world containing rooms. Generally user-constructed or made randomly.
 *
 * @author Stephen Carlson (NIST)
 * @version 4
 */
public class World implements XMLSerializable, XMLParseable, Iterable<WGRoomInstance>,
		Constants {
	private transient WGRoomDB data;
	private int depth;
	private transient boolean dirty;
	private transient int height;
	private final List<WGItem> items;
	private transient final Set<String> missingRooms;
	private String name;
	private final List<WGRoomInstance> rooms;
	private int width;

	private World() {
		missingRooms = new TreeSet<String>();
		items = new ArrayList<WGItem>(256);
		rooms = new ArrayList<WGRoomInstance>(256);
		dirty = false;
		height = 0;
	}
	/**
	 * Constructs a world from a file.
	 *
	 * @param file the File to read for world data
	 * @param lookup a database where rooms can be looked up
	 * @throws IOException if an I/O error occurs while reading
	 */
	public World(final File file, final WGRoomDB lookup) throws IOException {
		this();
		data = lookup;
		depth = width = 0;
		name = file.getName();
		Utils.parse(file, this);
		if (depth == 0 || width == 0)
			throw new IOException("No world in specified file");
		calculateHeight();
		data = null;
	}
	/**
	 * Creates a new world, optionally filling with random rooms.
	 *
	 * @param params the parameters used to construct the world
	 */
	public World(final WorldCreationParams params, final WGRoomDB lookup) {
		this();
		depth = params.getDepth();
		name = params.getName();
		width = params.getWidth();
		if (params.isRandom())
			RandomMapper.map(this, lookup);
	}
	/**
	 * Creates an empty world using parameters.
	 *
	 * @param width the world width
	 * @param depth the world depth
	 * @param name the world's name
	 */
	public World(final int width, final int depth, final String name) {
		this();
		this.depth = depth;
		this.name = name;
		this.width = width;
	}
	/**
	 * Adds an item to this world.
	 *
	 * @param item the item to add
	 */
	public void addItem(final WGItem item) {
		items.add(item);
		dirty = true;
	}
	/**
	 * Places a room in this world.
	 *
	 * @param test the room instance to add
	 */
	public void addRoom(final WGRoomInstance test) {
		if (encroaches(test))
			throw new IllegalArgumentException("Room intersects another or is out of bounds");
		rooms.add(new WGRoomInstance(test));
		calculateHeight();
		dirty = true;
	}
	/**
	 * Calculates the height
	 */
	public void calculateHeight() {
		int maxHeight = 0;
		for (WGRoomInstance room : rooms)
			maxHeight = Math.max(maxHeight, room.getHeight());
		height = maxHeight;
	}
	/**
	 * Checks to see if the specified room is in use by this world.
	 *
	 * @param room the room to check
	 * @return whether it is in use
	 */
	public boolean containsRoom(final WGRoom room) {
		boolean found = false;
		for (WGRoomInstance instance : rooms)
			if (instance.getRoom().equals(room)) {
				found = true;
				break;
			}
		return found;
	}
	/**
	 * Counts the number of doors which surround the given room, which is presumably part of
	 * this world object.
	 *
	 * @param room the room to count
	 * @return how many doors it has
	 */
	public int countDoorsAround(final WGRoomInstance room) {
		DoorInfo di; int count = 0;
		for (int i = 0; i < room.getRoom().getPerimeter(); i++) {
			di = nthDoor(room, i);
			if (di != null && getDoorAt(di.getX(), di.getY(), di.getDirection()) != null)
				count++;
		}
		return count;
	}
	/**
	 * Gets the number of rooms in this world.
	 *
	 * @return the number of rooms in the world (does not include items)
	 */
	public int count() {
		return rooms.size();
	}
	/**
	 * Checks for missing rooms.
	 *
	 * @return an array of all the missing rooms, or an empty array if everything is OK
	 */
	public String[] findMissingRooms() {
		final String[] out;
		if (missingRooms.size() > 0) {
			out = missingRooms.toArray(new String[missingRooms.size()]);
			missingRooms.clear();
		} else
			out = new String[0];
		return out;
	}
	/**
	 * Checks if a room instance leaves the bounds of the map or encroaches on another room
	 * already in this world.
	 *
	 * @param testRoom the instance to check
	 * @return whether the instance can be properly placed
	 */
	public boolean encroaches(final WGRoomInstance testRoom) {
		boolean encroach = false;
		if (testRoom.getX() < 0 || testRoom.getY() < 0 ||
				testRoom.getX() + testRoom.getDepth() > depth ||
				testRoom.getY() + testRoom.getWidth() > width)
			encroach = true;
		encroach = encroach || findRoomsIn(testRoom.getBounds()).length > 0;
		return encroach;
	}
	/**
	 * Finds all rooms that are at least partially enclosed in the given rectangle.
	 *
	 * @param rectangle the rectangle to look for rooms
	 * @return an array of all rooms found, or an empty array if no rooms are found inside
	 * the given boundaries
	 */
	public WGRoomInstance[] findRoomsIn(final Rectangle rectangle) {
		return Utils.findRooms(rooms, rectangle);
	}
	public void fromTag(String tagName, Attributes attributes) throws SAXException {
		try {
			if (tagName.equals("world")) {
				depth = Integer.parseInt(attributes.getValue("depth"));
				name = Utils.xmlDecode(attributes.getValue("name"));
				width = Integer.parseInt(attributes.getValue("width"));
			} else if (tagName.equals("room")) {
				final String fileName = Utils.xmlDecode(attributes.getValue("name"));
				final WGRoom room = data.getRoom(fileName);
				final int x = Integer.parseInt(attributes.getValue("x"));
				final int y = Integer.parseInt(attributes.getValue("y"));
				final int theta = Integer.parseInt(attributes.getValue("theta"));
				if (room != null) {
					final WGRoomInstance instance = new WGRoomInstance(room, x, y, theta);
					if (encroaches(instance))
						throw new SAXException("Room encroaches on another room");
					rooms.add(instance);
				} else
					missingRooms.add(fileName);
			} else if (tagName.equals("door")) {
				final int x = Integer.parseInt(attributes.getValue("x"));
				final int y = Integer.parseInt(attributes.getValue("y"));
				final int direction = Integer.parseInt(attributes.getValue("direction"));
				items.add(new WGDoor(x, y, direction));
			}
		} catch (NumberFormatException e) {
			throw new SAXException("Invalid value specified", e);
		}
	}
	/**
	 * Gets the world's width.
	 *
	 * @return the world width in grid units (Unreal Y axis)
	 */
	public int getWidth() {
		return width;
	}
	/**
	 * Gets the world's depth.
	 *
	 * @return the world depth in grid units (Unreal X axis)
	 */
	public int getDepth() {
		return depth;
	}
	/**
	 * Checks to see if there is a door at the given location.
	 *
	 * @param x the x coordinate
	 * @param y the y coordinate
	 * @param direction the direction to check
	 * @return whether a door exists there already
	 */
	public WGDoor getDoorAt(final int x, final int y, final int direction) {
		WGDoor door, found = null;
		for (WGItem item : items)
			if (item instanceof WGDoor) {
				door = (WGDoor)item;
				if (door.xAsInt() == x && door.yAsInt() == y && door.getDirection() % 2 ==
						direction % 2) {
					found = door;
					break;
				}
			}
		return found;
	}
	/**
	 * Gets the world's height.
	 *
	 * @return the world height in grid units (Unreal Z axis)
	 */
	public int getHeight() {
		return height;
	}
	/**
	 * Gets the world's size.
	 *
	 * @return a dimension describing the world's size in grid units
	 */
	public IntDimension3D getSize() {
		return new IntDimension3D(getDepth(), getWidth(), getHeight());
	}
	/**
	 * Gets the world name.
	 *
	 * @return the world's name
	 */
	public String getName() {
		return name;
	}
	/**
	 * Gets the items in this world.
	 *
	 * @return the items stored in the world
	 */
	public List<WGItem> getItems() {
		return items;
	}
	/**
	 * Gets the rooms stored in this world.
	 *
	 * @return a list of rooms in the world
	 */
	public List<WGRoomInstance> getRooms() {
		return rooms;
	}
	/**
	 * Checks to see if the world has been modified.
	 *
	 * @return whether the world is dirty
	 */
	public boolean isDirty() {
		return dirty;
	}
	public Iterator<WGRoomInstance> iterator() {
		return rooms.iterator();
	}
	// Get the location of the nth door of a given room
	private DoorInfo nthDoor(final WGRoomInstance room, final int n) {
		final int rx = room.getX(), ry = room.getY(), rw = room.getWidth(),
			rd = room.getDepth();
		final DoorInfo out; Point pt = null; final int direction;
		if (n < rw) {
			if (rx > 0)
				pt = new Point(rx, ry + n);
			direction = FACE_NORTH;
		} else if (n < rw + rd) {
			if (ry < getWidth() - 1)
				pt = new Point(rx + n - rw, ry + rw);
			direction = FACE_EAST;
		} else if (n < 2 * rw + rd) {
			if (rx < getDepth() - 1)
				pt = new Point(rx + rd, ry + 2 * rw + rd - n - 1);
			direction = FACE_SOUTH;
		} else if (n < 2 * rw + 2 * rd) {
			if (ry > 0)
				pt = new Point(rx + 2 * rw + 2 * rd - n - 1, ry);
			direction = FACE_WEST;
		} else
			direction = -1;
		if (pt != null)
			out = new DoorInfo(pt.x, pt.y, direction);
		else
			out = null;
		return out;
	}
	/**
	 * Rebuilds the doors around the given rooms.
	 *
	 * @param which the rooms around which to construct doors
	 */
	public void rebuildDoors(final Iterable<WGRoomInstance> which) {
		DoorInfo di;
		for (WGRoomInstance room : which)
			for (int i = 0; i < room.getRoom().getPerimeter(); i++) {
				di = nthDoor(room, i);
				if (di != null) {
					final WGRoomInstance next = roomAt(di.getNextX(), di.getNextY());
					if (getDoorAt(di.getX(), di.getY(), di.getDirection()) == null &&
							next != null && (!next.getRoom().isHallway() ||
							!room.getRoom().isHallway()))
						addItem(new WGDoor(di.getX(), di.getY(), di.getDirection()));
				}
			}
	}
	/**
	 * Removes the doors around the given rooms.
	 *
	 * @param which the rooms around which to delete doors
	 */
	public void removeDoors(final Iterable<WGRoomInstance> which) {
		DoorInfo di;
		for (WGRoomInstance room : which)
			for (int i = 0; i < room.getRoom().getPerimeter(); i++) {
				di = nthDoor(room, i);
				if (di != null)
					removeItem(getDoorAt(di.getX(), di.getY(), di.getDirection()));
			}
	}
	/**
	 * Removes the specified item from the world.
	 *
	 * @param toRemove the item to remove
	 */
	public void removeItem(final WGItem toRemove) {
		if (toRemove != null && items.remove(toRemove))
			dirty = true;
	}
	/**
	 * Removes the specified room from the world.
	 *
	 * @param toRemove the room instance to remove
	 */
	public void removeRoom(final WGRoomInstance toRemove) {
		if (toRemove != null && rooms.remove(toRemove)) {
			calculateHeight();
			dirty = true;
		}
	}
	/**
	 * Removes everything from the world.
	 */
	public void reset() {
		items.clear();
		rooms.clear();
		setDirty(true);
	}
	private WGRoomInstance roomAt(final int x, final int y) {
		final WGRoomInstance[] found = Utils.findRooms(rooms, new Point(x, y));
		final WGRoomInstance instance;
		if (found.length > 0)
			instance = found[0];
		else
			instance = null;
		return instance;
	}
	/**
	 * Changes the dirty flag.
	 *
	 * @param dirty whether the world is dirty (modified)
	 */
	public void setDirty(final boolean dirty) {
		this.dirty = dirty;
	}
	public String toString() {
		return name + " (" + width + "x" + depth + ")";
	}
	/**
	 * Converts this world to a T3D file.
	 *
	 * @param output the location for the T3D text
	 * @param params the parameters to use during export
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if an error occurs during conversion
	 */
	public void toT3D(final File output, final WorldExportParams params) throws IOException,
			T3DException {
		T3DIO.writeWorld(output, this, params);
	}
	public void toXML(PrintWriter out, int indent) {
		Utils.addTag(out, indent, "world", "depth", depth, "width", width, "name", name);
		for (WGRoomInstance room : rooms)
			room.toXML(out, indent + 1);
		for (WGItem item : items)
			item.toXML(out, indent + 1);
		Utils.addTag(out, indent, "/world");
	}

	/**
	 * Information about doors found from nthDoor()
	 */
	private static class DoorInfo {
		protected final int x;
		protected final int y;
		protected final int direction;
		protected final int nextX;
		protected final int nextY;

		protected DoorInfo(final int x, final int y, final int direction) {
			this.direction = direction;
			this.x = x;
			this.y = y;
			switch (direction) {
			case FACE_NORTH:
				nextX = x - 1; nextY = y;
				break;
			case FACE_WEST:
				nextX = x; nextY = y - 1;
				break;
			default:
				nextX = x; nextY = y;
			}
		}
		protected int getX() {
			return x;
		}
		protected int getY() {
			return y;
		}
		protected int getDirection() {
			return direction;
		}
		protected int getNextX() {
			return nextX;
		}
		protected int getNextY() {
			return nextY;
		}
	}
}