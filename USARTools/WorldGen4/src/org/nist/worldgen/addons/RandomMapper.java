package org.nist.worldgen.addons;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.*;
import java.util.*;

/**
 * Creates a random map using a Manhattan-style grid. This generator is astoundingly stupid;
 * upgrades to make the map more realistic are welcome!
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class RandomMapper implements Constants {
	/**
	 * Creates a random map inside the given world.
	 *
	 * @param world the world to map
	 * @param available the rooms available for use
	 */
	public static void map(final World world, final WGRoomDB available) {
		final RandomMapper map = new RandomMapper(world, available);
		map.borders();
		map.manhat();
		map.createDoors();
	}

	private final WGRoom hallway;
	private final int offset;
	private final List<WGRoom> rooms;
	private final WGRoomInstance[][] use;
	private final World world;

	private RandomMapper(final World world, final WGRoomDB db) {
		// Find offset
		if (world.getDepth() > D_SIZE_TWO && world.getWidth() > D_SIZE_TWO)
			offset = 2;
		else if (world.getDepth() > D_SIZE_ONE && world.getWidth() > D_SIZE_ONE)
			offset = 1;
		else
			offset = 0;
		hallway = db.getHallway();
		rooms = new ArrayList<WGRoom>(db.count());
		// Add all rooms to the list and sort descending by area
		for (WGRoom room : db)
			if (room != hallway)
				rooms.add(room);
		Collections.sort(rooms, new RoomAreaComparator());
		// Clear world to empty
		use = new WGRoomInstance[world.getDepth()][world.getWidth()];
		this.world = world;
		world.reset();
	}
	private void addRoom(final WGRoomInstance inst) {
		final int x = inst.getX(), y = inst.getY();
		world.addRoom(inst);
		// Mark as full to speed up future passes
		for (int i = x; i < x + inst.getDepth(); i++)
			for (int j = y; j < y + inst.getWidth(); j++)
				use[i][j] = inst;
	}
	private void addRoomsHoriz(final int row, final boolean up, final double prob) {
		// Compute offset of the room's touching side to the desired row
		final int dir = up ? 1 : -1, rotation = up ? FACE_NORTH : FACE_SOUTH;
		WGRoomInstance inst; WGRoom room; int j, coord;
		// Look for a room that could fit the bill
		for (int i = offset; i < world.getWidth() - offset; i++)
			if (use[row + dir][i] == null && Math.random() < prob) {
				// Search for usable room (this will eventually hit or fail)
				j = 0;
				do {
					room = randRoom();
					// Room must be moved by amount corresponding to direction
					coord = row + dir;
					if (!up)
						coord -= room.getSize().depth - 1;
					inst = new WGRoomInstance(room, coord, i, rotation);
					j++;
				} while (isBlocked(inst) && j < 50);
				if (!isBlocked(inst))
					addRoom(inst);
			}
	}
	private void addRoomsVert(final int col, final boolean right, final double prob) {
		// Compute offset of the room's touching side to the desired column
		final int dir = right ? -1 : 1, rotation = right ? FACE_WEST : FACE_EAST;
		WGRoomInstance inst; WGRoom room; int j, coord;
		// Look for a room that could fit the bill
		for (int i = offset; i < world.getDepth() - offset; i++)
			if (use[i][col + dir] == null && Math.random() < prob) {
				// Search for usable room (this will eventually hit or fail)
				j = 0;
				do {
					room = randRoom();
					// Room must be moved by amount corresponding to direction
					coord = col + dir;
					if (right)
						coord -= room.getSize().depth - 1;
					inst = new WGRoomInstance(room, i, coord, rotation);
					j++;
				} while (isBlocked(inst) && j < 50);
				if (!isBlocked(inst))
					addRoom(inst);
			}
	}
	private void borders() {
		// Adds hallway borders at the appropriate depth
		for (int i = offset; i < world.getWidth() - offset; i++) {
			// Horiz
			addRoom(new WGRoomInstance(hallway, offset, i, FACE_NORTH));
			addRoom(new WGRoomInstance(hallway, world.getDepth() - 1 - offset, i, FACE_NORTH));
		}
		for (int i = offset + 1; i < world.getDepth() - offset - 1; i++) {
			// Vert
			addRoom(new WGRoomInstance(hallway, i, offset, FACE_NORTH));
			addRoom(new WGRoomInstance(hallway, i, world.getWidth() - 1 - offset, FACE_NORTH));
		}
		if (offset > 0) {
			// Add rooms around the edge if needed
			addRoomsHoriz(offset, false, D_OUTSIDE_PROB);
			addRoomsVert(offset, true, D_OUTSIDE_PROB);
			addRoomsHoriz(world.getDepth() - offset - 1, true, D_OUTSIDE_PROB);
			addRoomsVert(world.getWidth() - offset - 1, false, D_OUTSIDE_PROB);
		}
	}
	private boolean checkCount(final WGDoor door, final int max) {
		// Checks to see if the door connects a hallway and a room with more than maxDoors
		final WGRoomInstance one, two;
		if (door.getDirection() % 2 == 0) {
			// Facing up/down
			one = use[door.xAsInt() - 1][door.yAsInt()];
			two = use[door.xAsInt()][door.yAsInt()];
		} else {
			// Facing left/right
			one = use[door.xAsInt()][door.yAsInt() - 1];
			two = use[door.xAsInt()][door.yAsInt()];
		}
		return (world.countDoorsAround(one) > max || world.countDoorsAround(two) > max) &&
			(one.getRoom().isHallway() || two.getRoom().isHallway());
	}
	private boolean checkSingle(final WGDoor door, final boolean checkHallway) {
		// Checks to see if the door is the only door to one or both of its rooms
		final WGRoomInstance one, two;
		if (door.getDirection() % 2 == 0) {
			// Facing up/down
			one = use[door.xAsInt() - 1][door.yAsInt()];
			two = use[door.xAsInt()][door.yAsInt()];
		} else {
			// Facing left/right
			one = use[door.xAsInt()][door.yAsInt() - 1];
			two = use[door.xAsInt()][door.yAsInt()];
		}
		// If checkHallway is true, marks the door as a singleton if one of the rooms is
		// a hallway
		return world.countDoorsAround(one) < 2 || world.countDoorsAround(two) < 2 ||
			(checkHallway && (one.getRoom().isHallway() || two.getRoom().isHallway()));
	}
	private void createDoors() {
		// Add most available doors (only door items can be in the world now)
		world.rebuildDoors(world);
		for (int i = 0; i < 10; i++)
			Collections.shuffle(world.getItems());
		Iterator<WGItem> it = world.getItems().iterator();
		while (it.hasNext())
			// If matching rooms have at least one door, apply rule
			if (!checkSingle((WGDoor)it.next(), false) && Math.random() >= D_1DOOR_PROB)
				it.remove();
		// Remove some more doors between the rooms
		it = world.getItems().iterator();
		while (it.hasNext())
			// If neither room is a hallway (and each has at least one door), apply rule
			if (!checkSingle((WGDoor)it.next(), true) && Math.random() >= D_2DOOR_PROB)
				it.remove();
		// Remove excess connections from a room to the hallway
		it = world.getItems().iterator();
		while (it.hasNext())
			if (checkCount((WGDoor)it.next(), D_MAX_DOORS))
				it.remove();
	}
	private boolean isBlocked(final WGRoomInstance instance) {
		// Faster check for blocking than encroaches()!
		final int x = instance.getX(), y = instance.getY();
		boolean used = false;
		for (int i = x; i < x + instance.getDepth(); i++)
			for (int j = y; j < y + instance.getWidth(); j++)
				used |= i < 0 || j < 0 || i >= world.getDepth() || j >= world.getWidth() ||
					use[i][j] != null;
		return used;
	}
	private void manhat() {
		final List<Command> execute = new LinkedList<Command>();
		// Create the Manhattan style grid
		int start = offset + Utils.randInt(D_VI_MIN, D_VI_MAX);
		for (int x = start; x < world.getDepth() - 2 - offset; x += Utils.randInt(D_VI_MIN,
				D_VI_MAX + 1)) {
			// Rows
			execute.add(new Command(x, 0, true, false));
			execute.add(new Command(x, 0, false, false));
		}
		start = offset + Utils.randInt(D_HI_MIN, D_HI_MAX);
		for (int y = start; y < world.getWidth() - 2 - offset; y += Utils.randInt(D_HI_MIN,
				D_HI_MAX + 1)) {
			// Columns
			execute.add(new Command(0, y, true, true));
			execute.add(new Command(0, y, false, true));
		}
		// Thoroughly randomize the command list
		for (int i = 0; i < 10; i++)
			Collections.shuffle(execute);
		for (Command cmd : execute)
			cmd.execute();
		// Add the remaining rooms around the borders
		addRoomsHoriz(offset, true, D_HALL_PROB);
		addRoomsVert(offset, false, D_HALL_PROB);
		addRoomsHoriz(world.getDepth() - offset - 1, false, D_HALL_PROB);
		addRoomsVert(world.getWidth() - offset - 1, true, D_HALL_PROB);
	}
	private WGRoom randRoom() {
		// Gets a random room (this deliberately favors the larger rooms)
		final int index = Utils.randInt(0, 3 * rooms.size() / 2);
		return rooms.get(index % rooms.size());
	}

	/**
	 * Represents a possible fill-in action. Other than the borders and their rooms,
	 * the other hallways and their rooms could be built in random orders!
	 */
	protected class Command {
		private final boolean direction;
		private final boolean hall;
		private final int x;
		private final int y;

		protected Command(final int x, final int y, final boolean hall,
				final boolean direction) {
			// Direction: true = vertical, false = horizontal
			this.direction = direction;
			this.hall = hall;
			this.x = x;
			this.y = y;
		}
		protected void execute() {
			if (hall) {
				// Add hallway
				if (direction) {
					// Add vertical hallway
					for (int xx = offset; xx < world.getDepth() - offset; xx++)
						if (use[xx][y] == null)
							addRoom(new WGRoomInstance(hallway, xx, y, FACE_NORTH));
				} else {
					// Add horizontal hallway
					for (int yy = offset; yy < world.getWidth() - offset; yy++)
						if (use[x][yy] == null)
							addRoom(new WGRoomInstance(hallway, x, yy, FACE_NORTH));
				}
			} else {
				// Add rooms
				if (direction) {
					// Add vertical rooms
					addRoomsVert(y, true, D_HALL_PROB);
					addRoomsVert(y, false, D_HALL_PROB);
				} else {
					// Add horizontal rooms
					addRoomsHoriz(x, true, D_HALL_PROB);
					addRoomsHoriz(x, false, D_HALL_PROB);
				}
			}
		}
	}

	/**
	 * Sorts rooms by area.
	 */
	protected static class RoomAreaComparator implements Comparator<WGRoom> {
		public int compare(WGRoom o1, WGRoom o2) {
			final IntDimension3D size1 = o1.getSize(), size2 = o2.getSize();
			return size1.width * size1.height - size2.width * size2.height;
		}
	}
}