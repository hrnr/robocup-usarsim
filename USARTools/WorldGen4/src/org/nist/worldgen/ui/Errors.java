/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.worldgen.ui;

import java.io.*;
import java.lang.Thread.*;
import java.util.regex.*;
import javax.swing.*;
import java.awt.*;

/**
 * Error handlers handle errors in the World Generator. These are entirely separate
 * to minimize World Generator crashes working their way into the error handler too.
 */
public final class Errors implements UncaughtExceptionHandler {
	private static final Pattern AND = Pattern.compile("&");
	private static final Pattern GREAT = Pattern.compile(">");
	// Patterns for replacing HTML escapes in the message log
	private static final Pattern LESS = Pattern.compile("<");
	private static final Pattern NL = Pattern.compile("\n");
	// Options for cleaning up after an error
	private static final String[] RESUME_OPTIONS = new String[] {
		"Details to Report", "Exit"
	};
	/**
	 * Encodes the HTML escape characters in the text.
	 * 
	 * @param text the error message
	 * @return the error message with &lt;, &amp;, and &gt; escaped
	 */
	private static String encode(String text) {
		String lt;
		if (text == null)
			lt = "No message";
		else {
			// replace each with & character code
			lt = AND.matcher(text).replaceAll("&amp;");
			lt = LESS.matcher(lt).replaceAll("&lt;");
			lt = GREAT.matcher(lt).replaceAll("&gt;");
			lt = NL.matcher(lt).replaceAll("<br>");
		}
		return lt;
	}
	/**
	 * Gets the text of the message that is displayed initially. 
	 * 
	 * @return the Oh No message text
	 */
	private static String getMessageText() {
		// Elaborate error message text
		StringBuilder message = new StringBuilder(512);
		message.append("<html><body><center><font size=\"+2\">Oh No!</font></center>");
		message.append("The World Generator for UDK has encountered a bug.<br>");
		message.append("Even worse, the internal error handler failed to catch it.<br>");
		message.append("It is better to exit now than cause more errors or corrupt data.<br>");
		message.append("Please file a bug report with the developers to fix this error.");
		message.append("</body></html>");
		return message.toString();
	}

	/**
	 * Handles errors on all threads.
	 */
	public static void handleErrors() {
		if (GraphicsEnvironment.isHeadless()) {
			System.out.println("The World Generator must be run in a GUI environment.");
			System.out.println("To generate worlds automatically, try AutoGenerate.");
			System.exit(1);
		}
		Thread.setDefaultUncaughtExceptionHandler(new Errors());
	}
	/**
	 * Ends the program with an "Oh no!" message. To be used in case of a
	 * programming error.
	 * 
	 * @param t the error that occurred
	 */
	public static void sorry(Throwable t) {
		StringWriter message; PrintWriter out; String msg, name; StackTraceElement[] stack;
		if (t == null) return;
		while (t.getCause() != null)
			t = t.getCause();
		// Clean up after memory/stack errors
		System.runFinalization();
		System.gc();
		msg = getMessageText();
		try {
			// Prompt to continue?
			if (JOptionPane.showOptionDialog(null, msg, "World Generator for UDK",
				JOptionPane.DEFAULT_OPTION, JOptionPane.ERROR_MESSAGE, null,
				RESUME_OPTIONS, "Exit") != 0)
				System.exit(1);
			// Create detailed message
			message = new StringWriter(512);
			out = new PrintWriter(message);
			// Include error name and message
			out.print("<html><body><pre><b>");
			out.print(t.getClass().getSimpleName());
			out.print("</b>: <i>");
			out.print(encode(t.getMessage()));
			out.print("</i><br>");
			// Print stack trace (max 64 elements)
			stack = t.getStackTrace();
			for (int i = 0; i < stack.length && i < 64; i++) {
				name = stack[i].getClassName();
				if (!name.startsWith("java") && !name.startsWith("sun"))
					out.print(" at " + encode(stack[i].toString()) + "<br>");
			}
			out.print("</pre></body></html>");
			// Display details
			out.close();
			JOptionPane.showMessageDialog(null, message, "Error Details",
				JOptionPane.ERROR_MESSAGE);
			// If it crashes inside this block, it's probably very, very dire
		} catch (Throwable e) {
			e.printStackTrace();
		}
		System.exit(1);
	}
	/**
	 * A user error brought the program down in a non-recoverable way.
	 * <b>Not</b> for a programming error.
	 * 
	 * @param message the error message
	 */
	public static void userError(String message) {
		StringBuilder text = new StringBuilder(512);
		text.append("<html><body><b>Error:</b> <font color=\"#FF0000\">");
		text.append(encode(message));
		text.append("</font><br>World Generator for UDK will exit now.</body></html>");
		JOptionPane.showMessageDialog(null, text.toString(), "World Generator for UDK",
			JOptionPane.ERROR_MESSAGE);
		System.exit(1);
	}
	private Errors() { }

	public void uncaughtException(Thread t, Throwable e) {
		sorry(e);
	}
}