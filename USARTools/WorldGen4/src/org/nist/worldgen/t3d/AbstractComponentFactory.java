package org.nist.worldgen.t3d;

/**
 * Partial implementation of UTObjectFactory for Component objects and subclasses.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class AbstractComponentFactory extends UTObjectFactory {
	/**
	 * Initializes the object this factory is to return.
	 *
	 * @param in the attributes read during creation
	 * @return an instance of the appropriate component
	 */
	protected abstract UTComponent initObject(final UTAttributeSet in);
	public UTObject createObject(final UTAttributeSet in) {
		final UTComponent obj = initObject(in);
		obj.setParent(in.getParent());
		obj.setArchetype(UTUtils.parseReference(in.get("Archetype")));
		return obj;
	}
	public abstract String getHandledType();
}