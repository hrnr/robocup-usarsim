package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.IntDimension3D;
import java.awt.*;

/**
 * Prompts the user for the size of the template world to generate.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class TemplateSizeDialog extends AbstractDialog implements Constants {
	/**
	 * Creates a new dialog to prompt for the template size.
	 *
	 * @param parent the component managing this dialog
	 */
	public TemplateSizeDialog(final Component parent) {
		super(parent);
	}
	protected String getDialogPrompt() {
		return "Template Size (Grid Units)";
	}
	protected Field[] getFormFields() {
		final Field<Integer> depth = new Field<Integer>(TYPE_INT, "Depth", 1, R_MAX_DIM);
		depth.setLabel("Room Dimensions (depth,width,height): ");
		depth.setValue(1);
		depth.setDisplayLength(4);
		final Field<Integer> width = new Field<Integer>(TYPE_INT, "Width", 1, R_MAX_DIM);
		width.setNewLine(false);
		width.setLabel(" * ");
		width.setValue(1);
		width.setDisplayLength(4);
		final Field<Integer> height = new Field<Integer>(TYPE_INT, "Height", 1, R_MAX_DIM);
		height.setNewLine(false);
		height.setLabel(" * ");
		height.setValue(1);
		height.setDisplayLength(4);
		return new Field[] { depth, width, height };
	}
	/**
	 * Gets the size to be used for the template.
	 *
	 * @return the size of the template room in grid units
	 */
	public IntDimension3D getSize() {
		final int depth = (Integer)getValue("Depth");
		final int width = (Integer)getValue("Width");
		final int height = (Integer)getValue("Height");
		return new IntDimension3D(depth, width, height);
	}
}