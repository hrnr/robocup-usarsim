package org.nist.worldgen.t3d;

import org.nist.worldgen.*;
import java.io.*;

/**
 * Base class for most complex components.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public abstract class PrimitiveComponent extends UTComponent implements Locatable {
	protected boolean acceptDynamicLights;
	protected boolean acceptLights;
	protected boolean allowApproximateOcclusion;
	protected boolean alwaysLoadOnClient;
	protected boolean alwaysLoadOnServer;
	protected boolean blockActors;
	protected boolean blockRigidBody;
	protected boolean castShadow;
	protected boolean castDynamicShadow;
	protected boolean collideActors;
	protected final RBCollisionChannels collisionChannels;
	protected boolean forceDirectLightMap;
	protected boolean hiddenEditor;
	protected boolean hiddenGame;
	protected final LightingChannels lightingChannels;
	protected String rbChannel;
	protected String replacement;
	protected Rotator3D rotation;
	protected double scale;
	protected Point3D scale3D;
	protected Point3D translation;
	protected boolean usePrecomputedShadows;

	/**
	 * Creates a new primitive component.
	 *
	 * @param name the object name
	 * @param staticName the name which matches the template for the real object
	 */
	protected PrimitiveComponent(final String name, final String staticName) {
		super(name, staticName);
		acceptDynamicLights = acceptLights = true;
		allowApproximateOcclusion = true;
		alwaysLoadOnClient = alwaysLoadOnServer = true;
		castShadow = castDynamicShadow = true;
		collisionChannels = new RBCollisionChannels();
		forceDirectLightMap = false;
		hiddenEditor = hiddenGame = false;
		lightingChannels = new LightingChannels();
		rbChannel = null;
		replacement = null;
		rotation = Rotator3D.NO_ROTATION.getRotation();
		scale = 1.0;
		scale3D = Actor.NO_SCALE.getLocation();
		translation = Point3D.ORIGIN.getLocation();
		usePrecomputedShadows = false;
		setCollision(true);
	}
	protected UTObject copyCustom(UTObject other) {
		final PrimitiveComponent prim = (PrimitiveComponent)other;
		prim.getCollisionChannels().setAll(getCollisionChannels());
		prim.getLightingChannels().setAll(getLightingChannels());
		prim.setAlwaysLoad(alwaysLoadOnClient);
		prim.setCollision(blockActors);
		prim.setHidden(isHiddenGame(), isHiddenEditor());
		prim.setLocation(getLocation().getLocation());
		prim.setPrecomputedShadows(usePrecomputedShadows);
		prim.setRBChannel(getRBChannel());
		prim.setRotation(getRotation().getRotation());
		prim.setScale(getScale());
		prim.setScale3D(getScale3D().getLocation());
		prim.acceptDynamicLights = acceptDynamicLights;
		prim.acceptLights = acceptLights;
		prim.allowApproximateOcclusion = allowApproximateOcclusion;
		prim.castShadow = castShadow;
		prim.castDynamicShadow = castDynamicShadow;
		prim.forceDirectLightMap = forceDirectLightMap;
		prim.blockRigidBody = blockRigidBody;
		prim.collideActors = collideActors;
		return super.copyCustom(other);
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			accept = true;
			if (key.equalsIgnoreCase("HiddenGame"))
				setHidden(Boolean.parseBoolean(value), isHiddenEditor());
			else if (key.equalsIgnoreCase("HiddenEditor"))
				setHidden(isHiddenGame(), Boolean.parseBoolean(value));
			else if (key.equalsIgnoreCase("ReplacementPrimitive"))
				setReplacement(UTUtils.noneAsNull(value));
			else if (key.equalsIgnoreCase("LightingChannels"))
				getLightingChannels().setFromString(value);
			else if (key.equalsIgnoreCase("RBChannel"))
				setRBChannel(UTUtils.noneAsNull(value));
			else if (key.equalsIgnoreCase("RBCollideWithChannels"))
				getCollisionChannels().setFromString(value);
			else if (key.equalsIgnoreCase("Scale"))
				setScale(Double.parseDouble(value));
			else if (key.equalsIgnoreCase("Scale3D"))
				setScale3D(UTUtils.parseLocation(value));
			else if (key.equalsIgnoreCase("Translation"))
				setLocation(UTUtils.parseLocation(value));
			else if (key.equalsIgnoreCase("Rotation"))
				setRotation(UTUtils.parseRotation(value));
			else if (key.equalsIgnoreCase("AlwaysLoadOnClient"))
				alwaysLoadOnClient = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("AlwaysLoadOnServer"))
				alwaysLoadOnServer = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bAcceptsLights"))
				acceptLights = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bAcceptsDynamicLights"))
				acceptDynamicLights = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bAllowApproximateOcclusion"))
				allowApproximateOcclusion = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("CastShadow"))
				castShadow = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bCastDynamicShadow"))
				castDynamicShadow = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bForceDirectLightMap"))
				forceDirectLightMap = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("bUsePrecomputedShadows"))
				usePrecomputedShadows = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("BlockRigidBody"))
				blockRigidBody = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("BlockActors"))
				blockActors = Boolean.parseBoolean(value);
			else if (key.equalsIgnoreCase("CollideActors"))
				collideActors = Boolean.parseBoolean(value);
			else
				accept = false;
		}
		return accept || key.equalsIgnoreCase("VertexPositionVersionNumber") ||
			key.toLowerCase().startsWith("irrelevantlights");
	}
	/**
	 * Gets the component's collision channels.
	 *
	 * @return the channels with which this mesh can collide
	 */
	public RBCollisionChannels getCollisionChannels() {
		return collisionChannels;
	}
	/**
	 * Gets the lighting channels in use by this brush component.
	 *
	 * @return the lighting channels enabled for this brush
	 */
	public LightingChannels getLightingChannels() {
		return lightingChannels;
	}
	public Point3D getLocation() {
		return translation;
	}
	public Rotator3D getRotation() {
		return rotation;
	}
	/**
	 * Gets the rigid body channel used by this component, or null if none is used.
	 *
	 * @return the rigid body channel used by this object
	 */
	public String getRBChannel() {
		return rbChannel;
	}
	/**
	 * Gets the replacement primitive for this object.
	 *
	 * @return the primitive that replaces it
	 */
	public String getReplacement() {
		return replacement;
	}
	/**
	 * Gets the object's scale.
	 *
	 * @return the scale factor
	 */
	public double getScale() {
		return scale;
	}
	/**
	 * Gets the object's 3D scale.
	 *
	 * @return the scale factor applied to individual axes
	 */
	public Point3D getScale3D() {
		return scale3D;
	}
	protected void initializeLighting(final boolean dynamic) {
		final LightingChannels ch = getLightingChannels();
		ch.setChannel(LightingChannels.CH_INITIALIZED, true);
		if (dynamic)
			ch.setChannel(LightingChannels.CH_DYNAMIC, true);
		else
			ch.setChannel(LightingChannels.CH_STATIC, true);
	}
	/**
	 * Checks to see if this object is hidden in-editor.
	 *
	 * @return whether the object is hidden in the editor
	 */
	public boolean isHiddenEditor() {
		return hiddenEditor;
	}
	/**
	 * Checks to see if this object is hidden in-game.
	 *
	 * @return whether the object is hidden in game
	 */
	public boolean isHiddenGame() {
		return hiddenGame;
	}
	/**
	 * Outputs all PrimitiveComponent fields available in this implementation to the output
	 * stream.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 */
	protected void prims(final PrintWriter out, final int indent) {
		final LightingChannels lc = getLightingChannels();
		final RBCollisionChannels rbcc = getCollisionChannels();
		final String rbc = getRBChannel(); final double sc = getScale();
		final Point3D s3d = getScale3D(), loc = getLocation();
		final Rotator3D rot = getRotation();
		if (!acceptLights)
			UTUtils.putAttribute(out, indent, "bAcceptsLights", "false");
		if (!acceptDynamicLights)
			UTUtils.putAttribute(out, indent, "bAcceptsDynamicLights", "false");
		if (!allowApproximateOcclusion)
			UTUtils.putAttribute(out, indent, "bAllowApproximateOcclusion", "false");
		if (!alwaysLoadOnClient)
			UTUtils.putAttribute(out, indent, "AlwaysLoadOnClient", "false");
		if (!alwaysLoadOnServer)
			UTUtils.putAttribute(out, indent, "AlwaysLoadOnServer", "false");
		if (!blockActors)
			UTUtils.putAttribute(out, indent, "BlockActors", "false");
		if (!blockRigidBody)
			UTUtils.putAttribute(out, indent, "BlockRigidBody", "false");
		if (!castShadow)
			UTUtils.putAttribute(out, indent, "CastShadow", "false");
		if (!castDynamicShadow)
			UTUtils.putAttribute(out, indent, "bCastDynamicShadow", "false");
		if (forceDirectLightMap)
			UTUtils.putAttribute(out, indent, "bForceDirectLightMap", "true");
		if (!collideActors)
			UTUtils.putAttribute(out, indent, "CollideActors", "false");
		if (usePrecomputedShadows)
			UTUtils.putAttribute(out, indent, "bUsePrecomputedShadows", "true");
		if (!Point3D.ORIGIN.equals(loc))
			UTUtils.putAttribute(out, indent, "Translation", loc.toExternalForm());
		if (!Rotator3D.NO_ROTATION.equals(rot))
			UTUtils.putAttribute(out, indent, "Rotation", rot.toExternalForm());
		if (!Utils.doubleEquals(sc, 1.0))
			UTUtils.putAttribute(out, indent, "Scale", sc);
		if (!Actor.NO_SCALE.equals(s3d))
			UTUtils.putAttribute(out, indent, "Scale3D", s3d.toExternalForm());
		UTUtils.putAttribute(out, indent, "ReplacementPrimitive",
			UTUtils.nullAsNone(getReplacement()));
		if (rbc != null)
			UTUtils.putAttribute(out, indent, "RBChannel", rbc);
		if (isHiddenGame())
			UTUtils.putAttribute(out, indent, "HiddenGame", "true");
		if (isHiddenEditor())
			UTUtils.putAttribute(out, indent, "HiddenEditor", "true");
		if (!lc.isEmpty())
			UTUtils.putAttribute(out, indent, "LightingChannels", lc);
		if (!rbcc.isEmpty())
			UTUtils.putAttribute(out, indent, "RBCollideWithChannels", rbcc);
	}
	/**
	 * Changes whether this sprite is always loaded.
	 *
	 * @param alwaysLoad whether the sprite must be loaded
	 */
	public void setAlwaysLoad(final boolean alwaysLoad) {
		alwaysLoadOnClient = alwaysLoadOnServer = alwaysLoad;
	}
	/**
	 * Enables or disables global collision for this object.
	 *
	 * @param collide whether this object should collide with others
	 */
	public void setCollision(final boolean collide) {
		blockRigidBody = blockActors = collide;
		collideActors = collide;
	}
	/**
	 * Shows or hides this object.
	 *
	 * @param hideGame whether the object is hidden in game
	 * @param hideEditor whether the object is hidden in the editor
	 */
	public void setHidden(final boolean hideGame, final boolean hideEditor) {
		hiddenEditor = hideEditor;
		hiddenGame = hideGame;
	}
	public void setLocation(final Point3D location) {
		translation = location;
	}
	/**
	 * Changes the value of the "usePrecomputedShadows" flag.
	 *
	 * @param usePrecomputedShadows whether precomputed shadows are used
	 */
	public void setPrecomputedShadows(final boolean usePrecomputedShadows) {
		forceDirectLightMap = this.usePrecomputedShadows = usePrecomputedShadows;
	}
	/**
	 * Changes the rigid body channel used by this component.
	 *
	 * @param rbChannel the new rigid body channel
	 */
	public void setRBChannel(final String rbChannel) {
		this.rbChannel = rbChannel;
	}
	/**
	 * Changes the replacement primitive.
	 *
	 * @param replacement the replacement primitive to use
	 */
	public void setReplacement(final String replacement) {
		this.replacement = replacement;
	}
	public void setRotation(Rotator3D rotation) {
		this.rotation = rotation;
	}
	/**
	 * Sets the scale of this object.
	 *
	 * @param scale the scaling amount
	 */
	public void setScale(double scale) {
		this.scale = scale;
	}
	/**
	 * Sets the 3-D scale of this object.
	 *
	 * @param scale3D the amount to scale each axis
	 */
	public void setScale3D(Point3D scale3D) {
		this.scale3D = scale3D;
	}
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode) {
		begin(out, indent, "Object");
		custom(out, indent, 0);
		prims(out, indent);
		putCustom(out, indent);
		end(out, indent, "Object");
	}
}