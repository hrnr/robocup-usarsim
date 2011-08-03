package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents the UT world information.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class WorldInfo extends UTObject {
	protected double killZ;
	protected String tag;

	/**
	 * Creates a new WorldInfo object with the given name.
	 *
	 * @param name the object name
	 */
	public WorldInfo(final String name) {
		super(name);
		killZ = -Constants.O_MAX_DIM;
		tag = null;
	}
	public UTObject copyOf() {
		final WorldInfo wi = new WorldInfo(getName());
		wi.setKillZ(getKillZ());
		wi.setTag(getTag());
		return wi;
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("Tag")) {
				setTag(UTUtils.noneAsNull(UTUtils.removeQuotes(value)));
				accept = true;
			} else if (key.equalsIgnoreCase("KillZ")) {
				setKillZ(Double.parseDouble(value));
				accept = true;
			}
		}
		return accept || key.equalsIgnoreCase("bMapNeedsLightingFullyRebuilt") ||
			key.equalsIgnoreCase("bHasPathNodes") || key.equalsIgnoreCase("bPathsRebuilt");
	}
	public Dimension3D getSize() {
		return Dimension3D.NO_SIZE;
	}
	/**
	 * Gets the KillZ, the zone below which actors go to die.
	 *
	 * @return the kill Z value
	 */
	public double getKillZ() {
		return killZ;
	}
	/**
	 * Gets the object's tag.
	 *
	 * @return the object Tag attribute (defaults to class name)
	 */
	public String getTag() {
		return tag;
	}
	/**
	 * Changes the KillZ of this map.
	 *
	 * @param killZ the new kill Z value
	 */
	public void setKillZ(double killZ) {
		this.killZ = killZ;
	}
	/**
	 * Changes the object's tag.
	 *
	 * @param tag the new tag
	 */
	public void setTag(final String tag) {
		this.tag = tag;
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		final double z = getKillZ();
		begin(out, indent, "Actor");
		// Ensure lighting gets rebuilt!
		UTUtils.putAttribute(out, indent, "bMapNeedsLightingFullyRebuilt", "true");
		if (z > -Constants.O_MAX_DIM)
			UTUtils.putAttribute(out, indent, "KillZ", z);
		if (getTag() != null)
			UTUtils.putAttributeQ(out, indent, "Tag", getTag());
		putCustom(out, indent);
		end(out, indent, "Actor");
	}
}