package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Represents a reference to an Unreal object.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTReference {
	private static boolean nullCmp(final String one, final String two) {
		return (one == null && two == null) || (one != null && two != null &&
			one.equalsIgnoreCase(two));
	}

	private final String group;
	private final String name;
	private final String pack;
	private final String type;

	/**
	 * Decodes an Unreal reference from its namesake string.
	 *
	 * @param toDecode the reference to decode
	 */
	public UTReference(final String toDecode) {
		this(null, toDecode);
	}
	/**
	 * Decodes an Unreal reference from its namesake string.
	 *
	 * @param type the reference type (StaticMesh, Model, BrushComponent...)
	 * @param toDecode the reference to decode
	 */
	public UTReference(final String type, final String toDecode) {
		if (toDecode == null || toDecode.length() < 1)
			throw new IllegalArgumentException("Invalid reference: " + toDecode);
		this.type = type;
		final StringTokenizer str = new StringTokenizer(toDecode, ".");
		String grp = "";
		if (str.countTokens() > 1)
			pack = str.nextToken();
		else
			pack = "";
		while (str.countTokens() > 1) {
			if (grp.length() > 0)
				grp += '.';
			grp += str.nextToken();
		}
		group = grp;
		name = str.nextToken();
	}
	/**
	 * Creates an Unreal reference from component parts.
	 *
	 * @param type the reference type
	 * @param pack the package name, or null for a relative reference
	 * @param name the object name
	 */
	public UTReference(final String type, final String pack, final String name) {
		group = null;
		this.name = name;
		this.pack = pack;
		this.type = type;
	}
	/**
	 * Creates an Unreal reference from component parts.
	 *
	 * @param type the reference type
	 * @param pack the package name, or null for a relative reference
	 * @param group the group name
	 * @param name the object name
	 */
	public UTReference(final String type, final String pack, final String group,
			final String name) {
		this.group = group;
		this.name = name;
		this.pack = pack;
		this.type = type;
	}
	public boolean equals(Object other) {
		if (!(other instanceof UTReference)) return false;
		final UTReference obj = (UTReference)other;
		return nullCmp(getName(), obj.getName()) && nullCmp(getType(), obj.getType()) &&
			nullCmp(getPackage(), obj.getPackage()) && nullCmp(getGroup(), obj.getGroup());
	}
	/**
	 * Gets the referenced object's group.
	 *
	 * @return the group attribute of that object
	 */
	public String getGroup() {
		return group;
	}
	/**
	 * Gets the referenced object's name.
	 *
	 * @return the name of that object
	 */
	public String getName() {
		return name;
	}
	/**
	 * Gets the referenced object's package.
	 *
	 * @return the package of that object
	 */
	public String getPackage() {
		return pack;
	}
	/**
	 * Gets the type of this reference.
	 *
	 * @return the reference type
	 */
	public String getType() {
		return type;
	}
	public int hashCode() {
		return toString().hashCode();
	}
	/**
	 * Checks to see if this reference is absolute.
	 *
	 * @return whether the reference contains a package name (and is therefore absolute)
	 */
	public boolean isAbsolute() {
		return pack != null;
	}
	public String toString() {
		final String grp = getGroup(), pc = getPackage(), typ = getType();
		final StringBuilder output = new StringBuilder(64);
		if (typ != null && typ.length() > 0) {
			output.append(typ);
			output.append('\'');
		}
		if (pc != null && pc.length() > 0) {
			output.append(pc);
			output.append('.');
		}
		if (grp != null && grp.length() > 0) {
			output.append(grp);
			output.append('.');
		}
		output.append(getName());
		if (typ != null && typ.length() > 0)
			output.append('\'');
		return output.toString();
	}
}