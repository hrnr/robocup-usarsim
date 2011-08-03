package org.nist.worldgen.t3d;

import java.lang.reflect.*;

/**
 * Creates generic objects using their types. If the object can reasonably be construed as a
 * component or an actor, use those instead! This is for last-resorts such as the top level
 * package and world info!
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SimpleObjectFactory extends UTObjectFactory {
	private final Class<? extends UTObject> objectClass;

	/**
	 * Creates a new simple object factory, using its class
	 *
	 * @param oClass the actor class to use
	 */
	public SimpleObjectFactory(final Class<? extends UTObject> oClass) {
		if (oClass.isInterface() || Modifier.isAbstract(oClass.getModifiers()))
			throw new IllegalArgumentException("Cannot instantiate " + oClass);
		objectClass = oClass;
	}
	public UTObject createObject(UTAttributeSet in) {
		// Assume one constructor with String argument for simplicity; this class is not used
		// often enough to make it worthy to precache the constructor
		try {
			final Constructor<? extends UTObject> cons =
				objectClass.getConstructor(String.class);
			return cons.newInstance(in.get("Name"));
		} catch (InvocationTargetException e) {
			throw new RuntimeException("Error when instantiating type " + getHandledType(),
				e.getTargetException());
		} catch (Exception e) {
			throw new IllegalStateException("Cannot construct " + getHandledType() +
				" using SimpleObjectFactory", e);
		}
	}
	public String getHandledType() {
		return objectClass.getSimpleName();
	}
}
