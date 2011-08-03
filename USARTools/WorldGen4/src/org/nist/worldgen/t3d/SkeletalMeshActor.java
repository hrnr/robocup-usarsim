package org.nist.worldgen.t3d;

/**
 * Represents a skeletal mesh's actor in the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SkeletalMeshActor extends ComponentActor {
	/**
	 * Creates a new skeletal mesh actor.
	 *
	 * @param name the actor name
	 */
	public SkeletalMeshActor(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new SkeletalMeshActor(getName()));
	}
	protected String getActorType() {
		return "SkeletalMeshComponent";
	}
	protected void initDefaults() {
		reset();
		addComponent(new SkeletalMeshComponent(getName() + "Mesh", "SkeletalMeshComponent0"));
	}
}