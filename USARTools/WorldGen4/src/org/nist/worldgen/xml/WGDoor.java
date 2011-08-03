package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import org.nist.worldgen.t3d.*;
import java.awt.*;
import java.io.*;

/**
 * Represents a door in the map.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class WGDoor extends WGItem implements Constants {
	private static void drawDoor(final Graphics g, final int x, final int y,
			final int direction, final boolean selected) {
		final int lw, lh; int nx = 2 * x, ny = 2 * y;
		switch (direction) {
		case FACE_NORTH:
		case FACE_SOUTH:
			lw = G_DOOR_WIDTH;
			lh = G_DOOR_HEIGHT;
			nx++;
			break;
		case FACE_EAST:
		case FACE_WEST:
			lw = G_DOOR_HEIGHT;
			lh = G_DOOR_WIDTH;
			ny++;
			break;
		default:
			throw new IllegalArgumentException("Bad direction " + direction);
		}
		if (selected)
			g.setColor(G_SELECT);
		else
			g.setColor(G_DOOR);
		g.fillRect((nx * G_GRID - lw) / 2, (ny * G_GRID - lh) / 2, lw, lh);
		if (selected)
			g.setColor(G_SELECT_BORDER);
		else
			g.setColor(G_DOOR_BORDER);
		g.drawRect((nx * G_GRID - lw) / 2, (ny * G_GRID - lh) / 2, lw, lh);
	}

	protected int direction;

	/**
	 * Creates a new door.
	 *
	 * @param x the door X coordinate
	 * @param y the door Y coordinate
	 * @param direction the door direction
	 */
	public WGDoor(final double x, final double y, final int direction) {
		super(x, y);
		if (x < 0.0 || y < 0.0)
			throw new IllegalArgumentException("X or Y is negative");
		this.direction = direction % 2;
	}
	public UTObject createT3D(Point3D origin, int id) {
		double xf = getX() * U_GRID, yf = getY() * U_GRID; final double w, d;
		final Dimension3D doorSize = UnitsConverter.sizeToUU(
			WGConfig.getDimension("WorldGen.DoorSize"));
		switch (direction) {
		case FACE_NORTH:
		case FACE_SOUTH:
			xf -= U_GRID / 2.0;
			d = doorSize.getDepth(); w = doorSize.getWidth();
			break;
		case FACE_EAST:
		case FACE_WEST:
			yf -= U_GRID / 2.0;
			w = doorSize.getDepth(); d = doorSize.getWidth();
			break;
		default:
			throw new IllegalArgumentException("Bad direction " + direction);
		}
		final Point3D center = new Point3D(origin.getX() - xf, origin.getY() + yf,
			origin.getZ() - (R_HEIGHT - doorSize.getHeight()) / 2.0);
		final Dimension3D size = new Dimension3D(d, w, doorSize.getHeight());
		final UTReference[] textures = new UTReference[6];
		textures[0] = textures[1] = textures[2] = textures[3] = new UTReference(
			WGConfig.getProperty("WorldGen.DoorWallMat"));
		textures[4] = new UTReference(WGConfig.getProperty("WorldGen.DoorFloorMat"));
		textures[5] = new UTReference(WGConfig.getProperty("WorldGen.DoorCeilMat"));
		return BrushFactory.create6DOP("Door_" + id, new Rectangle3D(center, size),
			CSGOperation.CSG_SUBTRACT, textures);
	}
	/**
	 * Gets the direction of this door.
	 *
	 * @return one of the constants FACE_ describing the door direction
	 */
	public int getDirection() {
		return direction;
	}
	public Rectangle getSelectionBounds() {
		final int lw, lh; int nx = 2 * yAsInt(), ny = 2 * xAsInt();
		switch (direction) {
		case FACE_NORTH:
		case FACE_SOUTH:
			lw = G_DOOR_WIDTH;
			lh = G_DOOR_HEIGHT;
			nx++;
			break;
		case FACE_EAST:
		case FACE_WEST:
			lw = G_DOOR_HEIGHT;
			lh = G_DOOR_WIDTH;
			ny++;
			break;
		default:
			throw new IllegalArgumentException("Bad direction " + direction);
		}
		return new Rectangle((nx * G_GRID - lw) / 2, (ny * G_GRID - lh) / 2, lw, lh);
	}
	public void paint(Graphics2D g, boolean selected) {
		drawDoor(g, yAsInt(), xAsInt(), getDirection(), selected);
	}
	public void toXML(PrintWriter out, int indent) {
		Utils.addTag(out, indent, "door", "x", xAsInt(), "y", yAsInt(), "direction",
			getDirection(), "/");
	}
	/**
	 * Gets the x coordinate in the grid.
	 *
	 * @return the grid X coordinate
	 */
	public int xAsInt() {
		return (int)Math.round(getX());
	}
	/**
	 * Gets the y coordinate in the grid.
	 *
	 * @return the grid Y coordinate
	 */
	public int yAsInt() {
		return (int)Math.round(getY());
	}
}