package org.nist.worldgen.addons;

import org.nist.worldgen.*;
import org.nist.worldgen.t3d.*;

import java.io.*;
import java.util.*;
import java.util.regex.*;

/**
 * Victimizes (adds victims to) a specified map.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class Victimizer {
	private static final Pattern VICTIM_TAG = Pattern.compile("(?:VictimPackage\\.animation" +
		"\\.)((Generic(?:Male|Female))_AnimTree_[A-Z0-9_]+)", Pattern.CASE_INSENSITIVE);

	protected static void addVictim(final UTMap map, final PathNode template, final int index) {
		// Add victim directly to the map (bypassing WGVictim)
		final Matcher m = VICTIM_TAG.matcher(template.getTag());
		if (m.matches())
			try {
				// Spawn victim, set type and animation tree
				final VictimObject object = AbstractActorFactory.spawn(VictimObject.class,
					"Victim_" + index);
				object.setAnimTree(new UTReference("AnimTree", "VictimPackage", "animation",
					m.group(1)));
				object.setLocation(template.getLocation());
				object.setRotation(template.getRotation());
				object.setVictimType(m.group(2));
				map.addComponent(object);
			} catch (SpawnException ignore) { }
	}
	/**
	 * Adds victims to a specified, previously-generated T3D file. It will output another T3D
	 * file named "victim_xxx.t3d" where "xxx" is the name of the original file. If more
	 * victims are entered than path nodes, one victim will be placed at each path node. The
	 * generator attempts to group at least 2 victims if possible.
	 * 
	 * @param file the file to modify
	 * @param count the number of victims to add
	 * @param compatMode the Unreal compatibility mode to use for output
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if an error occurs while parsing the file
	 */
	public static void victimize(final File file, int count, final int compatMode)
			throws IOException, T3DException {
		count = Math.max(count, 1);
		// Read old file
		final UTMap map = T3DIO.readMap(file); String tag;
		final List<PathNode> victimNodes = new ArrayList<PathNode>(32);
		// Find victim nodes
		for (PathNode node : map.listObjects(PathNode.class)) {
			tag = node.getTag();
			if (!tag.equalsIgnoreCase("PathNode") && VICTIM_TAG.matcher(tag).matches())
				victimNodes.add(node);
		}
		// Delete these to avoid unnecessary node warnings
		for (PathNode node : victimNodes)
			map.removeComponent(node);
		count = Math.min(count, victimNodes.size());
		// Add as many as possible
		if (count > 1) {
			// Group 2 victims (not 100% accurate, but it is pretty close)
			final int which = Utils.randInt(0, victimNodes.size() - 1); int vi;
			addVictim(map, victimNodes.get(which), which);
			addVictim(map, victimNodes.get(which + 1), which + 1);
			victimNodes.remove(which);
			victimNodes.remove(which + 1);
			// Iterate through the rest that need to be placed
			for (int i = 0; i < count - 2; i++) {
				vi = Utils.randInt(0, victimNodes.size());
				addVictim(map, victimNodes.remove(vi), vi);
			}
		} else if (count == 1) {
			// Cannot try to group 1 victim, so just place it randomly
			final int which = Utils.randInt(0, victimNodes.size());
			addVictim(map, victimNodes.get(which), which);
		}
		// Rename victims uniquely
		new UTObjectModifier(map).run();
		// Find new name
		final File outFile = new File(file.getParentFile(), "victim_" +
			Utils.baseName(file.getName()) + ".t3d");
		final OutputStream os = new BufferedOutputStream(new FileOutputStream(outFile), 1024);
		final PrintWriter out = new PrintWriter(new OutputStreamWriter(os));
		map.toUnrealText(out, 0, compatMode);
		out.flush();
		if (out.checkError())
			throw new IOException("I/O error when writing victim file!");
		out.close();
	}
}