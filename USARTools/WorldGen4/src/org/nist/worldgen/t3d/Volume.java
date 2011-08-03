package org.nist.worldgen.t3d;

/**
 * Represents any of several types of volume, including blocking volumes, physics volumes,
 * and fog volumes.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class Volume extends BrushActor {
	private final String type;

	/**
	 * Creates a new volume.
	 *
	 * @param name the volume name
	 * @param type the volume type
	 */
	public Volume(final String name, final String type) {
		super(name);
		this.type = type;
	}
	public UTObject copyOf() {
		return copyCustom(new Volume(getName(), getType()));
	}
	public String getType() {
		return type;
	}
	protected void initDefaults() {
		super.initDefaults();
		setCSGOperation(CSGOperation.CSG_NONE);
	}
}