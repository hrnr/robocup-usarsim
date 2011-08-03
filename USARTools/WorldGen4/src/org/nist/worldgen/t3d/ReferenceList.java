package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Represents a list which stores references.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class ReferenceList implements Iterable<UTReference> {
	private final Set<UTReference> references;

	/**
	 * Creates an empty reference list.
	 */
	public ReferenceList() {
		references = new HashSet<UTReference>(256);
	}
	/**
	 * Adds a reference to this list.
	 *
	 * @param ref the reference to add (duplicates will be omitted)
	 */
	public void addReference(final UTReference ref) {
		if (ref != null)
			references.add(ref);
	}
	/**
	 * Checks to see if the given reference is required by this map.
	 *
	 * @param ref the reference to check
	 * @return whether the reference is required
	 */
	public boolean contains(final UTReference ref) {
		return references.contains(ref);
	}
	public Iterator<UTReference> iterator() {
		return references.iterator();
	}
	public String toString() {
		return references.toString();
	}
}