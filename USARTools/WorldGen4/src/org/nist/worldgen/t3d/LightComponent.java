package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents a light component used as part of lights.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class LightComponent extends PrimitiveComponent {
	protected double brightness;
	protected String classification;
	protected UTColor color;
	protected boolean lCastShadows;
	protected boolean lCastStaticShadows;
	protected boolean lCastDynamicShadows;
	protected String lightmassSettings;
	protected boolean useDirectLightMap;

	protected LightComponent(String name, String staticName) {
		super(name, staticName);
		brightness = 1.0;
		classification = null;
		color = UTColor.WHITE;
		lCastShadows = lCastDynamicShadows = true;
		lightmassSettings = null;
		useDirectLightMap = true;
	}
	protected UTObject copyCustom(UTObject other) {
		final LightComponent lc = (LightComponent)other;
		lc.setBrightness(getBrightness());
		lc.setColor(new UTColor(getColor()));
		lc.setCastShadows(lCastShadows);
		lc.classification = classification;
		lc.lCastStaticShadows = lCastStaticShadows;
		lc.lCastDynamicShadows = lCastDynamicShadows;
		lc.lightmassSettings = lightmassSettings;
		lc.useDirectLightMap = useDirectLightMap;
		return super.copyCustom(other);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		final double bright = getBrightness();
		final UTColor col = getColor();
		if (!Utils.doubleEquals(bright, 1.0))
			UTUtils.putAttribute(out, indent, "Brightness", String.format("%f", bright));
		if (!col.equals(UTColor.WHITE))
			UTUtils.putAttribute(out, indent, "Color", col.toExternalForm());
		if (classification != null)
			UTUtils.putAttribute(out, indent, "LightAffectsClassification", classification);
		if (lightmassSettings != null)
			UTUtils.putAttribute(out, indent, "LightmassSettings", lightmassSettings);
		UTUtils.putAttribute(out, indent, "bPrecomputedLightingIsValid", "false");
		if (!lCastShadows)
			UTUtils.putAttribute(out, indent, "CastShadows", "false");
		if (!lCastDynamicShadows)
			UTUtils.putAttribute(out, indent, "CastDynamicShadows", "false");
		if (!lCastStaticShadows)
			UTUtils.putAttribute(out, indent, "CastStaticShadows", "false");
		UTUtils.putAttribute(out, indent, "UseDirectLightMap", useDirectLightMap);
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("Brightness")) {
				setBrightness(Double.parseDouble(value));
				accept = true;
			} else if (key.equalsIgnoreCase("CastShadows")) {
				lCastShadows = Boolean.parseBoolean(value);
				accept = true;
			} else if (key.equalsIgnoreCase("CastStaticShadows")) {
				lCastStaticShadows = Boolean.parseBoolean(value);
				accept = true;
			} else if (key.equalsIgnoreCase("CastDynamicShadows")) {
				lCastDynamicShadows = Boolean.parseBoolean(value);
				accept = true;
			} else if (key.equalsIgnoreCase("Color")) {
				setColor(UTUtils.parseColor(value));
				accept = true;
			} else if (key.equalsIgnoreCase("LightAffectsClassification")) {
				classification = value;
				accept = true;
			} else if (key.equalsIgnoreCase("LightmassSettings")) {
				lightmassSettings = value;
				accept = true;
			} else if (key.equalsIgnoreCase("UseDirectLightMap")) {
				useDirectLightMap = Boolean.parseBoolean(value);
				accept = true;
			}
		}
		return accept || key.equalsIgnoreCase("bPrecomputedLightingIsValid") ||
			key.equalsIgnoreCase("CachedParentToWorld") ||
			key.equalsIgnoreCase("PreviewLightRadius") || key.equalsIgnoreCase("LightGuid") ||
			key.equalsIgnoreCase("PreviewLightSourceRadius") ||
		 	key.equalsIgnoreCase("LightmapGuid") || key.equalsIgnoreCase("PreviewInnerCone") ||
			key.equalsIgnoreCase("PreviewOuterCone");
	}
	/**
	 * Gets the brightness of this light.
	 *
	 * @return the light's brightness
	 */
	public double getBrightness() {
		return brightness;
	}
	/**
	 * Gets the color of this light. Note that Unreal wants the alpha component to be 0 in
	 * most cases; use caution with AWT colors and/or colors from other areas!
	 *
	 * @return the light's color
	 */
	public UTColor getColor() {
		return color;
	}
	/**
	 * Changes the brightness of this light.
	 *
	 * @param brightness the new brightness
	 */
	public void setBrightness(final double brightness) {
		this.brightness = brightness;
	}
	/**
	 * Enables or disables shadows on this light.
	 *
	 * @param castShadows whether shadows should be cast
	 */
	public void setCastShadows(final boolean castShadows) {
		lCastShadows = lCastDynamicShadows = lCastStaticShadows = castShadows;
	}
	/**
	 * Changes the color of this light. Note that Unreal wants the alpha component to be 0 in
	 * most cases; use caution with AWT colors and/or colors from other areas!
	 *
	 * @param color the new color
	 */
	public void setColor(final UTColor color) {
		this.color = color;
	}
	public String toString() {
		return toString("name", getName(), "parent", getParent().getName(), "brightness=%.2f",
			getBrightness(), "color", getColor());
	}
}
