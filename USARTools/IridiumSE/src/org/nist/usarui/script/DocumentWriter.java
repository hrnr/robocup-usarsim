/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.script;

import javax.swing.text.*;
import java.awt.*;

/**
 * Appends specified text to a Document with the given color.
 *
 * @author Stephen Carlson (NIST)
 */
public class DocumentWriter {
	/**
	 * How many characters can go in the log before the first few are removed.
	 */
	public static final int MAX_LOG_LENGTH = 1024 * 1024;

	private final AttributeSet attr;
	private final Document document;

	/**
	 * Creates a DocumentWriter which reads from the specified stream.
	 *
	 * @param color the color to use when appending text
	 * @param doc the document to modify
	 */
	public DocumentWriter(Color color, Document doc) {
		document = doc;
		final StyleContext context = new StyleContext();
		attr = context.addAttribute(SimpleAttributeSet.EMPTY, StyleConstants.Foreground, color);
	}
	/**
	 * Writes the specified text into this document using the given color.
	 *
	 * @param text the text to append
	 */
	public void appendText(String text) {
		synchronized (document) {
			int len = document.getLength(), offset = 0, newLine = -1;
			try {
				if (len > MAX_LOG_LENGTH) {
					// Scan document quickly looking for new lines
					final Segment out = new Segment();
					out.setPartialReturn(true);
					while (len > 0) {
						document.getText(offset, len, out);
						// Remove first new line instance
						for (int i = 0; i < out.count; i++)
							if (out.array[i] == '\n') {
								newLine = offset + i;
								break;
							}
						len -= out.count;
						offset += out.count;
					}
					// Wipe out old lines
					if (newLine < 0)
						document.remove(0, document.getLength());
					else
						document.remove(0, newLine + 1);
					len = document.getLength();
				}
				document.insertString(len, text, attr);
			} catch (BadLocationException ignore) { }
		}
	}
}