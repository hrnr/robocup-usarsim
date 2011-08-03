package org.nist.worldgen;

/**
 * Converts between Unreal and SI units.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public final class UnitsConverter {
	/**
	 * Conversion factor for angles to UU.
	 */
	public static final double C_ANGLE = 32768.0 / Math.PI;
	/**
	 * Conversion factor for lengths to UU.
	 */
	public static final double C_LENGTH = 250.0;

	/**
	 * Converts an angle from Unreal rotator units to radians.
	 *
	 * @param in the angle to convert
	 * @return the output angle in radians
	 */
	public static double angleFromUU(final double in) {
		return in / C_ANGLE;
	}
	/**
	 * Converts an angle from radians to Unreal rotator units.
	 *
	 * @param in the angle to convert
	 * @return the output angle in Unreal units
	 */
	public static double angleToUU(final double in) {
		return in * C_ANGLE;
	}
	/**
	 * Converts the given Unreal rotator to radians. Note that the Unreal axes still hold.
	 *
	 * @param rot the rotator which contains the angle values
	 * @return a Point3D with axis angles matching these angles
	 */
	public static Point3D angleVectorFromUU(final Rotator3D rot) {
		return new Point3D(angleFromUU(rot.getRoll()), angleFromUU(rot.getPitch()),
			angleFromUU(rot.getYaw()));
	}
	/**
	 * Converts a length or coordinate from Unreal units to meters.
	 *
	 * @param in the length to convert
	 * @return the output length in meters
	 */
	public static double lengthFromUU(final double in) {
		return in / C_LENGTH;
	}
	/**
	 * Converts a length or coordinate from meters to Unreal units.
	 *
	 * @param in the length to convert
	 * @return the output length in UU
	 */
	public static double lengthToUU(final double in) {
		return in * C_LENGTH;
	}
	/**
	 * Converts the given UU lengths to meters. Note that the Unreal axes still hold.
	 * <b>No SAE flipping occurs here.</b>
	 *
	 * @param len a Point3D which contains the length values
	 * @return a Point3D with SI coordinates matching these lengths
	 */
	public static Point3D lengthVectorFromUU(final Point3D len) {
		return new Point3D(lengthFromUU(len.getX()), lengthFromUU(len.getY()),
			lengthFromUU(len.getZ()));
	}
	/**
	 * Converts the given meter sizes to UU. Note that the Unreal axes still hold.
	 * <b>No SAE flipping occurs here.</b>
	 *
	 * @param size a Dimension3D which contains the size values
	 * @return a Dimension3D with UU dimensions matching these sizes
	 */
	public static Dimension3D sizeToUU(final Dimension3D size) {
		return new Dimension3D(lengthToUU(size.getDepth()), lengthToUU(size.getWidth()),
			lengthToUU(size.getHeight()));
	}
}