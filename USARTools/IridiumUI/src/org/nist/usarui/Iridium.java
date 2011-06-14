package org.nist.usarui;

import java.io.*;
import java.lang.reflect.*;
import java.net.*;
import java.util.*;
import javax.swing.*;
import org.nist.usarui.handlers.*;

/**
 * The Iridium connection manager and format handler
 *
 * @author Stephen Carlson (NIST)
 */
public class Iridium {
	/**
	 * Indicates a skid-steered robot.
	 */
	public static final int DRIVETYPE_SKID = 0;
	/**
	 * Indicates an Ackerman steered robot.
	 */
	public static final int DRIVETYPE_ACKERMAN = 1;
	/**
	 * Indicates a flying robot.
	 */
	public static final int DRIVETYPE_AIR = 2;
	/**
	 * Maximum number of messages to display in the window. Messages parsed by sensor or data
	 * handlers do not count towards this limit.
	 */
	public static final int MAX_SIZE = 100;

	private final Properties config;
	private boolean frozen;
	private final List<StatusHandler> handlers;
	private BufferedReader in;
	private Writer out;
	private Socket toUSAR;
	private IridiumUI ui;
	private final List<USARPacket> usarData;

	/**
	 * Initializes the program and links it to the UI.
	 */
	public Iridium() {
		config = new Properties();
		loadConfig();
		frozen = false;
		handlers = new ArrayList<StatusHandler>(16);
		usarData = new LinkedList<USARPacket>();
		ui = new IridiumUI(this);
		// Fire up handlers
		loadHandlers();
	}
	/**
	 * Adds a packet to the list. If a data handler can handle it instead, the packet is not
	 * added and the handler gets the message instead. This method should be called on the event
	 * thread since UI updating occurs.
	 *
	 * @param packet the packet to insert
	 */
	public void addPacket(USARPacket packet) {
		boolean cont = true;
		for (StatusHandler handler : handlers)
			if (packet.isResponse())
				cont &= handler.statusReceived(packet);
			else
				cont &= handler.statusSent(packet);
		if (cont)
			synchronized (usarData) {
				// Truncate old data
				if (usarData.size() > MAX_SIZE) {
					usarData.remove(usarData.size() - 1);
					ui.packetRemoved();
				}
				usarData.add(0, packet);
				ui.packetAdded();
			}
	}
	/**
	 * Clears the log.
	 */
	public void clearLog() {
		synchronized (usarData) {
			usarData.clear();
		}
	}
	/**
	 * Connects to the specified server.
	 *
	 * @param hostPort Either "server" or "server:port"
	 */
	public synchronized void connect(String hostPort) {
		Socket temp; String host;
		disconnect();
		int port = 3000, index = hostPort.indexOf(':');
		if (index > 0) {
			host = hostPort.substring(0, index);
			try {
				port = Integer.parseInt(hostPort.substring(index + 1));
			} catch (Exception e) {
				Utils.showWarning(ui.getRoot(), "<b>Invalid address: \"" + hostPort +
					"\".</b><br><br>Valid forms:<br><ul><li><i>host</i></li>" +
					"<li><i>host</i>:<i>port</i></li></ul>");
				return;
			}
		} else
			host = hostPort;
		try {
			temp = new Socket();
			temp.connect(new InetSocketAddress(host, port), 1000);
			temp.setSoTimeout(0);
			toUSAR = temp;
			in = new BufferedReader(new InputStreamReader(toUSAR.getInputStream()));
			out = new BufferedWriter(new OutputStreamWriter(toUSAR.getOutputStream()));
		} catch (Exception e) {
			Utils.showWarning(ui.getRoot(), "<b>Cannot connect to \"" + host +
				"\".</b><br><br>Is Windows Firewall blocking UDK?");
			return;
		}
		Thread t = new Thread(new USARThread(), "USAR Messaging Thread");
		t.setPriority(Thread.MIN_PRIORITY);
		t.setDaemon(true);
		t.start();
		ui.invokeEvent("clear");
		ui.invokeEvent("connected");
	}
	/**
	 * Disconnects from the server.
	 */
	public synchronized void disconnect() {
		if (isConnected()) {
			try {
				toUSAR.close();
				out.close();
				in.close();
			} catch (Exception ignore) { }
			toUSAR = null;
			out = null;
			in = null;
			ui.invokeEvent("disconnect");
		}
	}
	/**
	 * Gets the Iridium configuration data.
	 *
	 * @return the Iridium options
	 */
	public Properties getConfig() {
		return config;
	}
	/**
	 * Gets the list of messages.
	 *
	 * @return the messages from the socket
	 */
	public List<USARPacket> getMessages() {
		return usarData;
	}
	/**
	 * Gets the specified user interface.
	 *
	 * @return the user interface
	 */
	public IridiumUI getUI() {
		return ui;
	}
	/**
	 * Gets whether the program is connected to USARSim.
	 *
	 * @return whether the program is currently connected
	 */
	public synchronized boolean isConnected() {
		return toUSAR != null && toUSAR.isConnected() && !toUSAR.isClosed();
	}
	/**
	 * Gets whether the message log is frozen (no new messages added)
	 *
	 * @return whether log messages have been stopped
	 */
	public boolean isFrozen() {
		return frozen;
	}
	/**
	 * Try to load user config; if that fails, load the one from the JAR
	 */
	private void loadConfig() {
		File file = new File("iridium.properties");
		boolean found = false;
		if (file.canRead())
			try {
				// Attempt file first
				InputStream is = new FileInputStream(file);
				config.load(is);
				is.close();
				found = true;
			} catch (IOException ignore) { }
		if (!found)
			try {
				// If not file, load from JAR
				InputStream jis = getClass().getResourceAsStream("/iridium.properties");
				if (jis != null) {
					config.load(jis);
					jis.close();
					found = true;
				}
			} catch (IOException ignore) { }
		if (!found)
			// Hardcode defaults to alert user of this issue
			config.put("RawCommand0", "INIT {Could not read iridium.properties file}");
	}
	/**
	 * Loads the data handlers
	 */
	@SuppressWarnings( "ConstantConditions" )
	private void loadHandlers() {
		Properties specs = new Properties(); String value; Class<?>[] arguments;
		try {
			InputStream is = getClass().getResourceAsStream("ActiveStatusHandlers.properties");
			if (is != null) {
				specs.load(is);
				is.close();
			}
			// If not available, none will be loaded
		} catch (IOException ignore) { }
		for (String key : specs.stringPropertyNames()) {
			value = specs.getProperty(key);
			// Key name is only partially relevant
			if (key.startsWith("Activate") && value != null)
				try {
					value = "org.nist.usarui.handlers." + value.trim();
					// Load up class and instantiate (assume constructor with Iridium)
					Class<?> hc = Class.forName(value);
					for (Constructor cons : hc.getConstructors()) {
						arguments = cons.getParameterTypes();
						if (arguments.length == 1 && arguments[0].equals(getClass()))
							// Instantiate
							handlers.add((StatusHandler)cons.newInstance(this));
					}
				} catch (Exception e) {
					System.err.println("Error activating handler " + value);
				}
		}
	}
	/**
	 * Sends joystick (or input field) commands to the robot drive. Expected range is from
	 * -1 to 1. X is left/right, Y is up/down.
	 *
	 * @param type the drive type (e.g. DRIVETYPE_SKID)
	 * @param lx left control stick, X axis
	 * @param ly left control stick, Y axis
	 * @param rx right control stick, X axis
	 * @param ry right control stick, Y axis
	 * @throws IOException if an I/O error occurs when sending
	 */
	public void sendJoystickValues(int type, double lx, double ly, double rx, double ry)
			throws IOException {
		switch (type) {
		case DRIVETYPE_SKID:
			sendMessage(String.format("DRIVE {Left %.2f} {Right %.2f}", ly, ry));
			break;
		case DRIVETYPE_ACKERMAN:
			sendMessage(String.format("DRIVE {Speed %.2f} {FrontSteer %.2f} {RearSteer %.2f}",
				ly, lx, ry));
			break;
		case DRIVETYPE_AIR:
			sendMessage(String.format("DRIVE {AltitudeVelocity %.2f} {LinearVelocity %.2f} " +
				"{LateralVelocity %.2f} {RotationalVelocity %.2f}", ry, ly, lx, rx));
			break;
		default:
			throw new IllegalArgumentException("Invalid drive type: " + type);
		}
	}
	/**
	 * Sends a message to the server.
	 *
	 * @param message the message to send
	 * @throws IOException if an I/O error occurs
	 */
	public void sendMessage(String message) throws IOException {
		out.write(message);
		out.write("\r\n");
		out.flush();
	}
	/**
	 * Freezes or unfreezes the contents of the log window.
	 *
	 * @param frozen whether the log window should accept new messages
	 */
	public void setFrozen(boolean frozen) {
		this.frozen = frozen;
	}

	/**
	 * Runs the thread which checks the socket for updates
	 */
	private class USARThread implements Runnable {
		private USARPacket packet;

		/**
		 * Creates a new monitor thread.
		 */
		public USARThread() {
			packet = null;
		}
		private USARThread(USARPacket packet) {
			this.packet = packet;
		}
		public void run() {
			String line;
			if (packet != null)
				// Delegate to put packet
				addPacket(packet);
			else
				// Listener thread
				try {
					while (isConnected() && (line = in.readLine()) != null)
						if (!frozen && (line = line.trim()).length() > 0)
							putPacketOnEventThread(new USARPacket(line, true));
				} catch (IOException ignore) {
				} finally {
					disconnect();
				}
		}
		/**
		 * Fixes nasty deadlock by processing packets on the event thread.
		 * Not the best way to do it (breaks UI-code separation) but it works.
		 *
		 * @param pack the packet to process
		 */
		private void putPacketOnEventThread(final USARPacket pack) {
			SwingUtilities.invokeLater(new USARThread(pack));
		}
	}
}