package org.nist.worldgen.t3d;

import java.io.PrintWriter;

/**
 * Implemented by all classes which want a custom method of writing their contents.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public interface UTWritable {
	/**
	 * Convert this object to Unreal Text.
	 *
	 * @param out the print writer where the text will be sent
	 * @param indent how many levels to indent
	 * @param utCompatMode the compatibility mode used in the output
	 */
	public void toUnrealText(PrintWriter out, int indent, int utCompatMode);
}
