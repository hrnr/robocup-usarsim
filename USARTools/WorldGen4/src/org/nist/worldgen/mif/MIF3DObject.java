package org.nist.worldgen.mif;

import org.nist.worldgen.*;

/**
 * Represents a 3D object that the MIF writer can use to calculate free and dead space.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface MIF3DObject {
	/**
	 * Gets this object's name.
	 *
	 * @return the object name
	 */
	public String getName();
	/**
	 * Gets this object's type.
	 *
	 * @return the object type
	 */
	public String getType();
	/**
	 * Gets the polygons contained within this object.
	 *
	 * @return the polygons inside the object
	 */
	public Iterable<? extends MifPolygon> getPolygons();
}