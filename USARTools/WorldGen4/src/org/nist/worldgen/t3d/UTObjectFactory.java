package org.nist.worldgen.t3d;

import java.lang.reflect.*;
import java.util.*;

/**
 * A class which spits out instances of Java objects to match T3D objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class UTObjectFactory {
	/**
	 * Creates a new actor.
	 *
	 * @param actorClass the actor class to spawn
	 * @param name the actor name
	 * @param <T> makes everything convenient
	 * @return the spawned actor
	 * @throws SpawnException if an error occurs during the spawn process
	 */
	public static <T extends Actor> T spawn(final Class<T> actorClass, String name)
			throws SpawnException {
		final Constructor<T> cons; final T actor;
		try {
			cons = actorClass.getConstructor(String.class);
		} catch (NoSuchMethodException e) {
			throw new SpawnException("Specified actor has no simple constructor", e);
		}
		if (name == null)
			name = actorClass.getSimpleName();
		try {
			actor = cons.newInstance(name);
			actor.initDefaults();
		} catch (Exception e) {
			throw new SpawnException("Error when creating or initializing actor", e);
		}
		return actor;
	}

	/**
	 * Instantiate a UTObject subclass based on information given in the line.
	 *
	 * @param in the parameters from the parser
	 * @return a UTObject subclass representing the line
	 */
	public abstract UTObject createObject(final UTAttributeSet in);
	/**
	 * Gets a glob-style matcher that describes the class names this factory can handle.
	 *
	 * @return a description of which types this factory can handle
	 */
	public abstract String getHandledType();
	/**
	 * Gets a list of glob-style matchers that describes the class names this factory can
	 * handle.
	 *
	 * @return a description of which types this factory can handle
	 */
	public String[] getHandledTypes() {
		return new String[] { getHandledType() };
	}
	public String toString() {
		return "UT Object Factory for type(s): " + Arrays.toString(getHandledTypes());
	}

	/**
	 * The default factory for actors.
	 */
	protected static class DefaultActorFactory extends AbstractActorFactory {
		protected Actor initObject(UTAttributeSet in) {
			return new DefaultActor(in.get("Class"), in.get("Name"));
		}
		public String getHandledType() {
			return "*";
		}
	}

	/**
	 * The default factory for components.
	 */
	protected static class DefaultComponentFactory extends AbstractComponentFactory {
		protected UTComponent initObject(final UTAttributeSet in) {
			return new DefaultComponent(in.get("Class"), in.get("ObjName"), in.get("Name"));
		}
		public String getHandledType() {
			return "*";
		}
	}
}