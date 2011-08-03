package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import java.awt.*;
import java.io.*;

/**
 * Improved version of Room (not serializable...) that uses XML to store data.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class WGRoom implements Comparable<WGRoom>, XMLSerializable {
	/**
	 * The room's file name on disk (with NO path!)
	 */
	private final String file;
	/**
	 * Whether the room is a hallway (more robust than a compareTo on the filename).
	 */
	private transient final boolean hallway;
	/**
	 * The room name.
	 */
	private final String name;
	/**
	 * Preview of the room's BSP layout.
	 */
	private transient Image preview;
	/**
	 * The room's size.
	 */
	private final IntDimension3D size;
	/**
	 * The room tag.
	 */
	private final String tag;

	/**
	 * Creates a new room.
	 *
	 * @param file the room's file name
	 * @param size the room's 3D dimensions
	 * @param name the room name
	 * @param tag the room tag(s)
	 */
	public WGRoom(final String file, final IntDimension3D size, final String name,
			final String tag) {
		this(file, size, name, tag, false);
	}
	/**
	 * Creates a new room.
	 *
	 * @param file the room's file name
	 * @param size the room's 3D dimensions
	 * @param name the room name
	 * @param tag the room tag(s)
	 * @param hallway whether the room is a hallway
	 */
	public WGRoom(final String file, final IntDimension3D size, final String name,
			final String tag, final boolean hallway) {
		if (tag == null || file == null || name == null)
			throw new NullPointerException("When creating WGRoom");
		this.file = file;
		this.name = name;
		preview = null;
		this.size = size;
		this.tag = tag;
		this.hallway = hallway;
	}
	public int compareTo(WGRoom o) {
		return getName().compareToIgnoreCase(o.getName());
	}
	public boolean equals(Object o) {
		if (!(o instanceof WGRoom)) return false;
		final WGRoom other = (WGRoom)o;
		return getFileName().equalsIgnoreCase(other.getFileName());
	}
	/**
	 * Gets the room filename.
	 *
	 * @return the file name to use in the look up table to find room data
	 */
	public String getFileName() {
		return file;
	}
	/**
	 * Gets the room name.
	 *
	 * @return the room's name
	 */
	public String getName() {
		return name;
	}
	/**
	 * Gets the perimeter of this room.
	 *
	 * @return the room perimeter
	 */
	public int getPerimeter() {
		return 2 * size.depth + 2 * size.width;
	}
	/**
	 * Gets the preview image for this room.
	 *
	 * @return the preview image of internal structure, or null if none has been computed
	 */
	public Image getPreviewImage() {
		return preview;
	}
	/**
	 * Gets the room size.
	 *
	 * @return the room's dimensions in grid units
	 */
	public IntDimension3D getSize() {
		return size;
	}
	/**
	 * Gets the room tag.
	 *
	 * @return the room's tag field (can be empty but not null!)
	 */
	public String getTag() {
		return tag;
	}
	/**
	 * Gets whether this room is a hallway.
	 *
	 * @return whether the room is a hallway room
	 */
	public boolean isHallway() {
		return hallway;
	}
	public int hashCode() {
		return file.hashCode();
	}
	/**
	 * Changes the preview image for this room.
	 *
	 * @param preview the preview image (computed at runtime) of this room
	 */
	public void setPreviewImage(final Image preview) {
		this.preview = preview;
	}
	public String toString() {
		return getClass().getSimpleName() + "[name=" + name + ", size=" + size + "]";
	}
	public void toXML(PrintWriter out, int indent) {
		Utils.addTag(out, indent, "room", "name", Utils.xmlEncode(name), "src",
			Utils.xmlEncode(file), "size", size.toExternalForm(), "tag",
			Utils.xmlEncode(tag), "/");
	}
}