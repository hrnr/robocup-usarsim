package org.nist.worldgen.t3d;

import java.io.PrintWriter;

/**
 * Represents a light in Unreal/UDK.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class Light extends ComponentActor {
	protected LightComponent lightComponent;

	/**
	 * Creates a new light with the given name.
	 *
	 * @param name the light name
	 */
	protected Light(final String name) {
		super(name);
		lightComponent = null;
	}
	public void addComponent(UTObject object) {
		// Cannot check getType() because that varies per light
		if (object instanceof LightComponent)
			lightComponent = (LightComponent)object;
		super.addComponent(object);
	}
	protected UTObject copyCustom(UTObject other) {
		final Light light = (Light)other;
		light.lightComponent = (LightComponent)getLightComponent().copyOf();
		return super.copyCustom(light);
	}
	protected void addLightSprite(final String spriteName) {
		final SpriteComponent lSprite = new SpriteComponent(getName() + "_Sprite", "Sprite");
		lSprite.setCategoryName("Lighting");
		lSprite.setHidden(true, false);
		lSprite.setScale(0.25);
		lSprite.setSprite(new UTReference("Texture2D", "EditorResources", "LightIcons",
			spriteName));
		addComponent(lSprite);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		super.custom(out, indent, utCompatMode);
	}
	protected boolean customPutAttribute(String key, String value) {
		return super.customPutAttribute(key, value) || key.equalsIgnoreCase("LightComponent");
	}
	protected String getActorKey() {
		return "LightComponent";
	}
	/**
	 * Gets the light component for this light.
	 *
	 * @return the light component determining attributes for this light
	 */
	public LightComponent getLightComponent() {
		return lightComponent;
	}
	public String toString() {
		return toString("name", getName(), "location", getLocation(), "rotation",
			getRotation(), "component", getLightComponent());
	}
}
