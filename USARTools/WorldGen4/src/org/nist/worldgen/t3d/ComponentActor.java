package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;
import java.util.*;

/**
 * Represents an actor which is composed of components.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class ComponentActor extends Actor implements UTContainer {
	protected UTObject centerObject;
	protected UTReference collision;
	protected final Map<String, UTObject> components;

	/**
	 * Creates a new component-based actor.
	 *
	 * @param name the actor name
	 */
	protected ComponentActor(final String name) {
		super(name);
		centerObject = null;
		collision = null;
		components = new LinkedHashMap<String, UTObject>(8);
	}
	public void addComponent(final UTObject object) {
		if (object.getType().equalsIgnoreCase(getActorType()))
			centerObject = object;
		components.put(object.getName(), object);
		object.setParent(this);
	}
	public void additionalReferences(ReferenceList list) {
		for (UTObject sc : this)
			if (sc != null)
				sc.additionalReferences(list);
		super.additionalReferences(list);
	}
	protected UTObject copyCustom(UTObject other) {
		final ComponentActor comp = (ComponentActor)other; UTObject loop;
		comp.collision = collision;
		for (UTObject sc : components.values()) {
			loop = sc.copyOf();
			comp.addComponent(loop);
		}
		if (centerObject == null)
			comp.centerObject = null;
		else
			comp.centerObject = comp.getComponent(centerObject.getName());
		return super.copyCustom(comp);
	}
	protected void custom(final PrintWriter out, final int indent, int utCompatMode) {
		final UTObject center = getCenterObject();
		final UTReference cc = getCollisionComponent();
		for (UTObject sc : this)
			if (sc != null)
				sc.toUnrealText(out, indent + 1, 0);
		UTUtils.putObjectList(out, indent, "Components", components.values());
		if (cc != null)
			UTUtils.putAttribute(out, indent, "CollisionComponent", cc);
		if (center != null)
			UTUtils.putAttribute(out, indent, getActorKey(), center.asReference());
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		// Ignore these, they are handled by the add component function
		if (!accept) {
			if (key.equalsIgnoreCase("CollisionComponent")) {
				collision = UTUtils.parseReference(value);
				accept = true;
			} else if (key.toLowerCase().startsWith("components(") ||
					key.equalsIgnoreCase(getActorType()))
				accept = true;
		}
		return accept;
	}
	/**
	 * Key name used to output the central actor. Different for Light objects from the
	 * default of getActorType().
	 *
	 * @return the key name used for the central actor
	 */
	protected String getActorKey() {
		return getActorType();
	}
	/**
	 * Gets the actor's central type. This type is placed into the centerObject field (as
	 * well as being placed in the component list) when encountered. Only one is expected.
	 *
	 * @return the actor's type (StaticMeshComponent, BrushComponent...)
	 */
	protected abstract String getActorType();
	/**
	 * Returns the object that the particular subclass declares as central to function.
	 * Example: the PointLightComponent of a PointLight.
	 *
	 * @return the center object of this object, or null if one has not yet been set
	 */
	public UTObject getCenterObject() {
		return centerObject;
	}
	/**
	 * Gets a reference to the collision component of this actor.
	 *
	 * @return the actor's collision component
	 */
	public UTReference getCollisionComponent() {
		return collision;
	}
	/**
	 * Gets the specified component of this object.
	 *
	 * @param compName the component name to look up
	 * @return the component
	 */
	public UTObject getComponent(final String compName) {
		return components.get(compName);
	}
	/**
	 * Gets a component using its static name. More robust but a little slower than getting
	 * the component by its real name.
	 *
	 * @param staticName the component's inherited sub-object name
	 * @return the component
	 */
	public UTComponent getInherited(final String staticName) {
		UTComponent object = null, loop;
		for (UTObject test : components.values())
			if (test instanceof UTComponent) {
				loop = (UTComponent)test;
				if (loop.getStaticName().equalsIgnoreCase(staticName)) {
					object = loop;
					break;
				}
			}
		return object;
	}
	/**
	 * Gets the number of components in this object.
	 *
	 * @return the number of components in this object
	 */
	public int getComponentCount() {
		return components.size();
	}
	public Dimension3D getSize() {
		return Dimension3D.NO_SIZE;
	}
	/**
	 * Allows foreach iteration over this component's objects.
	 *
	 * @return an iterator over this object's components
	 */
	public Iterator<UTObject> iterator() {
		return components.values().iterator();
	}
	/**
	 * Removes all subcomponents of this component.
	 */
	public void reset() {
		for (UTObject obj : components.values())
			obj.setParent(null);
		components.clear();
	}
	public String toString() {
		return toString("name", getName(), "location", getLocation(), "rotation",
			getRotation(), "components", getComponentCount());
	}
	protected void updateReferences(UTObject changed, String oldName) {
		if (collision != null && collision.getName().equalsIgnoreCase(oldName))
			collision = changed.asReference();
		super.updateReferences(changed, oldName);
	}
}