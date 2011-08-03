package org.nist.worldgen.t3d;

import java.io.*;

/**
 * Represents an Unreal path node.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class PathNode extends ComponentActor {
	/**
	 * Creates a new path node with the specified name.
	 *
	 * @param name the actor name
	 */
	public PathNode(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new PathNode(getName()));
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		super.custom(out, indent, utCompatMode);
		// Paths are always changed (force rebuild)
		UTUtils.putAttribute(out, indent, "bPathsChanged", "true");
	}
	protected boolean customPutAttribute(String key, String value) {
		return super.customPutAttribute(key, value) || key.equalsIgnoreCase("bPathsChanged") ||
			key.equalsIgnoreCase("NavGuid") || key.equalsIgnoreCase("nextNavigationPoint") ||
			key.equalsIgnoreCase("NetworkID");
	}
	protected String getActorType() {
		return "CylinderComponent";
	}
	protected void initDefaults() {
		final SpriteComponent good = new SpriteComponent(getName() + "_Good", "Sprite");
		final SpriteComponent bad = new SpriteComponent(getName() + "_Bad", "Sprite2");
		final ArrowComponent arrow = new ArrowComponent(getName() + "_Arrow", "Arrow");
		arrow.setArrowSize(0.5);
		arrow.setArrowColor(new UTColor(150, 200, 255, 255));
		arrow.setCategoryName("Navigation");
		bad.setCategoryName("Navigation");
		bad.setHidden(true, true);
		bad.setScale(0.25);
		bad.setSprite(new UTReference("Texture2D", "EditorResources", "Bad"));
		good.setCategoryName("Navigation");
		good.setHidden(true, false);
		good.setSprite(new UTReference("Texture2D", "EditorResources", "S_Pickup"));
		reset();
		addComponent(new CylinderComponent(getName() + "_Cylinder", "CollisionCylinder"));
		addComponent(good);
		addComponent(bad);
		addComponent(arrow);
		addComponent(new PathRenderingComponent(getName() + "_PathRender",
			"PathRenderer"));
	}

	/**
	 * Represents the path renderer assigned to each path node.
	 */
	public static class PathRenderingComponent extends PrimitiveComponent {
		public PathRenderingComponent(final String name, final String staticName) {
			super(name, staticName);
			initializeLighting(true);
		}
		public UTObject copyOf() {
			return copyCustom(new PathRenderingComponent(getName(), getStaticName()));
		}
		protected void custom(PrintWriter out, int indent, int utCompatMode) { }
	}
}