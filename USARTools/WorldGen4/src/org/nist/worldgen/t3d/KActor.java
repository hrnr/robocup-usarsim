package org.nist.worldgen.t3d;

import java.io.PrintWriter;

/**
 * Represents a rigid body's actor in the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class KActor extends ComponentActor {
	/**
	 * Creates a new rigid body actor.
	 *
	 * @param name the actor name
	 */
	public KActor(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new KActor(getName()));
	}
	protected String getActorType() {
		return "StaticMeshComponent";
	}
	protected void initDefaults() {
		final StaticMeshComponent mesh = new StaticMeshComponent(getName() + "_Mesh",
			"StaticMeshComponent0");
		reset();
		mesh.setCollision(true);
		mesh.setRBChannel("RBCC_GameplayPhysics");
		mesh.initializeLighting(true);
		addComponent(mesh);
		addComponent(new DynamicLightEnvironmentComponent(getName() + "_LE",
			"DynamicLightEnvironmentComponent0"));
	}
}