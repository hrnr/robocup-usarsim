package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.*;
import java.awt.*;

/**
 * Dialog shown when the user tries to create a maze.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class CreateMazeDialog extends AbstractDialog implements Constants {
	/**
	 * Creates a new dialog with the specified parent.
	 *
	 * @param parent the component managing this dialog
	 */
	public CreateMazeDialog(final Component parent) {
		super(parent);
	}
	protected String getDialogPrompt() {
		return "Maze Parameters";
	}
	protected Field[] getFormFields() {
		final Field<String> name = new Field<String>(TYPE_STRING, "Name");
		final Field<Integer> depth = new Field<Integer>(TYPE_INT, "Depth", 1, R_MAX_DIM);
		depth.setLabel("Size (depth, width; grid units): ");
		depth.setDisplayLength(4);
		depth.setValue(3);
		final Field<Integer> width = new Field<Integer>(TYPE_INT, "Width", 1, R_MAX_DIM);
		width.setLabel(" * ");
		width.setNewLine(false);
		width.setDisplayLength(4);
		width.setValue(3);
		final Field<String> diff = new Field<String>(TYPE_CHOICE, "Difficulty", new String[] {
			"No Ramps", "Orange", "Yellow"
		});
		final Field<String> incline = new Field<String>(TYPE_CHOICE, "Incline", new String[] {
			"5 Degrees", "10 Degrees", "15 Degrees"
		});
		return new Field[] { name, depth, width, diff, incline };
	}
	public int getDifficulty() {
		final String value = (String)getValue("Difficulty");
		final int diff;
		if (value.equalsIgnoreCase("Orange"))
			diff = A_ORANGE;
		else if (value.equalsIgnoreCase("Yellow"))
			diff = A_YELLOW;
		else
			diff = A_CLEAR;
		return diff;
	}
	public int getIncline() {
		final String value = (String)getValue("Incline");
		final int angle;
		if (value.equalsIgnoreCase("15 Degrees"))
			angle = 15;
		else if (value.equalsIgnoreCase("10 Degrees"))
			angle = 10;
		else
			angle = 5;
		return angle;
	}
	public String getName() {
		return (String)getValue("Name");
	}
	public IntDimension3D getSize() {
		final int depth = (Integer)getValue("Depth"), width = (Integer)getValue("Width");
		return new IntDimension3D(depth, width, 1);
	}
}