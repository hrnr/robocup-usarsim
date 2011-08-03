package org.nist.worldgen.mif;

import org.nist.worldgen.*;
import java.awt.Shape;
import java.awt.geom.*;
import java.io.*;
import java.util.*;

/**
 * Represents the contents of a MIF file.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class MifContainer implements Constants, Iterable<MifObject> {
	private final List<MifObject> objects;
	private final Area walls;

	/**
	 * Creates a new, empty MIF file with all areas initially passable.
	 */
	public MifContainer() {
		objects = new LinkedList<MifObject>();
		walls = new Area();
	}
	/**
	 * Adds the specified object to this MIF file.
	 *
	 * @param object the object to add
	 */
	public void add(final MifObject object) {
		objects.add(object);
		markClear(object.getGeometry());
	}
	/**
	 * Gets the areas unavailable for use.
	 *
	 * @return the areas marked as walls in this MIF
	 */
	public Area getClosedArea() {
		return walls;
	}
	public Iterator<MifObject> iterator() {
		return objects.iterator();
	}
	/**
	 * Marks the specified shape as an usable area. The shape is expanded slightly to cut back
	 * on round off errors.
	 *
	 * @param which the shape to mark off as a room
	 */
	public void markClear(final Shape which) {
		final Area area = new Area(which);
		if (!area.isEmpty()) {
			final Rectangle2D bounds = area.getBounds2D();
			final double dt = Utils.DOUBLE_TOLERANCE, tx = 1.0 + 10.0 * dt / bounds.getWidth(),
				ty = 1.0 + 10.0 * dt / bounds.getHeight(), cx = bounds.getCenterX(), cy =
				bounds.getCenterY();
			area.transform(AffineTransform.getTranslateInstance(-cx, -cy));
			area.transform(AffineTransform.getScaleInstance(tx, ty));
			area.transform(AffineTransform.getTranslateInstance(cx, cy));
			walls.subtract(area);
		}
	}
	/**
	 * Marks the specified shape as an unusable area.
	 *
	 * @param which the shape to mark off as a wall
	 */
	public void markWall(final Shape which) {
		walls.add(new Area(which));
	}
	/**
	 * Converts this MIF container to a MIF file.
	 *
	 * @param out the output stream to write the data
	 */
	public void toMIF(final PrintWriter out) {
		final Area free = new Area(MifUtils.growRect(walls.getBounds2D(),
			-Utils.DOUBLE_TOLERANCE));
		free.subtract(walls);
		MifUtils.writeHeader(out);
		MifUtils.writePolygon(out, free, Constants.M_COLOR_FREE);
		if (!walls.isEmpty())
			MifUtils.writePolygon(out, walls, M_COLOR_WALL);
		for (MifObject object : objects)
			object.toMIF(out);
	}
	/**
	 * Converts this MIF container to a MID file.
	 *
	 * @param out the output stream to write the data
	 */
	public void toMID(final PrintWriter out) {
		MifUtils.putObject(out, "CSG", "Room");
		if (!walls.isEmpty())
			MifUtils.putObject(out, "CSG", "Wall");
		for (MifObject object : objects)
			object.toMID(out);
	}
}