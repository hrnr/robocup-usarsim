package org.nist.worldgen.t3d;

/**
 * Partial implementation of UTObjectFactory for Actor objects and subclasses.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class AbstractActorFactory extends UTObjectFactory {
	/**
	 * Initializes the object this factory is to return.
	 *
	 * @param in the attributes read during creation
	 * @return an instance of the appropriate actor
	 */
	protected abstract Actor initObject(final UTAttributeSet in);
	public UTObject createObject(final UTAttributeSet in) {
		final Actor obj = initObject(in);
		obj.setArchetype(UTUtils.parseReference(in.get("Archetype")));
		return obj;
	}
	public abstract String getHandledType();
}
