package org.nist.usarui;

import java.awt.event.*;
import javax.swing.text.*;

/**
 * A class which automatically selects the contents of a text box when given focus.
 */
public class SelectOnFocus implements FocusListener {
	private JTextComponent box;

	public SelectOnFocus(JTextComponent toSelect) {
		box = toSelect;
	}
	public void focusGained(FocusEvent e) {
		if (!e.isTemporary())
			box.selectAll();
	}
	public void focusLost(FocusEvent e) { }
}