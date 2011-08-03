package org.nist.worldgen.xml;

/**
 * Interface describing any object that can obtain world creation parameters.
 *
 * @author Stephen Carlson (NIST)
 * @version 4
 */
public interface WorldCreationParams {
	/**
	 * Asks the user to input the parameters, or collects them from premade data.
	 *
	 * @return whether the operation succeeded
	 */
	public boolean collect();
	/**
	 * Gets the depth of the world.
	 *
	 * @return the world's depth
	 */
	public int getDepth();
	/**
	 * Gets the world's name.
	 *
	 * @return the world name (only useful for suggesting output values, etc.)
	 */
	public String getName();
	/**
	 * Gets the width of the world.
	 *
	 * @return the world's width
	 */
	public int getWidth();
	/**
	 * Gets whether the world is populated with random rooms.
	 *
	 * @return whether random rooms are to be generated
	 */
	public boolean isRandom();
}