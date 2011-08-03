package org.nist.worldgen.t3d;

/**
 * Represents a game destroyable static mesh's actor in the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class GameBreakableActor extends KActor {
	/**
	 * Creates a new game breakable actor.
	 *
	 * @param name the actor name
	 */
	public GameBreakableActor(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new GameBreakableActor(getName()));
	}
}