package org.nist.worldgen.t3d;

import java.io.PrintWriter;

/**
 * Represents the dynamic light environments used for movable actors (UDK).
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class DynamicLightEnvironmentComponent extends UTComponent {
	/**
	 * Creates a new dynamic light environment.
	 *
	 * @param name the object name
	 * @param staticName the name which matches the template for the real object
	 */
	public DynamicLightEnvironmentComponent(final String name, final String staticName) {
		super(name, staticName);
	}
	public UTObject copyOf() {
		return copyCustom(new DynamicLightEnvironmentComponent(getName(), getStaticName()));
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) { }
}
