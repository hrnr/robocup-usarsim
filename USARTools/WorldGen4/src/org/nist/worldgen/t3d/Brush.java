package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import org.nist.worldgen.mif.*;
import java.io.*;
import java.util.*;

/**
 * Represents the model Brush used to define geometry of every Brush.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class Brush extends UTObject implements MIF3DObject {
	protected final List<Polygon> polygons;

	/**
	 * Creates a new brush model.
	 *
	 * @param name the model name
	 */
	public Brush(final String name) {
		super(name);
		polygons = new ArrayList<Polygon>(8);
	}
	/**
	 * Adds a polygon to this brush model.
	 *
	 * @param obj the polygon to add
	 */
	public void addComponent(final UTObject obj) {
		if (obj instanceof Polygon) {
			polygons.add((Polygon)obj);
			obj.setParent(this);
		} else
			throw new IllegalArgumentException("Only polygons can be added to a Brush");
	}
	public UTObject copyOf() {
		final Brush brush = new Brush(getName());
		for (Polygon gon : polygons)
			brush.addComponent(gon.copyOf());
		return copyCustom(brush);
	}
	/**
	 * Gets the bounds of this Brush.
	 *
	 * @return an axis-oriented rectangle bounding the brush's geometry
	 */
	public Rectangle3D getBounds() {
		final Iterator<Polygon> it = polygons.iterator(); final Rectangle3D rect;
		if (it.hasNext()) {
			rect = it.next().getBounds();
			while (it.hasNext())
				rect.add(it.next().getBounds());
		} else
			rect = Rectangle3D.EMPTY_RECT;
		return rect;
	}
	/**
	 * Gets the number of polygons in this brush model.
	 *
	 * @return the number of polygons
	 */
	public int getPolygonCount() {
		return polygons.size();
	}
	public Iterable<? extends MifPolygon> getPolygons() {
		return polygons;
	}
	public Dimension3D getSize() {
		return getBounds().getSize();
	}
	/**
	 * Removes all polygons from this brush model.
	 */
	public void reset() {
		polygons.clear();
	}
	public String toString() {
		final StringBuilder out = new StringBuilder(512);
		final Iterator<Polygon> it = polygons.iterator();
		out.append(getType());
		out.append('[');
		out.append("count=");
		out.append(getPolygonCount());
		out.append(':');
		while (it.hasNext()) {
			out.append(it.next());
			if (it.hasNext())
				out.append(';');
		}
		out.append(']');
		return out.toString();
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		UTUtils.addIndent(out, indent, "Begin Brush Name=", getName());
		UTUtils.addIndent(out, indent + 1, "Begin PolyList");
		for (Polygon polygon : polygons)
			polygon.toUnrealText(out, indent + 2, utCompatMode);
		UTUtils.addIndent(out, indent + 1, "End PolyList");
		UTUtils.addIndent(out, indent, "End Brush");
	}
	public void transform(Point3D offset, Rotator3D rotate, Point3D rotateAbout) {
		for (Polygon polygon : polygons)
			polygon.transform(offset, rotate, rotateAbout);
	}

	/**
	 * A class representing an individual polygon in the brush geometry.
	 */
	public static class Polygon extends UTObject implements MifPolygon {
		/**
		 * Flags used by default in UDK.
		 */
		public static final int DEFAULT_FLAGS = 3584;
		private static final UTReference DEFAULT_MATERIAL = new UTReference(null,
			"EngineMaterials", "DefaultMaterial");

		protected final UTReference texture;
		protected final int flags;
		protected final int link;
		protected double panU;
		protected double panV;
		protected Point3D texU;
		protected Point3D texV;
		protected final double resolution;
		protected final List<Point3D> vertex;

		/**
		 * Creates a new polygon with the default resolution and no link index.
		 *
		 * @param tex the texture to use
		 * @param flags the Unreal flags denoting polygon states
		 */
		public Polygon(final UTReference tex, final int flags) {
			this(tex, flags, 0.0, -1);
		}
		/**
		 * Creates a new polygon with the specified settings.
		 *
		 * @param tex the texture to use
		 * @param flags the Unreal flags denoting polygon states
		 * @param res the texture resolution
		 * @param link the link index
		 */
		public Polygon(final UTReference tex, final int flags, final double res,
				final int link) {
			super("Polygon");
			if (tex == null || tex.equals(DEFAULT_MATERIAL))
				texture = null;
			else
				texture = tex;
			this.flags = flags;
			this.link = link;
			panU = 0.0;
			panV = 0.0;
			texU = Point3D.ORIGIN;
			texV = Point3D.ORIGIN;
			resolution = res;
			vertex = new ArrayList<Point3D>(8);
		}
		/**
		 * Adds a vertex to this polygon.
		 *
		 * @param vert the vertex to add
		 */
		public void addVertex(final Point3D vert) {
			vertex.add(vert);
		}
		public UTObject copyOf() {
			final Polygon gon = new Polygon(texture, flags, resolution, link);
			gon.setPan(panU, panV);
			gon.setTexU(texU);
			gon.setTexV(texV);
			for (Point3D vert : vertex)
				gon.addVertex(vert.getLocation());
			return copyCustom(gon);
		}
		/**
		 * Gets the bounds of this Polygon.
		 *
		 * @return an axis-oriented rectangle bounding the polygon
		 */
		public Rectangle3D getBounds() {
			final Iterator<Point3D> it = vertex.iterator(); final Rectangle3D rect;
			if (it.hasNext()) {
				rect = new Rectangle3D(it.next(), Dimension3D.NO_SIZE);
				while (it.hasNext())
					rect.add(it.next());
			} else
				rect = Rectangle3D.EMPTY_RECT;
			return rect;
		}
		public Dimension3D getSize() {
			return getBounds().getSize();
		}
		public Iterator<Point3D> iterator() {
			return vertex.iterator();
		}
		/**
		 * Removes all vertices from this polygon.
		 */
		public void reset() {
			vertex.clear();
		}
		/**
		 * Changes the texture pan of this polygon.
		 *
		 * @param panU the new U pan
		 * @param panV the new V pan
		 */
		public void setPan(final double panU, final double panV) {
			this.panU = panU;
			this.panV = panV;
		}
		/**
		 * Changes the texture U coordinate of this polygon.
		 *
		 * @param texU the new texture U coordinate
		 */
		public void setTexU(final Point3D texU) {
			this.texU = texU;
		}
		/**
		 * Changes the texture V coordinate of this polygon.
		 *
		 * @param texV the new texture V coordinate
		 */
		public void setTexV(final Point3D texV) {
			this.texV = texV;
		}
		public String toString() {
			final StringBuilder out = new StringBuilder(512);
			final Iterator<Point3D> it = iterator(); Point3D pt;
			while (it.hasNext()) {
				pt = it.next();
				out.append(String.format("%.2f %.2f %.2f", pt.getX(), pt.getY(), pt.getZ()));
				if (it.hasNext())
					out.append(',');
			}
			return out.toString();
		}
		public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
			final StringBuilder attr = new StringBuilder(64);
			if (texture != null) {
				attr.append(" Texture=");
				attr.append(texture);
			}
			attr.append(String.format(" Flags=%d", flags));
			if (resolution > 0.0)
				attr.append(String.format(" ShadowMapScale=%.6f", resolution));
			if (link >= 0)
				attr.append(String.format(" Link=%d", link));
			UTUtils.addIndent(out, indent, "Begin Polygon", attr);
			// NOTE: Normal and Origin do not do anything!
			if (panU != 0.0 || panV != 0.0)
				UTUtils.addIndent(out, indent + 1, "Pan      ",
					String.format("U=%+013.6f V=%+013.6f", panU, panV));
			if (!texU.equals(Point3D.ORIGIN))
				UTUtils.addIndent(out, indent + 1, "TextureU ", texU.toCoordinateForm());
			if (!texV.equals(Point3D.ORIGIN))
				UTUtils.addIndent(out, indent + 1, "TextureV ", texV.toCoordinateForm());
			for (Point3D vert : vertex)
				UTUtils.addIndent(out, indent + 1, "Vertex   ", vert.toCoordinateForm());
			UTUtils.addIndent(out, indent, "End Polygon");
		}
		public void transform(Point3D offset, Rotator3D rotate, Point3D rotateAbout) {
			super.transform(offset, rotate, rotateAbout);
			texU = UTUtils.rotateVector(texU, rotate);
			texV = UTUtils.rotateVector(texV, rotate);
			for (Point3D vert : vertex) {
				// Subtract center of rotation from delta
				Point3D delta = new Point3D(vert.getX() - rotateAbout.getX(), vert.getY() -
					rotateAbout.getY(), vert.getZ() - rotateAbout.getZ());
				// Rotate around center
				delta = UTUtils.rotateVector(delta, rotate);
				// Add center of rotation back to delta
				delta.setLocation(delta.getX() + rotateAbout.getX(), delta.getY() +
					rotateAbout.getY(), delta.getZ() + rotateAbout.getZ());
				// Move object
				delta.setLocation(delta.getX() + offset.getX(), delta.getY() + offset.getY(),
					delta.getZ() + offset.getZ());
				vert.setLocation(delta);
			}
		}
	}
}