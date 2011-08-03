package org.nist.worldgen;

import org.nist.worldgen.mif.*;
import org.nist.worldgen.t3d.*;
import org.nist.worldgen.xml.*;
import java.io.*;
import java.util.*;

/**
 * Manages I/O to T3D files.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public final class T3DIO implements Constants {
	protected static void addAllRooms(final UTMap map, final WGRoom room, final Point3D origin,
			final Collection<WGRoomInstance> roomList, final WorldExportParams params)
			throws IOException, T3DException {
		// Assumption: all rooms in roomList have the same WGRoom
		final File input = params.findRoom(room.getFileName());
		if (input == null)
			throw new T3DException("File in the database cannot be found on the file system");
		final UTMap obj = readMap(input);
		for (WGRoomInstance inst : roomList)
			addRoom(map, inst, origin, (UTMap)obj.copyOf());
	}
	protected static void addPlayerStarts(final UTMap map, final WGRoomInstance inst,
			final Point3D origin, final int utCompatMode) {
		// Find room center
		final Point3D pos = origin.getLocation();
		pos.setX(pos.getX() - inst.getX() * U_GRID);
		pos.setY(pos.getY() + inst.getY() * U_GRID);
		pos.setZ(pos.getZ() - R_HEIGHT / 2.0 + 40.0);
		try {
			if (utCompatMode == UT_COMPAT_UDK)
				// 1 player start
				map.addComponent(createPlayerStart("AutoPlayerStart_0", pos));
			else if (utCompatMode == UT_COMPAT_UT3) {
				// 16 player starts
				pos.setX(pos.getX() + 1.5 * R_PLAYERSTART_DIFF);
				pos.setY(pos.getY() - 1.5 * R_PLAYERSTART_DIFF);
				int k = 0;
				for (int i = 0; i < 4; i++)
					for (int j = 0; j < 4; j++)
						map.addComponent(createPlayerStart("AutoPlayerStart_" + (k++),
							new Point3D(pos.getX() - R_PLAYERSTART_DIFF * i, pos.getY() +
							R_PLAYERSTART_DIFF * j, pos.getZ())));
			}
		} catch (SpawnException ignore) {
			// Can this happen?
		}
	}
	protected static void addRoom(final UTMap map, final WGRoomInstance inst,
			final Point3D origin, final UTMap instMap) {
		final Point3D pos = origin.getLocation();
		final UTObjectModifier mod = new UTObjectModifier(instMap, String.format("WG_%d_%d_",
			inst.getX(), inst.getY()));
		pos.setX(pos.getX() - (inst.getX() + (inst.getDepth() - 1) / 2.0) * U_GRID);
		pos.setY(pos.getY() + (inst.getY() + (inst.getWidth() - 1) / 2.0) * U_GRID);
		mod.setOffset(pos);
		mod.setRotation(new Rotator3D(0, 0, (65536 - inst.getRotation() * 16384) % 65536));
		mod.run();
		for (UTObject object : instMap)
			map.addComponent(object);
	}
	protected static Map<WGRoom, Collection<WGRoomInstance>> collect(final World world,
			final WorldExportParams params) {
		final Map<WGRoom, Collection<WGRoomInstance>> instMap =
			new HashMap<WGRoom, Collection<WGRoomInstance>>(world.count() * 3 / 2);
		Collection<WGRoomInstance> el; int i = 0;
		for (WGRoomInstance ri : world) {
			el = instMap.get(ri.getRoom());
			if (el == null)
				instMap.put(ri.getRoom(), el = new LinkedList<WGRoomInstance>());
			el.add(ri);
			params.progressMade("Collecting rooms", i * 20 / world.count());
		}
		return instMap;
	}
	protected static PlayerStart createPlayerStart(final String name, final Point3D offset)
			throws SpawnException {
		final PlayerStart start = UTObjectFactory.spawn(PlayerStart.class, name);
		start.setTag(name);
		start.setLocation(offset);
		return start;
	}
	/**
	 * Exports a simple map meant to be used as a template.
	 *
	 * @param size the template area size
	 * @param outFile the file to export to
	 * @throws IOException if an I/O error occurs
	 */
	public static void createTemplate(final IntDimension3D size, final File outFile)
			throws IOException {
		final UTMap output = new UTMap("Template");
		final Rectangle3D extents = intendedRoomSize(size);
		final WorldInfo info = new WorldInfo("WorldInfo_0");
		info.setKillZ(-extents.getHeight());
		output.addComponent(info);
		output.addComponent(BrushFactory.createDefaultBrush());
		output.addComponent(BrushFactory.create6DOP("Brush_0", Utils.expandRectangle(extents,
			2 * R_WALL, true), CSGOperation.CSG_ADD, null));
		output.addComponent(BrushFactory.create6DOP("Brush_1", extents,
			CSGOperation.CSG_SUBTRACT, null));
		writeWorld(outFile, output, UT_COMPAT_UDK);
	}
	/**
	 * Creates a world from its XML representation.
	 *
	 * @param world the world to create
	 * @param params the world export parameters
	 * @return the created map
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if a parse or output error occurs
	 */
	public static UTMap createWorld(final World world, final WorldExportParams params)
			throws IOException, T3DException {
		// Check for hallway
		WGRoomInstance hallway = null;
		for (WGRoomInstance inst : world)
			if (inst.getRoom().isHallway()) {
				hallway = inst;
				break;
			}
		if (hallway == null)
			throw new T3DException("World must have at least one hallway to be exported");
		// Create map
		final UTMap output = new UTMap(world.getName());
		params.progressMade("Collecting rooms", 0);
		final Map<WGRoom, Collection<WGRoomInstance>> collected = collect(world, params);
		// Compute origin
		params.progressMade("Setup map", 5);
		final IntDimension3D dims = world.getSize();
		final Point3D origin = new Point3D(U_GRID * dims.getDepth() / 2.0,
			-U_GRID * dims.getWidth() / 2.0, 0.0);
		// Compute bounds and add a brush of that size
		final Rectangle3D extents = Utils.expandRectangle(intendedRoomSize(dims),
			2 * (R_WALL + U_ROOM), false);
		extents.setZ(extents.getZ() - R_WALL);
		extents.setHeight(extents.getHeight() + 2 * R_WALL);
		final BrushActor addExtents = BrushFactory.create6DOP("OuterBrush", extents,
			CSGOperation.CSG_ADD, null);
		final WorldInfo info = new WorldInfo("WorldInfo_0");
		// Should be comfortably below the lowest floor
		info.setKillZ(-extents.getHeight());
		info.setTag(world.getName());
		output.addComponent(info);
		output.addComponent(BrushFactory.createDefaultBrush());
		output.addComponent(addExtents);
		addPlayerStarts(output, hallway, origin, params.getCompatMode());
		// Add importance volume if UDK
		if (params.getCompatMode() == UT_COMPAT_UDK)
			output.addComponent(BrushFactory.create6DOP(LightmassImportanceVolume.class,
				"LightmassImportanceVolume_0", Utils.expandRectangle(extents, -R_WALL / 2.0,
				true), CSGOperation.CSG_NONE, null));
		// Add all rooms
		int i = 0; final int size = collected.size();
		for (WGRoom room : collected.keySet()) {
			params.progressMade(String.format("Adding rooms (%d/%d)", i, size),
				10 + 40 * i++ / size);
			addAllRooms(output, room, origin, collected.get(room), params);
		}
		// Add items (doors, victims...)
		params.progressMade("Adding other items", 50);
		i = 0;
		for (WGItem item : world.getItems())
			output.addComponent(item.createT3D(origin, i++));
		// Set lighting
		params.progressMade("Adding skylight", 60);
		if (params.isUsingSkylight()) {
			final SkyLight sl = UTObjectFactory.spawn(SkyLight.class, "SkyLight_0");
			((LightComponent)sl.getCenterObject()).setBrightness(2.0);
			output.removeObjects(Light.class);
			output.addComponent(sl);
		}
		params.progressMade("Writing world", 70);
		return output;
	}
	/**
	 * Finds the intended size in UU of a room.
	 *
	 * @param size the room's size in grid units
	 * @return the room's size in UU
	 */
	public static Rectangle3D intendedRoomSize(final IntDimension3D size) {
		return new Rectangle3D(Point3D.ORIGIN, new Dimension3D(U_ROOM + (size.depth - 1) *
			U_GRID, U_ROOM + (size.width - 1) * U_GRID, R_HEIGHT * size.height));
	}
	/**
	 * Parses a world in preparation for adding it to the room library.
	 *
	 * @param input the file to add to the room library
	 * @param room the room data under which this room will be stored
	 * @param forOutput the room finder which can provide the output file name
	 * @param params the world export parameters (the findRoom() method is not used!)
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if a parse error occurs
	 */
	public static void parse(final File input, final WGRoom room, final RoomFinder forOutput,
			final WorldExportParams params) throws IOException, T3DException {
		final File outFile = forOutput.getOutputLocation(room);
		if (outFile.getCanonicalFile().equals(input.getCanonicalFile()))
			throw new T3DException("Input and output files cannot match");
		params.progressMade("Parsing world", 0);
		final UTMap instMap = readMap(input); boolean stop = false;
		final UTObjectModifier mod = new UTObjectModifier(instMap);
		params.progressMade("Map cleanup", 30);
		// Remove all prefabs and world info
		instMap.removeObjects(PrefabInstance.class);
		instMap.removeObjects(WorldInfo.class);
		if (params.isUsingSkylight())
			instMap.removeObjects(Light.class);
		// Drop the default brush and 262144 brush
		params.progressMade("Remove extra brushes", 40);
		final Rectangle3D extents = intendedRoomSize(room.getSize());
		for (BrushActor actor : instMap.listObjects(BrushActor.class))
			if (actor.getAttribute("Layer") != null ||
					actor.getModel().getName().equalsIgnoreCase("Brush"))
				// Not backed by the map, so ok to delete without concurrent mod
				instMap.removeComponent(actor);
			else {
				final Rectangle3D bounds = actor.getBounds();
				if (!extents.contains(bounds)) {
					if (actor.getCSGOperation() == CSGOperation.CSG_SUBTRACT) {
						if (!params.exportWarning("Room boundaries are not sized properly.")) {
							stop = true;
							break;
						}
					} else
						// Delete 262144 and like brushes
						instMap.removeComponent(actor);
				}
			}
		if (!stop) {
			params.progressMade("Remove extra volumes", 50);
			// Drop the gravity, importance, and default physics volumes
			for (Volume volume : instMap.listObjects(Volume.class))
				if (volume.getType().equalsIgnoreCase("GravityVolume") ||
						volume.getType().equalsIgnoreCase("DefaultPhysicsVolume") ||
						volume.getType().equalsIgnoreCase("LightmassImportanceVolume"))
					instMap.removeComponent(volume);
			params.progressMade("Unique names", 60);
			mod.run();
			params.progressMade("Writing to file", 70);
			forOutput.writeOutputLocation(room);
			writeWorld(outFile, instMap, params.getCompatMode());
		}
		params.progressComplete();
	}
	/**
	 * Reads the specified map into memory as Java native objects.
	 *
	 * @param input the file to read
	 * @return the map that was parsed
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if an error occurs while parsing
	 */
	public static UTMap readMap(final File input) throws IOException, T3DException {
		final InputStream is = new BufferedInputStream(new FileInputStream(input), 1024);
		final UTObject obj;
		try {
			obj = T3DParser.parse(is);
			if (obj == null || !(obj instanceof UTMap))
				throw new T3DException("No valid map in the specified room file");
		} finally {
			is.close();
		}
		return (UTMap)obj;
	}
	/**
	 * Writes the map's package requirements to a side-by-side text file.
	 *
	 * @param dir the directory where the map was stored
	 * @param baseName the name of the T3D that was written
	 * @param map the map whose dependencies must be listed
	 * @throws IOException if an I/O error occurs
	 */
	public static void writeDependencies(final File dir, final String baseName,
			final UTMap map) throws IOException {
		final File deps = new File(dir, baseName + ".txt");
		final OutputStream os = new BufferedOutputStream(new FileOutputStream(deps), 1024);
		final PrintWriter out = new PrintWriter(new OutputStreamWriter(os, "ASCII"));
		final ReferenceList refs = map.listReferences();
		// Get all package names, sort, and remove unwanted packages
		final Set<String> packages = new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
		String pack;
		for (UTReference ref : refs) {
			pack = ref.getPackage();
			if (pack != null && pack.length() > 0)
				packages.add(pack);
		}
		packages.remove("Engine");
		packages.remove("EngineMaterials");
		packages.remove("Editor");
		packages.remove("EditorResources");
		// Output useful ones
		if (packages.size() > 0) {
			out.println("Texture packages required for this map:");
			out.println();
			for (String p : packages)
				out.println(p);
		} else
			out.println("Only the default texture packages are required for this map.");
		out.flush();
		out.close();
		if (out.checkError())
			throw new IOException("Error when writing map dependencies");
	}
	/**
	 * Writes the world to a T3D file.
	 *
	 * @param target the output file to write
	 * @param world the world to write
	 * @param params the world export parameters
	 * @throws IOException if an I/O error occurs
	 * @throws T3DException if a parse or output error occurs
	 */
	public static void writeWorld(final File target, final World world,
			final WorldExportParams params) throws IOException, T3DException {
		final File parent = target.getParentFile();
		final String name = Utils.baseName(target.getName());
		final UTMap map = createWorld(world, params);
		// Create and write map
		writeWorld(target, map, params.getCompatMode());
		params.progressMade("Writing dependencies", 85);
		writeDependencies(parent, name, map);
		if (params.shouldCreateMIF()) {
			params.progressMade("Writing MIF", 90);
			MifWriter.writeMIF(parent, name, MifWriter.mifFromMap(map));
		}
		params.progressComplete();
	}
	/**
	 * Writes the specified map to a T3D file.
	 *
	 * @param target the file to write the map
	 * @param world the map to write
	 * @param compatMode the compatibility mode to use while outputting
	 * @throws IOException if an I/O error occurs
	 */
	public static void writeWorld(final File target, final UTMap world,
			final int compatMode) throws IOException {
		final OutputStream out = new BufferedOutputStream(new FileOutputStream(target), 1024);
		final PrintWriter writer = new PrintWriter(new OutputStreamWriter(out, "ASCII"));
		try {
			world.toUnrealText(writer, 0, compatMode);
			writer.flush();
			if (writer.checkError())
				throw new IOException("I/O error when writing T3D file");
		} finally {
			writer.close();
		}
	}
}