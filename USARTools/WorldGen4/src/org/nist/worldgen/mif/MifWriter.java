package org.nist.worldgen.mif;

import org.nist.worldgen.*;
import org.nist.worldgen.t3d.*;
import org.nist.worldgen.xml.*;
import java.awt.*;
import java.awt.geom.*;
import java.awt.image.BufferedImage;
import java.io.*;

/**
 * Handles I/O to MIF and MID files. If a map must be parsed, T3DIO is up to the task.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class MifWriter implements Constants {
	/**
	 * Generates a preview image for the given room.
	 *
	 * @param src the file to read for the preview
	 * @param room the room for which the preview should be made
	 * @return a preview image of that room's BSP
	 */
	public static Image generatePreview(final File src, final WGRoom room) {
		Image preview;
		final double ratio = G_GRID / U_BLOCK; final IntDimension3D size = room.getSize();
		// Set image size to proper room size (if areas exceed bounds, they will be clipped)
		final int width = size.width * G_GRID, height = size.depth * G_GRID;
		try {
			// Generate a MIF
			final MifContainer mif = MifWriter.mifFromMap(T3DIO.readMap(src));
			final Area closed = mif.getClosedArea().createTransformedArea(
				AffineTransform.getScaleInstance(ratio, -ratio));
			// Create and render to image
			preview = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
			final Graphics2D g = (Graphics2D)preview.getGraphics();
			g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
				RenderingHints.VALUE_ANTIALIAS_ON);
			g.translate(width / 2, height / 2);
			// This shouldn't take too long unless the room is excessively complicated
			g.setColor(G_OBJECT);
			g.fill(closed);
			g.dispose();
		} catch (Exception e) {
			preview = null;
		}
		return preview;
	}
	/**
	 * Creates a MIF file from an Unreal map.
	 *
	 * @param map the map to convert
	 * @return a MIF representing the map
	 */
	public static MifContainer mifFromMap(final UTMap map) {
		final MifContainer mif = new MifContainer();
		final Rectangle3D extents3 = map.getBounds();
		final double groundMin = extents3.getZ() + UnitsConverter.lengthToUU(
			WGConfig.getDouble("WorldGen.GroundTolerance")),
			ramp = UnitsConverter.lengthToUU(WGConfig.getDouble("WorldGen.MaxRampHeight")),
			clear = UnitsConverter.lengthToUU(WGConfig.getDouble("WorldGen.MinClearance")) +
				extents3.getZ();
		BrushActor brush; Rectangle3D bounds; Shape model; Point3D pt; String type;
		for (Actor act : map.listObjects(Actor.class)) {
			bounds = act.getBounds(); type = act.getType().toLowerCase();
			if (type.equals("brush")) {
				// BSP
				brush = (BrushActor)act;
				model = BoundedMifObject.from3DObject(brush.getModel(), brush.getLocation());
				switch (brush.getCSGOperation()) {
				case CSGOperation.CSG_ADD:
					if (bounds.getHeight() <= ramp && bounds.getZ() <= groundMin)
						// Ramp
						mif.add(new BoundedMifObject(brush.getName(), "Ramp", model));
					else if (bounds.getZ() < clear)
						// Wall
						mif.markWall(model);
					break;
				case CSGOperation.CSG_SUBTRACT:
					// Open space
					mif.markClear(model);
					break;
				default:
					// Deintersect, etc. cannot be handled here
				}
			} else if ((!type.endsWith("volume") || M_OUTPUT_VOLUMES) &&
				(!type.endsWith("light") || M_OUTPUT_LIGHTS) &&
				((!type.equals("pathnode") && !type.equals("playerstart")) ||
					M_OUTPUT_NODES)) {
				// Useful actor not excluded by the rules
				pt = UnitsConverter.lengthVectorFromUU(act.getLocation());
				mif.add(new PointMifObject(act.getName(), act.getType(), new Point2D.Double(
					pt.getY(), pt.getX())));
			}
		}
		return mif;
	}
	/**
	 * Writes the MIF and MID files to the file system.
	 *
	 * @param dir the directory where the map was stored
	 * @param baseName the name of the T3D that was written
	 * @param container the MIF file to write
	 * @throws java.io.IOException if an I/O error occurs
	 */
	public static void writeMIF(final File dir, final String baseName,
			final MifContainer container) throws IOException {
		final File mif = new File(dir, baseName + ".mif");
		final File mid = new File(dir, baseName + ".mid");
		OutputStream os = new BufferedOutputStream(new FileOutputStream(mif), 1024);
		PrintWriter out = new PrintWriter(new OutputStreamWriter(os, "ASCII"));
		container.toMIF(out);
		out.flush();
		out.close();
		if (out.checkError())
			throw new IOException("Error when writing MIF file");
		os = new BufferedOutputStream(new FileOutputStream(mid), 1024);
		out = new PrintWriter(new OutputStreamWriter(os, "ASCII"));
		container.toMID(out);
		out.flush();
		out.close();
		if (out.checkError())
			throw new IOException("Error when writing MID file");
	}
}