package org.nist.worldgen.t3d;

/**
 * Thrown to indicate an error with T3D generation unrelated to I/O.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class T3DException extends Exception {
	private static final long serialVersionUID = 0L;

	public T3DException(String message) {
		super(message);
	}
	public T3DException(String message, Throwable cause) {
		super(message, cause);
	}
}
