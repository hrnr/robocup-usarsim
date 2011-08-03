package org.nist.worldgen.t3d;

/**
 * Represents a sky light.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SkyLight extends Light {
	/**
	 * Creates a new sky light with the given name.
	 *
	 * @param name the light name
	 */
	public SkyLight(final String name) {
		super(name);
	}
	public UTObject copyOf() {
		return copyCustom(new SkyLight(getName()));
	}
	protected String getActorType() {
		return "SkyLightComponent";
	}
	protected void initDefaults() {
		final SkyLightComponent slc = new SkyLightComponent(getName() + "_Light",
			"SkyLightComponent0");
		slc.putAttribute("bCanAffectDynamicPrimitivesOutsideDynamicChannel", Boolean.TRUE);
		reset();
		addComponent(slc);
		addLightSprite("Light_SkyLight");
	}

	/**
	 * Represents the sky light component that defines every sky light.
	 */
	public static class SkyLightComponent extends LightComponent {
		/**
		 * Creates a new sky light component.
		 *
		 * @param name the object name
		 * @param staticName the name which matches the template for the real object
		 */
		public SkyLightComponent(final String name, final String staticName) {
			super(name, staticName);
		}
		public UTObject copyOf() {
			return copyCustom(new SkyLightComponent(getName(), getStaticName()));
		}
	}
}