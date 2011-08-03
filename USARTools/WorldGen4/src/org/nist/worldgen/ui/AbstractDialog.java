package org.nist.worldgen.ui;

import org.nist.worldgen.Constraint;
import org.nist.worldgen.Utils;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

/**
 * A class representing a dialog with custom fields that can be shown to the user.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public abstract class AbstractDialog {
	/**
	 * The default field size on screen.
	 */
	public static final int DEFAULT_FIELD_LENGTH = 16;
	/**
	 * Signals that the dialog was closed using the Close button.
	 */
	public static final int DIALOG_CLOSED = -1;
	/**
	 * Signals that the dialog was closed with the "OK" (default) option.
	 */
	public static final int DIALOG_OK = 0;
	/**
	 * Field type of boolean.
	 */
	public static final int TYPE_BOOL = 3;
	/**
	 * Field type of string, with preset choices available.
	 */
	public static final int TYPE_CHOICE = 4;
	/**
	 * Field type of double.
	 */
	public static final int TYPE_DOUBLE = 2;
	/**
	 * Field type of integer.
	 */
	public static final int TYPE_INT = 1;
	/**
	 * Field type of string.
	 */
	public static final int TYPE_STRING = 0;

	/**
	 * Changes the value of a field.
	 *
	 * @param comp the component(s) to modify
	 * @param field the field matching those components
	 */
	protected static void setFieldValue(JComponent comp, Field field) {
		Object value = field.getValue();
		switch (field.getType()) {
		case TYPE_DOUBLE:
		case TYPE_STRING:
		case TYPE_INT:
			String text;
			if (value == null)
				// Empty
				text = "";
			else
				text = value.toString();
			((JTextField)comp).setText(text);
			break;
		case TYPE_BOOL:
			boolean select;
			if (value == null)
				select = false;
			else
				select = (Boolean)value;
			((JCheckBox)comp).setSelected(select);
			break;
		case TYPE_CHOICE:
			JComboBox box = (JComboBox)comp;
			if (value == null)
				// Empty
				box.setSelectedIndex(0);
			else
				box.setSelectedItem(value.toString());
			break;
		default:
		}
	}

	/**
	 * The dialog used to display this item. It can be reused between instances if tripped on
	 * the same parent component.
	 */
	private JDialog dialog;
	/**
	 * Entry boxes for the data.
	 */
	private JComponent[] entries;
	/**
	 * Listens for events given out by input boxes.
	 */
	private EventListener events;
	/**
	 * Cache of entry fields.
	 */
	private Field[] fields;
	/**
	 * The parent of this dialog.
	 */
	protected final Component parent;
	/**
	 * Status of close (type of closing operation).
	 */
	private volatile int status;

	/**
	 * Creates a dialog.
	 *
	 * @param parent the parent component of this dialog
	 */
	protected AbstractDialog(Component parent) {
		this.parent = parent;
		initDialog();
	}
	protected void buildEntryList() {
		int maxWidth = 0, length = getFields().length, prefWidth;
		JComponent row = null; JLabel[] labels = new JLabel[length];
		Container c = dialog.getContentPane();
		// Set border to show prompt
		JComponent formArea = new Box(BoxLayout.PAGE_AXIS);
		formArea.setBorder(BorderFactory.createCompoundBorder(
			BorderFactory.createEmptyBorder(5, 5, 5, 5), BorderFactory.createTitledBorder(
			BorderFactory.createEtchedBorder(), getDialogPrompt())));
		entries = new JComponent[length];
		// Build entry list
		for (int i = 0; i < length; i++) {
			entries[i] = createComponent(fields[i]);
			labels[i] = new JLabel(fields[i].getLabel());
			labels[i].setLabelFor(entries[i]);
			if (fields[i].isNewLine() || i == 0) {
				prefWidth = labels[i].getPreferredSize().width;
				maxWidth = Math.max(maxWidth, prefWidth);
			}
		}
		// Add entries to list
		for (int i = 0; i < length; i++) {
			prefWidth = labels[i].getPreferredSize().width;
			// Compute and add label
			if (fields[i].isNewLine() || i == 0) {
				row = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 1));
				row.add(Box.createHorizontalStrut(maxWidth - prefWidth + 2));
			}
			row.add(labels[i]);
			// Add components
			row.add(entries[i]);
			if (i >= length - 1 || fields[i + 1].isNewLine()) {
				row.add(Box.createHorizontalGlue());
				formArea.add(row);
			}
		}
		// Add components to toplevel dialog
		c.add(formArea, BorderLayout.CENTER);
		updateDialog();
		dialog.pack();
	}
	/**
	 * Creates the required components for the given data type. Override to implement custom.
	 *
	 * @param field the data type
	 * @return the components required
	 */
	protected JComponent createComponent(Field field) {
		JComponent ret;
		int type = field.getType();
		switch (type) {
		case TYPE_DOUBLE:
		case TYPE_STRING:
		case TYPE_INT:
			ret = createTextField(field);
			break;
		case TYPE_BOOL:
			ret = new JCheckBox(" ");
			ret.setFocusable(false);
			break;
		case TYPE_CHOICE:
			JComboBox box = new JComboBox();
			box.setFocusable(false);
			for (Object o : field.getValues())
				box.addItem(o);
			ret = box;
			break;
		default:
			throw new RuntimeException("Invalid type: " + type);
		}
		ret.setToolTipText(field.getName());
		return ret;
	}
	/**
	 * Creates a text field.
	 *
	 * @param field the field specification
	 * @return a matching JTextField (or one of many)
	 */
	protected JComponent createTextField(Field field) {
		JTextField comp = new JTextField(field.getDisplayLength());
		comp.addActionListener(events);
		comp.addFocusListener(events);
		comp.addKeyListener(events);
		comp.setActionCommand("ok");
		return comp;
	}
	/**
	 * @see javax.swing.JDialog#dispose()
	 */
	public void dispose() {
		dialog.dispose();
	}
	/**
	 * Gets the prompt shown at the top of the dialog.
	 *
	 * @return the prompt text
	 */
	protected abstract String getDialogPrompt();
	/**
	 * Gets the fields available in this dialog.
	 *
	 * @return an array of fields to be shown
	 */
	protected Field[] getFields() {
		if (fields == null) reset();
		return fields;
	}
	/**
	 * Produces the fields available in this dialog. They will be cached to save values.
	 *
	 * @return an array of fields to be shown
	 */
	protected abstract Field[] getFormFields();
	/**
	 * Gets the value for the specified field.
	 *
	 * @param fieldName the field name to check
	 * @return the value stored there, or null if no value was input
	 */
	public Object getValue(String fieldName) {
		Object value = null;
		for (int i = 0; i < getFields().length; i++)
			if (fields[i].getName().equals(fieldName)) {
				value = fields[i].getValue();
				break;
			}
		return value;
	}
	/**
	 * Creates and initializes the dialog instance.
	 */
	protected void initDialog() {
		JComponent buttons = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 5));
		events = new EventListener();
		// Create dialog
		dialog = new JDialog(Utils.findParent(parent), "User Input", true);
		dialog.setDefaultCloseOperation(JDialog.HIDE_ON_CLOSE);
		dialog.setResizable(false);
		// Cancel button
		JButton cancel = new JButton("Cancel");
		cancel.addActionListener(events);
		cancel.setActionCommand("cancel");
		cancel.setMnemonic(KeyEvent.VK_C);
		// OK button
		JButton ok = new JButton("OK");
		ok.addActionListener(events);
		ok.setActionCommand("ok");
		ok.setMnemonic(KeyEvent.VK_O);
		// Add buttons to button pane
		buttons.add(ok);
		buttons.add(cancel);
		// Add components to toplevel dialog
		dialog.getContentPane().add(buttons, BorderLayout.SOUTH);
	}
	/**
	 * Removes the cached data to regenerate the fields again.
	 */
	public void reset() {
		fields = getFormFields();
	}
	private boolean runTextValidation(Field spec, String input) {
		boolean valid = false; Comparable<?> value; int cmp;
		if (input.length() > spec.getMaxLength())
			// Too long
			warn("\"%s\" may not be longer than %d characters.", spec.getName(),
				spec.getMaxLength());
		else if (input.length() < spec.getMinLength()) {
			// Too short
			if (spec.getMinLength() < 2)
				warn("\"%s\" may not be blank.", spec.getName());
			else
				warn("\"%s\" may not be shorter than %d characters.", spec.getName(),
					spec.getMinLength());
		} else {
			value = null;
			// Type and scope validation
			try {
				switch (spec.getType()) {
				case TYPE_DOUBLE:
					value = Double.valueOf(input);
					break;
				case TYPE_INT:
					value = Integer.valueOf(input);
					break;
				case TYPE_STRING:
					value = input;
					break;
				default:
				}
			} catch (NumberFormatException e) {
				warn("Invalid value for \"%s\".", spec.getName());
			}
			// Bounds validation
			if (value != null) {
				cmp = spec.compareBounds(value);
				if (cmp > 0)
					warn("\"%s\" must be at most %s.", spec.getName(), spec.getMax());
				else if (cmp < 0)
					warn("\"%s\" must be at least %s.", spec.getName(), spec.getMin());
				else {
					spec.setValue(value);
					valid = true;
				}
			}
		}
		return valid;
	}
	/**
	 * Validates the fields. Displays the appropriate error if they do not meet requirements.
	 *
	 * @return whether validation succeeded
	 */
	protected boolean runValidation() {
		Field spec; int i; boolean valid = true;
		for (i = 0; i < entries.length && valid; i++) {
			// Read entered value
			spec = fields[i];
			switch (spec.getType()) {
			// Double, int, and string come in through a text box
			case TYPE_DOUBLE:
			case TYPE_INT:
			case TYPE_STRING:
				valid = runTextValidation(spec, ((JTextField)entries[i]).getText());
				break;
			// Boolean comes in through a checkbox
			case TYPE_BOOL:
				spec.setValue(((JCheckBox)entries[i]).isSelected());
				break;
			// Choice comes in through a combo box
			case TYPE_CHOICE:
				spec.setValue(((JComboBox)entries[i]).getSelectedItem().toString());
				break;
			default:
			}
		}
		// Select broken field if any
		if (!valid)
			entries[i - 1].requestFocusInWindow();
		return valid;
	}
	/**
	 * Shows the dialog and blocks until input is made. Can (and probably should) be called
	 * from the event thread.
	 *
	 * @param title the dialog title
	 * @return the trigger type that closed the dialog
	 */
	public int show(String title) {
		if (entries == null)
			buildEntryList();
		status = DIALOG_CLOSED;
		updateDialog();
		dialog.setTitle(title);
		Utils.centerWindow(dialog);
		dialog.setVisible(true);
		return status;
	}
	/**
	 * Changes all of the dialog's values to match the field values.
	 */
	public void updateDialog() {
		for (int i = 0; i < fields.length; i++)
			setFieldValue(entries[i], fields[i]);
	}
	/**
	 * Displays a formatted warning message with the specified text.
	 *
	 * @param message the message to display
	 * @param args the parameters to fill in for the message
	 */
	protected void warn(String message, Object... args) {
		JOptionPane.showMessageDialog(dialog, String.format(message, args), "Input Error",
			JOptionPane.WARNING_MESSAGE);
	}

	/**
	 * Listens for button events and flags them appropriately.
	 */
	private class EventListener extends KeyAdapter implements ActionListener, FocusListener {
		public void actionPerformed(ActionEvent e) {
			String cmd = e.getActionCommand();
			if (cmd == null)
				throw new RuntimeException("No action command set for " + e.getSource());
			if (cmd.equals("ok") && runValidation()) {
				// Gotcha
				status = DIALOG_OK;
				dialog.setVisible(false);
			} else if (cmd.equals("cancel"))
				dialog.setVisible(false);
		}
		public void focusGained(FocusEvent e) {
			Object src = e.getSource();
			if (src instanceof JTextField)
				((JTextField)src).selectAll();
		}
		public void focusLost(FocusEvent e) { }
		public void keyReleased(KeyEvent e) {
			if (e.getKeyCode() == KeyEvent.VK_ESCAPE)
				dialog.setVisible(false);
		}
	}

	/**
	 * A class representing a field in the dialog.
	 *
	 * @param <T> the field type
	 */
	protected static class Field<T extends Comparable<T>> {
		/**
		 * The minimum and maximum value.
		 */
		private Constraint<T> constraints;
		/**
		 * The field's suggested length.
		 */
		private int displayLength;
		/**
		 * The field's text label.
		 */
		private String label;
		/**
		 * The minimum and maxmimum allowable length of text.
		 */
		private Constraint<Integer> length;
		/**
		 * The field's name.
		 */
		private String name;
		/**
		 * Whether this field breaks lines or not (usually true)
		 */
		private boolean newLine;
		/**
		 * The field's type.
		 */
		private int type;
		/**
		 * The field's current value.
		 */
		private T value;
		/**
		 * Allowed values for the field (only useful for TYPE_CHOICE)
		 */
		private T[] values;

		/**
		 * Creates a non-blank form field with no other limits on the values.
		 *
		 * @param type the field type
		 * @param name the field's name
		 */
		public Field(int type, String name) {
			this(type, name, null, null, null);
		}
		/**
		 * Creates a non-blank form field with the specified value limits.
		 *
		 * @param type the field type
		 * @param name the field's name
		 * @param min the minimum field value
		 * @param max the maximum field value
		 */
		public Field(int type, String name, T min, T max) {
			this(type, name, min, max, null);
		}
		/**
		 * Creates a non-blank form field with the specified values available.
		 *
		 * @param type the field type
		 * @param name the field's name
		 * @param choices the value types allowed
		 */
		public Field(int type, String name, T[] choices) {
			this(type, name, null, null, choices);
		}
		private Field(int type, String name, T min, T max, T[] choices) {
			this.name = name;
			constraints = new Constraint<T>(min, max);
			length = new Constraint<Integer>(1, Integer.MAX_VALUE);
			this.type = type;
			label = name + ": ";
			displayLength = DEFAULT_FIELD_LENGTH;
			newLine = true;
			value = null;
			values = choices;
		}
		/**
		 * Checks to see if the value is in bounds. If so, return 0. If too low,
		 * return -1. If too high, return 1.
		 *
		 * @param newValue the value to check
		 * @return whether the value falls in bounds
		 */
		protected int compareBounds(T newValue) {
			return constraints.compareBounds(newValue);
		}
		/**
		 * Gets the preferred field size.
		 *
		 * @return the preferred field size
		 */
		public int getDisplayLength() {
			return displayLength;
		}
		/**
		 * Gets the label for this form field.
		 *
		 * @return the text displayed next to the field
		 */
		public String getLabel() {
			return label;
		}
		/**
		 * Gets the maximum value allowed.
		 *
		 * @return the max value
		 */
		public T getMax() {
			return constraints.getMax();
		}
		/**
		 * Gets the maximum entry length allowed.
		 *
		 * @return the maximum length
		 */
		public int getMaxLength() {
			return length.getMax();
		}
		/**
		 * Gets the minimum value allowed.
		 *
		 * @return the min value
		 */
		public T getMin() {
			return constraints.getMin();
		}
		/**
		 * Gets the minimum entry length allowed.
		 *
		 * @return the minimum length
		 */
		public int getMinLength() {
			return length.getMin();
		}
		/**
		 * Gets the name of this form field.
		 *
		 * @return the field name (used in dialog prompts and get() methods)
		 */
		public String getName() {
			return name;
		}
		/**
		 * Gets the field type.
		 *
		 * @return the type of the field, using constants defined above
		 */
		public int getType() {
			return type;
		}
		/**
		 * Gets the current field value.
		 *
		 * @return the field value (when validated, of correct type)
		 */
		public T getValue() {
			return value;
		}
		/**
		 * Gets the allowed field values.
		 *
		 * @return the field values allowed (only meaningful for TYPE_CHOICE)
		 */
		public T[] getValues() {
			return values;
		}
		/**
		 * Gets whether this field starts its line.
		 *
		 * @return whether this field begins on a new line
		 */
		public boolean isNewLine() {
			return newLine;
		}
		/**
		 * Changes the displayed field size.
		 *
		 * @param displayLength the preferred width of the field in columns
		 */
		public void setDisplayLength(int displayLength) {
			this.displayLength = displayLength;
		}
		/**
		 * Changes the field's text label.
		 *
		 * @param label the new text label to be displayed
		 */
		public void setLabel(String label) {
			this.label = label;
		}
		/**
		 * Changes the maximum entry length allowed.
		 *
		 * @param maxLength the new maximum length
		 */
		public void setMaxLength(int maxLength) {
			length = length.createMaxConstraint(maxLength);
		}
		/**
		 * Changes the minimum entry length allowed.
		 *
		 * @param minLength the new minimum length
		 */
		public void setMinLength(int minLength) {
			length = length.createMaxConstraint(minLength);
		}
		/**
		 * Changes whether the field starts a new line.
		 *
		 * @param newLine whether this field has its own line (true) or is on the same line
		 * as the previous field (false)
		 */
		public void setNewLine(boolean newLine) {
			this.newLine = newLine;
		}
		/**
		 * Changes the current field value.
		 *
		 * @param value the new field value (must be correctly typed)
		 */
		public void setValue(T value) {
			this.value = value;
		}
	}
}