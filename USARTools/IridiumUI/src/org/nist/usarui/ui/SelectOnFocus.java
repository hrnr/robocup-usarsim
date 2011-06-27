/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.ui;

import java.awt.event.*;
import javax.swing.text.*;

/**
 * A class which automatically selects the contents of a text box when given focus.
 */
public class SelectOnFocus extends FocusAdapter {
	private final JTextComponent box;

	/**
	 * Creates a new SelectOnFocus that will use the target component.
	 *
	 * @param toSelect the component to select when focused
	 */
	public SelectOnFocus(JTextComponent toSelect) {
		box = toSelect;
	}
	public void focusGained(FocusEvent e) {
		if (!e.isTemporary() && e.getSource() == box)
			box.selectAll();
	}
}