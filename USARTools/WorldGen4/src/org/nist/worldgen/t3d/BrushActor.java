package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Class representing the container object that holds brush geometry.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class BrushActor extends ComponentActor {
	protected int csg;
	protected Brush model;

	/**
	 * Creates a new brush actor.
	 *
	 * @param name the actor name
	 */
	public BrushActor(final String name) {
		super(name);
		csg = CSGOperation.CSG_NONE;
	}
	public void additionalReferences(ReferenceList list) {
		final Brush mod = getModel();
		if (mod != null)
			list.addReference(new UTReference("Model", null, mod.getName()));
		super.additionalReferences(list);
	}
	public void addComponent(UTObject object) {
		if (object instanceof Brush)
			// Can't compare the getType() because both BrushActor and Brush return "Brush"
			model = (Brush)object;
		else
			super.addComponent(object);
	}
	public UTObject copyOf() {
		return copyCustom(new BrushActor(getName()));
	}
	protected UTObject copyCustom(UTObject other) {
		final BrushActor brush = (BrushActor)other;
		brush.setCSGOperation(getCSGOperation());
		brush.model = (Brush)getModel().copyOf();
		brush.model.setParent(brush);
		return super.copyCustom(other);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		final String refName; final Brush mod = getModel(); final int csgOp = getCSGOperation();
		if (mod != null)
			refName = mod.getName();
		else
			refName = null;
		UTUtils.addIndent(out, indent + 1, "Begin PolyList");
		UTUtils.addIndent(out, indent + 1, "End PolyList");
		if (mod != null)
			mod.toUnrealText(out, indent + 1, 0);
		super.custom(out, indent, utCompatMode);
		if (csgOp > CSGOperation.CSG_NONE)
			UTUtils.putAttribute(out, indent, "CsgOper", CSGOperation.csgToString(csgOp));
		UTUtils.putAttribute(out, indent, "Brush", UTUtils.asReference("Model", refName));
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("CsgOper")) {
				setCSGOperation(CSGOperation.csgFromString(value));
				accept = true;
			} else if (key.equalsIgnoreCase("Brush"))
				// This was already handled in the model case
				accept = true;
		}
		return accept;
	}
	protected String getActorType() {
		return "BrushComponent";
	}
	public Rectangle3D getBounds() {
		return model.getBounds();
	}
	/**
	 * Gets the CSG operation performed by this brush.
	 *
	 * @return the CSG type (CSG_Add, CSG_Subtract)
	 */
	public int getCSGOperation() {
		return csg;
	}
	/**
	 * Gets the geometry of this brush.
	 *
	 * @return the brush geometry
	 */
	public Brush getModel() {
		return model;
	}
	public Dimension3D getSize() {
		return model.getSize();
	}
	// Unreal has this all wrong...
	public String getType() {
		return "Brush";
	}
	protected void initDefaults() {
		final BrushComponent bc = new BrushComponent(getName() + "_Brush", "BrushComponent0");
		bc.initializeLighting(true);
		reset();
		model = new Brush(getName() + "_Model");
		setCSGOperation(CSGOperation.CSG_ADD);
		addComponent(bc);
	}
	/**
	 * Changes the CSG operation performed by this brush.
	 *
	 * @param csg the CSG operation to perform
	 */
	public void setCSGOperation(final int csg) {
		this.csg = csg;
	}
	void setName(String newName) {
		// Fix brush-renaming problem
		super.setName(newName);
		if (model != null)
			model.setName(newName + "_Model");
	}
	public String toString() {
		return toString("name", getName(), "operation",
			CSGOperation.csgToString(getCSGOperation()), "model", getModel().getName());
	}
	public void transform(Point3D offset, Rotator3D rotate, Point3D rotateAbout) {
		final Rotator3D rot = getRotation();
		super.transform(Point3D.ORIGIN, rotate, rotateAbout);
		setRotation(rot);
		model.transform(offset, rotate, rotateAbout);
	}

	/**
	 * Represents the BrushComponent that every Brush must have.
	 */
	public static class BrushComponent extends PrimitiveComponent {
		public BrushComponent(final String name, final String staticName) {
			super(name, staticName);
		}
		protected void custom(final PrintWriter out, final int indent, int utCompatMode) {
			final Brush model = ((BrushActor)getParent()).getModel();
			if (model != null)
				UTUtils.addIndent(out, indent + 1, "Brush=Model'", model.getName(), '\'');
		}
		public UTObject copyOf() {
			return copyCustom(new BrushComponent(getName(), getStaticName()));
		}
		protected boolean customPutAttribute(String key, String value) {
			return super.customPutAttribute(key, value) || key.equalsIgnoreCase("Brush")
				|| key.equalsIgnoreCase("BrushAggGeom");
		}
		public Dimension3D getSize() {
			final Brush model = ((BrushActor)getParent()).getModel();
			final Dimension3D size;
			if (model == null)
				size = Dimension3D.NO_SIZE;
			else
				size = model.getSize();
			return size;
		}
	}
}