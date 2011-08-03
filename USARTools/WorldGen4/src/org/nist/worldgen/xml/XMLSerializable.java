package org.nist.worldgen.xml;

import java.io.*;

/**
 * Represents objects which can smoothly convert themselves to XML.
 *
 * @author Stephen Carlson (NIST)
 * @version 4
 */
public interface XMLSerializable {
	/**
	 * Converts this object to XML.
	 *
	 * @param out the output stream to which to write
	 * @param indent how many levels this object should be indented for human readability
	 */
	public void toXML(PrintWriter out, int indent);
}
