package org.nist.worldgen.t3d;

import org.nist.worldgen.*;

/**
 * Represents a static mesh's actor in the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class StaticMeshActor extends ComponentActor {
	/**
	 * Creates a new static mesh actor.
	 *
	 * @param name the actor name
	 */
	public StaticMeshActor(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new StaticMeshActor(getName()));
	}
	protected String getActorType() {
		return "StaticMeshComponent";
	}
	protected void initDefaults() {
		final StaticMeshComponent mesh = new StaticMeshComponent(getName() + "_Mesh",
			"StaticMeshComponent0");
		reset();
		mesh.setPrecomputedShadows(true);
		mesh.setCollision(true);
		mesh.initializeLighting(false);
		addComponent(mesh);
	}
}