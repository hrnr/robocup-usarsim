package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.*;
import java.awt.*;

/**
 * Dialog that appears for creation of new world parameters.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class NewWorldDialog extends AbstractDialog implements WorldCreationParams, Constants {
	/**
	 * Creates a new world dialog.
	 *
	 * @param parent the component managing this dialog
	 */
	public NewWorldDialog(final Component parent) {
		super(parent);
	}
	public boolean collect() {
		return show("Create New World") == DIALOG_OK;
	}
	protected String getDialogPrompt() {
		return "World Creation Parameters";
	}
	protected Field[] getFormFields() {
		final Field<Integer> depth = new Field<Integer>(TYPE_INT, "Depth", 2, U_MAX_DIM);
		depth.setLabel("World Size (depth,width): ");
		depth.setDisplayLength(4);
		depth.setValue(WGConfig.getInteger("WorldGen.DefaultX"));
		final Field<Integer> width = new Field<Integer>(TYPE_INT, "Width", 2, U_MAX_DIM);
		width.setNewLine(false);
		width.setLabel(" * ");
		width.setDisplayLength(4);
		width.setValue(WGConfig.getInteger("WorldGen.DefaultY"));
		final Field<String> name = new Field<String>(TYPE_STRING, "Name");
		name.setDisplayLength(32);
		name.setLabel("World Name: ");
		name.setMaxLength(128);
		name.setValue(WGConfig.getProperty("WorldGen.DefaultName"));
		final Field<Boolean> random = new Field<Boolean>(TYPE_BOOL, "Random");
		random.setLabel("Add Random Rooms? ");
		random.setValue(false);
		return new Field[] {
			depth, width, name, random
		};
	}
	public int getDepth() {
		return (Integer)getValue("Depth");
	}
	public String getName() {
		return (String)getValue("Name");
	}
	public int getWidth() {
		return (Integer)getValue("Width");
	}
	public boolean isRandom() {
		return (Boolean)getValue("Random");
	}
}
