package org.nist.worldgen.mif;

import org.nist.worldgen.*;
import java.awt.*;
import java.awt.geom.*;
import java.io.*;
import java.util.*;

/**
 * Sophisticated polygon handling functions for the MIF writer 4.0.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class MifUtils implements Constants {
	/**
	 * Rapidly approximate the area of a shape. Generally useful for deleting round-off error
	 * shapes from the shape splitter.
	 *
	 * @param shape the shape to find the area (cannot contain curves)
	 * @return the approximate area of the shape
	 */
	private static double approxArea(final Shape shape) {
		double a = 0.0, x, y; int segType;
		double[] coords = new double[6];
		double startX = Double.NaN, startY = Double.NaN;
		Line2D segment = new Line2D.Double(Double.NaN, Double.NaN, Double.NaN, Double.NaN);
		for (PathIterator it = shape.getPathIterator(null); !it.isDone(); it.next()) {
			segType = it.currentSegment(coords);
			x = coords[0]; y = coords[1];
			switch (segType) {
			case PathIterator.SEG_CLOSE:
				segment.setLine(segment.getX2(), segment.getY2(), startX, startY);
				a += hexArea(segment);
				startX = startY = Double.NaN;
				segment.setLine(Double.NaN, Double.NaN, Double.NaN, Double.NaN);
				break;
			case PathIterator.SEG_LINETO:
				segment.setLine(segment.getX2(), segment.getY2(), x, y);
				a += hexArea(segment);
				break;
			case PathIterator.SEG_MOVETO:
				startX = x;
				startY = y;
				segment.setLine(Double.NaN, Double.NaN, x, y);
				break;
			default:
				throw new IllegalArgumentException("Shape contains curved segments");
			}
		}
		if (Double.isNaN(a))
			throw new IllegalArgumentException("Shape contains an open path");
		else
			return 0.5 * Math.abs(a);
	}
	/**
	 * Grows the rectangle by a tiny amount to cuts down on round-off error and avoid small
	 * slivers around the box.
	 *
	 * @param in the rectangle to expand
	 * @param amount how much to grow (or shrink) the rectangle
	 * @return a copy of the rectangle, ever so slightly bigger
	 */
	public static Rectangle2D growRect(final Rectangle2D in, final double amount) {
		double x = in.getX(), y = in.getY(), width = in.getWidth(), height = in.getHeight();
		x -= amount; y -= amount;
		width += 2 * amount; height += 2 * amount;
		return new Rectangle2D.Double(x, y, width, height);
	}
	private static double hexArea(final Line2D seg) {
		return seg.getX1() * seg.getY2() - seg.getX2() * seg.getY1();
	}
	/**
	 * Outputs the specified object as MID data.
	 *
	 * @param out the output stream to write the data
	 * @param name the object name
	 * @param desc the object description (type)
	 */
	public static void putObject(final PrintWriter out, final String name, final String desc) {
		out.print('"');
		out.print(desc);
		out.print("\", \"");
		out.print(name);
		out.print('"');
		if (M_FORCE_ROT)
			out.print(", 0, 0, 0");
		out.println();
	}
	private static void splitPolygon(final Area in, final Collection<Area> out,
			final double lastSplit) {
		// Check if there is more than one "border"
		final double[] values = new double[6];
		final Path2D interior = new Path2D.Double(Path2D.WIND_EVEN_ODD);
		final Collection<Area> found = new LinkedList<Area>();
		final Rectangle2D bounds = in.getBounds2D();
		boolean end = false; double area; Area test;
		// NOTE: Many kludgy fixes cut down on round off error! Test, test, test after changes!
		for (PathIterator it = in.getPathIterator(null); !it.isDone() && !end; it.next())
			switch (it.currentSegment(values)) {
			case PathIterator.SEG_MOVETO:
				interior.reset();
				interior.moveTo(values[0], values[1]);
				break;
			case PathIterator.SEG_CLOSE:
				interior.closePath();
				area = approxArea(interior);
				if (area > M_MIN_AREA) {
					// Check to see if the returned shape is a member of the parent shape
					test = new Area(interior);
					found.add(new Area(test));
					test.subtract(in);
					final double middle = interior.getBounds2D().getCenterX();
					if (!test.isEmpty() && !Utils.doubleEquals(lastSplit, middle)) {
						// Split required (do it by X coordinate)
						final Rectangle2D lhs = growRect(new Rectangle2D.Double(bounds.getX(),
							bounds.getY(), middle - bounds.getX(), bounds.getHeight()),
							Utils.DOUBLE_TOLERANCE);
						final Rectangle2D rhs = growRect(new Rectangle2D.Double(middle,
							bounds.getY(), bounds.getMaxX() - middle, bounds.getHeight()),
							Utils.DOUBLE_TOLERANCE);
						// Compute intersections and recursively check those
						final Area one = new Area(lhs);
						one.intersect(in);
						final Area two = new Area(rhs);
						two.intersect(in);
						splitPolygon(one, out, middle);
						splitPolygon(two, out, middle);
						end = true;
					}
				}
				break;
			case PathIterator.SEG_LINETO:
				interior.lineTo(values[0], values[1]);
				break;
			default:
				throw new UnsupportedOperationException("Curves cannot be written as MIF");
			}
		if (!end)
			out.addAll(found);
	}
	/**
	 * Writes the polygon in MIF form to the output stream.
	 *
	 * @param out the output stream to write the data
	 * @param toWrite the polygon to write
	 * @param color the color for areas inside the polygon
	 */
	public static void writePolygon(final PrintWriter out, final Shape toWrite,
			final int color) {
		final Collection<Area> areas = new LinkedList<Area>();
		splitPolygon(new Area(toWrite), areas, Double.MAX_VALUE);
		out.print("Region ");
		out.println(areas.size());
		for (Area area : areas)
			writePolygon(out, area);
		out.print("Brush (2, ");
		out.print(color);
		out.println(")");
		out.println();
	}
	private static int writePolygon(final PrintWriter out, final Shape toWrite) {
		final double[] values = new double[6];
		int len = 0;
		// Find length and invalid values now!
		for (PathIterator it = toWrite.getPathIterator(null); !it.isDone(); it.next())
			switch (it.currentSegment(values)) {
			case PathIterator.SEG_MOVETO:
			case PathIterator.SEG_LINETO:
				len++;
				break;
			case PathIterator.SEG_CLOSE:
				break;
			default:
				// I'm sorry, Dave, but I'm afraid that I can't let you do that.
				throw new UnsupportedOperationException("Curves cannot be written as MIF");
			}
		out.print("   ");
		out.println(len);
		// Output now
		for (PathIterator it = toWrite.getPathIterator(null); !it.isDone(); it.next())
			if (it.currentSegment(values) != PathIterator.SEG_CLOSE) {
				out.format("%.3f, %.3f", values[0], values[1]);
				out.println();
			}
		return len;
	}
	/**
	 * Writes the header for the MIF file.
	 *
	 * @param out the output stream to write the data
	 */
	public static void writeHeader(final PrintWriter out) {
		out.println("Version 450");
		out.println("Charset \"Neutral\"");
		out.println("Delimiter \",\"");
		out.println("Index 1");
		out.print("Columns ");
		if (M_FORCE_ROT)
			out.println(5);
		else
			out.println(2);
		out.println("   Description char(254)");
		out.println("   Name char(254)");
		if (M_FORCE_ROT) {
			out.println("   Roll float");
			out.println("   Pitch float");
			out.println("   Yaw float");
		}
		out.println("Data");
	}
}