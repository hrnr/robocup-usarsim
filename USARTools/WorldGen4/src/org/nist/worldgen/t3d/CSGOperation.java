package org.nist.worldgen.t3d;

/**
 * Last modified: 7/8/11
 *
 * @author scarlson
 * @version 1
 */
public final class CSGOperation {
	/**
	 * Unknown or invalid CSG operation.
	 */
	public static final int CSG_NONE = 0;
	/**
	 * CSG addition operation.
	 */
	public static final int CSG_ADD = 1;
	/**
	 * CSG subtraction operation.
	 */
	public static final int CSG_SUBTRACT = 2;
	/**
	 * CSG addition operation.
	 */
	public static final int CSG_INTERSECT = 3;
	/**
	 * CSG subtraction operation.
	 */
	public static final int CSG_DEINTERSECT = 4;

	/**
	 * Parses a CSG operation from a string.
	 *
	 * @param in the string to parse
	 * @return the matching CSG operation, or CSG_NONE if invalid or undefined
	 */
	public static int csgFromString(final String in) {
		final int csg;
		if (in.equalsIgnoreCase("CSG_Add"))
			csg = CSG_ADD;
		else if (in.equalsIgnoreCase("CSG_Subtract"))
			csg = CSG_SUBTRACT;
		else if (in.equalsIgnoreCase("CSG_Intersect"))
			csg = CSG_INTERSECT;
		else if (in.equalsIgnoreCase("CSG_Deintersect"))
			csg = CSG_DEINTERSECT;
		else
			csg = CSG_NONE;
		return csg;
	}
	/**
	 * Converts a CSG operation back to its Unreal string.
	 *
	 * @param csg the CSG operation to convert
	 * @return a string that Unreal can understand
	 */
	public static String csgToString(final int csg) {
		final String out;
		switch (csg) {
		case CSG_ADD:
			out = "CSG_Add";
			break;
		case CSG_SUBTRACT:
			out = "CSG_Subtract";
			break;
		case CSG_INTERSECT:
			out = "CSG_Intersect";
			break;
		case CSG_DEINTERSECT:
			out = "CSG_Deintersect";
			break;
		case CSG_NONE:
		default:
			out = "None";
		}
		return out;
	}

	// Probably won't be used as a class
	private CSGOperation() { }
}