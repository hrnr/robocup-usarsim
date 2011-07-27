/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.script;

import org.jruby.*;
import org.jruby.embed.*;
import org.jruby.exceptions.*;
import org.jruby.javasupport.*;
import org.nist.usarui.*;
import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import javax.swing.text.Document;
import java.awt.*;
import java.awt.event.*;
import java.io.*;

/**
 * The Iridium Scripting Engine allows complex scripts to be written in Ruby to control USAR.
 * For instance, multiple robots can be controlled with different socket connections.
 *
 * @author Stephen Carlson (NIST)
 */
public class IridiumSE implements IridiumListener {
	/**
	 * Color for error messages in the output window.
	 */
	public static final Color ERROR_COLOR = Color.RED;
	/**
	 * Color for code output messages in the output window.
	 */
	public static final Color OUTPUT_COLOR = Color.BLACK;
	/**
	 * Color for system messages in the output window.
	 */
	public static final Color SYS_MSG_COLOR = new Color(0, 0, 127);

	// TEST
	public static void main(String[] args) {
		Errors.handleErrors();
		Utils.setUI();
		final IridiumSE test = new IridiumSE();
		test.start();
	}

	private JFileChooser chooser;
	private JFrame frame;
	private JTextPane output;
	private String rbVersion;
	private Action runAction;
	private Thread scriptThread;
	private Action stopAction;
	private DocumentWriter sysWriter;
	private final IridiumRubyConnector state;

	/**
	 * Creates and initializes the Scripting Engine and its UI.
	 */
	public IridiumSE() {
		rbVersion = "JRuby version not detected";
		state = new IridiumRubyConnector();
		setupUI();
		sysWriter = new DocumentWriter(SYS_MSG_COLOR, output.getDocument());
		Utils.centerWindow(frame);
	}
	/**
	 * Initializes a script context.
	 * Do this in another thread to avoid clogging up the AWT event loop.
	 */
	private void initScriptContext() {
		ScriptingContainer temp = new ScriptingContainer(LocalContextScope.SINGLETON);
		rbVersion = temp.getSupportedRubyVersion();
		temp.terminate();
		processEvent("context");
	}
	public void processEvent(final String event) {
		if (EventQueue.isDispatchThread())
			uiEvent(event);
		else
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					uiEvent(event);
				}
			});
	}
	public void processPacket(USARPacket packet) {
	}
	/**
	 * Runs the specified script.
	 *
	 * @param file the script file to run
	 */
	public synchronized void runScript(final File file) {
		if (scriptThread == null) {
			scriptThread = new Thread(new Runnable() {
				public void run() {
					try {
						runExternalScript(file);
					} catch (IOException e) {
						// File read error?
						systemMessage("I/O error when accessing: " + file.getName());
					}
					processEvent("stopped");
				}
			});
			scriptThread.setDaemon(true);
			processEvent("running");
			scriptThread.start();
		}
	}
	/**
	 * Run the specified script. Should be started and configured in a proper thread.
	 *
	 * @param file the file to execute
	 * @throws IOException if an I/O error occurs when reading the script
	 */
	private void runExternalScript(File file) throws IOException {
		final FileInputStream is = new FileInputStream(file);
		JavaEmbedUtils.EvalUnit code = null;
		final ScriptingContainer container = new ScriptingContainer(
			LocalContextScope.SINGLETHREAD, LocalVariableBehavior.TRANSIENT);
		container.setCompileMode(RubyInstanceConfig.CompileMode.JIT);
		setupStreams(container);
		// Parse file
		try {
			code = container.parse(is, file.getName(), 1);
		} catch (ParseFailedException ignore) { }
		is.close();
		// Run file
		if (code != null)
			try {
				code.run();
			} catch (EvalFailedException ignore) {
			} catch (RaiseException ignore) { }
		container.terminate();
		state.close();
	}
	/**
	 * Initializes the error and output streams. Redirects the context to these streams.
	 *
	 * @param container the ScriptingContainer for which to build streams
	 */
	private void setupStreams(ScriptingContainer container) {
		final Document doc = output.getDocument();
		try {
			// Script output writer
			final PipedReader sIn = new PipedReader();
			final Thread outputThread = new Thread(new DocumentReaderThread(sIn,
				new DocumentWriter(OUTPUT_COLOR, doc)), "Script Output Stream");
			outputThread.setDaemon(true);
			// Script error writer
			final PipedReader eIn = new PipedReader();
			final Thread errorThread = new Thread(new DocumentReaderThread(eIn,
				new DocumentWriter(ERROR_COLOR, doc)), "Script Error Stream");
			errorThread.setDaemon(true);
			// Assign class variables
			container.setOutput(new PipedWriter(sIn));
			container.setError(new PipedWriter(eIn));
			container.put("$__irid__", state);
			outputThread.start();
			errorThread.start();
			// IO errors should never happen!
		} catch (IOException ignore) { }
	}
	/**
	 * Initializes the user interface.
	 */
	private void setupUI() {
		// Create window
		frame = new JFrame("Iridium SE");
		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				state.close();
			}
		});
		frame.setResizable(true);
		// Create output pane
		output = new JTextPane();
		output.setEditable(false);
		output.setFont(new Font("Lucida Sans Typewriter", Font.PLAIN, 12));
		// Run/stop script actions
		runAction = new ScriptAction("Run Script...", "run", KeyEvent.VK_R);
		stopAction = new ScriptAction("Stop Script", "stop", KeyEvent.VK_C);
		// Run/stop script options
		final JPopupMenu menu = new JPopupMenu();
		final JMenuItem runScript = new JMenuItem(runAction);
		runScript.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_R, KeyEvent.CTRL_MASK));
		runScript.setActionCommand("run");
		runScript.setEnabled(false);
		menu.add(runScript);
		final JMenuItem stopScript = new JMenuItem(stopAction);
		stopScript.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_C, KeyEvent.CTRL_MASK));
		stopScript.setActionCommand("stop");
		stopScript.setEnabled(false);
		menu.add(stopScript);
		// Trip popup menu on right-click
		output.addMouseListener(new MouseAdapter() {
			public void mousePressed(MouseEvent e) {
				mouseReleased(e);
			}
			public void mouseReleased(MouseEvent e) {
				if (e.getClickCount() == 1 && e.isPopupTrigger())
					menu.show(output, e.getX(), e.getY());
			}
		});
		output.add(menu);
		// Add output to frame
		final JComponent temp = new JPanel(new BorderLayout(0, 0));
		temp.setBorder(BorderFactory.createEmptyBorder());
		temp.add(output, BorderLayout.CENTER);
		final JScrollPane sp = new JScrollPane(temp);
		sp.setBorder(BorderFactory.createEmptyBorder());
		// Repair slow-scrolling bug
		sp.getHorizontalScrollBar().setUnitIncrement(16);
		sp.getVerticalScrollBar().setUnitIncrement(16);
		sp.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		frame.getContentPane().add(sp, BorderLayout.CENTER);
		frame.setSize(640, 480);
		// Script chooser
		chooser = new JFileChooser(new File(".").getAbsoluteFile());
		chooser.setApproveButtonMnemonic(KeyEvent.VK_R);
		chooser.setDialogTitle("Run Script");
		chooser.setDialogType(JFileChooser.OPEN_DIALOG);
		chooser.setDragEnabled(false);
		chooser.setFileFilter(new FileFilter() {
			public boolean accept(File f) {
				return !f.isHidden() && (f.isDirectory() || f.getName().endsWith(".rb"));
			}
			public String getDescription() {
				return "Ruby Scripts (*.rb)";
			}
		});
		chooser.setMultiSelectionEnabled(false);
	}
	/**
	 * Shows or hides the Iridium SE main window.
	 *
	 * @param visible whether the main window is visible
	 */
	public void setVisible(boolean visible) {
		frame.setVisible(visible);
		if (visible)
			output.requestFocusInWindow();
	}
	/**
	 * Initializes the Iridium UI (may take up to 5 seconds)
	 */
	protected void start() {
		setVisible(true);
		initScriptContext();
	}
	/**
	 * Displays a system message in the console.
	 *
	 * @param message the message to display
	 */
	public void systemMessage(String message) {
		sysWriter.appendText("[System] " + message + "\n");
	}
	/**
	 * Process a UI or Iridium event.
	 *
	 * @param event the event which occurred
	 */
	private void uiEvent(final String event) {
		if (event.equals("context")) {
			// 1st context initialized
			systemMessage(rbVersion);
			systemMessage("This is a development version of Iridium.");
			systemMessage("No support for this program is provided by NIST.");
			runAction.setEnabled(true);
		} else if (event.equals("clearLog"))
			// Remove all text
			output.setText("");
		else if (event.equals("running")) {
			// Script started
			runAction.setEnabled(false);
			stopAction.setEnabled(true);
		} else if (event.equals("run") && scriptThread == null) {
			// Run script
			if (chooser.showDialog(output, "Run") == JFileChooser.APPROVE_OPTION) {
				// Wipe up the past
				state.close();
				systemMessage("Loading: " + chooser.getSelectedFile().getName());
				runScript(chooser.getSelectedFile());
			}
		} else if (event.equals("stopped")) {
			// Script ended
			runAction.setEnabled(true);
			stopAction.setEnabled(false);
			scriptThread = null;
		} else if (event.equals("stop"))
			// Stop script cleanly (disconnects the state, which causes every operation to
			// raise an exception, which should be caught and used to kill the script)
			state.close();
	}

	/**
	 * An action which triggers events related to scripts.
	 */
	private class ScriptAction extends AbstractAction {
		private static final long serialVersionUID = 0L;

		/**
		 * Creates a new ScriptAction.
		 *
		 * @param name the text to display
		 * @param command the command to fire
		 * @param key the key which will fire this action
		 */
		public ScriptAction(String name, String command, int key) {
			super(name);
			final KeyStroke accel = KeyStroke.getKeyStroke(key, KeyEvent.CTRL_MASK);
			putValue(ACCELERATOR_KEY, accel);
			putValue(MNEMONIC_KEY, Integer.valueOf(key));
			putValue(ACTION_COMMAND_KEY, command);
			setEnabled(false);
			output.getInputMap(JComponent.WHEN_FOCUSED).put(accel, command);
			output.getActionMap().put(command, this);
		}
		public void actionPerformed(ActionEvent e) {
			uiEvent(e.getActionCommand());
		}
	}

	/**
	 * A runnable object which pumps text from a Reader to a DocumentWriter until the
	 * stream is closed or an exception occurs.
	 */
	private class DocumentReaderThread implements Runnable {
		private final Reader reader;
		private final DocumentWriter writer;

		/**
		 * Creates a new DocumentReaderThread with the specified reader and DocumentWriter.
		 *
		 * @param reader the character Reader to read from
		 * @param writer the DocumentWriter to push text
		 */
		public DocumentReaderThread(Reader reader, DocumentWriter writer) {
			this.reader = reader;
			this.writer = writer;
		}
		public void run() {
			final char[] buffer = new char[1024]; int count;
			try {
				// Push text using copy loop
				while ((count = reader.read(buffer)) >= 0)
					if (count > 0) {
						writer.appendText(new String(buffer, 0, count));
						output.setCaretPosition(output.getDocument().getLength());
					}
			} catch (IOException ignore) {
				// Happens naturally when the write end goes dead
			} finally {
				// Close reader
				try {
					reader.close();
				} catch (IOException ignore) { }
			}
		}
	}
}