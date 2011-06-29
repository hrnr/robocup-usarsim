/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

import java.io.*;
import java.net.*;
import java.util.*;

/**
 * The Iridium connection manager and format handler
 *
 * @author Stephen Carlson (NIST)
 */
public class Iridium implements IridiumConnector {
	private final Properties config;
	private BufferedReader in;
	private final List<IridiumListener> listeners;
	private Writer out;
	private Socket toUSAR;

	/**
	 * Initializes the program.
	 */
	public Iridium() {
		config = new Properties();
		listeners = new ArrayList<IridiumListener>(5);
		loadConfig();
	}
	public void addIridiumListener(IridiumListener listener) {
		synchronized (listeners) {
			listeners.add(listener);
		}
	}
	public synchronized void connect(String hostPort) throws IOException {
		Socket temp; String host;
		disconnect();
		int port = 3000, index = hostPort.indexOf(':');
		if (index > 0) {
			host = hostPort.substring(0, index);
			try {
				port = Integer.parseInt(hostPort.substring(index + 1));
			} catch (NumberFormatException e) {
				throw new IOException("Host not found: " + hostPort);
			}
		} else
			host = hostPort;
		// Open socket
		temp = new Socket();
		temp.connect(new InetSocketAddress(host, port), 1000);
		temp.setSoTimeout(0);
		// Create socket input and output
		toUSAR = temp;
		in = new BufferedReader(new InputStreamReader(toUSAR.getInputStream()));
		out = new BufferedWriter(new OutputStreamWriter(toUSAR.getOutputStream()));
		// Start thread to handle socket messages
		Thread t = new Thread(new USARThread(), "USAR Messaging Thread");
		t.setPriority(Thread.MIN_PRIORITY);
		t.setDaemon(true);
		t.start();
		invokeEvent("connected");
	}
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
			invokeEvent("disconnect");
		}
	}
	public Properties getConfig() {
		return config;
	}
	public IridiumListener[] getIridiumListeners() {
		synchronized (listeners) {
			return listeners.toArray(new IridiumListener[listeners.size()]);
		}
	}
	/**
	 * Fires the specified event to all listeners.
	 *
	 * @param eventName the event that occurred
	 */
	public void invokeEvent(String eventName) {
		synchronized (listeners) {
			for (IridiumListener listener : listeners)
				listener.processEvent(eventName);
		}
	}
	/**
	 * Fires the specified packet to all listeners.
	 *
	 * @param packet the packet triggering the event
	 */
	public void invokePacket(USARPacket packet) {
		synchronized (listeners) {
			for (IridiumListener listener : listeners)
				listener.processPacket(packet);
		}
	}
	public synchronized boolean isConnected() {
		return toUSAR != null && toUSAR.isConnected() && !toUSAR.isClosed();
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
	public void removeIridiumListener(IridiumListener listener) {
		synchronized (listeners) {
			listeners.remove(listener);
		}
	}
	public void sendMessage(String message) throws IOException {
		out.write(message);
		out.write("\r\n");
		out.flush();
	}

	/**
	 * Runs the thread which checks the socket for updates.
	 */
	private class USARThread implements Runnable {
		public void run() {
			String line;
			// Listener thread
			try {
				while (isConnected() && (line = in.readLine()) != null)
					if ((line = line.trim()).length() > 0)
						invokePacket(new USARPacket(line, true));
			} catch (IOException ignore) {
			} finally {
				disconnect();
			}
		}
	}
}