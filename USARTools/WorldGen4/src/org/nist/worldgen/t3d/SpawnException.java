package org.nist.worldgen.t3d;

/**
 * Represents an error which occurs while spawning an actor.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class SpawnException extends T3DException {
	private static final long serialVersionUID = 0L;

	public SpawnException(String message) {
		super(message);
	}
	public SpawnException(String message, Throwable cause) {
		super(message, cause);
	}
}