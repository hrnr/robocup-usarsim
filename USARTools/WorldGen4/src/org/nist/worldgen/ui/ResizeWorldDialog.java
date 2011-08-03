package org.nist.worldgen.ui;

import org.nist.worldgen.Constants;
import org.nist.worldgen.xml.*;
import java.awt.*;

/**
 * Prompts the user for the new size to resize a world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class ResizeWorldDialog extends AbstractDialog implements Constants {
	private final int oldDepth;
	private final int oldWidth;

	/**
	 * Creates a new dialog to prompt for the template size.
	 *
	 * @param parent the component managing this dialog
	 * @param existing the existing world (to be resized)
	 */
	public ResizeWorldDialog(final Component parent, final World existing) {
		super(parent);
		oldDepth = existing.getDepth();
		oldWidth = existing.getWidth();
	}
	protected String getDialogPrompt() {
		return "New World Size (Grid Units)";
	}
	protected Field[] getFormFields() {
		final Field<Integer> depth = new Field<Integer>(TYPE_INT, "Depth", 2, U_MAX_DIM);
		depth.setLabel("World Size (depth,width): ");
		depth.setValue(oldDepth);
		depth.setDisplayLength(4);
		final Field<Integer> width = new Field<Integer>(TYPE_INT, "Width", 2, U_MAX_DIM);
		width.setNewLine(false);
		width.setLabel(" * ");
		width.setValue(oldWidth);
		width.setDisplayLength(4);
		return new Field[] { depth, width };
	}
	/**
	 * Gets the depth of the world
	 *
	 * @return the depth to resize to
	 */
	public int getDepth() {
		return (Integer)getValue("Depth");
	}
	/**
	 * Gets the width of the world.
	 *
	 * @return the width to resize to
	 */
	public int getWidth() {
		return (Integer)getValue("Width");
	}
}