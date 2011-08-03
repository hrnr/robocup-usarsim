package org.nist.worldgen.mif;

import org.nist.worldgen.*;
import java.awt.Shape;
import java.awt.geom.*;
import java.io.*;
import java.util.*;

/**
 * Represents ramps and other MIF objects that have a nonzero area.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class BoundedMifObject extends MifObject implements Constants {
	private static int compareCCW(final Point2D one, final Point2D two, final Point2D three) {
		final double det = (two.getX() - one.getX()) * (three.getY() - one.getY()) -
			(two.getY() - one.getY()) * (three.getX() - one.getX());
		final int result;
		if (det < 0.0)
			result = -1;
		else if (det > 0.0)
			result = 1;
		else
			result = 0;
		return result;
	}
	/**
	 * Finds the 2D representation of the given 3D geometry using BSP projection.
	 *
	 * @param object the object to project
	 * @param loc the location of the object's center in 3D space
	 * @return 2D planar geometry closely matching the object
	 */
	public static Shape from3DObject(final MIF3DObject object, final Point3D loc) {
		// This method works but only computes the bounding box
		/*Rectangle2D bounds = null;
		for (MifPolygon gon : object.getPolygons())
			for (Point3D point : gon) {
				cPoint = UnitsConverter.lengthVectorFromUU(point);
				if (bounds == null)
					bounds = new Rectangle2D.Double(cPoint.getY() + y, cPoint.getX() + x,
						0.0, 0.0);
				else
					bounds.add(new Point2D.Double(cPoint.getY() + y, cPoint.getX() + x));
			}
		return bounds;*/
		// MCP method from Graham's scan
		Point3D cPoint, origin = UnitsConverter.lengthVectorFromUU(loc);
		final double x = origin.getX(), y = origin.getY();
		final List<Point2D> pointsIn = new LinkedList<Point2D>();
		// Compile point list
		for (MifPolygon gon : object.getPolygons())
			for (Point3D point : gon) {
				cPoint = UnitsConverter.lengthVectorFromUU(point);
				pointsIn.add(new Point2D.Double(cPoint.getY() + y, cPoint.getX() + x));
			}
		// Select point with smallest y value
		final int n = pointsIn.size();
		Point2D ly = null;
		for (Point2D point : pointsIn)
			if (ly == null || point.getY() < ly.getY() || (Utils.doubleEquals(point.getY(),
					ly.getY()) && point.getX() < ly.getX()))
				ly = point;
		final Shape out;
		if (ly != null && n > 3) {
			// Array is non-empty and point array is large enough
			Collections.sort(pointsIn, new CCWSortComparator(ly));
			final Point2D[] points = new Point2D[n + 1];
			// Sort points by radial angle from the comparison point
			pointsIn.toArray(points);
			points[n] = points[0];
			// Loop through looking for points which "turn left" (vec 1 cross vec 2 < 0)
			int m = 1, i = m + 1;
			while (i < n) {
				while (compareCCW(points[m - 1], points[m], points[i]) <= 0)
					if (m == 1) {
						swap(points, i, m);
						i++;
					} else
						m--;
				m++;
				swap(points, i, m);
				i++;
			}
			// Compile output path from first M points
			final Path2D path = new Path2D.Double(Path2D.WIND_NON_ZERO);
			path.moveTo(points[0].getX(), points[0].getY());
			for (i = 1; i <= m; i++)
				path.lineTo(points[i].getX(), points[i].getY());
			path.closePath();
			out = path;
		} else if (n == 3) {
			// Create a simple triangle out of the points
			final Path2D path = new Path2D.Double(Path2D.WIND_NON_ZERO);
			final Iterator<Point2D> it = pointsIn.iterator();
			Point2D pt = it.next();
			path.moveTo(pt.getX(), pt.getY());
			while (it.hasNext()) {
				pt = it.next();
				path.lineTo(pt.getX(), pt.getY());
			}
			path.closePath();
			out = path;
		} else
			// Less than 3 points creates a line which has no area
			out = new Rectangle2D.Double(0.0, 0.0, 0.0, 0.0);
		return out;
	}
	private static void swap(final Point2D[] array, final int first, final int second) {
		final Point2D temp = array[first];
		array[first] = array[second];
		array[second] = temp;
	}

	private final Area area;

	/**
	 * Creates a new bounded MIF object.
	 *
	 * @param name the name of the object
	 * @param type the object's type (used in the "Description" MID field)
	 * @param bounds the object's geometric shape
	 */
	public BoundedMifObject(final String name, final String type, final Shape bounds) {
		super(name, type);
		area = new Area(bounds);
	}
	public Shape getGeometry() {
		return area;
	}
	public void toMID(PrintWriter out) {
		MifUtils.putObject(out, getName(), getType());
	}
	public void toMIF(PrintWriter out) {
		MifUtils.writePolygon(out, area, M_COLOR_RAMP);
	}

	/**
	 * Sorts points by polar angle with the specified point. This point must have a smaller y
	 * value than all coordinates or sorting might fail!
	 */
	protected static class CCWSortComparator implements Comparator<Point2D> {
		private final Point2D comparison;

		protected CCWSortComparator(final Point2D comparison) {
			this.comparison = comparison;
		}
		public int compare(Point2D o1, Point2D o2) {
			final double d1 = comparison.distance(o1), d2 = comparison.distance(o2);
			final int result;
			// Avoid div by 0 on same-point
			if (d1 <= 0.0 && d2 <= 0.0)
				result = 0;
			else if (d1 <= 0.0)
				result = -1;
			else if (d2 <= 0.0)
				result = 1;
			else {
				final double cos1 = (o1.getX() - comparison.getX()) / d1;
				final double cos2 = (o2.getX() - comparison.getX()) / d2;
				final double diff = cos2 - cos1;
				if (diff < 0.0)
					result = -1;
				else if (diff > 0.0)
					result = 1;
				else
					result = 0;
			}
			return result;
		}
	}
}