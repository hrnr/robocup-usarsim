package org.nist.worldgen;

import org.nist.worldgen.xml.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import java.awt.*;
import java.io.*;
import java.util.*;
import java.util.regex.*;
import javax.swing.*;

/**
 * World generator utility functions.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public final class Utils {
	/**
	 * Two double values are considered equal if they fall within this amount of each other.
	 */
	public static final double DOUBLE_TOLERANCE = 1e-5;
	/**
	 * String used for XML indentation.
	 */
	public static final String INDENT_XML = "  ";
	// Patterns for replacement in escaping
	private static final Pattern AMP = Pattern.compile("&amp;");
	private static final Pattern AND = Pattern.compile("&");
	private static final Pattern GREAT = Pattern.compile(">");
	private static final Pattern GT = Pattern.compile("&gt;");
	private static final Pattern LESS = Pattern.compile("<");
	private static final Pattern LT = Pattern.compile("&lt;");
	private static final Pattern QUOT = Pattern.compile("&quot;");
	private static final Pattern QUOTE = Pattern.compile("\"");

	/**
	 * Adds an XML tag to the output stream with the proper indentation.
	 *
	 * @param out the output stream to write (should NOT have autoflush on!)
	 * @param ind how many levels to indent
	 * @param tagName the XML tag name to write
	 * @param args alternate
	 */
	public static void addTag(final PrintWriter out, final int ind, final String tagName,
			final Object... args) {
		final int parity = args.length % 2;
		for (int i = 0; i < ind; i++)
			out.print(INDENT_XML);
		out.print('<');
		out.print(tagName);
		for (int i = 0; i < args.length - parity; i += 2) {
			out.print(' ');
			out.print(args[i]);
			out.print("=\"");
			out.print(args[i + 1]);
			out.print('"');
		}
		if (parity != 0)
			out.print(" /");
		out.print(">");
		out.println();
	}
	/**
	 * Adds the required tags to the specified string so it is interpreted as HTML.
	 *
	 * @param html the HTML text
	 * @return the text wrapped in html and body tags
	 */
	public static String asHTML(final String html) {
		final StringBuilder build = new StringBuilder(html.length() + 27);
		build.append("<html><body>");
		build.append(html);
		build.append("</body></html>");
		return build.toString();
	}
	/**
	 * Removes the file extension from the given file name, if present.
	 *
	 * @param name the file name
	 * @return the file name without its extension
	 */
	public static String baseName(final String name) {
		final String out;
		final int index = name.lastIndexOf('.');
		if (index > 0)
			out = name.substring(0, index);
		else
			out = name;
		return out;
	}
	/**
	 * Puts the window in the center of the screen.
	 *
	 * @param win the window to center
	 */
	public static void centerWindow(final Window win) {
		final Dimension ss = win.getToolkit().getScreenSize(), ws = win.getSize();
		final Point start = new Point(0, 0); final Frame parent = findParent(win);
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
	 * Creates a button for the toolbar.
	 *
	 * @param action the Action to configure the button
	 * @return the toolbar button
	 */
	public static JButton createToolbarButton(final Action action) {
		final JButton but = new JButton(action);
		but.setFocusable(false);
		but.setText(null);
		return but;
	}
	/**
	 * Displays the export warning dialog and prompts the user to continue import.
	 *
	 * @param parent the component managing the dialog
	 * @param message the message to display
	 * @return whether import should continue
	 */
	public static boolean defaultExportWarning(final Component parent, final String message) {
		return JOptionPane.showConfirmDialog(parent, Utils.asHTML(message +
			"<br>Continue with export?"), "Generation Warning", JOptionPane.YES_NO_OPTION,
			JOptionPane.WARNING_MESSAGE) == JOptionPane.YES_OPTION;
	}
	/**
	 * Compares the two specified double values for equality.
	 *
	 * @param one the first value
	 * @param two the second value
	 * @return whether the two values are within DOUBLE_TOLERANCE of each other
	 */
	public static boolean doubleEquals(final double one, final double two) {
		return Math.abs(one - two) < DOUBLE_TOLERANCE;
	}
	/**
	 * Expands the specified rectangle in all directions by the given amount.
	 *
	 * @param input the rectangle to expand
	 * @param amount how much to expand it
	 * @param expandZ whether the Z axis should be expanded as well
	 * @return an expanded copy of that rectangle
	 */
	public static Rectangle3D expandRectangle(final Rectangle3D input, final double amount,
			final boolean expandZ) {
		final Rectangle3D out = input.getBounds();
		out.setX(out.getX() - amount);
		out.setY(out.getY() - amount);
		out.setDepth(out.getDepth() + 2.0 * amount);
		out.setWidth(out.getWidth() + 2.0 * amount);
		if (expandZ) {
			out.setZ(out.getZ() - amount);
			out.setHeight(out.getHeight() + 2.0 * amount);
		}
		return out;
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
	 * Finds rooms in the given list which overlap the given point
	 *
	 * @param rooms the room list to search
	 * @param at the point to look at
	 * @return an array of rooms at the given point (which should be only 1...)
	 */
	public static WGRoomInstance[] findRooms(final Collection<WGRoomInstance> rooms,
			final Point at) {
		return findRooms(rooms, new Rectangle(at.x, at.y, 1, 1));
	}
	/**
	 * Finds rooms in the given list which fall partially within the specified rectangle.
	 *
	 * @param rooms the room list to search
	 * @param bounds the boundaries to look within
	 * @return an array of all rooms found wholly or partially inside the rectangle
	 */
	public static WGRoomInstance[] findRooms(final Collection<WGRoomInstance> rooms,
			final Rectangle bounds) {
		final Collection<WGRoomInstance> found = new LinkedList<WGRoomInstance>();
		for (WGRoomInstance room : rooms)
			if (room.getBounds().intersects(bounds))
				found.add(room);
		return found.toArray(new WGRoomInstance[found.size()]);
	}
	/**
	 * Flattens the specified object to an XML file.
	 *
	 * @param file the file name to write
	 * @param obj the object to serialize
	 * @throws IOException if an I/O error occurs
	 */
	public static void flatten(final File file, final XMLSerializable obj) throws IOException {
		final Writer os = new OutputStreamWriter(new FileOutputStream(file, false), "UTF-8");
		final PrintWriter out = new PrintWriter(new BufferedWriter(os, 1024), false);
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		obj.toXML(out, 0);
		out.flush();
		out.close();
		// Now check it
		if (out.checkError())
			throw new IOException("Error when writing file!");
	}
	/**
	 * Creates a tool tip for the given room.
	 *
	 * @param room the room for which a tooltip is required
	 * @return tool tip text for that room
	 */
	public static String generateTooltip(final WGRoom room) {
		return asHTML(String.format("<b>%s</b><br>Dimensions: %s<br>File path: %s<br>Tag: %s",
			xmlEncode(room.getName()), room.getSize(), xmlEncode(room.getFileName()),
			xmlEncode(room.getTag())));
	}
	/**
	 * Parses the specified file and feeds its information to the object.
	 *
	 * @param file the file name to read
	 * @param obj the object to deserialize into
	 * @throws IOException if an I/O error occurs
	 */
	public static void parse(final File file, final XMLParseable obj) throws IOException {
		final InputStream is = new BufferedInputStream(new FileInputStream(file), 1024);
		final InputSource src = new InputSource(is);
		src.setEncoding("UTF-8");
		final DefaultHandler handler = new DefaultXMLHandler(obj);
		try {
			final XMLReader reader = XMLReaderFactory.createXMLReader();
			reader.setContentHandler(handler);
			reader.setErrorHandler(handler);
			reader.parse(src);
		} catch (SAXException e) {
			throw new IOException("XML parse error when reading file");
		} finally {
			is.close();
		}
	}
	/**
	 * Generates a random number inside the specified range.
	 *
	 * @param beg the low value
	 * @param end the high value
	 * @return a number from beg to end inclusive both ends
	 */
	public static int randInt(final int beg, final int end) {
		return (int) Math.floor(((end - beg) * Math.random()) + beg);
	}
	/**
	 * Makes the Java UI match the system UI much more closely.
	 */
	public static void setSystemUI() {
		UIManager.put("FileChooser.readOnly", Boolean.TRUE);
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (Exception ignore) { }
	}
	/**
	 * Shows a confirmation message.
	 *
	 * @param src the component displaying the message
	 * @param text the message text
	 * @return whether the user accepted (Yes)
	 */
	public static boolean showConfirm(final Component src, final String text) {
		return JOptionPane.showConfirmDialog(src, asHTML(text), "World Generator for UDK",
			JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION;
	}
	/**
	 * Shows a warning message.
	 *
	 * @param src the component displaying the message
	 * @param text the message text
	 */
	public static void showWarning(final Component src, final String text) {
		JOptionPane.showMessageDialog(src, asHTML(text), "World Generator for UDK",
			JOptionPane.WARNING_MESSAGE);
	}
	/**
	 * Changes an XMLed string back to the original.
	 *
	 * @param in the input string from XML
	 * @return the output string
	 */
	public static String xmlDecode(String in) {
		String out = null;
		if (in != null) {
			out = QUOT.matcher(in).replaceAll("\"");
			out = GT.matcher(out).replaceAll(">");
			out = LT.matcher(out).replaceAll("<");
			out = AMP.matcher(out).replaceAll("&");
		}
		return out;
	}
	/**
	 * Escapes a string to be used in XML.
	 *
	 * @param in the input string
	 * @return the output string safe for XML use
	 */
	public static String xmlEncode(String in) {
		String out = null;
		if (in != null) {
			out = AND.matcher(in).replaceAll("&amp;");
			out = GREAT.matcher(out).replaceAll("&gt;");
			out = QUOTE.matcher(out).replaceAll("&quot;");
			out = LESS.matcher(out).replaceAll("&lt;");
		}
		return out;
	}

	/**
	 * Represents the default XML hander which simply passes SAX events to its object.
	 */
	public static class DefaultXMLHandler extends DefaultHandler {
		private XMLParseable object;

		/**
		 * Creates a new default XML handler using the specified parseable object.
		 *
		 * @param object the object to forward events
		 */
		public DefaultXMLHandler(final XMLParseable object) {
			this.object = object;
		}
		public void fatalError(SAXParseException e) throws SAXException {
			throw e;
		}
		public void error(SAXParseException e) throws SAXException {
			throw e;
		}
		public void startElement(String uri, String localName, String qName,
				Attributes attributes) throws SAXException {
			if (qName == null)
				throw new SAXException("Must use qualified names when parsing");
			object.fromTag(qName, attributes);
		}
	}
}