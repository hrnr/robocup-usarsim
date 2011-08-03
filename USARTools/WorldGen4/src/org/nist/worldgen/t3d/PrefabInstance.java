package org.nist.worldgen.t3d;

import java.io.PrintWriter;

/**
 * Represents an instance of a prefab.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class PrefabInstance extends ComponentActor {
	protected UTReference templatePrefab;

	/**
	 * Creates a new prefab instance.
	 *
	 * @param name the actor name
	 */
	public PrefabInstance(final String name) {
		super(name);
		templatePrefab = null;
	}
	public void additionalReferences(ReferenceList list) {
		list.addReference(getPrefab());
		super.additionalReferences(list);
	}
	public UTObject copyOf() {
		final PrefabInstance inst = new PrefabInstance(getName());
		inst.setPrefab(getPrefab());
		return copyCustom(inst);
	}
	protected void custom(PrintWriter out, int indent, int utCompatMode) {
		super.custom(out, indent, utCompatMode);
		UTUtils.putAttribute(out, indent, "TemplatePrefab", getPrefab());
	}
	protected boolean customPutAttribute(String key, String value) {
		boolean accept = super.customPutAttribute(key, value);
		if (!accept) {
			if (key.equalsIgnoreCase("TemplatePrefab")) {
				setPrefab(UTUtils.parseReference(value));
				accept = true;
			}
		}
		return accept || key.equalsIgnoreCase("TemplateVersion") ||
			key.toUpperCase().startsWith("PI_");
	}
	// There is no center component
	protected String getActorType() {
		return "NoComponent";
	}
	/**
	 * Gets a reference to the prefab used to construct this instance.
	 *
	 * @return a reference to the prefabricated object used
	 */
	public UTReference getPrefab() {
		return templatePrefab;
	}
	protected void initDefaults() {
		final SpriteComponent sprite = new SpriteComponent(getName() + "_Sprite", "Sprite");
		sprite.initializeLighting(true);
		sprite.setCategoryName("Prefabs");
		sprite.setHidden(true, false);
		sprite.setSprite(new UTReference("Texture2D", "EditorResources", "PrefabSprite"));
		sprite.putAttribute("bIsScreenSizeScaled", Boolean.TRUE);
		sprite.putAttribute("ScreenSize", 0.0025);
		reset();
		addComponent(sprite);
	}
	/**
	 * Changes the prefab to use. Note that if this object is linked, links may be broken and
	 * the actors will become disconnected.
	 *
	 * @param templatePrefab the template prefab to use
	 */
	public void setPrefab(final UTReference templatePrefab) {
		this.templatePrefab = templatePrefab;
	}
}