/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.net.URL;
import java.util.*;

/**
 * IRIDIUM utility functions.
 *
 * @author Stephen Carlson
 */
public final class Utils {
	/**
	 * Adds an action listener for when the Enter key is pressed in an editable combo box.
	 *
	 * @param comp the combo box to modify
	 * @param listener the listener to set up
	 * @param command the command to be used
	 */
	public static void armActionListener(JComboBox comp, ActionListener listener,
			String command) {
		JTextField field = getEditorTextField(comp);
		if (field != null) {
			field.addActionListener(listener);
			field.setActionCommand(command);
		}
	}
	/**
	 * Adds a SelectOnFocus listener to the specified combo box.
	 *
	 * @param box the component to add
	 */
	public static void armFocusListener(JComboBox box) {
		JTextField field = getEditorTextField(box);
		if (field != null)
			armFocusListener(field);
	}
	/**
	 * Adds a SelectOnFocus listener to the specified text field.
	 *
	 * @param field the component to add
	 */
	public static void armFocusListener(JTextField field) {
		if (field != null)
			field.addFocusListener(new SelectOnFocus(field));
	}
	/**
	 * Adds the required tags to the specified string so it is interpreted as HTML.
	 *
	 * @param html the HTML text
	 * @return the text wrapped in html and body tags
	 */
	public static String asHTML(String html) {
		StringBuilder build = new StringBuilder(html.length() + 27);
		build.append("<html><body>");
		build.append(html);
		build.append("</body></html>");
		return build.toString();
	}
	/**
	 * Puts the window in the center of the screen.
	 *
	 * @param win the window to center
	 */
	public static void centerWindow(Window win) {
		Dimension ss = win.getToolkit().getScreenSize(), ws = win.getSize();
		Point start = new Point(0, 0); Frame parent = findParent(win);
		if (parent != null && parent != win) {
			parent.getSize(ss);
			parent.getLocation(start);
		}
		if (ws.width > ss.width) ws.width = ss.width;
		if (ws.height > ss.height) ws.height = ss.height;
		if (ws.equals(ss) && win instanceof Frame)
			((Frame)win).setExtendedState(Frame.MAXIMIZED_BOTH);
		else {
			win.setSize(ws);
			win.setLocation((ss.width - ws.width) / 2 + start.x,
				(ss.height - ws.height) / 2 + start.y);
		}
	}
	/**
	 * Creates a check box.
	 *
	 * @param text the text label to display
	 * @param tooltip the tool tip text to show
	 * @return the check box with default options set
	 */
	public static JCheckBox createCheckBox(String text, String tooltip) {
		final JCheckBox box = new JCheckBox(text, false);
		box.setFocusable(false);
		box.setToolTipText(tooltip);
		return box;
	}
	/**
	 * Creates a non-editable combo box with the specified items.
	 *
	 * @param tooltip the tool tip to show
	 * @param items the choices available
	 * @return the combo box with default options set
	 */
	public static JComboBox createComboBox(String tooltip, final String... items) {
		final JComboBox box = new JComboBox(items);
		box.setFocusable(false);
		box.setToolTipText(tooltip);
		return box;
	}
	/**
	 * Creates an editable combo box with the specified initial items.
	 *
	 * @param tooltip the tool tip to show
	 * @param items the choices available
	 * @return the combo box with default options set
	 */
	public static JComboBox createEntryBox(String tooltip, final String... items) {
		final JComboBox box = Utils.createComboBox(tooltip, items);
		box.setEditable(true);
		box.setFocusable(true);
		if (box.getItemCount() > 0)
			box.setSelectedIndex(0);
		Utils.armFocusListener(box);
		box.addItemListener(new ItemListener() {
			public void itemStateChanged(ItemEvent e) {
				Component editor = box.getEditor().getEditorComponent();
				if (editor instanceof JTextField && e.getStateChange() == ItemEvent.SELECTED)
					((JTextField)editor).selectAll();
			}
		});
		return box;
	}
	/**
	 * Creates a label attached to an input field.
	 *
	 * @param text the label text
	 * @param field the field to label
	 * @return a label which will handle that field
	 */
	public static JLabel createFieldLabel(String text, Component field) {
		final JLabel label = new JLabel(text);
		label.setHorizontalAlignment(SwingConstants.RIGHT);
		label.setLabelFor(field);
		return label;
	}
	/**
	 * Creates a label meant to display data.
	 *
	 * @param tooltip the display label's tool tip text
	 * @return the label with default options set
	 */
	public static JLabel createInfoLabel(String tooltip) {
		final JLabel label = new JLabel();
		label.setToolTipText(tooltip);
		label.setHorizontalAlignment(SwingConstants.CENTER);
		return label;
	}
	/**
	 * Creates a component intended to display its contents along one row.
	 *
	 * @return a panel which lays out its components linearly left aligned
	 */
	public static JComponent createSingleRow() {
		return new JPanel(new FlowLayout(FlowLayout.CENTER, 2, 2));
	}
	/**
	 * Finds the top-level component which contains and paints the specified one.
	 *
	 * @param comp the component to investigate
	 * @return the top-level component which holds this argument, or null if none can be found
	 */
	public static Frame findParent(Component comp) {
		Frame ret = null;
		if (comp instanceof Frame)
			ret = (Frame)comp;
		else
			// Look for parent frame
			while (ret == null && comp.getParent() != null) {
				comp = comp.getParent();
				if (comp instanceof Frame)
					ret = (Frame)comp;
			}
		return ret;
	}
	/**
	 * Transfers focus to the first available component.
	 *
	 * @param container the component which contains items to focus
	 * @return whether a component was found to give focus
	 */
	public static boolean focusFirstComponent(Container container) {
		Component entry; boolean found = false;
		for (int i = 0; i < container.getComponentCount() && !found; i++) {
			entry = container.getComponent(i);
			if (entry instanceof JPanel && entry.isShowing()) {
				if (focusFirstComponent((Container)entry))
					found = true;
			} else if (entry.isFocusable() && entry.isEnabled() && entry.isShowing() &&
					!(entry instanceof JLabel)) {
				entry.requestFocusInWindow();
				found = true;
			}
		}
		return found;
	}
	/**
	 * Gets the editor as a text field of the specified combo box.
	 *
	 * @param box the combo box (must be editable)
	 * @return the text editor responsible, or null if invalid
	 */
	public static JTextField getEditorTextField(JComboBox box) {
		Component editor = box.getEditor().getEditorComponent();
		JTextField field = null;
		if (editor instanceof JTextField)
			field = (JTextField)editor;
		return field;
	}
	/**
	 * Gets the selected starting pose for the robot (INIT/CONTROL panel), or null if custom.
	 *
	 * @param box the combo box with choices
	 * @return the robot's starting pose
	 */
	public static StartPose getPlayerStart(JComboBox box) {
		Object item; StartPose pose = null;
		String text = box.getEditor().getItem().toString();
		// Look for the pose location or tag, whichever is useful
		for (int i = 0; i < box.getItemCount(); i++) {
			item = box.getItemAt(i);
			pose = null;
			if (item instanceof StartPose) {
				pose = (StartPose)box.getItemAt(i);
				if (pose.toString().equalsIgnoreCase(text))
					// Matched!
					break;
				else
					pose = null;
			}
		}
		return pose;
	}
	/**
	 * Sanitizes the string by escaping its HTML characters.
	 *
	 * @param in the string to sanitize
	 * @return the string with all HTML special characters (&lt;, &gt;, &amp;) escaped
	 */
	public static String htmlSpecialChars(String in) {
		return in.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
	}
	/**
	 * Checks to see if the two floating-point values are about the same. Intended for use
	 * with the joystick.
	 *
	 * @param one the first value
	 * @param two the second value
	 * @return whether the values are within epsilon (0.01) of each other
	 */
	public static boolean isFloatEqual(float one, float two) {
		return Math.abs(one - two) < 0.01f;
	}
	/**
	 * Loads an image from the specified path.
	 *
	 * @param path the path to the image
	 * @return the image as an icon (use getImage() to get as image)
	 */
	public static ImageIcon loadImage(String path) {
		URL url = Utils.class.getResource("/" + path);
		if (url == null)
			Errors.userError("Missing file " + path);
		return new ImageIcon(url);
	}
	/**
	 * Reads a 3-vector from a comma delimited string (e.g. from GetStartPoses)
	 *
	 * @param value the string
	 * @return the 3-vector read
	 * @throws NoSuchElementException if not enough elements are available
	 * @throws NumberFormatException if an element cannot be parsed
	 */
	public static Vec3 read3Vector(String value) {
		Vec3 vector = null;
		if (value != null) {
			StringTokenizer str = new StringTokenizer(value, ",");
			float x = Float.parseFloat(str.nextToken().trim());
			float y = Float.parseFloat(str.nextToken().trim());
			float z = Float.parseFloat(str.nextToken().trim());
			vector = new Vec3(x, y, z);
		}
		return vector;
	}
	/**
	 * Makes the Java UI match the system UI much more closely.
	 */
	public static void setUI() {
		boolean uiChanged = false;
		UIManager.put("FileChooser.readOnly", Boolean.TRUE);
		try {
			for (UIManager.LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
				if ("Nimbus".equals(info.getName())) {
					UIManager.setLookAndFeel(info.getClassName());
					uiChanged = true;
					break;
				}
			}
		} catch (Exception ignore) { }
		if (!uiChanged)
			try {
				UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
			} catch (Exception ignore) { }
	}
	/**
	 * Shows a warning message.
	 *
	 * @param src the component displaying the message
	 * @param text the message's text
	 */
	public static void showWarning(Component src, String text) {
		JOptionPane.showMessageDialog(src, asHTML(text), "Iridium",
			JOptionPane.WARNING_MESSAGE);
	}
}