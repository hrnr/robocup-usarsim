package org.nist.usarui;

import java.io.*;
import java.lang.Thread.*;
import java.util.regex.*;
import javax.swing.*;
import java.awt.*;

/**
 * Error handlers handle errors in Iridium. These are entirely separate
 *  to minimize Iridium crashes working their way into the error handler too.
 */
public final class Errors implements UncaughtExceptionHandler {
	// Options for cleaning up after an error
	private static final String[] RESUME_OPTIONS = new String[] {
		"Details to Report", "Exit"
	};
	// Patterns for replacing HTML escapes in the message log
	private static final Pattern LESS = Pattern.compile("<");
	private static final Pattern AND = Pattern.compile("&");
	private static final Pattern NL = Pattern.compile("\n");
	private static final Pattern GREAT = Pattern.compile(">");

	/**
	 * Handles errors on all threads.
	 */
	public static void handleErrors() {
		Thread.setDefaultUncaughtExceptionHandler(new Errors());
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
		text.append("</font><br>Iridium will exit now.</body></html>");
		JOptionPane.showMessageDialog(null, text.toString(), "Iridium",
			JOptionPane.ERROR_MESSAGE);
		System.exit(1);
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
		if (GraphicsEnvironment.isHeadless()) {
			// If error was caused in command line environment
			t.printStackTrace();
			return;
		}
		// Clean up after memory/stack errors
		System.runFinalization();
		System.gc();
		msg = getMessageText();
		try {
			// Prompt to continue?
			if (JOptionPane.showOptionDialog(null, msg, "Iridium", JOptionPane.DEFAULT_OPTION,
				JOptionPane.ERROR_MESSAGE, null, RESUME_OPTIONS, "Exit") != 0)
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
		} catch (Throwable e) {
			t.printStackTrace();
		}
		System.exit(1);
	}
	/**
	 * Gets the text of the message that is displayed initially. 
	 * 
	 * @return the Oh No message text
	 */
	private static String getMessageText() {
		// Elaborate error message text
		StringBuilder message = new StringBuilder(512);
		message.append("<html><body><center><font size=\"+2\">Oh no!</font></center><br>");
		message.append("Though Iridium is almost done, errors still happen.<br>Even worse, ");
		message.append("Iridium could not handle this error.<br>It is better to exit now ");
		message.append("than cause more errors.<br>We are sorry if any data was lost.");
		message.append("</body></html>");
		return message.toString();
	}
	/**
	 * Encodes the HTML escape characters in the text.
	 * 
	 * @param text the error message
	 * @return the error message with &lt;, &amp;, and &gt; escaped
	 */
	private static String encode(String text) {
		String lt;
		if (text == null) return "No message";
		// replace each with & character code
		lt = AND.matcher(text).replaceAll("&amp;");
		lt = LESS.matcher(lt).replaceAll("&lt;");
		lt = GREAT.matcher(lt).replaceAll("&gt;");
		return NL.matcher(lt).replaceAll("<br>");
	}

	public void uncaughtException(Thread t, Throwable e) {
		sorry(e);
	}
	private Errors() { }
}