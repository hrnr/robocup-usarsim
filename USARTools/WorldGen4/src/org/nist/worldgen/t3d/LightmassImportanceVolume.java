package org.nist.worldgen.t3d;

/**
 * Represents the UDK volume used to indicate a zone as being important for Lightmass.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class LightmassImportanceVolume extends Volume {
	/**
	 * Creates a new lightmass importance volume.
	 *
	 * @param name the volume's name
	 */
	public LightmassImportanceVolume(final String name) {
		super(name, "LightmassImportanceVolume");
	}
	public UTObject copyOf() {
		return copyCustom(new LightmassImportanceVolume(getName()));
	}
	protected void initDefaults() {
		super.initDefaults();
		final PrimitiveComponent bc = (PrimitiveComponent)getCenterObject();
		bc.putAttribute("bDisableAllRigidBody", Boolean.TRUE);
		bc.setRBChannel("RBCC_Nothing");
	}
}