package org.nist.worldgen.addons;

import org.nist.worldgen.*;
import org.nist.worldgen.t3d.*;
import org.nist.worldgen.xml.*;
import java.awt.*;
import java.util.*;
import java.util.List;

/**
 * Generates mazes for the World Generator with a given ramp difficulty.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class Maze implements Constants {
	private static final Point[] MOVE = new Point[] {
		new Point(-1, 0), new Point(0, 1), new Point(1, 0), new Point(0, -1)
	};

	private static int direction(final Point curr, final Point next) {
		final byte dir;
		switch (next.y - curr.y) {
		case 1:
			// move east
			dir = FACE_EAST;
			break;
		case -1:
			// move west
			dir = FACE_WEST;
			break;
		default:
			switch (next.x - curr.x) {
			case 1:
				// move south
				dir = FACE_SOUTH;
				break;
			case -1:
				// move north
				dir = FACE_NORTH;
				break;
			default:
				throw new RuntimeException("Invalid offset in ramp generation!");
			}
		}
		return dir;
	}

	private final int cols;
	private final int difficulty;
	private final int incline;
	private final byte[][] maze;
	private transient final int per;
	private final int rows;
	private final UTReference[] tex;
	private transient final double thick;
	private transient final double zh;

	/**
	 * Creates an empty maze.
	 *
	 * @param rows the number of rows
	 * @param cols the number of columns
	 * @param difficulty the difficulty: A_YELLOW, A_ORANGE, A_CLEAR
	 * @param incline the degree of ramp inclination
	 */
	public Maze(final int rows, final int cols, final int difficulty, final int incline) {
		this.cols = cols;
		this.difficulty = difficulty;
		this.incline = incline;
		maze = new byte[rows][cols];
		this.rows = rows;
		// Initialize these values fromm the configuration
		per = WGConfig.getInteger("WorldGen.MazeCellsPerGrid");
		tex = BrushFactory.allTextures(new UTReference(
			WGConfig.getProperty("WorldGen.MazeWallMat")));
		tex[4] = new UTReference(WGConfig.getProperty("WorldGen.MazeFloorMat"));
		tex[5] = new UTReference(WGConfig.getProperty("WorldGen.MazeCeilMat"));
		thick = UnitsConverter.lengthToUU(WGConfig.getDouble("WorldGen.MazeWallThickness"));
		zh = UnitsConverter.lengthToUU(WGConfig.getDouble("WorldGen.MazeWallHeight"));
	}
	private void addMazePolygons(final UTMap map, final Rectangle3D size) {
		// Write polygons
		final double z = (zh - R_HEIGHT) / 2.0, half = U_GRID / (2.0 * per);
		Rectangle3D bounds; Point3D center;
		for (int x = 0; x < rows; x++)
			for (int y = 0; y < cols; y++) {
				center = computeCellOrigin(size, x, y);
				if (x > 0 && (maze[x][y] & A_NORTH) != 0) {
					// North walls
					bounds = new Rectangle3D(new Point3D(center.getX() + half, center.getY() -
						thick / 2.0, z), new Dimension3D(thick, half * 2.0, zh));
					map.addComponent(BrushFactory.create6DOP("Maze_N" + x + "_" + y,
						bounds, CSGOperation.CSG_ADD, tex));
				}
				if (y > 0 && (maze[x][y] & A_WEST) != 0) {
					// West walls
					bounds = new Rectangle3D(new Point3D(center.getX() + thick / 2.0,
						center.getY() - half, z), new Dimension3D(half * 2.0, thick, zh));
					map.addComponent(BrushFactory.create6DOP("Maze_W" + x + "_" + y,
						bounds, CSGOperation.CSG_ADD, tex));
				}
			}
	}
	private void addRamp(final UTMap map, final int direction, final Point3D center,
			final int id) {
		final Dimension3D rampSize = new Dimension3D(U_GRID / per, U_GRID / per - thick, 0.0);
		map.addComponent(createRamp(direction, new Rectangle3D(center, rampSize), id));
	}
	private void addRamps(final UTMap map, final Rectangle3D size) {
		Point curr = new Point(Utils.randInt(0, rows), Utils.randInt(0, cols)), next; int r, c;
		// Initialize direction array (holds direction that the ramp faces)
		final int[][] dirs = new int[rows][cols];
		for (r = 0; r < rows; r++)
			for (c = 0; c < cols; c++)
				dirs[r][c] = 4;
		// Visit all squares and add ramps according to difficulty
		final LinkedList<Point> stack = new LinkedList<Point>();
		final List<Point> neighbors = new ArrayList<Point>(4);
		stack.push(curr);
		// Initialize the first square
		dirs[curr.x][curr.y] = FACE_NORTH;
		while (!stack.isEmpty()) {
			// Look for unvisited neighbors where solver can go according to the maze walls
			for (int i = FACE_NORTH; i <= FACE_WEST; i++) {
				r = curr.x + MOVE[i].x; c = curr.y + MOVE[i].y;
				if (r >= 0 && c >= 0 && r < rows && c < cols && dirs[r][c] > FACE_WEST
						&& canGo(curr, next = new Point(r, c)))
					neighbors.add(next);
			}
			if (neighbors.isEmpty())
				curr = stack.pop();
			else {
				// Add found ramps to the array
				stack.push(curr);
				curr = setRamps(curr, dirs, neighbors);
				neighbors.clear();
			}
		}
		createRamps(map, size, dirs);
	}
	private void createRamps(UTMap map, Rectangle3D size, int[][] dirs) {
		int rampID = 0; boolean add;
		final double prob = WGConfig.getDouble("WorldGen.OrangeRampProbability");
		// Write ramps to map
		for (int r = 0; r < rows; r++)
			for (int c = 0; c < cols; c++) {
				switch (difficulty) {
				case A_YELLOW:
					// Always add ramp (continuous)
					add = true;
					break;
				case A_ORANGE:
					// Ramp with probability
					add = Math.random() < prob;
					break;
				default:
					add = false;
				}
				if (add)
					addRamp(map, dirs[r][c], computeCellOrigin(size, r, c), rampID++);
			}
	}
	private boolean canGo(final Point current, final Point next) {
		final byte walls = maze[current.x][current.y]; final boolean blocked;
		switch (next.y - current.y) {
		case 1:
			// move east
			blocked = (walls & A_EAST) != 0;
			break;
		case -1:
			// move west
			blocked = (walls & A_WEST) != 0;
			break;
		default:
			switch (next.x - current.x) {
			case 1:
				// move south
				blocked = (walls & A_SOUTH) != 0;
				break;
			case -1:
				// move north
				blocked = (walls & A_NORTH) != 0;
				break;
			default:
				throw new RuntimeException("Invalid offset in ramp generation!");
			}
		}
		return !blocked;
	}
	private Point3D computeCellOrigin(final Rectangle3D size, final int x, final int y) {
		final double depth = size.getDepth(), width = size.getWidth(), half = U_GRID / (2.0 *
			per), ox = depth / 2.0 - half, oy = -width / 2.0 + half;
		return new Point3D(-x * depth / rows + ox - thick / 2.0,
			y * width / cols + oy + thick / 2.0, size.getZ());
	}
	/**
	 * Creates a map from this maze. The maze must be generated first!
	 *
	 * @return a map containing this maze's geometry
	 */
	public UTMap createMap() {
		final UTMap map = new UTMap("Maze");
		// World preparation
		final WorldInfo info = new WorldInfo("WorldInfo_0");
		info.setKillZ(-R_HEIGHT);
		map.addComponent(info);
		map.addComponent(BrushFactory.createDefaultBrush());
		try {
			map.addComponent(AbstractActorFactory.spawn(SkyLight.class, "SkyLight_0"));
		} catch (SpawnException ignore) { }
		// Create bounds
		final Rectangle3D extents = T3DIO.intendedRoomSize(new IntDimension3D(rows / per,
			cols / per, 1));
		map.addComponent(BrushFactory.create6DOP("RoomBrush", extents,
			CSGOperation.CSG_SUBTRACT, tex));
		// Add components
		addMazePolygons(map, extents);
		addRamps(map, extents);
		return map;
	}
	private BrushActor createRamp(final int direction, final Rectangle3D bounds,
			final int id) {
		final BrushActor brush;
		// sin(x) approximately equals x for our purposes (angles << 30 degrees)
		final double sinT = Math.toRadians(incline);
		final double height = Math.max(bounds.getWidth(), bounds.getDepth()) * sinT;
		// Compute points on the bottom rectangle
		final double z = bounds.getZ();
		final Point3D sbl = new Point3D(bounds.getX(), bounds.getY(), z);
		final Point3D sbr = new Point3D(bounds.getX(), bounds.getMaxY(), z);
		final Point3D tbr = new Point3D(bounds.getMaxX(), bounds.getMaxY(), z);
		final Point3D tbl = new Point3D(bounds.getMaxX(), bounds.getY(), z);
		try {
			brush = AbstractActorFactory.spawn(BrushActor.class, "Ramp_" + id);
		} catch (SpawnException ignore) {
			// Should never happen; satisfy Java with exception to kill uninitialized error
			throw new IllegalArgumentException("Invalid ramp parameters");
		}
		final Brush bm = brush.getModel();
		// Tall side (facing NORTH when direction == 0)
		final Point3D ttl = tbl.getLocation(), ttr = tbr.getLocation();
		ttl.setZ(ttl.getZ() + height); ttr.setZ(ttr.getZ() + height);
		bm.addComponent(BrushFactory.createPolygon(tex[0], tbl, tbr, ttr, ttl));
		// Incline
		bm.addComponent(BrushFactory.createPolygon(tex[5], sbl, ttl, ttr, sbr));
		// Left and right sides
		bm.addComponent(BrushFactory.createPolygon(tex[1], sbl, tbl, ttl));
		bm.addComponent(BrushFactory.createPolygon(tex[2], sbr, ttr, tbr));
		// Bottom
		bm.addComponent(BrushFactory.createPolygon(tex[4], sbl, sbr, tbr, tbl));
		brush.setCSGOperation(CSGOperation.CSG_ADD);
		// Rotate to position
		bm.transform(Point3D.ORIGIN, new Rotator3D(0, 0, (65536 - direction * 16384) % 65536),
			new Point3D(bounds.getCenterX(), bounds.getCenterY(), 0.0));
		return brush;
	}
	/**
	 * Generates the maze.
	 */
	public void generate() {
		int r, c, index;
		for (r = 0; r < rows; r++)
			for (c = 0; c < cols; c++)
				maze[r][c] = A_ALL;
		final LinkedList<Point> stack = new LinkedList<Point>();
		final List<Point> neighbors = new ArrayList<Point>(4);
		Point curr = new Point(Utils.randInt(0, rows), Utils.randInt(0, cols)), next;
		stack.push(curr);
		// Visit all cells
		while (!stack.isEmpty()) {
			// Look for neighbors with all walls
			for (int i = FACE_NORTH; i <= FACE_WEST; i++) {
				r = curr.x + MOVE[i].x; c = curr.y + MOVE[i].y;
				if (r >= 0 && c >= 0 && r < rows && c < cols && maze[r][c] == A_ALL)
					neighbors.add(new Point(r, c));
			}
			if (neighbors.isEmpty())
				// Not found, backtrack
				curr = stack.pop();
			else {
				// If found, select one and remove the matching wall
				index = Utils.randInt(0, neighbors.size());
				stack.push(curr);
				next = neighbors.get(index);
				switch (direction(curr, next)) {
				case FACE_EAST:
					// move east
					maze[curr.x][curr.y] &= ~A_EAST;
					maze[next.x][next.y] &= ~A_WEST;
					break;
				case FACE_WEST:
					// move west
					maze[curr.x][curr.y] &= ~A_WEST;
					maze[next.x][next.y] &= ~A_EAST;
					break;
				case FACE_SOUTH:
					// move south
					maze[curr.x][curr.y] &= ~A_SOUTH;
					maze[next.x][next.y] &= ~A_NORTH;
					break;
				case FACE_NORTH:
					// move north
					maze[curr.x][curr.y] &= ~A_NORTH;
					maze[next.x][next.y] &= ~A_SOUTH;
					break;
				default:
				}
				curr = next;
				neighbors.clear();
			}
		}
	}
	private static Point setRamps(final Point curr, final int[][] dirs,
			final List<Point> neighbors) {
		int dir, cx, cy; Point inDir = null;
		cx = curr.x; cy = curr.y;
		// Look for points where ramps can be added
		for (Point next : neighbors) {
			dir = direction(curr, next);
			// Find a direction that matches if available
			if (dir % 2 == dirs[cx][cy] % 2) {
				dirs[next.x][next.y] = (dirs[cx][cy] + 2) % 4;
				inDir = next;
				break;
			}
		}
		// If cannot go straight, select first available point and go that route
		if (inDir == null) {
			inDir = neighbors.get(0);
			dirs[inDir.x][inDir.y] = direction(curr, inDir);
		}
		return inDir;
	}
}