package org.nist.worldgen.t3d;

/**
 * Represents a value read from an Unreal T3D file which is not yet mapped to a Java type.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTConstant {
	private String value;

	/**
	 * Creates a new Unreal constant.
	 *
	 * @param value the constant value
	 */
	public UTConstant(final String value) {
		this.value = value;
	}
	/**
	 * Gets the value of this constant.
	 *
	 * @return the value read from the T3D file
	 */
	public String getValue() {
		return value;
	}
	public String toString() {
		return value;
	}
}
