package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

/**
 * Class which can paint a representation of a World object on screen.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class WorldPainter extends JComponent implements Constants {
	/**
	 * A polygon representing the directional arrow.
	 */
	private static final Polygon UP_ICON = new Polygon(new int[] { 4, 0, -4, 0 },
		new int[] { 5, -5, 5, 3 }, 4);

	/**
	 * Draws the specified room.
	 *
	 * @param g the graphics context on which to draw
	 * @param room the room to draw
	 * @param bg the background color to use
	 * @param fg the foreground color to use
	 * @param world the world containing the room
	 */
	public static void drawRoom(final Graphics g, final WGRoomInstance room, final Color bg,
			final Color fg, final World world) {
		final int rw = room.getWidth(), rh = room.getDepth(), rx = room.getY(),
			ry = room.getX();
		final int w = rw * G_GRID, h = rh * G_GRID, x = rx * G_GRID, y = ry * G_GRID;
		g.setColor(bg);
		g.fillRect(x, y, w, h);
		g.setColor(fg);
		g.drawRect(x, y, w, h);
		if (room.getRoom().isHallway()) {
			// Try to merge (creates new rectangle every time, so modify is safe)
			final Rectangle bounds = room.getBounds();
			bounds.x = Math.max(0, bounds.x - 1);
			bounds.y = Math.max(0, bounds.y - 1);
			bounds.width = Math.min(bounds.x + world.getWidth(), bounds.width + 2);
			bounds.height = Math.min(bounds.y + world.getDepth(), bounds.height + 2);
			g.setColor(bg);
			for (WGRoomInstance item : world.findRoomsIn(bounds))
				if (item.getRoom().isHallway()) {
					// Find out which side it touches on and kick down the wall
					if (item.getX() + item.getDepth() == room.getX() &&
							vertIntersects(room, item))
						g.drawLine(x + 1, y, x + w - 1, y);
					else if (item.getX() == room.getX() + room.getDepth() &&
							vertIntersects(room, item))
						g.drawLine(x + 1, y + h, x + w - 1, y + h);
					else if (item.getY() + item.getWidth() == room.getY() &&
							horizIntersects(room, item))
						g.drawLine(x, y + 1, x, y + h - 1);
					else if (item.getY() == room.getY() + room.getWidth() &&
							horizIntersects(room, item))
						g.drawLine(x + w, y + 1, x + w, y + h - 1);
				}
		} else {
			// Icon indicating north
			final Graphics2D tg = (Graphics2D)g.create();
			final Image prev = room.getRoom().getPreviewImage();
			tg.translate(x + w / 2, y + h / 2);
			tg.rotate(-room.getRotation() * Math.PI / 2);
			if (prev != null)
				tg.drawImage(prev, -prev.getWidth(null) / 2, -prev.getHeight(null) / 2, null);
			tg.setColor(G_BG_OVERLAY);
			tg.fill(UP_ICON);
			tg.dispose();
		}
	}
	/**
	 * Finds the world coordinates of a given mouse location.
	 *
	 * @param x the mouse x
	 * @param y the mouse y
	 * @return the World grid coordinates of that point
	 */
	public static Point getWorldCoordinates(final int x, final int y) {
		return new Point(y / G_GRID, x / G_GRID);
	}
	/**
	 * Checks to see if the two rooms intersect horizontally.
	 *
	 * @param one the first room
	 * @param two the second room
	 * @return whether the rooms intersect horizontally (Y dimension)
	 */
	public static boolean horizIntersects(final WGRoomInstance one, final WGRoomInstance two) {
		final int xd = one.getX() + one.getDepth();
		return (one.getX() >= two.getX() && one.getX() < two.getX() + two.getDepth()) ||
			(xd > two.getX() && xd <= two.getX() + two.getDepth());
	}
	/**
	 * Rotates the specified rooms by the given amount.
	 *
	 * @param rooms the rooms to rotate
	 * @param ccw whether the rotation is CCW (true) or CW (false)
	 */
	public static void rotateRooms(final Iterable<WGRoomInstance> rooms, final boolean ccw) {
		final int amount;
		if (ccw)
			amount = 3;
		else
			amount = 1;
		for (WGRoomInstance room : rooms)
			if (!room.getRoom().isHallway())
				room.setRotation((room.getRotation() + amount) % 4);
	}
	/**
	 * Checks to see if the two rooms intersect vertically.
	 *
	 * @param one the first room
	 * @param two the second room
	 * @return whether the rooms intersect vertically (X dimension)
	 */
	public static boolean vertIntersects(final WGRoomInstance one, final WGRoomInstance two) {
		final int yw = one.getY() + one.getWidth();
		return (one.getY() >= two.getY() && one.getY() < two.getY() + two.getWidth()) ||
			(yw > two.getY() && yw <= two.getY() + two.getWidth());
	}

	private final Rule leftHeader;
	private final Map<WGRoomInstance, WGRoomInstance> moveRooms;
	private WGRoomInstance placing;
	private final Set<WGRoomInstance> selectedRooms;
	private WGItem selectedItem;
	private Rectangle selection;
	private final Rule topHeader;
	private World world;

	/**
	 * Creates a new, empty world painter.
	 */
	public WorldPainter() {
		leftHeader = new Rule(SwingConstants.VERTICAL);
		placing = null;
		moveRooms = new HashMap<WGRoomInstance, WGRoomInstance>(32);
		selectedItem = null;
		selectedRooms = new HashSet<WGRoomInstance>(32);
		selection = null;
		topHeader = new Rule(SwingConstants.HORIZONTAL);
		world = null;
		findSize();
		setFocusable(true);
		setOpaque(true);
		final SelectionManagerListener events = new SelectionManagerListener();
		addMouseListener(events);
		addMouseMotionListener(events);
	}
	/**
	 * Adds an action listener to this component.
	 *
	 * @param listener the listener for actions (place, rotate...)
	 */
	public void addActionListener(final ActionListener listener) {
		listenerList.add(ActionListener.class, listener);
	}
	/**
	 * Selects all rooms residing within the specified rectangle of grid coordinates.
	 *
	 * @param toSelect the rectangle which selects all rooms at least partially inside it
	 */
	public void addSelectionRectangle(final Rectangle toSelect) {
		final WGRoomInstance[] items = world.findRoomsIn(toSelect);
		Collections.addAll(selectedRooms, items);
		repaint();
	}
	/**
	 * Clears the list of selected rooms.
	 */
	public void clearSelection() {
		selectedRooms.clear();
		repaint();
		fireActionCommand("select", 0);
	}
	private void dropSelection() {
		if (!moveRooms.isEmpty()) {
			// Encroach check!
			boolean encroach = false;
			for (WGRoomInstance room : moveRooms.values())
				encroach |= world.encroaches(room);
			final Collection<WGRoomInstance> output;
			if (encroach) {
				output = moveRooms.keySet();
				getToolkit().beep();
			} else {
				output = moveRooms.values();
				world.setDirty(true);
			}
			world.getRooms().addAll(output);
			world.rebuildDoors(output);
			selectedRooms.clear();
			selectedRooms.addAll(output);
			moveRooms.clear();
		}
	}
	private void findSize() {
		final Dimension dims;
		if (world == null)
			dims = new Dimension(1, 1);
		else
			dims = new Dimension(G_GRID * world.getWidth(), G_GRID * world.getDepth());
		setPreferredSize(dims);
		setMinimumSize(dims);
		leftHeader.findSize();
		topHeader.findSize();
	}
	private void fireActionCommand(final String command, final int modifiers) {
		final ActionEvent evt = new ActionEvent(this, ActionEvent.ACTION_PERFORMED, command,
			modifiers);
		for (ActionListener listener : listenerList.getListeners(ActionListener.class))
			listener.actionPerformed(evt);
	}
	/**
	 * Gets the object currently being placed.
	 *
	 * @return the object being placed
	 */
	public WGRoomInstance getPlacing() {
		return placing;
	}
	/**
	 * Gets a collection of the currently selected rooms.
	 *
	 * @return the rooms currently selected
	 */
	public Collection<WGRoomInstance> getSelectedRooms() {
		return selectedRooms;
	}
	/**
	 * Gets the header for the top part of the window.
	 *
	 * @return the top header
	 */
	public JComponent getTopHeader() {
		return topHeader;
	}
	/**
	 * Gets the header for the left part of the window.
	 *
	 * @return the left header
	 */
	public JComponent getLeftHeader() {
		return leftHeader;
	}
	private boolean itemSelect(final int x, final int y) {
		boolean found = false;
		for (WGItem item : world.getItems())
			if (item.getSelectionBounds().contains(x, y)) {
				selectedItem = item;
				found = true;
				break;
			}
		if (found)
			fireActionCommand("select", 0);
		return found;
	}
	private void moveSelection(final int dx, final int dy) {
		Point loc;
		for (Map.Entry<WGRoomInstance, WGRoomInstance> ent :
				moveRooms.entrySet()) {
			loc = ent.getKey().getLocation();
			ent.getValue().setLocation(loc.x + dx, loc.y + dy);
		}
	}
	private void moveToMouse(final int x, final int y) {
		final Point loc = getWorldCoordinates(x, y);
		placing.setX(loc.x);
		placing.setY(loc.y);
		repaint();
	}
	public void paint(Graphics g2) {
		final Graphics2D g = (Graphics2D)g2;
		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		g.setColor(G_BG_INVALID);
		g.fillRect(0, 0, getWidth(), getHeight());
		if (world != null) {
			g.setColor(G_BG);
			g.fillRect(0, 0, world.getWidth() * G_GRID, world.getDepth() * G_GRID);
			g.setColor(G_GRID_COLOR);
			// Render grid
			for (int i = 0; i <= world.getWidth(); i++)
				g.drawLine(i * G_GRID, 0, i * G_GRID, world.getDepth() * G_GRID);
			for (int i = 0; i <= world.getDepth(); i++)
				g.drawLine(0, i * G_GRID, world.getWidth() * G_GRID, i * G_GRID);
			// Render symmetrical rooms
			for (WGRoomInstance room : world)
				if (room.getRoom().isHallway() && !selectedRooms.contains(room))
					drawRoom(g, room, G_GREEN, G_GREEN_BORDER, world);
			// Render asymmetrical rooms
			for (WGRoomInstance room : world)
				if (!room.getRoom().isHallway() && !selectedRooms.contains(room))
					drawRoom(g, room, G_BLUE, G_BLUE_BORDER, world);
			// Render selected rooms
			if (moveRooms.isEmpty())
				for (WGRoomInstance room : selectedRooms)
					drawRoom(g, room, G_SELECT, G_SELECT_BORDER, world);
			else {
				for (WGRoomInstance room : moveRooms.values())
					if (world.encroaches(room))
						drawRoom(g, room, G_RED, G_RED_BORDER, world);
					else
						drawRoom(g, room, G_SELECT, G_SELECT_BORDER, world);
			}
			// Render placing room
			if (placing != null && placing.getX() >= 0 && placing.getY() >= 0
				&& placing.getX() < world.getDepth() && placing.getY() < world.getWidth()) {
				if (world.encroaches(placing))
					drawRoom(g, placing, G_RED, G_RED_BORDER, world);
				else
					drawRoom(g, placing, G_SELECT, G_SELECT_BORDER, world);
			}
			// Render items
			for (WGItem item : world.getItems())
				item.paint(g, item == selectedItem);
			// Render select rectangle
			if (selection != null && selection.width != 0 && selection.height != 0) {
				final Rectangle drawRect = new Rectangle(selection);
				if (drawRect.width < 0) {
					drawRect.x += drawRect.width;
					drawRect.width *= -1;
				}
				if (drawRect.height < 0) {
					drawRect.y += drawRect.height;
					drawRect.height *= -1;
				}
				g.setColor(G_RED_BORDER);
				g.draw(drawRect);
			}
		}
	}
	private void pickupSelection() {
		// Ditch the rooms from the world(!)
		for (WGRoomInstance room : selectedRooms)
			moveRooms.put(room, new WGRoomInstance(room));
		world.removeDoors(selectedRooms);
		selectedRooms.clear();
		world.getRooms().removeAll(moveRooms.keySet());
		// Copy instance
		selectedRooms.addAll(moveRooms.values());
	}
	private Point placeRoomAt(final Point loc, Point lastLoc) {
		if (loc.x >= 0 && loc.y >= 0 && loc.x < world.getDepth() &&
				loc.y < world.getWidth() && !loc.equals(lastLoc)) {
			lastLoc = loc;
			fireActionCommand("place", KeyEvent.SHIFT_MASK);
		}
		return lastLoc;
	}
	/**
	 * Selects the object at the specified point in mouse coordinates.
	 *
	 * @param x the x coordinate
	 * @param y the y coordinate
	 * @param add whether the item should be added (if false, the selection will be cleared
	 * before the item is added)
	 */
	public void pointSelect(final int x, final int y, final boolean add) {
		final Point target = getWorldCoordinates(x, y);
		if (target.x >= 0 && target.y >= 0 && target.x < world.getDepth() &&
			target.y < world.getWidth()) {
			final WGRoomInstance[] rooms = Utils.findRooms(world.getRooms(), target);
			final WGRoomInstance room;
			if (rooms.length == 1) {
				room = rooms[0];
				if (!add)
					selectedRooms.clear();
				if (selectedRooms.contains(room))
					selectedRooms.remove(room);
				else
					selectedRooms.add(room);
				repaint();
			} else
				selectedRooms.clear();
		}
		fireActionCommand("select", 0);
	}
	/**
	 * Selects all rooms partially or wholly inside the given rectangle in mouse coordinates.
	 *
	 * @param target the rectangle to search
	 * @param add whether the item(s) should be added
	 */
	public void rectangleSelect(final Rectangle target, final boolean add) {
		final Rectangle select = new Rectangle(target);
		if (select.width < 0) {
			select.x += select.width;
			select.width *= -1;
		}
		if (select.height < 0) {
			select.y += select.height;
			select.height *= -1;
		}
		final Point start = getWorldCoordinates(select.x, select.y);
		final Point end = getWorldCoordinates(select.x + select.width,
			select.y + select.height);
		select.x = Math.max(0, Math.min(start.x, world.getDepth()));
		select.y = Math.max(0, Math.min(start.y, world.getWidth()));
		// Rectangle sizes do not include their bottom right!?
		select.width = end.x - select.x + 1;
		select.height = end.y - select.y + 1;
		if (!add)
			selectedRooms.clear();
		addSelectionRectangle(select);
		fireActionCommand("select", 0);
	}
	/**
	 * Removes an action listener from the listener list.
	 *
	 * @param listener the listener which will no longer receive events
	 */
	public void removeActionListener(final ActionListener listener) {
		listenerList.remove(ActionListener.class, listener);
	}
	/**
	 * Deletes the selected rooms or items from the world.
	 */
	public void removeSelected() {
		if (world != null) {
			if (selectedItem == null) {
				for (WGRoomInstance room : selectedRooms)
					world.removeRoom(room);
				world.removeDoors(selectedRooms);
				clearSelection();
			} else {
				world.removeItem(selectedItem);
				selectedItem = null;
				repaint();
				fireActionCommand("select", 0);
			}
		}
	}
	/**
	 * Rotates the selected rooms in place.
	 *
	 * @param ccw whether the rotation is to be counterclockwise
	 */
	public void rotateInPlace(final boolean ccw) {
		if (!selectedRooms.isEmpty()) {
			// Drop rooms from the world
			for (WGRoomInstance room : selectedRooms)
				moveRooms.put(room, new WGRoomInstance(room));
			world.getRooms().removeAll(selectedRooms);
			world.removeDoors(selectedRooms);
			rotateRooms(moveRooms.values(), ccw);
			boolean encroach = false;
			// Encroach check
			for (WGRoomInstance room : moveRooms.values())
				encroach |= world.encroaches(room);
			if (encroach)
				getToolkit().beep();
			else {
				// Add back again
				selectedRooms.clear();
				selectedRooms.addAll(moveRooms.values());
				world.setDirty(true);
			}
			world.getRooms().addAll(selectedRooms);
			world.rebuildDoors(selectedRooms);
			moveRooms.clear();
		}
	}
	/**
	 * Selects all rooms in the world. If all rooms are selected, selects none.
	 */
	public void selectAll() {
		if (world != null) {
			final int size = selectedRooms.size();
			selectedRooms.clear();
			if (size < world.count())
				selectedRooms.addAll(world.getRooms());
			repaint();
			fireActionCommand("select", 0);
		}
	}
	/**
	 * Changes the room being placed.
	 *
	 * @param room the room to place
	 */
	public void setPlacing(final WGRoom room) {
		if (room == null)
			placing = null;
		else if (placing == null || !placing.getRoom().equals(room)) {
			placing = new WGRoomInstance(room, -1, -1, FACE_NORTH);
			final Point point = getMousePosition();
			if (point != null)
				moveToMouse(point.x, point.y);
		}
		repaint();
	}
	/**
	 * Changes the selected world.
	 *
	 * @param newWorld the new world to show
	 */
	public void setWorld(final World newWorld) {
		world = newWorld;
		setPlacing(null);
		findSize();
		revalidate();
		repaint();
	}
	public void update(Graphics g) {
		paint(g);
	}

	/**
	 * Paints custom row and column headers (if desired)
	 */
	private class Rule extends JComponent {
		private int direction;

		/**
		 * Creates a new Rule with the specified direction.
		 *
		 * @param direction either HORIZONTAL or VERTICAL (SwingConstants)
		 */
		public Rule(int direction) {
			this.direction = direction;
			setOpaque(true);
		}
		/**
		 * Resizes the component to fit the painter.
		 */
		public void findSize() {
			final Dimension size = new Dimension(WorldPainter.this.getPreferredSize());
			if (direction == SwingConstants.HORIZONTAL)
				size.height = 20;
			else if (direction == SwingConstants.VERTICAL)
				size.width = 20;
			setPreferredSize(size);
			setMinimumSize(size);
			revalidate();
			repaint();
		}
		public void paint(Graphics g2) {
			final Graphics2D g = (Graphics2D)g2;
			final int w = getWidth(), h = getHeight(); int sw;
			final FontMetrics fm = g2.getFontMetrics(); String str;
			g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
				RenderingHints.VALUE_ANTIALIAS_ON);
			g.setColor(G_BG_OVERLAY);
			g.fillRect(0, 0, w, h);
			g.setColor(G_BG);
			if (world != null) {
				if (direction == SwingConstants.HORIZONTAL) {
					g.drawLine(0, h, world.getWidth() * G_GRID, h);
					for (int i = 0; i <= world.getWidth(); i++) {
						g.drawLine(i * G_GRID, h - 5, i * G_GRID, h);
						if (i < world.getWidth()) {
							str = Integer.toString(i);
							sw = SwingUtilities.computeStringWidth(fm, str);
							g.drawString(str, i * G_GRID + (G_GRID - sw) / 2 + 1, h - 3);
						}
					}
				} else if (direction == SwingConstants.VERTICAL) {
					g.drawLine(w, 0, w, world.getDepth() * G_GRID);
					for (int i = 0; i <= world.getDepth(); i++) {
						g.drawLine(w - 5, i * G_GRID, w, i * G_GRID);
						if (i < world.getDepth()) {
							str = Integer.toString(i);
							sw = SwingUtilities.computeStringWidth(fm, str);
							g.drawString(str, w - 2 - sw, i * G_GRID - 1 + (G_GRID +
								fm.getHeight()) / 2);
						}
					}
				} else
					g.drawString("INVALID DIRECTION", 2, h);
			}
		}
		public void update(Graphics g) {
			paint(g);
		}
	}

	/**
	 * Manages the selection and placement due to mouse events.
	 */
	private class SelectionManagerListener extends MouseInputAdapter {
		private Point lastLoc;
		private boolean pickupReady;
		private Point startLoc;

		/**
		 * Creates a new selection manager.
		 */
		public SelectionManagerListener() {
			lastLoc = null;
			pickupReady = false;
			startLoc = null;
		}
		public void mouseMoved(MouseEvent e) {
			if (world != null) {
				if (placing != null)
					moveToMouse(e.getX(), e.getY());
				else {
					final Point target = getWorldCoordinates(e.getX(), e.getY());
					final WGRoomInstance[] found = Utils.findRooms(world.getRooms(), target);
					if (found.length > 0)
						setToolTipText(Utils.generateTooltip(found[0].getRoom()));
					else
						setToolTipText(null);
				}
			}
		}
		public void mouseExited(MouseEvent e) {
			if (placing != null) {
				placing.setX(-1);
				placing.setY(-1);
				repaint();
			}
		}
		public void mouseDragged(MouseEvent e) {
			mouseMoved(e);
			if (world != null) {
				final Point loc;
				if (placing == null) {
					final int dx, dy;
					if (pickupReady) {
						loc = getWorldCoordinates(e.getX(), e.getY());
						final WGRoomInstance[] list = Utils.findRooms(selectedRooms, loc);
						if (list.length > 0) {
							startLoc = loc;
							pickupSelection();
						} else
							selection = new Rectangle(e.getX(), e.getY(), 0, 0);
						pickupReady = false;
					} else if (selection != null) {
						dx = e.getX() - selection.x;
						dy = e.getY() - selection.y;
						selection.setBounds(selection.x, selection.y, dx, dy);
					} else if (!moveRooms.isEmpty()) {
						loc = getWorldCoordinates(e.getX(), e.getY());
						moveSelection(loc.x - startLoc.x, loc.y - startLoc.y);
					}
					repaint();
				} else if (lastLoc != null)
					lastLoc = placeRoomAt(getWorldCoordinates(e.getX(), e.getY()), lastLoc);
			}
		}
		public void mousePressed(MouseEvent e) {
			selectedItem = null;
			pickupReady = false;
			if (e.getButton() == MouseEvent.BUTTON1 && world != null) {
				final Point hit = getWorldCoordinates(e.getX(), e.getY());
				if (placing == null) {
					if (itemSelect(e.getX(), e.getY()))
						clearSelection();
					else
						pickupReady = true;
				} else {
					fireActionCommand("place", e.getModifiers());
					lastLoc = hit;
				}
			}
			repaint();
		}
		public void mouseReleased(MouseEvent e) {
			pickupReady = false;
			if (selectedItem == null) {
				if (e.getButton() == MouseEvent.BUTTON1 && world != null) {
					final boolean add = e.isShiftDown() || e.isControlDown();
					if (placing != null) {
						if (!e.isShiftDown())
							fireActionCommand("drop", e.getModifiers());
						lastLoc = null;
					} else if (!moveRooms.isEmpty())
						dropSelection();
					else if (selection != null)
						rectangleSelect(selection, add);
					else
						pointSelect(e.getX(), e.getY(), add);
					requestFocusInWindow();
					// Remove rectangles
					startLoc = null;
					selection = null;
				} else if (placing != null && world != null)
					fireActionCommand("rotate", e.getModifiers());
				else if (!moveRooms.isEmpty())
					rotateRooms(selectedRooms, e.isShiftDown());
				else if (world != null)
					rotateInPlace(e.isShiftDown());
			}
			repaint();
		}
	}
}