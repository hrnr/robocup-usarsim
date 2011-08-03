package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import java.awt.*;

/**
 * A dialog used for victimization parameters.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class VictimizeDialog extends AbstractDialog implements Constants {
	/**
	 * Creates a new victimize dialog.
	 *
	 * @param parent the component managing this dialog
	 */
	public VictimizeDialog(final Component parent) {
		super(parent);
	}
	protected String getDialogPrompt() {
		return "Victim Parameters";
	}
	protected Field[] getFormFields() {
		final Field<Integer> count = new Field<Integer>(TYPE_INT, "VictimCount", 1, null);
		count.setDisplayLength(4);
		count.setLabel("Victim Quantity: ");
		count.setValue(2);
		final Field<String> compat = new Field<String>(TYPE_CHOICE, "UT3Mode", new String[] {
			"UDK", "UT3"
		});
		compat.setLabel("Output For: ");
		compat.setValue("UDK");
		return new Field[] { count, compat };
	}
	/**
	 * Gets the compatibility mode of the output.
	 *
	 * @return the compatibility level that the map should use
	 */
	public int getCompatMode() {
		return getValue("UT3Mode").equals("UDK") ? UT_COMPAT_UDK : UT_COMPAT_UT3;
	}
	/**
	 * Gets the number of victims to be added.
	 *
	 * @return the number of victims to be generated
	 */
	public int getVictimCount() {
		return (Integer)getValue("VictimCount");
	}
}