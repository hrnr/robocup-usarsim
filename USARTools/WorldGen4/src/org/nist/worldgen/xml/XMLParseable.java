package org.nist.worldgen.xml;

import org.xml.sax.*;

/**
 * Marks objects that, once constructed, can reconstitute themselves from an XML connection.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public interface XMLParseable {
	/**
	 * Fired during XML parsing when a tag is encountered for deserialization for this object
	 * or one of its children. Tags will come in order of appearance in the file.
	 *
	 * @param tagName the tag name encountered
	 * @param attributes the tag attributes
	 * @throws SAXException if a parse error occurs
	 */
	public void fromTag(String tagName, Attributes attributes) throws SAXException;
}