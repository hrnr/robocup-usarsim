package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import org.nist.worldgen.mif.MifWriter;
import org.xml.sax.*;

import java.awt.*;
import java.io.*;
import java.util.*;

/**
 * A container which stores the available rooms in XML format.
 *
 * @author Stephen Carlson (NIST)
 * @version 4
 */
public class WGRoomDB implements XMLSerializable, XMLParseable, Iterable<WGRoom>, Constants {
	private final File file;
	private final RoomFinder finder;
	private final WGRoom hallway;
	private final Map<String, WGRoom> rooms;

	/**
	 * Creates a room databse backed by a file.
	 *
	 * @param backing the File which stores room data
	 */
	public WGRoomDB(final File backing) {
		file = backing;
		finder = new RoomFinder(backing.getParentFile());
		hallway = new WGRoom("hallway.t3d", new IntDimension3D(1, 1, 1), "Hallway", "", true);
		rooms = new TreeMap<String, WGRoom>(String.CASE_INSENSITIVE_ORDER);
	}
	/**
	 * Adds a room (assumed already processed and in the file system) to this database.
	 *
	 * @param room the room to add
	 */
	public void addRoom(final WGRoom room) {
		rooms.put(room.getFileName(), room);
	}
	/**
	 * Clears all preview images!
	 */
	public void clearPreviews() {
		Image img;
		for (WGRoom room : rooms.values()) {
			img = room.getPreviewImage();
			if (img != null)
				img.flush();
			room.setPreviewImage(null);
		}
	}
	/**
	 * Computes and saves the preview image for the specified room. Saves a null preview image
	 * if an I/O error occurs.
	 *
	 * @param room the room to (re)compute a preview image
	 */
	public void computePreview(final WGRoom room) {
		final File src = lookup(room.getFileName());
		if (src != null && !room.isHallway() && room.getPreviewImage() == null)
			room.setPreviewImage(MifWriter.generatePreview(src, room));
	}
	/**
	 * Gets the number of rooms loaded.
	 *
	 * @return the number of available rooms
	 */
	public int count() {
		return rooms.size();
	}
	public void fromTag(final String tagName, final Attributes attributes) throws SAXException {
		if (tagName.equals("room")) {
			final String fileName = Utils.xmlDecode(attributes.getValue("src"));
			final String name = Utils.xmlDecode(attributes.getValue("name"));
			final String xTag = attributes.getValue("tag"), tag;
			if (xTag == null || xTag.length() < 1)
				tag = "";
			else
				tag = Utils.xmlDecode(xTag);
			final IntDimension3D size = IntDimension3D.fromExternalForm(
				attributes.getValue("size"));
			if (size == null)
				throw new SAXException("Invalid size for room " + fileName);
			final WGRoom room = new WGRoom(fileName, size, name, tag);
			addRoom(room);
		}
	}
	/**
	 * Gets the hallway room.
	 *
	 * @return the singleton Room used for hallways
	 */
	public WGRoom getHallway() {
		return hallway;
	}
	/**
	 * Gets the room for the specified file name.
	 *
	 * @param name the room name to look up
	 * @return the room, or null if not found
	 */
	public WGRoom getRoom(final String name) {
		final WGRoom ret;
		if (name.equals(hallway.getFileName()))
			ret = hallway;
		else
			ret = rooms.get(name);
		return ret;
	}
	/**
	 * Gets the room finder used to resolve rooms in this database.
	 *
	 * @return the room finder which finds files on the file system
	 */
	public RoomFinder getRoomFinder() {
		return finder;
	}
	/**
	 * Delegate method to ease use in foreach loops.
	 *
	 * @return an iterator over all available rooms
	 */
	public Iterator<WGRoom> iterator() {
		return rooms.values().iterator();
	}
	/**
	 * Looks up a room in the database.
	 *
	 * @param name the room name to look up
	 * @return the path on the file system to that room, or null if the room does not exist
	 */
	public File lookup(final String name) {
		return finder.lookup(name);
	}
	/**
	 * Reads the room data from its backing file.
	 *
	 * @throws IOException if an I/O error occurs while reading
	 */
	public void read() throws IOException {
		clearPreviews();
		rooms.clear();
		if (file.exists())
			Utils.parse(file, this);
		else
			// Obviously nothing to read, so wipe and write
			write();
	}
	/**
	 * Deletes a room from the database.
	 *
	 * @param room the room to remove
	 */
	public void removeRoom(final WGRoom room) {
		rooms.remove(room.getFileName());
	}
	/**
	 * Writes the room data to its backing file.
	 *
	 * @throws IOException if an I/O error occurs while writing
	 */
	public void write() throws IOException {
		Utils.flatten(file, this);
	}
	public void toXML(PrintWriter out, int indent) {
		Utils.addTag(out, indent, "roomList");
		for (WGRoom room : this)
			room.toXML(out, indent + 1);
		Utils.addTag(out, indent, "/roomList");
	}
}