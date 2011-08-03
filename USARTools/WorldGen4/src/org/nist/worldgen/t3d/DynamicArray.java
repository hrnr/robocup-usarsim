package org.nist.worldgen.t3d;

import java.io.PrintWriter;
import java.util.*;

/**
 * Represents a simple and probably inefficient version of UT Dynamic Arrays.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class DynamicArray implements Iterable<Object> {
	protected final List<Object> array;

	/**
	 * Creates a new dynamic array.
	 */
	public DynamicArray() {
		array = new ArrayList<Object>(64);
	}
	/**
	 * Gets the element at the specified index.
	 *
	 * @param index the index to look up
	 * @return the element (in native form) at that index
	 */
	public Object get(final int index) {
		return array.get(index);
	}
	/**
	 * Gets an iterator over the elements.
	 *
	 * @return an iterator over the elements in this dynamic array
	 */
	public Iterator<Object> iterator() {
		return array.iterator();
	}
	/**
	 * Gets the length of this array.
	 *
	 * @return the array length
	 */
	public int length() {
		return array.size();
	}
	/**
	 * Deletes the element at the specified index.
	 *
	 * @param index the index to remove
	 */
	public void remove(final int index) {
		array.remove(index);
	}
	/**
	 * Adds or changes an element in this array.
	 *
	 * @param index the index to put the item at; the array will grow automatically if necessary
	 * @param item the item to add
	 */
	public void set(final int index, final Object item) {
		final int len = length();
		if (index < len)
			array.set(index, item);
		else {
			for (int i = len; i < index; i++)
				array.add(null);
			array.add(item);
		}
	}
	public String toString() {
		return array.toString();
	}
}