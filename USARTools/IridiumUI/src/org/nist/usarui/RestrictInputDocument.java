/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

import javax.swing.text.*;

/**
 * Allows text strings containing only certain characters to be entered into a document. If
 * an invalid string is entered, the entire entry will fail.
 *
 * @author Stephen Carlson (NIST)
 */
public class RestrictInputDocument extends PlainDocument {
	private static final long serialVersionUID = 0L;

	/**
	 * The characters allowed.
	 */
	private final String allowChars;

	/**
	 * Creates a RestrictInputDocument with the specified characters allowed.
	 *
	 * @param allowChars the characters allowed in a string
	 * @param text the initial text
	 */
	public RestrictInputDocument(String allowChars, String text) {
		this.allowChars = allowChars;
		try {
			// Exception can't happen
			getContent().insertString(0, text);
		} catch (BadLocationException ignore) { }
	}
	/*
	 * Only insertions can really cause issues with validation.
	 */
	public void insertString(int offs, String str, AttributeSet a) throws BadLocationException {
		boolean allow = true;
		for (int i = 0; i < str.length(); i++)
			if (allowChars.indexOf(str.charAt(i)) < 0) {
				// Check each character (better way?)
				allow = false;
				break;
			}
		if (allow)
			super.insertString(offs, str, a);
	}
}