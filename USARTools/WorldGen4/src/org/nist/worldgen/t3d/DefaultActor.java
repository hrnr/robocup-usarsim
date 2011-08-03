package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * When no native representation is available for an actor, this actor steps in to maintain
 * perfect fidelity with the original world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class DefaultActor extends ComponentActor {
	protected final String type;

	/**
	 * Creates a new default actor with the given name.
	 *
	 * @param type the type to emulate
	 * @param name the actor's name
	 */
	public DefaultActor(final String type, final String name) {
		super(name);
		this.type = type;
	}
	public UTObject copyOf() {
		return copyCustom(new DefaultActor(getType(), getName()));
	}
	// This will never be used since centerObject is always null!
	protected String getActorType() {
		return "Default";
	}
	public String getType() {
		return type;
	}
	protected void initDefaults() {
		throw new UnsupportedOperationException("Default actors cannot be spawned");
	}
}