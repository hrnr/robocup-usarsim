package org.nist.worldgen.t3d;

/**
 * Represents a player start.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class PlayerStart extends PathNode {
	/**
	 * Creates a new player start with the specified name.
	 *
	 * @param name the actor name
	 */
	public PlayerStart(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new PlayerStart(getName()));
	}
	protected void initDefaults() {
		super.initDefaults();
		final CylinderComponent cc = (CylinderComponent)getInherited("CollisionCylinder");
		cc.setHeight(80.0);
		cc.setRadius(40.0);
		((SpriteComponent)getInherited("Sprite")).setSprite(new UTReference("Texture2D",
			"EditorResources", "S_Player"));
	}
}