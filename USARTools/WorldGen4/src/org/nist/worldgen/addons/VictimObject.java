package org.nist.worldgen.addons;

import org.nist.worldgen.t3d.*;
import java.io.PrintWriter;

/**
 * Represents a victim's T3D skeletal mesh.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class VictimObject extends SkeletalMeshActor {
	protected SkeletalMeshComponent animMesh;
	protected String victimType;

	/**
	 * Creates a new victim object.
	 *
	 * @param name the actor's name
	 */
	public VictimObject(final String name) {
		super(name);
		animMesh = null;
		victimType = "GenericMale";
	}
	public void addComponent(UTObject object) {
		super.addComponent(object);
		if (object instanceof SkeletalMeshComponent) {
			// Handle future file read-ins as well
			final SkeletalMeshComponent comp = (SkeletalMeshComponent)object;
			if (comp.getStaticName().equalsIgnoreCase("WPawnSkeletalMeshComponent"))
				animMesh = comp;
		}
	}
	public UTObject copyOf() {
		final VictimObject obj = (VictimObject)copyCustom(new VictimObject(getName()));
		obj.setVictimType(victimType);
		return obj;
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		super.custom(out, indent, utCompatMode);
	}
	protected String getActorType() {
		return "CylinderComponent";
	}
	public UTReference getArchetype() {
		return new UTReference(getType(), "USARVictim", "Default__" + getType());
	}
	public String getType() {
		final String type;
		if (victimType.toLowerCase().startsWith("generic") && victimType.length() > 7)
			type = victimType.substring(7, victimType.length()) + "Victim";
		else
			type = victimType + "Victim";
		return type;
	}
	protected void initDefaults() {
		// No call to parent, do not need a skeletal mesh component!
		reset();
		addComponent(new CylinderComponent(getName() + "_Cylinder", "CollisionCylinder"));
		addComponent(new ArrowComponent(getName() + "_Arrow", "Arrow"));
		addComponent(new SkeletalMeshComponent(getName() + "_PawnMesh",
			"WPawnSkeletalMeshComponent"));
	}
	/**
	 * Changes the victim's animation tree. Only works if the object was 1) read from a
	 * file, 2) manually initialized, or 3) spawned!
	 *
	 * @param animTree the animation tree to use
	 */
	public void setAnimTree(final UTReference animTree) {
		if (animMesh != null)
			animMesh.setAnimTree(animTree);
	}
	/**
	 * Changes the victim's type (gender)
	 *
	 * @param victimType either "GenericMale" or "GenericFemale"
	 */
	public void setVictimType(final String victimType) {
		this.victimType = victimType;
	}
}