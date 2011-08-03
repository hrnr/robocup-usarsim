package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents a point light.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class PointLight extends Light {
	/**
	 * Creates a new point light with the given name.
	 *
	 * @param name the light name
	 */
	public PointLight(final String name) {
		super(name);
	}
	public void addComponent(UTObject object) {
		if (!object.getType().equalsIgnoreCase("DrawLightRadiusComponent"))
			super.addComponent(object);
	}
	public UTObject copyOf() {
		return copyCustom(new PointLight(getName()));
	}
	protected String getActorType() {
		return "PointLightComponent";
	}
	protected void initDefaults() {
		reset();
		addComponent(new PointLightComponent(getName() + "_Light", "PointLightComponent0"));
		addLightSprite("Light_Point_Stationary_Statics");
	}

	/**
	 * Represents the point light component that defines every point light.
	 */
	public static class PointLightComponent extends LightComponent {
		protected double radius;

		/**
		 * Creates a new point light component.
		 *
		 * @param name the object name
		 * @param staticName the name which matches the template for the real object
		 */
		public PointLightComponent(final String name, final String staticName) {
			super(name, staticName);
			radius = 1024.0;
		}
		public UTObject copyOf() {
			final PointLightComponent plc = new PointLightComponent(getName(), getStaticName());
			plc.setRadius(getRadius());
			return copyCustom(plc);
		}
		protected void custom(PrintWriter out, int indent, int utCompatMode) {
			final double rad = getRadius();
			if (!Utils.doubleEquals(rad, 1024.0))
				UTUtils.putAttribute(out, indent, "Radius", String.format("%s", rad));
			super.custom(out, indent, utCompatMode);
		}
		protected boolean customPutAttribute(String key, String value) {
			boolean accept = super.customPutAttribute(key, value);
			if (!accept && key.equalsIgnoreCase("Radius")) {
				setRadius(Double.parseDouble(value));
				accept = true;
			}
			return accept || key.equalsIgnoreCase("PreviewLightRadius") ||
				key.equalsIgnoreCase("PreviewLightSourceRadius");
		}
		/**
		 * Gets the radius of this point light.
		 *
		 * @return the light's illumination radius
		 */
		public double getRadius() {
			return radius;
		}
		/**
		 * Changes the radius of this point light.
		 *
		 * @param radius the light's new radius
		 */
		public void setRadius(double radius) {
			this.radius = radius;
		}
		public String toString() {
			return toString("name", getName(), "parent", getParent().getName(), "radius=%.1f",
				getRadius(), "brightness=%.2f", getBrightness(), "color", getColor());
		}
	}
}