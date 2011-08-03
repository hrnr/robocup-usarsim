package org.nist.worldgen.t3d;

/**
 * Represents a directional light.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class DirectionalLight extends Light {
	/**
	 * Creates a new directional light with the given name.
	 *
	 * @param name the light name
	 */
	public DirectionalLight(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new DirectionalLight(getName()));
	}
	protected String getActorType() {
		return "DirectionalLightComponent";
	}
	protected void initDefaults() {
		final ArrowComponent arrow = new ArrowComponent(getName() + "_Arrow",
			"ArrowComponent0");
		arrow.setArrowColor(new UTColor(150, 200, 255, 255));
		arrow.setCategoryName("Lighting");
		reset();
		addComponent(new DirectionalLightComponent(getName() + "_Light",
			"DirectionalLightComponent0"));
		addComponent(arrow);
		addLightSprite("Light_Directional_Stationary_UserSelected");
	}

	/**
	 * Represents the directional light component that defines every directional light.
	 */
	public static class DirectionalLightComponent extends LightComponent {
		/**
		 * Creates a new directional light component.
		 *
		 * @param name the object name
		 * @param staticName the name which matches the template for the real object
		 */
		public DirectionalLightComponent(final String name, final String staticName) {
			super(name, staticName);
		}
		public UTObject copyOf() {
			return copyCustom(new DirectionalLightComponent(getName(), getStaticName()));
		}
	}
}