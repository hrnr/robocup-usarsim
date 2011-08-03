package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * An object contained inside another object.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class UTComponent extends UTObject {
	protected String staticName;

	/**
	 * Creates a new component. Contrary to expectations, "name" is still the object's
	 * unique name whereas "staticName" is its "Name" field!
	 *
	 * @param name the object name
	 * @param staticName the name which matches the template for the real object
	 */
	protected UTComponent(final String name, final String staticName) {
		super(name);
		parent = null;
		this.staticName = staticName;
	}
	protected void begin(final PrintWriter out, final int indent, final String type) {
		UTUtils.addIndent(out, indent, "Begin ", type, " Class=", getType(), " Name=",
			getStaticName(), " ObjName=", getName(), " Archetype=",
			UTUtils.nullAsNone(getArchetype()));
	}
	/**
	 * Output any custom attributes of this actor.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 * @param utCompatMode the compatibility mode used in the output
	 */
	protected abstract void custom(final PrintWriter out, final int indent, int utCompatMode);
	public UTReference getArchetype() {
		final UTReference arch;
		if (archetype == null) {
			final UTReference par = getParent().getArchetype();
			arch = new UTReference(getType(), par.getPackage(), par.getName() + ':' +
				getStaticName());
		} else
			arch = archetype;
		return arch;
	}
	// Components rarely have a size
	public Dimension3D getSize() {
		return Dimension3D.NO_SIZE;
	}
	/**
	 * Gets the name this object inherited from its parent.
	 *
	 * @return the inherited Name field from the parent's declaration
	 */
	public String getStaticName() {
		return staticName;
	}
	public String toString() {
		return toString("name", getName(), "inheritName", getStaticName(), "parent",
			getParent().getName());
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		begin(out, indent, "Object");
		custom(out, indent, utCompatMode);
		putCustom(out, indent);
		end(out, indent, "Object");
	}
}