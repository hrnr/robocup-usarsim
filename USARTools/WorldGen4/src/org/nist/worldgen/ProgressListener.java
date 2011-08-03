package org.nist.worldgen;

/**
 * Listener class for handling progress events.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface ProgressListener {
	/**
	 * Indicates that the event is complete.
	 */
	public void progressComplete();
	/**
	 * Indicates that progress has occurred.
	 *
	 * @param progress how much progress (from 0-100) that has occurred
	 */
	public void progressMade(final String title, final int progress);
}