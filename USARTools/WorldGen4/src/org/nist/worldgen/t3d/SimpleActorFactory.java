package org.nist.worldgen.t3d;

import java.lang.reflect.*;

/**
 * Creates actors using their class.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SimpleActorFactory extends AbstractActorFactory {
	private final Class<? extends Actor> actorClass;
	private final Constructor<? extends Actor> actorConstructor;

	/**
	 * Creates a new simple actor factory, using its class (StaticMeshActor.class, ...)
	 *
	 * @param aClass the actor class to use
	 */
	public SimpleActorFactory(final Class<? extends Actor> aClass) {
		if (aClass.isInterface() || Modifier.isAbstract(aClass.getModifiers()))
			throw new IllegalArgumentException("Cannot instantiate " + aClass);
		actorClass = aClass;
		try {
			actorConstructor = actorClass.getConstructor(String.class);
		} catch (NoSuchMethodException e) {
			throw new IllegalStateException("Cannot construct " + getHandledType() +
				" using SimpleActorFactory - no simple constructor", e);
		}
	}
	protected Actor initObject(UTAttributeSet in) {
		// Assume one constructor with String argument for simplicity
		try {
			return actorConstructor.newInstance(in.get("Name"));
		} catch (InvocationTargetException e) {
			throw new RuntimeException("Error when instantiating type " + getHandledType(),
				e.getTargetException());
		} catch (Exception e) {
			throw new IllegalStateException("Access error when constructing " +
				getHandledType(), e);
		}
	}
	public String getHandledType() {
		return actorClass.getSimpleName();
	}
}