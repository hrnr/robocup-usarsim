package org.nist.worldgen.t3d;

import java.lang.reflect.*;

/**
 * Creates components using their class.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SimpleComponentFactory extends AbstractComponentFactory {
	private final Class<? extends UTComponent> componentClass;
	private final Constructor<? extends UTComponent> componentConstructor;

	/**
	 * Creates a new simple component factory, using its class (BrushComponent.class, ...)
	 *
	 * @param cClass the component class to use
	 */
	public SimpleComponentFactory(final Class<? extends UTComponent> cClass) {
		if (cClass.isInterface() || Modifier.isAbstract(cClass.getModifiers()))
			throw new IllegalArgumentException("Cannot instantiate " + cClass);
		componentClass = cClass;
		try {
			componentConstructor = componentClass.getConstructor(String.class, String.class);
		} catch (NoSuchMethodException e) {
			throw new IllegalStateException("Cannot construct " + getHandledType() +
				" using SimpleComponentFactory - no simple constructor", e);
		}
	}
	protected UTComponent initObject(UTAttributeSet in) {
		// Assume one constructor with String, String arguments for simplicity
		try {
			return componentConstructor.newInstance(in.get("ObjName"), in.get("Name"));
		} catch (InvocationTargetException e) {
			throw new RuntimeException("Error when instantiating type " + getHandledType(),
				e.getTargetException());
		} catch (Exception e) {
			throw new IllegalStateException("Access error when constructing " +
				getHandledType(), e);
		}
	}
	public String getHandledType() {
		return componentClass.getSimpleName();
	}
}
