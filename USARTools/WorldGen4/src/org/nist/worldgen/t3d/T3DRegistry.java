package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Stores references to object factories which turn out copies of objects based on their
 * attributes. Used extensively for registering classes to be created on parse.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class T3DRegistry {
	private static final T3DRegistry actorRegistry = new T3DRegistry(
		new UTObjectFactory.DefaultActorFactory());
	private static final T3DRegistry componentRegistry = new T3DRegistry(
		new UTObjectFactory.DefaultComponentFactory());

	/**
	 * Gets the registry used to create actors.
	 *
	 * @return the actor registry
	 */
	public synchronized static T3DRegistry getActorRegistry() {
		if (actorRegistry.isEmpty()) registerActors();
		return actorRegistry;
	}
	/**
	 * Gets the registry used to create components.
	 *
	 * @return the component registry
	 */
	public synchronized static T3DRegistry getComponentRegistry() {
		if (componentRegistry.isEmpty()) registerComponents();
		return componentRegistry;
	}

	private static void registerActors() {
		actorRegistry.register(new SimpleActorFactory(DirectionalLight.class));
		actorRegistry.register(new SimpleActorFactory(GameBreakableActor.class));
		actorRegistry.register(new SimpleActorFactory(KActor.class));
		actorRegistry.register(new SimpleActorFactory(PathNode.class));
		actorRegistry.register(new SimpleActorFactory(PlayerStart.class));
		actorRegistry.register(new SimpleActorFactory(PointLight.class));
		actorRegistry.register(new SimpleActorFactory(PrefabInstance.class));
		actorRegistry.register(new SimpleActorFactory(SkeletalMeshActor.class));
		actorRegistry.register(new SimpleActorFactory(SkyLight.class));
		actorRegistry.register(new SimpleActorFactory(SpotLight.class));
		actorRegistry.register(new SimpleActorFactory(StaticMeshActor.class));
		actorRegistry.register(new SimpleObjectFactory(WorldInfo.class));
		actorRegistry.register(new AbstractActorFactory() {
			protected Actor initObject(UTAttributeSet in) {
				return new BrushActor(in.get("Name"));
			}
			public String getHandledType() {
				return "Brush";
			}
		});
		actorRegistry.register(new AbstractActorFactory() {
			protected Actor initObject(UTAttributeSet in) {
				return new Volume(in.get("Name"), in.get("Class"));
			}
			public String getHandledType() {
				return "*Volume";
			}
		});
	}
	private static void registerComponents() {
		componentRegistry.register(new SimpleObjectFactory(
			SkeletalMeshComponent.AnimNodeSequence.class));
		componentRegistry.register(new SimpleComponentFactory(ArrowComponent.class));
		componentRegistry.register(new SimpleComponentFactory(AudioComponent.class));
		componentRegistry.register(new SimpleComponentFactory(BrushActor.BrushComponent.class));
		componentRegistry.register(new SimpleComponentFactory(CylinderComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			DirectionalLight.DirectionalLightComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			DynamicLightEnvironmentComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			PathNode.PathRenderingComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			PointLight.PointLightComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			SkyLight.SkyLightComponent.class));
		componentRegistry.register(new SimpleComponentFactory(
			SpotLight.SpotLightComponent.class));
		componentRegistry.register(new SimpleComponentFactory(SkeletalMeshComponent.class));
		componentRegistry.register(new SimpleComponentFactory(SpriteComponent.class));
		componentRegistry.register(new SimpleComponentFactory(StaticMeshComponent.class));
	}

	private final UTObjectFactory defaultFactory;
	private final Map<String, UTObjectFactory> registry;

	private T3DRegistry(final UTObjectFactory defaultFactory) {
		this.defaultFactory = defaultFactory;
		registry = new LinkedHashMap<String, UTObjectFactory>(64);
	}
	/**
	 * Creates a UT object from the parser's output.
	 *
	 * @param type the object type to create
	 * @param attr the attributes read
	 * @return the matching object, or null if none was found
	 */
	public UTObject createObject(final String type, final UTAttributeSet attr) {
		final UTObjectFactory fact = findObjectFactory(type);
		return fact.createObject(attr);
	}
	/**
	 * Finds the proper UTObjectFactory instance for specified items.
	 *
	 * @param objectType the object type to locate
	 * @return the object factory for the item (the default one if none is found)
	 */
	protected UTObjectFactory findObjectFactory(final String objectType) {
		UTObjectFactory factory = defaultFactory;
		for (Map.Entry<String, UTObjectFactory> entry : registry.entrySet())
			if (UTUtils.globMatch(objectType, entry.getKey())) {
				factory = entry.getValue();
				break;
			}
		return factory;
	}
	private boolean isEmpty() {
		return registry.isEmpty();
	}
	/**
	 * Register a UTObjectHandler to handle objects passed in.
	 *
	 * @param factory the object
	 */
	public void register(final UTObjectFactory factory) {
		for (String type : factory.getHandledTypes())
			registry.put(type, factory);
	}
}