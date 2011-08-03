package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Class representing the various types of rigid body collisions available for objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class RBCollisionChannels {
	/**
	 * Denotes the Default channel (which isn't really a channel!)
	 */
	public static final int CH_DEFAULT = 0;
	/**
	 * Denotes the Nothing (disable all) channel.
	 */
	public static final int CH_NOTHING = 1;
	/**
	 * Denotes the Pawn/Player channel.
	 */
	public static final int CH_PAWN = 2;
	/**
	 * Denotes the Vehicle channel.
	 */
	public static final int CH_VEHICLE = 3;
	/**
	 * Denotes the GameplayPhysics channel (which is where most physics actors go!).
	 */
	public static final int CH_GAMEPLAY = 5;
	/**
	 * Denotes the Effect channel.
	 */
	public static final int CH_EFFECT = 6;
	/**
	 * Denotes the Blocking Volume channel.
	 */
	public static final int CH_BLOCKING = 15;
	/**
	 * UT names of each channel.
	 */
	protected static final String[] CHANNEL_NAMES = {
		"Default", "Nothing", "Pawn", "Vehicle", "Water", "GameplayPhysics", "EffectPhysics",
		"Untitled1", "Untitled2", "Untitled3", "Untitled4", "Cloth", "FluidDrain",
		"SoftBody", "FracturedMeshPart", "BlockingVolume", "DeadPawn", "Clothing",
		"ClothingCollision"
	};
	// Cinematic, gameplay, etc. not used here

	private final BitSet channels;

	/**
	 * Creates a new rigid body collision channel list with all channels disabled.
	 */
	public RBCollisionChannels() {
		channels = new BitSet(CHANNEL_NAMES.length);
	}
	public boolean equals(Object o) {
		return o instanceof RBCollisionChannels &&
			channels.equals(((RBCollisionChannels)o).channels);
	}
	/**
	 * Gets the values of the specified channel.
	 *
	 * @param channel the channel to look up
	 * @return the set/clear status of that channel
	 */
	public boolean getChannel(final int channel) {
		if (channel < 0 || channel >= CHANNEL_NAMES.length)
			throw new IndexOutOfBoundsException("Invalid lighting channel " + channel);
		return channels.get(channel);
	}
	/**
	 * Checks to see if this channel set is empty.
	 *
	 * @return whether no bits are set in the channels
	 */
	public boolean isEmpty() {
		return channels.isEmpty();
	}
	/**
	 * Changes all of the values in these collision channels to match another.
	 *
	 * @param other the channels to copy
	 */
	public void setAll(final RBCollisionChannels other) {
		channels.clear();
		channels.or(other.channels);
	}
	/**
	 * Changes the value of the specified lighting channel.
	 *
	 * @param channel the channel to set
	 * @param value whether the channel is enabled
	 */
	public void setChannel(final int channel, final boolean value) {
		if (channel < 0 || channel >= CHANNEL_NAMES.length)
			throw new IndexOutOfBoundsException("Invalid lighting channel " + channel);
		channels.set(channel, value);
	}
	/**
	 * Sets the values of the lighting channels from the specified T3D string.
	 *
	 * @param values the values of the lighting channels expressed as a string
	 */
	public void setFromString(final String values) {
		// Strip the parens
		final int len = values.length(); int index; String in = values, token, key;
		if (len > 1) {
			final char first = values.charAt(0), last = values.charAt(len - 1);
			if (first == '(' && last == ')')
				in = values.substring(1, len - 1);
			final StringTokenizer str = new StringTokenizer(in, ",");
			while (str.hasMoreTokens()) {
				token = str.nextToken();
				index = token.indexOf('=');
				if (index > 0) {
					key = token.substring(0, index);
					// Look for lighting key and set value
					for (int i = 0; i < CHANNEL_NAMES.length; i++)
						if (CHANNEL_NAMES[i].equalsIgnoreCase(key)) {
							setChannel(i, Boolean.parseBoolean(token.substring(index + 1)));
							break;
						}
				}
			}
		}
	}
	public String toString() {
		final StringBuilder out = new StringBuilder(64);
		out.append("(");
		for (int i = 0; i < CHANNEL_NAMES.length; i++)
			if (getChannel(i)) {
				if (out.length() > 1)
					out.append(',');
				out.append(CHANNEL_NAMES[i]);
				out.append("=True");
			}
		out.append(")");
		return out.toString();
	}
}