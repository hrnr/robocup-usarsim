package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Pools UTReferences to archetypes (which can be required in large numbers, straining the heap)
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
class PooledArchetypes {
	private static final Map<String, UTReference> arch =
		new LinkedHashMap<String, UTReference>(32);

	protected static UTReference getArchetype(final String type) {
		final String lcType = type.toLowerCase();
		UTReference out = arch.get(lcType);
		if (out == null) {
			synchronized (arch) {
				out = new UTReference(type, "Engine", "Default__" + type);
				arch.put(lcType, out);
			}
		}
		return out;
	}
}