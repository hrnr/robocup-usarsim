package org.nist.worldgen.t3d;

import org.nist.worldgen.Dimension3D;

import java.io.PrintWriter;

/**
 * Represents a skeletal mesh component used in skeletal mesh actors.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SkeletalMeshComponent extends PrimitiveComponentContainer {
	protected UTReference animTreeTemplate;
	protected UTReference animations;
	protected UTReference skeletalMesh;

	/**
	 * Creates a new skeletal mesh component.
	 *
	 * @param name the object name
	 * @param staticName the name which matches the template for the real object
	 */
	public SkeletalMeshComponent(final String name, final String staticName) {
		super(name, staticName);
		animTreeTemplate = null;
		animations = null;
		skeletalMesh = null;
	}
	public void additionalReferences(ReferenceList list) {
		super.additionalReferences(list);
		list.addReference(animations);
		list.addReference(animTreeTemplate);
		list.addReference(skeletalMesh);
	}
	public UTObject copyOf() {
		final SkeletalMeshComponent smc = new SkeletalMeshComponent(getName(), getStaticName());
		smc.setAnimTree(getAnimTree());
		smc.setSkeletalMesh(getSkeletalMesh());
		smc.animations = animations;
		return copyCustom(smc);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		final UTReference animTree = getAnimTree(), mesh = getSkeletalMesh();
		super.custom(out, indent, utCompatMode);
		if (mesh != null)
			UTUtils.putAttribute(out, indent, "SkeletalMesh", mesh);
		if (animTree != null)
			UTUtils.putAttribute(out, indent, "AnimTreeTemplate",
				UTUtils.nullAsNone(animTree));
		if (animations != null)
			UTUtils.putAttribute(out, indent, "Animations",
				UTUtils.nullAsNone(animations));
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("AnimTreeTemplate")) {
				setAnimTree(UTUtils.parseReference(value));
				accept = true;
			} else if (key.equalsIgnoreCase("Animations")) {
				animations = UTUtils.parseReference(value);
				accept = true;
			} else if (key.equalsIgnoreCase("SkeletalMesh")) {
				setSkeletalMesh(UTUtils.parseReference(value));
				accept = true;
			}
		}
		return accept;
	}
	/**
	 * Gets the animation tree used to animate this skeletal mesh component.
	 *
	 * @return the animation tree used to move the component
	 */
	public UTReference getAnimTree() {
		return animTreeTemplate;
	}
	/**
	 * Gets the skeletal mesh used by this skeletal mesh component.
	 *
	 * @return the skeletal mesh used by this component
	 */
	public UTReference getSkeletalMesh() {
		return skeletalMesh;
	}
	/**
	 * Changes the animation tree used by this skeletal mesh component.
	 *
	 * @param animTreeTemplate the animation tree to use
	 */
	public void setAnimTree(final UTReference animTreeTemplate) {
		this.animTreeTemplate = animTreeTemplate;
	}
	/**
	 * Changes the skeletal mesh used by this component.
	 *
	 * @param skeletalMesh the new skeletal mesh to use
	 */
	public void setSkeletalMesh(final UTReference skeletalMesh) {
		this.skeletalMesh = skeletalMesh;
	}
	public String toString() {
		return toString("name", getName(), "parent", getParent().getName(), "mesh",
			getSkeletalMesh(), "animation", getAnimTree());
	}

	/**
	 * Represents the AnimNodeSequence object for custom animations on skeletal meshes.
	 */
	public static class AnimNodeSequence extends UTObject {
		/**
		 * Creates a new AnimNodeSequence object.
		 *
		 * @param name the sequence name
		 */
		public AnimNodeSequence(final String name) {
			super(name);
		}
		public UTObject copyOf() {
			return copyCustom(new AnimNodeSequence(getName()));
		}
		public Dimension3D getSize() {
			return Dimension3D.NO_SIZE;
		}
		public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
			begin(out, indent, "Object");
			putCustom(out, indent);
			end(out, indent, "Object");
		}
	}
}
