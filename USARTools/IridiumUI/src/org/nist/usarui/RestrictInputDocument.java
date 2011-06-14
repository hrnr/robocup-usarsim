package org.nist.usarui;

import javax.swing.text.*;

/**
 * Allows text strings containing only certain characters to be entered into a document. If
 * an invalid string is entered, the entire entry will fail.
 *
 * @author Stephen Carlson (NIST)
 */
public class RestrictInputDocument extends PlainDocument {
	/**
	 * The characters allowed.
	 */
	private String allowChars;

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
		for (int i = 0; i < str.length(); i++)
			if (allowChars.indexOf(str.charAt(i)) < 0) return;
		super.insertString(offs, str, a);
	}
}