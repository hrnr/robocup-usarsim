package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents an Unreal package used for storing local objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTPackage extends UTObject {
	/**
	 * Creates a new package with the specified name.
	 *
	 * @param name the package name
	 */
	public UTPackage(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new UTPackage(getName()));
	}
	public Dimension3D getSize() {
		return Dimension3D.NO_SIZE;
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		begin(out, indent, "TopLevelPackage");
		putCustom(out, indent);
		end(out, indent, "TopLevelPackage");
	}
}
