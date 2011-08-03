package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents the arrow on each path node.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class ArrowComponent extends PrimitiveComponent {
	protected UTColor arrowColor;
	protected double arrowSize;
	protected String spriteCategoryName;
	protected boolean treatAsSprite;

	public ArrowComponent(final String name, final String staticName) {
		super(name, staticName);
		arrowColor = UTColor.WHITE;
		arrowSize = 1.0;
		spriteCategoryName = null;
		treatAsSprite = true;
	}
	public UTObject copyOf() {
		final ArrowComponent arrow = new ArrowComponent(getName(), getStaticName());
		arrow.setArrowColor(new UTColor(getArrowColor()));
		arrow.setArrowSize(getArrowSize());
		arrow.setCategoryName(getCategoryName());
		arrow.treatAsSprite = treatAsSprite;
		return copyCustom(arrow);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		final UTColor col = getArrowColor(); final String cat = getCategoryName();
		final double size = getArrowSize();
		UTUtils.putAttribute(out, indent, "bTreatAsASprite", treatAsSprite);
		if (!col.equals(UTColor.WHITE))
			UTUtils.putAttribute(out, indent, "ArrowColor", col.toExternalForm());
		if (!Utils.doubleEquals(size, 1.0))
			UTUtils.putAttribute(out, indent, "ArrowSize", String.format("%f", size));
		if (cat != null)
			UTUtils.putAttributeQ(out, indent, "SpriteCategoryName", cat);
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("ArrowColor")) {
				setArrowColor(UTUtils.parseColor(value));
				accept = true;
			} else if (key.equalsIgnoreCase("ArrowSize")) {
				setArrowSize(Double.parseDouble(value));
				accept = true;
			} else if (key.equalsIgnoreCase("SpriteCategoryName")) {
				setCategoryName(UTUtils.noneAsNull(UTUtils.removeQuotes(value)));
				accept = true;
			} else if (key.equalsIgnoreCase("bTreatAsASprite")) {
				treatAsSprite = Boolean.parseBoolean(value);
				accept = true;
			}
		}
		return accept;
	}
	/**
	 * Gets the color of this arrow component.
	 *
	 * @return the arrow color in the editor
	 */
	public UTColor getArrowColor() {
		return arrowColor;
	}
	/**
	 * Gets the size of this arrow component.
	 *
	 * @return the arrow size in the editor
	 */
	public double getArrowSize() {
		return arrowSize;
	}
	/**
	 * Gets the category name of this sprite.
	 *
	 * @return the sprite's category
	 */
	public String getCategoryName() {
		return spriteCategoryName;
	}
	/**
	 * Changes the color of this arrow component.
	 *
	 * @param arrowColor the new arrow color
	 */
	public void setArrowColor(final UTColor arrowColor) {
		this.arrowColor = arrowColor;
	}
	/**
	 * Changes the size of this arrow component.
	 *
	 * @param arrowSize the new arrow size
	 */
	public void setArrowSize(final double arrowSize) {
		this.arrowSize = arrowSize;
	}
	/**
	 * Changes the sprite category name. Only applies if "treatAsSprite" is true (which it is
	 * by default)
	 *
	 * @param categoryName the category name
	 */
	public void setCategoryName(final String categoryName) {
		spriteCategoryName = categoryName;
	}
	public String toString() {
		return toString("name", getName(), "parent", getParent().getName(), "color",
			getArrowColor(), "size", getArrowSize());
	}
}