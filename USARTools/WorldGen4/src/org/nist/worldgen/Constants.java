package org.nist.worldgen;

import javax.swing.*;
import javax.swing.border.Border;
import java.awt.*;

/**
 * Contains important constants shared by all parts of the World Generator.
 * Note that user configurable constants from the config file do not belong here,
 * although their defaults might.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public interface Constants {
	/**
	 * Represents the north wall (maze generator).
	 */
	public static final byte A_NORTH = 1;
	/**
	 * Represents the east wall.
	 */
	public static final byte A_EAST = 2;
	/**
	 * Represents the south wall.
	 */
	public static final byte A_SOUTH = 4;
	/**
	 * Represents the west wall.
	 */
	public static final byte A_WEST = 8;
	/**
	 * Represents all directions.
	 */
	public static final byte A_ALL = A_NORTH + A_EAST + A_SOUTH + A_WEST;
	/**
	 * Represents a maze with no ramps.
	 */
	public static final int A_CLEAR = 0;
	/**
	 * Represents the orange difficulty level (random ramps, with probability)
	 */
	public static final int A_ORANGE = 1;
	/**
	 * Represents the yellow difficulty level (continuous ramps)
	 */
	public static final int A_YELLOW = 2;
	/**
	 * Probability of a door remaining on the first pass (all possible locations)
	 */
	public static final double D_1DOOR_PROB = 0.7;
	/**
	 * Probability of a door remaining on the second pass (between rooms)
	 */
	public static final double D_2DOOR_PROB = 0.7;
	/**
	 * Probability of a room appearing (per available square) around the hallways
	 */
	public static final double D_HALL_PROB = 0.7;
	/**
	 * Maximum horizontal spacing between vertical hallways.
	 */
	public static final int D_HI_MAX = 5;
	/**
	 * Minimum horizontal spacing between vertical hallways.
	 */
	public static final int D_HI_MIN = 3;
	/**
	 * Maximum number of doors a room may have.
	 */
	public static final int D_MAX_DOORS = 4;
	/**
	 * Probability of a room appearing (per available square) around the outside border
	 * Prevents the border from totally filling with 1x1 rooms
	 */
	public static final double D_OUTSIDE_PROB = 0.7;
	/**
	 * Minimum world size for a size-1 border room.
	 */
	public static final int D_SIZE_ONE = 5;
	/**
	 * Minimum world size for a size-2 border room.
	 */
	public static final int D_SIZE_TWO = 9;
	/**
	 * Maximum vertical spacing between horizontal hallways.
	 */
	public static final int D_VI_MAX = 5;
	/**
	 * Minimum vertical spacing between horizontal hallways.
	 */
	public static final int D_VI_MIN = 3;
	/**
	 * Indicates no rotation (facing north)
	 */
	public static final int FACE_NORTH = 0;
	/**
	 * Indicates 90 degrees CW rotation (facing east)
	 */
	public static final int FACE_EAST = 1;
	/**
	 * Indicates 180 degrees (C)CW rotation (facing south)
	 */
	public static final int FACE_SOUTH = 2;
	/**
	 * Indicates 90 degrees CCW rotation (facing west)
	 */
	public static final int FACE_WEST = 3;
	/**
	 * Background color of the overhead view.
	 */
	public static final Color G_BG = new Color(255, 255, 255);
	/**
	 * Background color of the overhead view in invalid space (outside world bounds).
	 */
	public static final Color G_BG_INVALID = new Color(63, 63, 63);
	/**
	 * Color used for coordinate rules.
	 */
	public static final Color G_BG_OVERLAY = new Color(31, 31, 31);
	/**
	 * Light blue color (user interface)
	 */
	public static final Color G_BLUE = new Color(204, 204, 255);
	/**
	 * Border color used for placed rooms.
	 */
	public static final Color G_BLUE_BORDER = Color.BLUE;
	/**
	 * Gray color (user interface)
	 */
	public static final Color G_DOOR = new Color(63, 63, 63, 127);
	/**
	 * Border color used for doors.
	 */
	public static final Color G_DOOR_BORDER = Color.BLACK;
	/**
	 * The door height in pixels.
	 */
	public static final int G_DOOR_HEIGHT = 4;
	/**
	 * The door width in pixels. Note that this is not dependent on the door size option!
	 */
	public static final int G_DOOR_WIDTH = 16;
	/**
	 * Light green color (user interface)
	 */
	public static final Color G_GREEN = new Color(204, 255, 204);
	/**
	 * Border color used for placed hallways.
	 */
	public static final Color G_GREEN_BORDER = Color.GREEN;
	/**
	 * The default size in pixels of one grid square on the screen.
	 */
	public static final int G_GRID = 48;
	/**
	 * Color used for the grid lines.
	 */
	public static final Color G_GRID_COLOR = new Color(204, 204, 230);
	/**
	 * Color used to render the BSP preview projection.
	 */
	public static final Color G_OBJECT = new Color(31, 31, 31, 127);
	/**
	 * Light orange color (user interface)
	 */
	public static final Color G_SELECT = new Color(255, 218, 204);
	/**
	 * Border color used for placed hallways.
	 */
	public static final Color G_SELECT_BORDER = new Color(255, 127, 0);
	/**
	 * Light red color (user interface)
	 */
	public static final Color G_RED = new Color(255, 150, 150);
	/**
	 * Border color used for invalid placement.
	 */
	public static final Color G_RED_BORDER = Color.RED;
	/**
	 * Integer color used for free space.
	 */
	public static final int M_COLOR_FREE = 65280;
	/**
	 * Integer color used for ramps.
	 */
	public static final int M_COLOR_RAMP = 16776960;
	/**
	 * Integer color used for walls.
	 */
	public static final int M_COLOR_WALL = 16711680;
	/**
	 * Shapes with areas smaller than this will be ignored in the MIF.
	 */
	public static final double M_MIN_AREA = 1e-4;
	/**
	 * Should lights be output in the MIF?
	 */
	public static final boolean M_OUTPUT_LIGHTS = false;
	/**
	 * Should path nodes and player starts be output in the MIF?
	 */
	public static final boolean M_OUTPUT_NODES = true;
	/**
	 * Should volumes be output in the MIF? Even if so, they will appear as a dot!
	 */
	public static final boolean M_OUTPUT_VOLUMES = false;
	/**
	 * Symbol used by the MIF writer for static meshes.
	 */
	public static final String M_SM_SYMBOL = "Symbol(34, 1, 4)";
	/**
	 * Whether the MIF writer always outputs roll, pitch, yaw (even though constant and 0).
	 */
	public static final boolean M_FORCE_ROT = false;
	/**
	 * Border used to surround the tree entries.
	 */
	public static final Border O_ENTRY_BORDER = BorderFactory.createEmptyBorder(0, 2, 0, 0);
	/**
	 * The maximum size of a rectangle in Unreal.
	 */
	public static final double O_MAX_DIM = 262144.0;
	/**
	 * Path to the modules stored on the file system, relative to current directory.
	 */
	public static final String O_ROOT_PATH = "Modules/";
	/**
	 * Default window title (prepends other titles as well).
	 */
	public static final String O_TITLE = "World Generator for UDK";
	/**
	 * Each room is a multiple of the specified height.
	 */
	public static final double R_HEIGHT = 896.;
	/**
	 * The largest allowable room dimension.
	 */
	public static final int R_MAX_DIM = 32;
	/**
	 * The spacing between the 16 automatically generated player starts.
	 */
	public static final double R_PLAYERSTART_DIFF = 200.0;
	/**
	 * Each module gets a wall thickness between it and the next module.
	 */
	public static final double R_WALL = 16.0;
	/**
	 * Rooms come in units of blocks, where a block is a specified quantity of meters.
	 */
	public static final double U_BLOCK = 3.0;
	/**
	 * The largest allowable world size.
	 */
	public static final int U_MAX_DIM = 128;
	/**
	 * The length of a meter in Unreal units.
	 */
	public static final double U_METER = UnitsConverter.lengthToUU(1.0);
	/**
	 * The size of one room in Unreal units.
	 */
	public static final double U_ROOM = U_METER * U_BLOCK;
	/**
	 * The size of a block in Unreal units.
	 */
	public static final double U_GRID = U_ROOM + 2 * R_WALL;
	/**
	 * Indicates compatibility with UT3.
	 */
	public static final int UT_COMPAT_UT3 = 1;
	/**
	 * Indicates compatibility with UDK.
	 */
	public static final int UT_COMPAT_UDK = 2;
}