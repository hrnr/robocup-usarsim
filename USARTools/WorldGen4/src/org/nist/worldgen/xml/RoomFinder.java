package org.nist.worldgen.xml;

import java.io.*;
import java.util.*;

/**
 * Finds the file name of a room on the file system given its friendly name. Just like Unreal,
 * the world generator allows almost any directory structure, so long as file names are unique.
 * When a call goes out for the room named "computer_lab.t3d", this class will know where the
 * actual room is.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class RoomFinder implements FileFilter {
	private final File base;
	private final Map<String, File> fileIndex;

	/**
	 * Creates an empty room finder, but no files will resolve unless index() is called first.
	 *
	 * @param base the base path where rooms will be stored
	 */
	public RoomFinder(final File base) {
		File baseFile;
		try {
			baseFile = base.getCanonicalFile();
		} catch (IOException e) {
			baseFile = base.getAbsoluteFile();
		}
		this.base = baseFile;
		fileIndex = new HashMap<String, File>(128);
	}
	public boolean accept(File pathname) {
		final String name = pathname.getName();
		return !pathname.isHidden() && pathname.canRead() && (pathname.isDirectory() ||
			(pathname.isFile() && name.toLowerCase().endsWith(".t3d")));
	}
	/**
	 * Finds the location where the room should go.
	 *
	 * @param room the room to output
	 * @return where the room belongs in the directory structure
	 */
	public synchronized File getOutputLocation(final WGRoom room) {
		final IntDimension3D size = room.getSize();
		return new File(base, String.format("Modules_%dx%d%s%s", size.depth, size.width,
			File.separator, room.getFileName()));
	}
	/**
	 * Indexes the Modules/ folder.
	 */
	public synchronized void index() {
		fileIndex.clear();
		index(base);
	}
	protected void index(final File directory) {
		final File[] files = directory.listFiles(this);
		if (files != null && files.length > 0)
			for (File file : files) {
				if (file.isDirectory())
					index(file);
				else
					fileIndex.put(file.getName(), file);
			}
	}
	/**
	 * Finds the file for the specified module.
	 *
	 * @param name the module's file name
	 * @return the path to that module, or null if the module does not exist
	 */
	public synchronized File lookup(final String name) {
		return fileIndex.get(name);
	}
	/**
	 * Prepares the output location of this room.
	 *
	 * @param room the room that will be written
	 * @throws IOException if an I/O error occurs
	 */
	public void writeOutputLocation(final WGRoom room) throws IOException {
		final File loc = getOutputLocation(room), par = loc.getParentFile();
		if (!par.exists() && !par.mkdir())
			throw new IOException("Failed to create output directory");
		if (!par.canWrite())
			throw new IOException("Cannot write room to output directory");
		fileIndex.put(room.getFileName(), loc);
	}
}