package org.nist.worldgen.t3d;

/**
 * Allow users to pass code to be run on items of a specified type in a map.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface UTIterator<T extends UTObject> {
	/**
	 * Run commands for the specified item.
	 *
	 * @param item the object to run code
	 */
	public void run(T item);
}