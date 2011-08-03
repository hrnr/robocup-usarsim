package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents a spot light.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SpotLight extends Light {
	/**
	 * Creates a new spot light with the given name.
	 *
	 * @param name the light name
	 */
	public SpotLight(final String name) {
		super(name);
	}
	public void addComponent(UTObject object) {
		final String type = object.getType();
		if (!type.equalsIgnoreCase("DrawLightRadiusComponent") &&
				!type.equalsIgnoreCase("DrawLightConeComponent"))
			super.addComponent(object);
	}
	public UTObject copyOf() {
		return copyCustom(new SpotLight(getName()));
	}
	protected String getActorType() {
		return "SpotLightComponent";
	}
	protected void initDefaults() {
		final ArrowComponent arrow = new ArrowComponent(getName() + "_Arrow",
			"ArrowComponent0");
		arrow.setArrowColor(new UTColor(150, 200, 255, 255));
		arrow.setCategoryName("Lighting");
		reset();
		addComponent(new SpotLightComponent(getName() + "_Light", "SpotLightComponent0"));
		addComponent(arrow);
		addLightSprite("Light_Spot_Stationary_Statics");
	}

	/**
	 * Represents the spot light component that defines every spot light.
	 */
	public static class SpotLightComponent extends LightComponent {
		protected double innerConeAngle;
		protected double outerConeAngle;
		protected double innerRadius;
		protected double outerRadius;

		/**
		 * Creates a new spot light component.
		 *
		 * @param name the object name
		 * @param staticName the name which matches the template for the real object
		 */
		public SpotLightComponent(final String name, final String staticName) {
			super(name, staticName);
			innerRadius = innerConeAngle = 0.0;
			outerConeAngle = 44.0;
			outerRadius = 1024.0;
		}
		public UTObject copyOf() {
			final SpotLightComponent slc = new SpotLightComponent(getName(), getStaticName());
			slc.setInnerConeAngle(getInnerConeAngle());
			slc.setInnerRadius(getInnerRadius());
			slc.setOuterConeAngle(getOuterConeAngle());
			slc.setOuterRadius(getOuterRadius());
			return copyCustom(slc);
		}
		protected void custom(PrintWriter out, int indent, int utCompatMode) {
			final double inRad = getInnerRadius(), outRad = getOuterRadius();
			final double inAngle = getInnerConeAngle(), outAngle = getOuterConeAngle();
			if (!Utils.doubleEquals(inRad, 0.0))
				UTUtils.putAttribute(out, indent, "InnerRadius", String.format("%f", inRad));
			if (!Utils.doubleEquals(outRad, 1024.0))
				UTUtils.putAttribute(out, indent, "OuterRadius", String.format("%f", outRad));
			if (!Utils.doubleEquals(inAngle, 0.0))
				UTUtils.putAttribute(out, indent, "InnerConeAngle",
					String.format("%f", inAngle));
			if (!Utils.doubleEquals(outAngle, 44.0))
				UTUtils.putAttribute(out, indent, "OuterConeAngle",
					String.format("%f", outAngle));
			super.custom(out, indent, utCompatMode);
		}
		protected boolean customPutAttribute(String key, String value) {
			boolean accept = super.customPutAttribute(key, value);
			if (!accept) {
				if (key.equalsIgnoreCase("InnerRadius")) {
					setInnerRadius(Double.parseDouble(value));
					accept = true;
				} else if (key.equalsIgnoreCase("OuterRadius")) {
					setOuterRadius(Double.parseDouble(value));
					accept = true;
				} else if (key.equalsIgnoreCase("InnerConeAngle")) {
					setInnerConeAngle(Double.parseDouble(value));
					accept = true;
				} else if (key.equalsIgnoreCase("OuterConeAngle")) {
					setOuterConeAngle(Double.parseDouble(value));
					accept = true;
				}
			}
			return accept;
		}
		/**
		 * Gets the inner cone angle.
		 *
		 * @return the angle inside which no light is cast
		 */
		public double getInnerConeAngle() {
			return innerConeAngle;
		}
		/**
		 * Gets the inner radius.
		 *
		 * @return the distance inside which no light is cast
		 */
		public double getInnerRadius() {
			return innerRadius;
		}
		/**
		 * Gets the outer cone angle.
		 *
		 * @return the angle which limits the spread of illumination
		 */
		public double getOuterConeAngle() {
			return outerConeAngle;
		}
		/**
		 * Gets the outer cone angle.
		 *
		 * @return the radius which limits the spread of illumination
		 */
		public double getOuterRadius() {
			return outerRadius;
		}
		/**
		 * Changes the inner cone angle.
		 *
		 * @param innerConeAngle the new inner cone angle
		 */
		public void setInnerConeAngle(double innerConeAngle) {
			this.innerConeAngle = innerConeAngle;
		}
		/**
		 * Changes the inner radius.
		 *
		 * @param innerRadius the new inner radius
		 */
		public void setInnerRadius(double innerRadius) {
			this.innerRadius = innerRadius;
		}
		/**
		 * Changes the outer cone angle.
		 *
		 * @param outerConeAngle the new outer cone angle
		 */
		public void setOuterConeAngle(double outerConeAngle) {
			this.outerConeAngle = outerConeAngle;
		}
		/**
		 * Changes the outer radius.
		 *
		 * @param outerRadius the new outer radius
		 */
		public void setOuterRadius(double outerRadius) {
			this.outerRadius = outerRadius;
		}
		public String toString() {
			return toString("name", getName(), "parent", getParent().getName(), "radius",
				"[" + getInnerRadius() + "-" + getOuterRadius() + "]", "angle", "[" +
				getInnerConeAngle() + "-" + getOuterConeAngle() + "]", "brightness=%.2f",
				getBrightness(), "color", getColor());
		}
	}
}