package org.nist.worldgen.t3d;

import java.util.*;

/**
 * Class representing the various types of lighting channels available to objects.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class LightingChannels {
	/**
	 * Denotes the bInitialized channel (which isn't really a channel!)
	 */
	public static final int CH_INITIALIZED = 0;
	/**
	 * Denotes the BSP channel.
	 */
	public static final int CH_BSP = 1;
	/**
	 * Denotes the Static lighting channel.
	 */
	public static final int CH_STATIC = 2;
	/**
	 * Denotes the Dynamic lighting channel.
	 */
	public static final int CH_DYNAMIC = 3;
	/**
	 * Denotes the Composite Dynamic channel.
	 */
	public static final int CH_COMPOSITE = 4;
	/**
	 * Denotes the Skybox lighting channel.
	 */
	public static final int CH_SKYBOX = 5;
	/**
	 * UT names of each channel.
	 */
	protected static final String[] CHANNEL_NAMES = {
		"bInitialized", "BSP", "Static", "Dynamic", "CompositeDynamic", "Skybox",
		"Unnamed_1", "Unnamed_2", "Unnamed_3", "Unnamed_4", "Unnamed_5", "Unnamed_6",
		"Cinematic_1", "Cinematic_2", "Cinematic_3", "Cinematic_4", "Cinematic_5",
		"Cinematic_6", "Gameplay_1", "Gameplay_2", "Gameplay_3", "Gameplay_4",
	};
	// Cinematic, gameplay, etc. not used here

	private final BitSet channels;

	/**
	 * Creates a new lighting channel list with all channels disabled.
	 */
	public LightingChannels() {
		channels = new BitSet(CHANNEL_NAMES.length);
	}
	/**
	 * Creates a new lighting channel list with the bits (in order) set as given.
	 *
	 * @param args the values of the first few bits
	 */
	public LightingChannels(boolean... args) {
		this();
		for (int i = 0; i < args.length && i < CHANNEL_NAMES.length; i++)
			setChannel(i, args[i]);
	}
	public boolean equals(Object o) {
		return o instanceof LightingChannels &&
			channels.equals(((LightingChannels)o).channels);
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
	 * Changes all of the values in these lighting channels to match another.
	 *
	 * @param other the channels to copy
	 */
	public void setAll(final LightingChannels other) {
		channels.clear();
		channels.or(other.channels);
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