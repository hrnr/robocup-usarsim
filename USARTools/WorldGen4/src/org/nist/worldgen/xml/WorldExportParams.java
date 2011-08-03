package org.nist.worldgen.xml;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Parameters passed to the T3D exporter.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface WorldExportParams extends ProgressListener {
	/**
	 * Show an export warning to the user.
	 *
	 * @param message the warning message to show
	 * @return whether export should continue
	 */
	public boolean exportWarning(final String message);
	/**
	 * Finds the file system path to the specified room.
	 *
	 * @param name the room's friendly file name
	 * @return the path to that room, or null if not found
	 */
	public File findRoom(final String name);
	/**
	 * Gets the Unreal compatibility mode.
	 *
	 * @return the UT version that the map should be compatible with
	 */
	public int getCompatMode();
	/**
	 * Gets whether lighting uses a single skylight or uses room lights.
	 *
	 * @return skylight (true) or room lights (false)
	 */
	public boolean isUsingSkylight();
	/**
	 * Gets whether a MIF file should be generated.
	 *
	 * @return whether a MIF file is generated along with the world
	 */
	public boolean shouldCreateMIF();
}