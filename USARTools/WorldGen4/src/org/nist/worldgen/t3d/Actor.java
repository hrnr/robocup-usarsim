package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Represents a UDK actor.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class Actor extends UTObject implements Locatable {
	/**
	 * Indicates the default draw scale.
	 */
	public static final Point3D NO_SCALE = new Point3D(1.0, 1.0, 1.0);

	protected double drawScale;
	protected Point3D drawScale3D;
	protected boolean hidden;
	protected Point3D location;
	protected Rotator3D rotation;
	protected String tag;

	/**
	 * Creates a new actor with the given name
	 *
	 * @param name the actor name
	 */
	public Actor(final String name) {
		super(name);
		drawScale = 1.0;
		drawScale3D = NO_SCALE.getLocation();
		hidden = false;
		location = Point3D.ORIGIN.getLocation();
		rotation = Rotator3D.NO_ROTATION.getRotation();
		tag = null;
	}
	protected UTObject copyCustom(UTObject other) {
		final Actor act = (Actor)other;
		act.setDrawScale(getDrawScale());
		act.setDrawScale3D(getDrawScale3D());
		act.setHidden(isHidden());
		act.setLocation(getLocation().getLocation());
		act.setRotation(getRotation().getRotation());
		act.setTag(getTag());
		return super.copyCustom(other);
	}
	/**
	 * Output any custom attributes of this actor.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 * @param utCompatMode the compatibility mode used in the output
	 */
	protected abstract void custom(final PrintWriter out, final int indent, int utCompatMode);
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("bHidden")) {
				setHidden(Boolean.parseBoolean(value));
				accept = true;
			} else if (key.equalsIgnoreCase("DrawScale")) {
				setDrawScale(Double.parseDouble(value));
				accept = true;
			} else if (key.equalsIgnoreCase("DrawScale3D")) {
				setDrawScale3D(UTUtils.parseLocation(value));
				accept = true;
			} else if (key.equalsIgnoreCase("Location")) {
				setLocation(UTUtils.parseLocation(value));
				accept = true;
			} else if (key.equalsIgnoreCase("Rotation")) {
				setRotation(UTUtils.parseRotation(value));
				accept = true;
			} else if (key.equalsIgnoreCase("Tag")) {
				setTag(UTUtils.noneAsNull(UTUtils.removeQuotes(value)));
				accept = true;
			}
		}
		return accept || key.equalsIgnoreCase("CreationTime");
	}
	public Rectangle3D getBounds() {
		return new Rectangle3D(getLocation(), getSize());
	}
	/**
	 * Gets this actor's draw scale.
	 *
	 * @return the draw scale applied to all axes
	 */
	public double getDrawScale() {
		return drawScale;
	}
	/**
	 * Gets this actor's 3-D draw scale.
	 *
	 * @return the draw scale applied to individual axes
	 */
	public Point3D getDrawScale3D() {
		return drawScale3D;
	}
	public Point3D getLocation() {
		return location;
	}
	public Rotator3D getRotation() {
		return rotation;
	}
	/**
	 * Gets the object's tag.
	 *
	 * @return the object Tag attribute (defaults to class name)
	 */
	public String getTag() {
		final String ret;
		if (tag == null)
			ret = getType();
		else
			ret = tag;
		return ret;
	}
	/**
	 * Initialize default components of this actor if applicable.
	 */
	protected abstract void initDefaults();
	/**
	 * Checks to see if the actor is hidden.
	 *
	 * @return whether this actor is hidden
	 */
	public boolean isHidden() {
		return hidden;
	}
	/**
	 * Outputs the pose and tag of this actor to the stream.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 */
	protected void pose(final PrintWriter out, final int indent) {
		final double ds = getDrawScale(); final Point3D ds3 = getDrawScale3D();
		if (isHidden())
			UTUtils.putAttribute(out, indent, "bHidden", "true");
		if (!Utils.doubleEquals(ds, 1.0))
			UTUtils.putAttribute(out, indent, "DrawScale", ds);
		if (!NO_SCALE.equals(ds3))
			UTUtils.putAttribute(out, indent, "DrawScale3D", ds3.toExternalForm());
		UTUtils.putAttribute(out, indent, "Location", getLocation().toExternalForm());
		UTUtils.putAttribute(out, indent, "Rotation", getRotation().toExternalForm());
		UTUtils.putAttributeQ(out, indent, "Tag", getTag());
	}
	/**
	 * Changes the uniform drawing scale of this actor.
	 *
	 * @param drawScale the scale applied to all axes of this actor when drawing
	 */
	public void setDrawScale(double drawScale) {
		this.drawScale = drawScale;
	}
	/**
	 * Changes the drawing scale of this actor.
	 *
	 * @param drawScale3D the scales applied to each axis of this actor
	 */
	public void setDrawScale3D(Point3D drawScale3D) {
		this.drawScale3D = drawScale3D;
	}
	/**
	 * Shows or hides this actor.
	 *
	 * @param hidden whether the actor should be hidden
	 */
	public void setHidden(final boolean hidden) {
		this.hidden = hidden;
	}
	public void setLocation(final Point3D location) {
		this.location = location;
	}
	public void setRotation(final Rotator3D rotation) {
		this.rotation = rotation;
	}
	/**
	 * Changes the object's tag.
	 *
	 * @param tag the new tag
	 */
	public void setTag(final String tag) {
		if (!tag.equalsIgnoreCase(getTag()))
			this.tag = tag;
	}
	public String toString() {
		return toString("name", getName(), "location", getLocation(), "rotation",
			getRotation(), "tag", getTag());
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		begin(out, indent, "Actor");
		custom(out, indent, utCompatMode);
		putCustom(out, indent);
		pose(out, indent);
		end(out, indent, "Actor");
	}
	public void transform(Point3D offset, Rotator3D rotate, Point3D rotateAbout) {
		super.transform(offset, rotate, rotateAbout);
		// Subtract center of rotation from delta
		final Point3D loc = getLocation();
		Point3D delta = new Point3D(loc.getX() - rotateAbout.getX(), loc.getY() -
			rotateAbout.getY(), loc.getZ() - rotateAbout.getZ());
		// Rotate around center
		delta = UTUtils.rotateVector(delta, rotate);
		// Add center of rotation back to delta
		delta.setLocation(delta.getX() + rotateAbout.getX(), delta.getY() +
			rotateAbout.getY(), delta.getZ() + rotateAbout.getZ());
		// Rotate object about its axes
		final Rotator3D curRot = getRotation();
		final Rotator3D rot = new Rotator3D(rotate.getRoll() + curRot.getRoll(),
			rotate.getPitch() + curRot.getPitch(), rotate.getYaw() + curRot.getYaw());
		setRotation(rot);
		// Move object
		delta.setLocation(delta.getX() + offset.getX(), delta.getY() + offset.getY(),
			delta.getZ() + offset.getZ());
		setLocation(delta);
	}
}