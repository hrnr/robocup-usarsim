package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;
import java.util.*;

/**
 * Represents the map containing all UTObjects in a world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class UTMap extends UTObject implements UTContainer {
	private static <T extends UTObject> void allObjects(final Iterable<UTObject> it,
			final Class<T> itemClass, final UTIterator<T> forEach) {
		for (UTObject object : it)
			if (object != null) {
				if (itemClass.isAssignableFrom(object.getClass()))
					forEach.run((T)object);
				if (object instanceof UTContainer)
					allObjects((UTContainer)object, itemClass, forEach);
			}
	}

	protected final List<UTObject> objects;

	/**
	 * Creates a new, empty map.
	 *
	 * @param name the map's name
	 */
	public UTMap(final String name) {
		super(name);
		objects = new LinkedList<UTObject>();
	}
	/**
	 * Adds an object to this map.
	 *
	 * @param object the object to add
	 */
	public void addComponent(final UTObject object) {
		objects.add(object);
		object.setParent(this);
	}
	public void additionalReferences(final ReferenceList list) {
		allObjects(UTObject.class, new UTIterator<UTObject>() {
			public void run(UTObject item) {
				item.additionalReferences(list);
			}
		});
	}
	/**
	 * Iterates over all items of the specified class in the map, running the user specified
	 * code on each one.
	 *
	 * @param itemClass the item class to find
	 * @param forEach the iterator to run on each actor
	 * @param <T> makes everything convenient
	 */
	public <T extends UTObject> void allObjects(final Class<T> itemClass,
			final UTIterator<T> forEach) {
		allObjects(this, itemClass, forEach);
	}
	public UTObject copyOf() {
		final UTMap map = new UTMap(getName());
		for (UTObject obj : objects)
			map.addComponent(obj.copyOf());
		return copyCustom(map);
	}
	public Rectangle3D getBounds() {
		final Rectangle3D bounds = new Rectangle3D(0.0, 0.0, 0.0, -1.0, -1.0, -1.0);
		for (UTObject object : this)
			bounds.add(object.getBounds());
		return bounds;
	}
	public Dimension3D getSize() {
		return getBounds().getSize();
	}
	public String getType() {
		return "Map";
	}
	public Iterator<UTObject> iterator() {
		return objects.iterator();
	}
	/**
	 * Returns a list of all objects of the specified type. Uses more memory than allObjects
	 * but avoids an anonymous inner class in many cases.
	 *
	 * @param itemClass the item class to find
	 * @param <T> makes everything convenient
	 * @return an array of all objects of that type, or an empty array if none are found
	 */
	public <T extends UTObject> Iterable<T> listObjects(final Class<T> itemClass) {
		final List<T> out = new LinkedList<T>();
		allObjects(itemClass, new UTIterator<T>() {
			public void run(final T item) {
				out.add(item);
			}
		});
		return Collections.unmodifiableList(out);
	}
	/**
	 * Lists the references required by objects in this map.
	 *
	 * @return a list of references to resources required by this map
	 */
	public ReferenceList listReferences() {
		final ReferenceList list = new ReferenceList();
		additionalReferences(list);
		return list;
	}
	/**
	 * Removes an object from this map.
	 *
	 * @param object the object to remove
	 */
	public void removeComponent(final UTObject object) {
		objects.remove(object);
	}
	/**
	 * Removes objects of the specified type from this map.
	 *
	 * @param itemClass the item type to remove
	 */
	public void removeObjects(final Class<? extends UTObject> itemClass) {
		final Iterator<UTObject> it = iterator(); UTObject obj;
		while (it.hasNext()) {
			obj = it.next();
			if (itemClass.isAssignableFrom(obj.getClass()))
				it.remove();
		}
	}
	/**
	 * Removes all objects (but the WorldInfo) from this map.
	 */
	public void reset() {
		for (UTObject obj : objects)
			obj.setParent(null);
		objects.clear();
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		// Do not output the name, it causes a UDK crash!
		UTUtils.addIndent(out, indent, "Begin Map");
		// The level is always named PersistentLevel!
		UTUtils.addIndent(out, indent + 1, "Begin Level Name=PersistentLevel");
		for (UTObject object : objects)
			object.toUnrealText(out, indent + 2, utCompatMode);
		UTUtils.addIndent(out, indent + 1, "End Level");
		UTUtils.addIndent(out, indent, "Begin Surface");
		UTUtils.addIndent(out, indent, "End Surface");
		UTUtils.addIndent(out, indent, "End Map");
	}
}