package org.nist.worldgen.t3d;

import java.io.*;

/**
 * Represents a sprite used in path nodes and player starts.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class SpriteComponent extends PrimitiveComponent {
	protected UTReference sprite;
	protected String spriteCategoryName;

	/**
	 * Creates a new sprite.
	 *
	 * @param name the object name
	 * @param staticName the object's inherited name
	 */
	public SpriteComponent(final String name, final String staticName) {
		super(name, staticName);
		sprite = null;
		spriteCategoryName = null;
		initializeLighting(true);
	}
	public void additionalReferences(ReferenceList list) {
		list.addReference(sprite);
		super.additionalReferences(list);
	}
	public UTObject copyOf() {
		final SpriteComponent sc = new SpriteComponent(getName(), getStaticName());
		sc.setCategoryName(spriteCategoryName);
		sc.setSprite(getSprite());
		return copyCustom(sc);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		UTUtils.putAttribute(out, indent, "Sprite", UTUtils.nullAsNone(getSprite()));
		UTUtils.putAttributeQ(out, indent, "SpriteCategoryName", spriteCategoryName);
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("Sprite")) {
				setSprite(UTUtils.parseReference(value));
				accept = true;
			} else if (key.equalsIgnoreCase("SpriteCategoryName")) {
				setCategoryName(UTUtils.noneAsNull(UTUtils.removeQuotes(value)));
				accept = true;
			}
		}
		return accept;
	}
	/**
	 * Gets this object's sprite.
	 *
	 * @return the sprite texture used to display the object
	 */
	public UTReference getSprite() {
		return sprite;
	}
	/**
	 * Changes the sprite category name.
	 *
	 * @param categoryName the category name
	 */
	public void setCategoryName(final String categoryName) {
		spriteCategoryName = categoryName;
	}
	/**
	 * Changes this object's sprite.
	 *
	 * @param sprite the new sprite to display
	 */
	public void setSprite(final UTReference sprite) {
		this.sprite = sprite;
	}
	public String toString() {
		return toString("name", getName(), "parent", getParent().getName(), "sprite",
			getSprite());
	}
}