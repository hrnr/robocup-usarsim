package org.nist.worldgen.t3d;

import org.nist.worldgen.*;

/**
 * Creates instances of brushes with commonly used properties.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class BrushFactory {
	private static final UTReference[] NO_TEXTURES = new UTReference[6];

	/**
	 * Creates an array that will use the specified input texture for all sides of a 6DOP.
	 *
	 * @param texture the texture to use
	 * @return an array of that texture repeated the required number of times
	 */
	public static UTReference[] allTextures(final UTReference texture) {
		final UTReference[] textures = new UTReference[6];
		for (int i = 0; i < textures.length; i++)
			textures[i] = texture;
		return textures;
	}
	/**
	 * Creates a 6DOP (think: rectangular prism) of the specified size.
	 *
	 * @param type the class of volume/brush to spawn
	 * @param name the brush name
	 * @param size the brush location and dimensions
	 * @param csgOp the CSG operation to perform
	 * @param textures the textures to apply
	 * @return a 6DOP brush with the specified parameters
	 */
	public static BrushActor create6DOP(final Class<? extends BrushActor> type,
			final String name, final Rectangle3D size, final int csgOp,
			UTReference[] textures) {
		BrushActor brush;
		if (textures == null)
			textures = NO_TEXTURES;
		try {
			brush = UTObjectFactory.spawn(type, name);
		} catch (SpawnException e) {
			// Can this happen?
			brush = null;
		}
		if (brush != null) {
			brush.setCSGOperation(csgOp);
			final Brush model = brush.getModel();
			// Origin is the bottom front left, max is the top right back
			final Point3D origin = new Point3D(size.getX(), size.getY(), size.getZ());
			final Point3D max = new Point3D(size.getMaxX(), size.getMaxY(), size.getMaxZ());
			Point3D tl, br;
			// FRONT
			br = origin.getLocation();
			br.setY(max.getY());
			tl = origin.getLocation();
			tl.setZ(max.getZ());
			model.addComponent(createRectangle(textures[0], tl, br));
			// LEFT
			tl = max.getLocation();
			tl.setY(origin.getY());
			model.addComponent(createRectangle(textures[1], tl, origin));
			// BACK
			br = origin.getLocation();
			br.setX(max.getX());
			model.addComponent(createRectangle(textures[2], max, br));
			// RIGHT
			tl = max.getLocation();
			tl.setX(origin.getX());
			br = max.getLocation();
			br.setZ(origin.getZ());
			model.addComponent(createRectangle(textures[3], tl, br));
			// TOP
			tl = max.getLocation();
			tl.setY(origin.getY());
			br = max.getLocation();
			br.setX(origin.getX());
			model.addComponent(createRectangle(textures[5], tl, br));
			// BOTTOM
			tl = max.getLocation();
			tl.setZ(origin.getZ());
			model.addComponent(createRectangle(textures[4], tl, origin));
		}
		return brush;
	}
	/**
	 * Creates a 6DOP (think: rectangular prism) of the specified size.
	 *
	 * @param name the brush name
	 * @param size the brush location and dimensions
	 * @param csgOp the CSG operation to perform
	 * @param textures an array of 6 textures to be applied to the 4 walls, floor, and
	 * ceiling respectively
	 * @return a 6DOP brush with the specified parameters
	 */
	public static BrushActor create6DOP(final String name, final Rectangle3D size,
			final int csgOp, final UTReference[] textures) {
		return create6DOP(BrushActor.class, name, size, csgOp, textures);
	}
	/**
	 * Creates a new default brush.
	 *
	 * @return the default brush
	 */
	public static BrushActor createDefaultBrush() {
		final BrushActor def = create6DOP("Default_Brush", new Rectangle3D(Point3D.ORIGIN,
			new Dimension3D(256.0, 256.0, 256.0)), CSGOperation.CSG_NONE, null);
		def.getModel().setName("Brush");
		def.putAttribute("Layer", "Cube");
		return def;
	}
	/**
	 * Creates a polygon using the specified texture and points. Put vertices in CCW order!
	 *
	 * @param texture the texture to use
	 * @param vertex vertices to create the polygon
	 * @return a polygon with the specified vertices
	 */
	public static Brush.Polygon createPolygon(final UTReference texture,
			final Point3D... vertex) {
		final Brush.Polygon poly = new Brush.Polygon(texture, Brush.Polygon.DEFAULT_FLAGS);
		for (Point3D vert : vertex)
			poly.addVertex(vert);
		return poly;
	}
	// Only useful for polygons parallel to the axes!
	protected static Brush.Polygon createRectangle(final UTReference texture,
			final Point3D tlIn, final Point3D brIn) {
		Point3D tl = tlIn.getLocation(), br = brIn.getLocation(), tr, bl;
		if (Utils.doubleEquals(tl.getY(), br.getY())) {
			// Left/Right
			tr = new Point3D(br.getX(), tl.getY(), tl.getZ());
			bl = new Point3D(tl.getX(), br.getY(), br.getZ());
		} else {
			tr = new Point3D(tl.getX(), br.getY(), tl.getZ());
			bl = new Point3D(br.getX(), tl.getY(), br.getZ());
		}
		return createPolygon(texture, tr, br, bl, tl);
	}
}