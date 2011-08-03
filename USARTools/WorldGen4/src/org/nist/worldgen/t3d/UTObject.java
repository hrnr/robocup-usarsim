package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.PrintWriter;
import java.util.*;
import java.util.regex.Matcher;

/**
 * Class representing an object that can be written to a T3D (Unreal Text) file.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class UTObject implements UTWritable {
	protected UTReference archetype;
	String name;
	UTObject parent;
	protected Map<String, Object> attrs;

	/**
	 * Creates a new object with the given name.
	 *
	 * @param name the object name
	 */
	protected UTObject(final String name) {
		archetype = null;
		attrs = null;
		this.name = name;
		parent = null;
	}
	/**
	 * Adds a subcomponent to this object.
	 *
	 * @param object the subcomponent to add
	 */
	public void addComponent(final UTObject object) {
		throw new UnsupportedOperationException("Cannot add subcomponents to this component");
	}
	/**
	 * Add references that this object uses to the given reference list.
	 *
	 * @param list the reference list where references are added
	 */
	public void additionalReferences(final ReferenceList list) {
		list.addReference(getArchetype());
		if (attrs != null)
			for (Object value : attrs.values())
				if (value instanceof UTReference)
					list.addReference((UTReference)value);
	}
	/**
	 * Gets a reference to this object.
	 *
	 * @return a reference to this object
	 */
	public UTReference asReference() {
		return new UTReference(getType(), null, getName());
	}
	/**
	 * Outputs the begin object marker to the stream.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 * @param type the supertype to output (usually "Object" or "Actor")
	 */
	protected void begin(final PrintWriter out, final int indent, final String type) {
		UTUtils.addIndent(out, indent, "Begin ", type, " Class=", getType(), " Name=",
			getName(), " Archetype=", UTUtils.nullAsNone(getArchetype()));
	}
	/**
	 * Copies the custom attributes of this object to another.
	 *
	 * @param other the object to copy the custom attributes to
	 * @return the object passed in
	 */
	protected UTObject copyCustom(final UTObject other) {
		other.setParent(getParent());
		other.setArchetype(getArchetype());
		if (attrs == null)
			other.attrs = null;
		else {
			// ATTN: Shallow copy!
			other.attrs = new LinkedHashMap<String, Object>(attrs.size());
			other.attrs.putAll(attrs);
		}
		return other;
	}
	/**
	 * Duplicates this object. All attributes should be copied.
	 *
	 * @return a copy of this object
	 */
	public abstract UTObject copyOf();
	/**
	 * When parsing T3D files, attributes encountered will first get a pass through this
	 * function. If the class has instance variables to handle it, return true to suppress the
	 * default action of storing it in the property map.
	 *
	 * @param key the attribute name
	 * @param value the attribute value
	 * @return whether the item was handled by this class
	 */
	protected boolean customPutAttribute(final String key, final String value) {
		return key.equalsIgnoreCase("ObjectArchetype") || key.equalsIgnoreCase("Name");
	}
	/**
	 * Outputs the end object marker to the stream.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 * @param type the supertype to output (usually "Object" or "Actor")
	 */
	protected void end(final PrintWriter out, final int indent, final String type) {
		UTUtils.putAttributeQ(out, indent, "Name", getName());
		UTUtils.putAttribute(out, indent, "ObjectArchetype",
			UTUtils.nullAsNone(getArchetype()));
		UTUtils.addIndent(out, indent, "End ", type);
	}
	/**
	 * Gets this object's archetype.
	 *
	 * @return the archetype
	 */
	public UTReference getArchetype() {
		final UTReference arch;
		if (archetype == null)
			arch = PooledArchetypes.getArchetype(getType());
		else
			arch = archetype;
		return arch;
	}
	/**
	 * Gets the value of the specified attribute.
	 *
	 * @param key the attribute to look up
	 * @return the value, or null if not defined
	 */
	public Object getAttribute(final String key) {
		final Object value;
		if (attrs != null)
			value = attrs.get(key);
		else
			value = null;
		return value;
	}
	/**
	 * Gets the bounding box of this object.
	 *
	 * @return a box which bounds the object
	 */
	public Rectangle3D getBounds() {
		return Rectangle3D.EMPTY_RECT;
	}
	/**
	 * Gets the name of this object.
	 *
	 * @return the object name
	 */
	public String getName() {
		return name;
	}
	/**
	 * Gets the parent of this component.
	 *
	 * @return the parent component or actor of this component
	 */
	public UTObject getParent() {
		return parent;
	}
	/**
	 * Gets the default name prefix for this object.
	 *
	 * @return the default prefix for automatically generated names
	 */
	public String getPrefix() {
		return getType();
	}
	/**
	 * Gets the size of this object.
	 *
	 * @return a Dimension3D containing the size of this object in UU
	 */
	public abstract Dimension3D getSize();
	/**
	 * Gets the object type.
	 *
	 * @return the object class (Pawn, DynamicSMActor, Brush...)
	 */
	public String getType() {
		return getClass().getSimpleName();
	}
	/**
	 * Adds a custom attribute to this object. Handles dynamic arrays properly.
	 *
	 * @param key the attribute key
	 * @param value the attribute value
	 */
	void putAttributeParse(final String key, final String value) {
		if (!customPutAttribute(key, value)) {
			final Matcher m = UTUtils.extractArrayValues(key);
			if (m.matches()) {
				final String realKey = m.group(1); final DynamicArray array;
				final Object obj = getAttribute(realKey);
				if (obj == null) {
					array = new DynamicArray();
					putAttribute(realKey, array);
				} else if (obj instanceof DynamicArray)
					array = (DynamicArray)obj;
				else
					throw new IllegalArgumentException("Cannot add elements to " + realKey);
				array.set(Integer.parseInt(m.group(2)), UTUtils.nativeType(value));
			} else
				putAttribute(key, UTUtils.nativeType(value));
		}
	}
	/**
	 * Changes a custom attribute of this object using a Java native type.
	 *
	 * @param key the attribute key
	 * @param value the attribute value
	 */
	public void putAttribute(final String key, final Object value) {
		if (attrs == null)
			// Initialize
			attrs = new LinkedHashMap<String, Object>(16);
		attrs.put(key, value);
	}
	/**
	 * Writes all of the custom attributes to the stream.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 */
	protected void putCustom(final PrintWriter out, final int indent) {
		Object obj;
		if (attrs != null && !attrs.isEmpty())
			for (Map.Entry<String, Object> entry : attrs.entrySet()) {
				obj = entry.getValue();
				if (obj instanceof DynamicArray)
					UTUtils.putArray(out, indent, entry.getKey(), (DynamicArray)obj);
				else
					UTUtils.putAttribute(out, indent, entry.getKey(), UTUtils.utType(obj));
			}
	}
	/**
	 * Changes this object's archetype.
	 *
	 * @param archetype the new archetype
	 */
	public void setArchetype(final UTReference archetype) {
		if (!archetype.equals(getArchetype()))
			this.archetype = archetype;
	}
	/**
	 * Renames this object.
	 *
	 * @param newName the object's new name
	 */
	void setName(final String newName) {
		final UTObject par = getParent(); final String oldName = name;
		name = newName;
		if (par != null)
			par.updateReferences(this, oldName);
	}
	/**
	 * Changes the object's parent.
	 *
	 * @param parent the new parent of this object
	 */
	void setParent(final UTObject parent) {
		this.parent = parent;
	}
	/**
	 * Converts attributes of this object to a string.
	 *
	 * @param args alternating key-value pairs of attributes to output
	 * @return a representation of this UTObject as a String
	 */
	protected String toString(final Object... args) {
		final StringBuilder out = new StringBuilder(256); String key;
		out.append(getType());
		out.append('[');
		for (int i = 0; i < args.length; i += 2) {
			key = args[i].toString();
			if (key.indexOf('=') >= 0)
				out.append(String.format(key, args[i + 1]));
			else {
				out.append(key);
				out.append('=');
				out.append(args[i + 1]);
			}
			if (i + 2 < args.length)
				out.append(',');
		}
		out.append(']');
		return out.toString();
	}
	public String toString() {
		return toString("name=%s", getName());
	}
	/**
	 * Transforms this object by the specified amount. Technically, rotation should be applied
	 * first, then translation.
	 *
	 * @param offset the offset to move
	 * @param rotate the amount to rotate
	 * @param rotateAbout the location around which to rotate
	 */
	public void transform(final Point3D offset, final Rotator3D rotate,
			final Point3D rotateAbout) {
	}
	/**
	 * Updates any references of this object if an object's name is changed. This method is
	 * only guaranteed to be called if an object is renamed!
	 *
	 * @param changed the object that was renamed
	 * @param oldName the name the object had before it was renamed
	 */
	protected void updateReferences(final UTObject changed, final String oldName) {
		// Look through the custom attribute table
		if (attrs != null)
			for (String key : attrs.keySet()) {
				final Object obj = attrs.get(key);
				if (obj instanceof UTReference) {
					final UTReference ref = (UTReference)obj;
					if (ref.getPackage() == null && ref.getName().equalsIgnoreCase(oldName))
						attrs.put(key, changed.asReference());
				}
			}
	}
}