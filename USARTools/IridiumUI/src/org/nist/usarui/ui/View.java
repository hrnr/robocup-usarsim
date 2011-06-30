/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.ui;

import org.nist.usarui.*;
import java.awt.*;
import javax.swing.*;

/**
 * Represents an abstract view that can be detached from the main Iridium window.
 *
 * @author Stephen Carlson (NIST)
 */
public class View {
	/**
	 * The dialog window that shows the map.
	 */
	protected final JDialog dialog;

	/**
	 * Creates a new view.
	 *
	 * @param parent the parent component of this view
	 * @param title the view window title
	 */
	protected View(Component parent, String title) {
		dialog = new JDialog(Utils.findParent(parent), title, false);
		dialog.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
		dialog.setSize(300, 300);
	}
	/**
	 * Closes the window.
	 */
	public void close() {
		dialog.dispose();
	}
	/**
	 * Gets the size of this view.
	 *
	 * @return the view's window size
	 */
	public Dimension getSize() {
		return dialog.getSize();
	}
	/**
	 * Determines whether this view is visible.
	 *
	 * @return whether the view is visible on the screen
	 */
	public boolean isVisible() {
		return dialog.isVisible();
	}
	/**
	 * Moves this view to center it over another component.
	 *
	 * @param c the component to center this dialog over
	 */
	public void setLocationRelativeTo(Component c) {
		dialog.setLocationRelativeTo(c);
	}
	/**
	 * Moves this view to the specified location.
	 *
	 * @param x the x coordinate in screen space
	 * @param y the y coordinate in screen space
	 */
	public void setLocation(int x, int y) {
		dialog.setLocation(x, y);
	}
	/**
	 * Changes the title of this view.
	 *
	 * @param title the new view title
	 */
	public void setTitle(String title) {
		dialog.setTitle(title);
	}
	/**
	 * Changes the visibility of the view.
	 *
	 * @param visible whether the view should be visible
	 */
	public void setVisible(boolean visible) {
		dialog.setVisible(visible);
	}
}