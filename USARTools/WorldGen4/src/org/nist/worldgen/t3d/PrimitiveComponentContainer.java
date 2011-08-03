package org.nist.worldgen.t3d;

import java.io.*;
import java.util.*;

/**
 * A PrimitiveComponent that can contain other objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class PrimitiveComponentContainer extends PrimitiveComponent
		implements UTContainer {
	protected final List<UTObject> objects;

	/**
	 * Creates a new primitive component.
	 *
	 * @param name the object name
	 * @param staticName the name which matches the template for the real object
	 */
	protected PrimitiveComponentContainer(final String name, final String staticName) {
		super(name, staticName);
		objects = new ArrayList<UTObject>(8);
	}
	public void addComponent(UTObject object) {
		objects.add(object);
		object.setParent(this);
	}
	public void additionalReferences(ReferenceList list) {
		for (UTObject sc : objects)
			sc.additionalReferences(list);
		super.additionalReferences(list);
	}
	protected UTObject copyCustom(UTObject other) {
		for (UTObject sc : objects)
			other.addComponent(sc.copyOf());
		return super.copyCustom(other);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		for (UTObject sc : objects)
			sc.toUnrealText(out, indent + 1, 0);
	}
	public Iterator<UTObject> iterator() {
		return objects.iterator();
	}
	/**
	 * Removes all components from this object.
	 */
	public void reset() {
		for (UTObject obj : objects)
			obj.setParent(null);
		objects.clear();
	}
}
