package org.nist.usarui;

import com.centralnexus.input.*;
import javax.swing.*;
import javax.swing.border.Border;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

/**
 * Iridium graphical user interface (hand cleaned)
 *
 * @author Stephen Carlson (NIST)
 */
public class IridiumUI {
	/**
	 * Insets applied to fields.
	 */
	public static final Insets FIELD_INSETS = new Insets(1, 0, 1, 0);
	/**
	 * The border displayed around sensor information panels.
	 */
	public static final Border INFO_BORDER = BorderFactory.createCompoundBorder(
		BorderFactory.createEtchedBorder(),
		BorderFactory.createEmptyBorder(0, 2, 0, 2));
	/**
	 * The color used for the title of information bars.
	 */
	public static final Color INFO_TITLE = new Color(0, 0, 127);
	/**
	 * Insets applied to field labels.
	 */
	public static final Insets NO_INSETS = new Insets(0, 0, 0, 0);
	/**
	 * Available options for SET when using "Camera" as type.
	 */
	public static final String[] OPT_CAMERA = { "FOV" };
	/**
	 * Available options for SET when using "Gripper" as type.
	 */
	public static final String[] OPT_GRIPPER = { "Open", "Close" };
	/**
	 * Available options for SET when using "Joint" as type.
	 */
	public static final String[] OPT_JOINTS = { "Angle", "Velocity", "Torque" };
	/**
	 * The distance between the main window and auxiliary windows.
	 */
	public static final int PAD = 5;

	private Icon badIcon;
	private JLabel batteryLife;
	private JComboBox commandType;
	private JButton connectButton;
	private JTextField driveAltitude;
	private JTextField driveFront;
	private JCheckBox driveHeadlights;
	private JTextField driveLateral;
	private JTextField driveLeft;
	private JTextField driveLinear;
	private JCheckBox driveNormalized;
	private JTextField driveRear;
	private JTextField driveRight;
	private JTextField driveRotational;
	private JTextField driveSpeed;
	private JComboBox driveType;
	private JComponent driveView;
	private JLabel elapsedTime;
	private JButton freezeButton;
	private JTextField geoName;
	private JComboBox geoType;
	private Icon goodIcon;
	private JComboBox initClass;
	private JComboBox initLocation;
	private JTextField initRotation;
	private JLabel levelName;
	private EventListener listener;
	private JComponent mainUI;
	private JTextField misLink;
	private JComboBox misName;
	private JTextField misValue;
	private JComboBox rawCommand;
	private JList responseList;
	private JCheckBox rotDegrees;
	private JButton sendButton;
	private JTextField serverName;
	private JComboBox setName;
	private JComboBox setOpcode;
	private JTextField setParams;
	private JComboBox setType;
	private JButton stopButton;
	private JButton swapButton;
	private JComponent topInfo;
	private JComponent typePanel;

	private final float[] axes;
	private final Map<String, MapView> dialogs;
	private final Map<String, InfoPanel> infoPanels;
	private final Iridium state;
	private Joystick stick;

	/**
	 * Initializes the Iridium GUI.
	 *
	 * @param state the program to link
	 */
	public IridiumUI(Iridium state) {
		axes = new float[4];
		dialogs = new HashMap<String, MapView>(8);
		infoPanels = new HashMap<String, InfoPanel>(24);
		this.state = state;
		stick = null;
		loadImages();
		setupUI();
		setConnected(false);
	}
	/**
	 * Iterate through the properties and add items to the combo box as required
	 *
	 * @param box the combo box to which to add items
	 * @param prefix the prefix denoting item indices
	 */
	private void addToComboBox(JComboBox box, String prefix) {
		String value;
		for (int i = 0; (value = state.getConfig().getProperty(prefix + i, null)) != null; i++)
			box.addItem(value.trim());
	}
	/**
	 * Adds the command to the history in the advanced input box.
	 *
	 * @param command the command string to add
	 */
	private void addToHistory(String command) {
		for (int i = 0; i < rawCommand.getItemCount(); i++)
			// Remove older items in history
			if (((String)rawCommand.getItemAt(i)).equalsIgnoreCase(command))
				rawCommand.removeItemAt(i);
		rawCommand.insertItemAt(command, 0);
		if (rawCommand.getItemCount() > Iridium.MAX_SIZE)
			// Clean this one up too
			rawCommand.removeItemAt(rawCommand.getItemCount() - 1);
		rawCommand.setSelectedIndex(0);
	}
	/**
	 * Clears all information panels.
	 */
	private void clearAllPanels() {
		infoPanels.clear();
		topInfo.removeAll();
		mainUI.validate();
	}
	/**
	 * Closes all dialogs opened by sensor panels.
	 */
	private void closeAllDialogs() {
		synchronized (dialogs) {
			for (MapView view : dialogs.values())
				view.close();
			dialogs.clear();
		}
	}
	/**
	 * Disconnects and releases the joystick if connected.
	 */
	private void closeJoystick() {
		if (stick != null) {
			stick.removeJoystickListener(listener);
			stick = null;
		}
	}
	/**
	 * Initializes the user interface when the program connects.
	 */
	private void connected() {
		// Clean out old data from past runs
		clearAllPanels();
		closeAllDialogs();
		updateJoints(null);
		updateMisPkg(null);
		setConnected(true);
		// Startup info that would be nice to populate boxes
		sendInternalMessage("GETSTARTPOSES");
		sendInternalMessage("GETCONF {Type MisPkg}");
	}
	/**
	 * Creates a button.
	 *
	 * @param text the text label to display
	 * @param tooltip the tool tip text to show
	 * @param action the action event to fire when clicked
	 * @return the button with default options set
	 */
	protected JButton createButton(String text, String tooltip, String action) {
		final JButton button = new JButton(text);
		button.addActionListener(listener);
		button.setActionCommand(action);
		button.setFocusable(false);
		button.setToolTipText(tooltip);
		return button;
	}
	/**
	 * Creates a default floating point entry field.
	 *
	 * @param tooltip the tool tip to show
	 * @return the field with default options set
	 */
	protected JTextField createFloatTextField(String tooltip) {
		final JTextField field = createTextField("0.0", 5, tooltip);
		field.setDocument(new RestrictInputDocument("-0123456789.Ee", "0.0"));
		return field;
	}
	/**
	 * Creates a default text entry field.
	 *
	 * @param text the default text
	 * @param columns the field width
	 * @param tooltip the tool tip to show
	 * @return the field with default options set
	 */
	protected JTextField createTextField(String text, int columns, String tooltip) {
		final JTextField field = new JTextField(text, columns);
		field.addActionListener(listener);
		field.setActionCommand("send");
		field.setToolTipText(tooltip);
		Utils.armFocusListener(field);
		return field;
	}
	/**
	 * Cleans up the status when the program disconnects.
	 */
	private void disconnected() {
		setConnected(false);
		updateJoints(null);
		updateLevel(null);
		updateMisPkg(null);
		updateStartPoses(null);
		updateTime(-1.f);
		updateBattery(Integer.MAX_VALUE);
	}
	/**
	 * Exits the program cleanly.
	 */
	public void exit() {
		state.disconnect();
		closeJoystick();
		closeAllDialogs();
	}
	/**
	 * Feeds a DRIVE command if necessary to the robot if the joystick is connected and moved.
	 */
	private void feedJoystickToRobot() {
		float x, y, z, r;
		if (stick != null) {
			// Allow partial control of vehicles if the joystick is insufficient
			if (stick.getNumAxes() > 3) {
				// Full
				x = stick.getX();
				y = stick.getY();
				z = stick.getZ();
				r = stick.getR();
			} else if (stick.getNumAxes() == 3) {
				// Disable y (works well for ackerman, ok for skid)
				x = stick.getX();
				r = stick.getY();
				z = stick.getZ();
				y = 0.f;
			} else {
				// Disable r and z (skid only)
				x = stick.getX();
				z = stick.getY();
				y = r = 0.f;
			}
			if (!Utils.isFloatEqual(x, axes[0]) || !Utils.isFloatEqual(y, axes[1]) ||
				!Utils.isFloatEqual(z, axes[2]) || !Utils.isFloatEqual(r, axes[3])) {
				// Send message; if error, treat like any other
				if (state.isConnected())
					try {
						state.sendJoystickValues(driveType.getSelectedIndex(), z, r, x, y);
					} catch (IOException e) {
						state.disconnect();
					}
				// Update last values
				axes[0] = x;
				axes[1] = y;
				axes[2] = z;
				axes[3] = r;
			}
		}
	}
	/**
	 * Returns the parameter string associated with GETGEO/GETCONF requests from the panel UI.
	 *
	 * @return the common aspect of the
	 */
	private String getGeoconfParameters() {
		String params = "{Type " + geoType.getEditor().getItem() + "}",
			name = geoName.getText();
		if (name != null && name.length() > 0)
			params += " {Name " + name.trim() + "}";
		return params;
	}
	/**
	 * Gets the specified information panel, creating it if necessary.
	 *
	 * @param group the panel name
	 * @param name the name of the individual entry in the panel
	 * @param label the panel's label (used only if creation required)
	 * @return the appropriate panel
	 */
	public InfoPanel getInfoPanel(String group, String name, String label) {
		InfoPanel panel = infoPanels.get(group);
		if (panel == null) {
			// Create new panel and add to list
			panel = new InfoPanel(label, name);
			topInfo.add(panel.getPanel());
			topInfo.add(Box.createVerticalStrut(1));
			mainUI.validate();
			infoPanels.put(group, panel);
		}
		return panel;
	}
	/**
	 * Gets the selected starting pose for the robot (INIT panel), or null if customized.
	 *
	 * @return the robot's starting pose
	 */
	private StartPose getPlayerStart() {
		Object item; StartPose pose = null;
		String text = initLocation.getEditor().getItem().toString();
		// Look for the pose location or tag, whichever is useful
		for (int i = 0; i < initLocation.getItemCount(); i++) {
			item = initLocation.getItemAt(i);
			pose = null;
			if (item instanceof StartPose) {
				pose = (StartPose)initLocation.getItemAt(i);
				if (pose.toString().equalsIgnoreCase(text))
					// Matched!
					break;
				else
					pose = null;
			}
		}
		return pose;
	}
	/**
	 * Gets the component which can be displayed in a top level container.
	 *
	 * @return the parent UI component
	 */
	public JComponent getRoot() {
		return mainUI;
	}
	/**
	 * Gets the specified view, opening it if necessary.
	 *
	 * @param title the view title
	 * @return the view
	 */
	public MapView getView(final String title) {
		MapView ret = dialogs.get(title); final Rectangle ss, thisWin;
		if (ret == null) {
			ret = new MapView(title, mainUI);
			synchronized (dialogs) {
				dialogs.put(title, ret);
			}
			final Dimension vs = ret.getSize();
			// Try to place the view on the screen, first right, then left, then bottom
			ss = GraphicsEnvironment.getLocalGraphicsEnvironment().getMaximumWindowBounds();
			thisWin = Utils.findParent(mainUI).getBounds();
			if (thisWin.width + thisWin.x + PAD + vs.width < ss.width)
				ret.setLocation(thisWin.x + thisWin.width + PAD, thisWin.y);
			else if (thisWin.x - PAD - vs.width > ss.x)
				ret.setLocation(thisWin.x - PAD - vs.width, thisWin.y);
			else if (thisWin.y + PAD + vs.height < ss.height)
				ret.setLocation(thisWin.x, thisWin.y + PAD);
			else
				// Else give up
				ret.setLocationRelativeTo(responseList);
			ret.setVisible(true);
		}
		return ret;
	}
	/**
	 * Grabs the joystick input if possible. Warns the user if their joystick may not work.
	 */
	protected void grabJoystick() {
		try {
			stick = Joystick.createInstance();
			if (stick.getNumAxes() < 4)
				Utils.showWarning(mainUI, "<b>Joystick warning</b>:<br><br>Your joystick " +
					"has fewer than 4 axes; it may not be able to control all robots.");
			// NOTE: There is no scale factor available, so full throttle = 1 rad/s
			stick.setDeadZone(0.1f);
			stick.setPollInterval(50);
			stick.addJoystickListener(listener);
			// Reset axes
			axes[0] = axes[1] = axes[2] = axes[3] = 0.f;
		} catch (IOException e) {
			stick = null;
		} catch (UnsatisfiedLinkError e) {
			// Library load error
			stick = null;
		}
	}
	/**
	 * Fires the specified event to occur on the event thread after all pending events have
	 * been dispatched.
	 *
	 * @param cmd the event to invoke
	 */
	public void invokeEvent(final String cmd) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				processEvent(cmd);
			}
		});
	}
	/**
	 * Gets whether the UI is in degree mode.
	 *
	 * @return whether UI values should be degrees, not radians
	 */
	public boolean isInDegrees() {
		return rotDegrees.isSelected();
	}
	/**
	 * Loads the images required to run.
	 */
	private void loadImages() {
		badIcon = Utils.loadImage("images/bad.png");
		goodIcon = Utils.loadImage("images/good.png");
	}
	/**
	 * Triggered when a message is added to the log.
	 */
	protected void packetAdded() {
		// Message added
		synchronized (state.getMessages()) {
			((ListDataModel)responseList.getModel()).fireIntervalAdded(0, 0);
		}
	}
	/**
	 * Triggered when a message is removed from the log due to log size.
	 */
	protected void packetRemoved() {
		// Message removed
		int len = state.getMessages().size();
		synchronized (state.getMessages()) {
			((ListDataModel)responseList.getModel()).fireIntervalRemoved(len - 1, len - 1);
		}
	}
	/**
	 * Processes the specified UI event. <i>Must be called on the event thread.</i>
	 *
	 * @param cmd the UI event that was triggered
	 */
	private void processEvent(String cmd) {
		boolean status;
		if (cmd.equals("swap"))
			// Show/hide Advanced Input
			showRawCommand(!rawCommand.isVisible());
		else if (cmd.equals("send") && state.isConnected()) {
			// Send message
			if (swapButton.isSelected())
				sendMessage((String)rawCommand.getEditor().getItem());
			else
				sendWSIWYG();
		} else if (cmd.equals("freeze")) {
			// Freeze/Unfreeze
			status = state.isUnfrozen();
			state.setFrozen(status);
			if (status)
				freezeButton.setText("Unfreeze");
			else
				freezeButton.setText("Freeze");
		} else if (cmd.equals("card")) {
			// Change available type
			cmd = commandType.getSelectedItem().toString().toLowerCase();
			if (cmd.equals("getgeo") || cmd.equals("getconf"))
				cmd = "geoconf";
			((CardLayout)typePanel.getLayout()).show(typePanel, cmd);
			Utils.focusFirstComponent(typePanel);
		} else if (cmd.equals("drive")) {
			// Change drive type
			cmd = driveType.getSelectedItem().toString();
			((CardLayout)driveView.getLayout()).show(driveView, cmd.toLowerCase());
			Utils.focusFirstComponent(driveView);
		} else if (cmd.equals("connect")) {
			// Connect/disconnect
			if (state.isConnected())
				state.disconnect();
			else
				state.connect(serverName.getText());
		} else if (cmd.equals("connected"))
			// Connect explicitly
			connected();
		else if (cmd.equals("disconnect"))
			// Disconnect explicitly
			disconnected();
		else if (cmd.equals("clear")) {
			// Clear log
			state.clearLog();
			((ListDataModel)responseList.getModel()).fireCleared();
		} else if (cmd.equals("estop"))
			// Stop robot!
			sendInternalMessage("DRIVE {Left 0} {Right 0} {Speed 0} {AltitudeVelocity 0} " +
				"{LinearVelocity 0} {LateralVelocity 0} {RotationalVelocity 0}");
		else if (cmd.equals("feed"))
			// Joystick
			feedJoystickToRobot();
	}
	/**
	 * Sends a DRIVE command with the appropriate values.
	 */
	private void sendCmdDrive() {
		// Set up normalization and headlights
		String extra = "";
		if (driveHeadlights.isSelected())
			extra = " {Light true}";
		if (driveNormalized.isSelected())
			extra += " {Normalized true}";
		// Depends on drive type
		switch (driveType.getSelectedIndex()) {
		case 0:
			float left, right;
			// Skid
			try {
				left = Float.parseFloat(driveLeft.getText());
				right = Float.parseFloat(driveRight.getText());
			} catch (NumberFormatException e) {
				Utils.showWarning(mainUI, "Enter valid speeds for left and right wheels.");
				break;
			}
			sendMessage(String.format("DRIVE {Left %.2f} {Right %.2f}%s", left, right, extra));
			break;
		case 1:
			float speed, front, back;
			// Ackerman
			try {
				speed = Float.parseFloat(driveSpeed.getText());
				front = Float.parseFloat(driveFront.getText());
				back = Float.parseFloat(driveRear.getText());
				// Convert if needed
				if (isInDegrees()) {
					front = (float)Math.toRadians(front);
					back = (float)Math.toRadians(back);
				}
			} catch (NumberFormatException e) {
				Utils.showWarning(mainUI, "Enter valid speeds and steering amounts.");
				break;
			}
			sendMessage(String.format("DRIVE {Speed %.2f} {FrontSteer %.2f} {RearSteer %.2f}%s",
				speed, front, back, extra));
			break;
		case 2:
			float alt, lin, lat, rot;
			// Flying
			try {
				alt = Float.parseFloat(driveAltitude.getText());
				lin = Float.parseFloat(driveLinear.getText());
				lat = Float.parseFloat(driveLateral.getText());
				rot = Float.parseFloat(driveRotational.getText());
				// Convert if needed
				if (isInDegrees())
					rot = (float)Math.toRadians(rot);
			} catch (NumberFormatException e) {
				Utils.showWarning(mainUI, "Enter valid velocities for vehicle.");
				break;
			}
			sendMessage(String.format("DRIVE {AltitudeVelocity %.2f} {LinearVelocity %.2f} " +
				"{LateralVelocity %.2f} {RotationalVelocity %.2f}%s", alt, lin, lat, rot, extra));
			break;
		default:
			throw new RuntimeException("Unsupported drive type: " + driveType.getSelectedItem());
		}
	}
	/**
	 * Sends an INIT command with the appropriate values.
	 */
	private void sendCmdInit() {
		String botClass = initClass.getEditor().getItem().toString(), etc = null;
		StartPose pose = getPlayerStart(); Vec3 rot, loc;
		if (botClass.endsWith("."))
			Utils.showWarning(mainUI, "Enter a valid class name for robot to spawn.");
		else if (pose == null || pose.isGeneric())
			try {
				// Read location and rotation from custom input
				rot = Utils.read3Vector(initRotation.getText());
				loc = Utils.read3Vector(initLocation.getEditor().getItem().toString());
				rot = rot.degToRad(isInDegrees());
				etc = "{Location " + loc.toPrecisionString() + "} {Rotation " +
					rot.toPrecisionString() + "}";
			} catch (RuntimeException e) {
				Utils.showWarning(mainUI, "Enter valid 3-vectors for rotation and location.");
			}
		else
			etc = "{Start " + pose.getTag() + "}";
		if (etc != null)
			sendMessage("INIT {ClassName " + botClass + "} " + etc);
	}
	/**
	 * Sends a MIS command with the appropriate values.
	 */
	private void sendCmdMis() {
		int link; float value;
		try {
			link = Integer.parseInt(misLink.getText());
			value = Float.parseFloat(misValue.getText());
			// Convert if needed
			if (isInDegrees())
				value = (float)Math.toRadians(value);
			sendMessage("MISPKG {Name " + misName.getEditor().getItem() + "} {Link " + link +
				String.format("} {Order 0} {Value %.4f}", value));
		} catch (NumberFormatException e) {
			Utils.showWarning(mainUI, "Enter valid link and target for mission package.");
		}
	}
	/**
	 * Sends a SET command with the appropriate values.
	 */
	private void sendCmdSet() {
		float params;
		try {
			params = Float.parseFloat(setParams.getText());
			// Convert if needed
			if (isInDegrees() && setOpcode.getSelectedIndex() == 0)
				params = (float)Math.toRadians(params);
			sendMessage("SET {Type " + setType.getSelectedItem() + "} {Name " +
				setName.getEditor().getItem() + "} {Opcode " + setOpcode.getSelectedItem() +
				String.format("} {Params %.4f}", params));
		} catch (NumberFormatException e) {
			Utils.showWarning(mainUI, "Enter a valid numeric value for parameters.");
		}
	}
	/**
	 * Sends a message to USAR. It will not appear on the screen or history.
	 *
	 * @param message the message text to send
	 * @return whether the operation succeeded
	 */
	private boolean sendInternalMessage(String message) {
		boolean done = false;
		if (state.isConnected())
			try {
				// Send to socket
				state.sendMessage(message);
				done = true;
			} catch (IOException e) {
				state.disconnect();
			}
		return done;
	}
	/**
	 * Sends a message to USAR.
	 *
	 * @param message the message text to send
	 */
	public void sendMessage(String message) {
		// Message has content?
		message = message.trim();
		if (message.length() > 0 && sendInternalMessage(message)) {
			// Add to the execute list in rawCommand
			addToHistory(message);
			// Add packet to the list
			state.addPacket(new USARPacket(message, false));
		}
	}
	/**
	 * Sends whatever message has been coded in the input fields.
	 */
	public void sendWSIWYG() {
		int type = commandType.getSelectedIndex();
		switch (type) {
		case 0:
			// INIT
			sendCmdInit();
			break;
		case 1:
			// DRIVE
			sendCmdDrive();
			break;
		case 2:
			// SET
			sendCmdSet();
			break;
		case 3:
			// MISPKG
			sendCmdMis();
			break;
		case 4:
			// GETGEO
			sendMessage("GETGEO " + getGeoconfParameters());
			break;
		case 5:
			// GETCONF
			sendMessage("GETCONF " + getGeoconfParameters());
			break;
		default:
			Utils.showWarning(mainUI, "Unimplemented command: " + commandType.getSelectedItem());
		}
	}
	/**
	 * Swaps the UI elements required when connection status changes.
	 *
	 * @param connected whether the program appears to be connected
	 */
	public void setConnected(boolean connected) {
		sendButton.setEnabled(connected);
		stopButton.setEnabled(connected);
		rotDegrees.setEnabled(!connected);
		if (connected) {
			connectButton.setIcon(goodIcon);
			connectButton.setText("Disconnect");
		} else {
			connectButton.setIcon(badIcon);
			connectButton.setText("Connect");
		}
	}
	/**
	 * Initializes the UI for the bottom panel (command buttons and entries)
	 */
	private void setupBottomUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Bottom
		final JComponent bottomPanel = new JPanel(new BorderLayout(0, 2));
		mainUI.add(bottomPanel, BorderLayout.SOUTH);
		final JComponent buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 15, 0));
		bottomPanel.add(buttonPanel, BorderLayout.SOUTH);
		// Button: Clear
		final JButton bClear = createButton("Clear", "Clears response text from the window",
			"clear");
		bClear.setMnemonic('l');
		buttonPanel.add(bClear);
		// Button: Freeze/Unfreeze
		freezeButton = createButton("Freeze", "Prevents new messages from appearing.",
			"freeze");
		freezeButton.setMnemonic('F');
		buttonPanel.add(freezeButton);
		// Button: Stop!
		stopButton = createButton("Stop!", "Stops robot motion!", "estop");
		stopButton.setIcon(badIcon);
		stopButton.setMnemonic('t');
		buttonPanel.add(stopButton);
		// Combo Box: Advanced Commands
		rawCommand = Utils.createEntryBox("Send a raw command to the server");
		addToComboBox(rawCommand, "RawCommand");
		rawCommand.setSelectedItem("");
		Utils.armActionListener(rawCommand, listener, "send");
		rawCommand.setVisible(false);
		bottomPanel.add(rawCommand, BorderLayout.NORTH);
		// Layout: Command Type Options
		typePanel = new JPanel(new CardLayout(0, 0));
		bottomPanel.add(typePanel, BorderLayout.CENTER);
		// Layout: Send Commands
		final JComponent sendPanel = new JPanel(new GridBagLayout());
		bottomPanel.add(sendPanel, BorderLayout.EAST);
		// Button: Send
		sendButton = createButton("Send", "Sends the command to USARSim", "send");
		sendButton.setEnabled(false);
		sendButton.setMnemonic('S');
		gbc.gridx = 0;
		gbc.gridy = 2;
		sendPanel.add(sendButton, gbc);
		// Button: ... (Swap)
		swapButton = createButton("Raw", "Shows or hides Advanced Input", "swap");
		swapButton.setMnemonic('w');
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		sendPanel.add(swapButton, gbc);
		// Spacer: 4px
		gbc.gridx = 0;
		gbc.gridy = 1;
		gbc.fill = GridBagConstraints.VERTICAL;
		sendPanel.add(Box.createVerticalStrut(4), gbc);
		// Layout: Command Panel
		final JComponent commandPanel = new JPanel(new BorderLayout());
		bottomPanel.add(commandPanel, BorderLayout.WEST);
		// Combo Box: Command Type
		commandType = Utils.createComboBox("Command type to send", "INIT", "DRIVE", "SET",
			"MISPKG", "GETGEO", "GETCONF");
		commandType.addActionListener(listener);
		commandType.setActionCommand("card");
		commandPanel.add(commandType, BorderLayout.NORTH);
	}
	/**
	 * Initializes the UI for the "DRIVE" Ackerman option.
	 */
	private void setupDriveAckermanUI() {
		// Layout: Drive Options Ackerman
		final JComponent driveAckerman = Utils.createSingleRow();
		driveView.add(driveAckerman, "ackerman");
		// Text Field: Wheel Speed
		driveSpeed = createFloatTextField("Wheel speed in rads/s");
		// Label: Speed
		driveAckerman.add(Utils.createFieldLabel("Speed", driveSpeed));
		driveAckerman.add(driveSpeed);
		// Spacer: 5px
		driveAckerman.add(Box.createHorizontalStrut(5));
		// Text Field: Front Angle
		driveFront = createFloatTextField("Front wheel steer angle in rads");
		// Label: FrontSteer
		driveAckerman.add(Utils.createFieldLabel("FrontSteer", driveFront));
		driveAckerman.add(driveFront);
		// Spacer: 5px
		driveAckerman.add(Box.createHorizontalStrut(5));
		// Text Field: Rear Angle
		driveRear = createFloatTextField("Rear wheel steer angle in rads");
		// Label: RearSteer
		driveAckerman.add(Utils.createFieldLabel("RearSteer", driveRear));
		driveAckerman.add(driveRear);
	}
	/**
	 * Initializes the UI for the "DRIVE" Aerial option.
	 */
	private void setupDriveAerialUI() {
		// Layout: Drive Options Aerial
		final JComponent driveAerial = Utils.createSingleRow();
		driveView.add(driveAerial, "aerial");
		// Text Field: Altitude Velocity
		driveAltitude = createFloatTextField("Altitude velocity in m/s");
		driveAltitude.setColumns(4);
		// Label: Altitude
		driveAerial.add(Utils.createFieldLabel("Altitude", driveAltitude));
		driveAerial.add(driveAltitude);
		// Spacer: 5px
		driveAerial.add(Box.createHorizontalStrut(5));
		// Text Field: Linear Velocity
		driveLinear = createFloatTextField("Linear velocity in m/s");
		driveLinear.setColumns(4);
		// Label: Linear
		driveAerial.add(Utils.createFieldLabel("Linear", driveLinear));
		driveAerial.add(driveLinear);
		// Spacer: 5px
		driveAerial.add(Box.createHorizontalStrut(5));
		driveLateral = createFloatTextField("Lateral velocity in m/s");
		driveLateral.setColumns(4);
		// Label: Lateral
		driveAerial.add(Utils.createFieldLabel("Lateral", driveLateral));
		driveAerial.add(driveLateral);
		// Spacer: 5px
		driveAerial.add(Box.createHorizontalStrut(5));
		driveRotational = createFloatTextField("Rotational velocity in rads/s");
		driveRotational.setColumns(4);
		// Label: Rotational
		driveAerial.add(Utils.createFieldLabel("Rotational", driveRotational));
		driveAerial.add(driveRotational);
	}
	/**
	 * Initializes the UI for the "DRIVE" Skid option.
	 */
	private void setupDriveSkidUI() {
		// Layout: Drive Options Skid
		final JComponent driveSkid = Utils.createSingleRow();
		driveView.add(driveSkid, "skid");
		// Text Box: Left Wheel Speed
		driveLeft = createFloatTextField("Left wheel speed in rads/s");
		// Label: Left
		driveSkid.add(Utils.createFieldLabel("Left", driveLeft));
		driveSkid.add(driveLeft);
		// Spacer: 5px
		driveSkid.add(Box.createHorizontalStrut(5));
		// Text Box: Right Wheel Speed
		driveRight = createFloatTextField("Right wheel speed in rads/s");
		// Label: Right
		driveSkid.add(Utils.createFieldLabel("Right", driveRight));
		driveSkid.add(driveRight);
	}
	/**
	 * Initializes the UI for "DRIVE" options.
	 */
	private void setupDriveUI() {
		// Layout: Drive Options
		final JComponent drivePanel = new JPanel(new BorderLayout(0, 2));
		typePanel.add(drivePanel, "drive");
		final JComponent driveMaster = new JPanel(new FlowLayout(FlowLayout.CENTER, 2, 2));
		drivePanel.add(driveMaster, BorderLayout.NORTH);
		// Combo Box: Steering Type
		driveType = Utils.createComboBox("Steering type used by the robot", "Skid", "Ackerman",
			"Aerial");
		driveType.setActionCommand("drive");
		driveType.addActionListener(listener);
		// Label: DriveType
		driveMaster.add(Utils.createFieldLabel("DriveType", driveType));
		driveMaster.add(driveType);
		// Spacer: 5px
		driveMaster.add(Box.createHorizontalStrut(5));
		// Check Box: Normalized
		driveNormalized = Utils.createCheckBox("Normalized",
			"Allow values to be input from -100 to 100 and scaled");
		driveMaster.add(driveNormalized);
		// Spacer: 5px
		driveMaster.add(Box.createHorizontalStrut(5));
		// Check Box: Headlights
		driveHeadlights = Utils.createCheckBox("Headlights",
			"Turns the robot headlight on or off");
		driveMaster.add(driveHeadlights);
		// Layout: Drive Views
		driveView = new JPanel(new CardLayout(0, 0));
		drivePanel.add(driveView, BorderLayout.CENTER);
		setupDriveSkidUI();
		setupDriveAckermanUI();
		setupDriveAerialUI();
	}
	/**
	 * Initializes the UI for "GETGEO"/"GETCONF" options.
	 */
	private void setupGeoUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Geo/Conf Options
		final JPanel geoOptions = new JPanel(new GridBagLayout());
		typePanel.add(geoOptions, "geoconf");
		// Combo Box: Configuration Type
		geoType = Utils.createEntryBox("Configuration type to request", "Robot", "MisPkg",
			"Gripper");
		Utils.armActionListener(geoType, listener, "send");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		geoOptions.add(geoType, gbc);
		// Text Field: Device Name
		geoName = createTextField("", 16, "(Optional) Name of device to request");
		gbc.gridx = 1;
		gbc.gridy = 1;
		geoOptions.add(geoName, gbc);
		// Label: Type
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		geoOptions.add(Utils.createFieldLabel("Type ", geoType), gbc);
		// Label: Name
		gbc.gridx = 0;
		gbc.gridy = 1;
		geoOptions.add(Utils.createFieldLabel("Name (optional) ", geoName), gbc);
	}
	/**
	 * Initializes the UI for "INIT" options.
	 */
	private void setupInitUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Init Options
		final JPanel initPanel = new JPanel(new GridBagLayout());
		typePanel.add(initPanel, "init");
		// Combo Box: Init Class
		initClass = Utils.createEntryBox("Class name of robot to spawn", "USARBot.");
		addToComboBox(initClass, "RobotType");
		initClass.setSelectedIndex(0);
		Utils.armActionListener(initClass, listener, "send");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		initPanel.add(initClass, gbc);
		// Combo Box: Location Select
		initLocation = Utils.createEntryBox("Coordinates or PlayerStart name to spawn robot",
			"0.00, 0.00, 0.00");
		Utils.armActionListener(initLocation, listener, "send");
		// Add a listener to selectively enable/disable the rotation field as appropriate
		final JTextField text = Utils.getEditorTextField(initLocation);
		text.getDocument().addDocumentListener(new DocumentListener() {
			public void insertUpdate(DocumentEvent e) {
				changedUpdate(e);
			}
			public void removeUpdate(DocumentEvent e) {
				changedUpdate(e);
			}
			public void changedUpdate(DocumentEvent e) {
				// If the document's new text matches a value in the list, disable rotation
				// otherwise, allow it for custom entry
				StartPose pose = getPlayerStart();
				if (pose == null)
					initRotation.setEnabled(true);
				else {
					Vec3 outRot = pose.getRotation().radToDeg(isInDegrees());
					initRotation.setText(outRot.toString());
					initRotation.setEnabled(false);
				}
			}
		});
		gbc.gridx = 1;
		gbc.gridy = 1;
		initPanel.add(initLocation, gbc);
		// Text Field: Rotation Select
		initRotation = createTextField(" ", 10, "Rotation in rads to spawn robot");
		initRotation.setDocument(new RestrictInputDocument("-0123456789.Ee, ",
			"0.00, 0.00, 0.00"));
		gbc.gridx = 1;
		gbc.gridy = 2;
		initPanel.add(initRotation, gbc);
		// Label: ClassName
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		initPanel.add(Utils.createFieldLabel("ClassName ", initClass), gbc);
		// Label: Location
		gbc.gridx = 0;
		gbc.gridy = 1;
		initPanel.add(Utils.createFieldLabel("Location ", initLocation), gbc);
		// Label: Rotation
		gbc.gridx = 0;
		gbc.gridy = 2;
		initPanel.add(Utils.createFieldLabel("Rotation ", initRotation), gbc);
	}
	/**
	 * Initializes the UI for "MISPKG" options.
	 */
	private void setupMisUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Mission Package Options
		final JComponent misOptions = new JPanel(new GridBagLayout());
		typePanel.add(misOptions, "mispkg");
		// Combo Box: Mission Package Name
		misName = Utils.createEntryBox("Mission package name to control", "");
		Utils.armActionListener(misName, listener, "send");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		misOptions.add(misName, gbc);
		// Text Field: Link to Move
		misLink = createTextField("1", 4, "Link index to move");
		misLink.setDocument(new RestrictInputDocument("0123456789", "1"));
		gbc.gridx = 1;
		gbc.gridy = 1;
		misOptions.add(misLink, gbc);
		// Text Field: Target Position
		misValue = createFloatTextField("Angle or position to move joint");
		gbc.gridx = 1;
		gbc.gridy = 2;
		misOptions.add(misValue, gbc);
		// Label: Name
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		misOptions.add(Utils.createFieldLabel("Name ", misName), gbc);
		// Label: Link
		gbc.gridx = 0;
		gbc.gridy = 1;
		misOptions.add(Utils.createFieldLabel("Link ", misLink), gbc);
		// Label: Value
		gbc.gridx = 0;
		gbc.gridy = 2;
		misOptions.add(Utils.createFieldLabel("Value ", misValue), gbc);
	}
	/**
	 * Initializes the ui for "SET" options.
	 */
	private void setupSetUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Set Options
		final JComponent setOptions = new JPanel(new GridBagLayout());
		typePanel.add(setOptions, "set");
		// Combo Box: Item Type
		setType = Utils.createComboBox("Type of item to control", "Joint", "Gripper", "Camera");
		setType.addItemListener(new ItemListener() {
			public void itemStateChanged(ItemEvent e) {
				// Update the opcode box if the type is changed
				if (e.getStateChange() == ItemEvent.SELECTED) {
					((OpcodeModel)setOpcode.getModel()).fireChange();
					setOpcode.setSelectedIndex(0);
				}
			}
		});
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.insets = FIELD_INSETS;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		setOptions.add(setType, gbc);
		// Combo Box: Package Name
		setName = Utils.createEntryBox("Joint or sensor to move");
		gbc.gridx = 1;
		gbc.gridy = 1;
		setOptions.add(setName, gbc);
		// Combo Box: Type
		setOpcode = Utils.createComboBox("Type of manipulation to apply");
		setOpcode.setModel(new OpcodeModel());
		setOpcode.setSelectedIndex(0);
		gbc.gridx = 4;
		gbc.gridy = 0;
		setOptions.add(setOpcode, gbc);
		// Text Field: Param Values
		setParams = createFloatTextField("Value(s) corresponding with opcode");
		gbc.gridx = 4;
		gbc.gridy = 1;
		setOptions.add(setParams, gbc);
		// Label: Type
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		setOptions.add(Utils.createFieldLabel("Type ", setType), gbc);
		// Label: Name
		gbc.gridx = 0;
		gbc.gridy = 1;
		setOptions.add(Utils.createFieldLabel("Name ", setName), gbc);
		// Label: Opcode
		gbc.gridx = 3;
		gbc.gridy = 0;
		setOptions.add(Utils.createFieldLabel("Opcode ", setOpcode), gbc);
		// Label: Params
		gbc.gridx = 3;
		gbc.gridy = 1;
		setOptions.add(Utils.createFieldLabel("Params ", setParams), gbc);
		// Spacer: 5px
		gbc.gridx = 2;
		gbc.gridy = 0;
		setOptions.add(Box.createHorizontalStrut(5), gbc);
	}
	/**
	 * Initializes the UI for the top panel (server connect and status)
	 */
	private void setupTopUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Top
		final JComponent topPanel = new JPanel(new GridBagLayout());
		mainUI.add(topPanel, BorderLayout.NORTH);
		// Text Field: Server Name
		serverName = createTextField("localhost", 16,
			"Server name (and optionally port) to connect");
		serverName.setActionCommand("connect");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.insets = FIELD_INSETS;
		topPanel.add(serverName, gbc);
		// Button: Connect/Disconnect
		connectButton = createButton("Connect", "Connects or disconnects from the server",
			"connect");
		connectButton.setMnemonic('n');
		gbc.gridx = 3;
		gbc.anchor = GridBagConstraints.CENTER;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = NO_INSETS;
		topPanel.add(connectButton, gbc);
		// Spacer: 10px
		gbc.gridx = 4;
		topPanel.add(Box.createHorizontalStrut(10), gbc);
		// Check Box: Degree mode
		rotDegrees = Utils.createCheckBox("Degree Mode", Utils.asHTML(
			"Enter angles in degree mode; does <b>not</b> apply to raw commands"));
		rotDegrees.setMnemonic('D');
		// Default value from config
		if (state.getConfig().getProperty("Degrees", "false").equalsIgnoreCase("true"))
			rotDegrees.setSelected(true);
		gbc.gridx = 5;
		topPanel.add(rotDegrees, gbc);
		// Label: Connect To
		final JLabel lConnect = Utils.createFieldLabel("Connect To: ", serverName);
		lConnect.setDisplayedMnemonic('C');
		gbc.gridx = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		topPanel.add(lConnect, gbc);
		// Label: Level Name
		levelName = Utils.createInfoLabel("Name of the currently loaded world");
		gbc.gridx = 1;
		gbc.gridy = 1;
		gbc.anchor = GridBagConstraints.CENTER;
		topPanel.add(levelName, gbc);
		// Label: Elapsed Time
		elapsedTime = Utils.createInfoLabel("Time in seconds since world creation");
		gbc.gridx = 3;
		topPanel.add(elapsedTime, gbc);
		// Label: Battery Life
		batteryLife = Utils.createInfoLabel("Estimated remaining robot battery life");
		gbc.gridx = 5;
		topPanel.add(batteryLife, gbc);
		// Layout: additional components
		topInfo = new Box(BoxLayout.PAGE_AXIS);
		gbc.gridwidth = GridBagConstraints.REMAINDER;
		gbc.gridx = 0;
		gbc.gridy = 2;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		topPanel.add(topInfo, gbc);
	}
	/**
	 * Initializes the user interface.
	 */
	private void setupUI() {
		// Layout: All
		mainUI = new JPanel(new BorderLayout(0, 2));
		mainUI.setBorder(BorderFactory.createEmptyBorder(2, 2, 2, 2));
		listener = new EventListener();
		// List: Responses
		responseList = new JList(new ListDataModel<USARPacket>(state.getMessages()));
		responseList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		responseList.setToolTipText("Response messages from the server");
		responseList.addMouseListener(new MouseAdapter() {
			public void mouseClicked(MouseEvent e) {
				if (e.getClickCount() == 2 && responseList.getSelectedIndices().length == 1) {
					USARPacket packet = (USARPacket)responseList.getSelectedValue();
					if (!packet.isResponse() && state.isConnected())
						sendMessage(packet.getMessage());
				}
			}
		});
		mainUI.add(new JScrollPane(responseList), BorderLayout.CENTER);
		// DO THIS!
		setupTopUI();
		setupBottomUI();
		setupInitUI();
		setupDriveUI();
		setupSetUI();
		setupMisUI();
		setupGeoUI();
	}
	/**
	 * Shows or hides the "Advanced command" box.
	 *
	 * @param show whether the box should be shown (and basic UI hidden)
	 */
	private void showRawCommand(boolean show) {
		rawCommand.setVisible(show);
		swapButton.setSelected(show);
		typePanel.setVisible(!show);
		commandType.setVisible(!show);
		if (show)
			rawCommand.requestFocusInWindow();
	}
	/**
	 * Updates the battery life indicator.
	 *
	 * @param battery the approximate life time remaining of battery (seconds)
	 */
	public void updateBattery(int battery) {
		if (battery >= 99999)
			batteryLife.setText(null);
		else if (battery <= 0)
			batteryLife.setText("Battery dead");
		else
			batteryLife.setText(String.format("Battery: %d:%02d", battery / 60, battery % 60));
	}
	/**
	 * Updates the names and values of joints on the specified (legged) robot.
	 *
	 * @param packet the packet containing joint information
	 */
	public void updateJoints(USARPacket packet) {
		String key;
		if (packet != null && setName.getItemCount() == 0) {
			// Go through the packet (keys that aren't "Battery" or "Type" are joints)
			for (Map.Entry<String, String> entry : packet.getParams().entrySet()) {
				key = entry.getKey();
				if (!key.equalsIgnoreCase("Battery") && !key.equalsIgnoreCase("Type"))
					setName.addItem(key);
			}
			if (setName.getItemCount() > 0)
				setName.setSelectedIndex(0);
		}
		// Manual clean
		if (packet == null) setName.removeAllItems();
	}
	/**
	 * Changes the displayed level.
	 *
	 * @param level the level to display
	 */
	public void updateLevel(String level) {
		if (level == null || level.length() < 1)
			levelName.setText(null);
		else
			levelName.setText("Level: " + level);
	}
	/**
	 * Updates the list of available mission packages.
	 *
	 * @param packet the packet containing mission package information
	 * @return whether mission package information was updated
	 */
	public boolean updateMisPkg(USARPacket packet) {
		String value; boolean updated = false;
		if (packet != null && misName.getItemCount() == 0) {
			// Go through the packet (all Name, Name_0, ... are packages)
			value = packet.getParam("Name");
			if (value != null) misName.addItem(value);
			for (int i = 0; (value = packet.getParam("Name_" + i)) != null; i++)
				misName.addItem(value);
			if (misName.getItemCount() > 0) {
				misName.setSelectedIndex(0);
				updated = true;
			}
		}
		// Manual clean
		if (packet == null) misName.removeAllItems();
		return updated;
	}
	/**
	 * Updates the list of available start poses.
	 *
	 * @param packet the packet containing start pose information
	 */
	public void updateStartPoses(USARPacket packet) {
		StringTokenizer str; String tag; Vec3 loc, rot;
		initLocation.removeAllItems();
		if (packet != null) {
			// Go through the packet (keys that aren't "StartPoses" are lists)
			for (Map.Entry<String, String> entry : packet.getParams().entrySet())
				if (!entry.getKey().equalsIgnoreCase("StartPoses"))
					try {
						str = new StringTokenizer(entry.getKey() + " " + entry.getValue());
						while (str.hasMoreTokens()) {
							// Split across " " into tag and parameters
							tag = str.nextToken();
							// Location X,Y,Z Rotation P,R,Y
							loc = Utils.read3Vector(str.nextToken());
							rot = Utils.read3Vector(str.nextToken());
							initLocation.addItem(new StartPose(loc, rot, tag));
						}
						// Ignore exceptions
					} catch (NumberFormatException ignore) {
					} catch (NoSuchElementException ignore) { }
		}
		// Select appropriate item
		if (initLocation.getItemCount() < 1) {
			initLocation.addItem("0.00, 0.00, 0.00");
			initLocation.setSelectedIndex(0);
		} else {
			initLocation.insertItemAt("0.00, 0.00, 0.00", 0);
			initLocation.setSelectedIndex(1);
		}
	}
	/**
	 * Updates the elapsed-time indicator.
	 *
	 * @param elapsed how much time has elapsed (since world creation)
	 */
	public void updateTime(float elapsed) {
		if (elapsed < 0.f)
			elapsedTime.setText(null);
		else
			elapsedTime.setText(String.format("Time: %.1f", elapsed));
	}

	/**
	 * Handles UI events by calling Iridium actions.
	 */
	private class EventListener implements ActionListener, JoystickListener {
		public void actionPerformed(ActionEvent e) {
			processEvent(e.getActionCommand());
		}
		public void joystickAxisChanged(Joystick joystick) {
			feedJoystickToRobot();
		}
		public void joystickButtonChanged(Joystick joystick) {
			feedJoystickToRobot();
		}
	}

	/**
	 * A class representing an information panel shown in the UI.
	 */
	public static class InfoPanel {
		private final Map<String, JLabel> entries;
		private final JComboBox names;
		private final JComponent panel;

		/**
		 * Creates a new information panel.
		 *
		 * @param label the label to show next to the text area
		 * @param initialName the initial name to show
		 */
		public InfoPanel(String label, String initialName) {
			entries = new LinkedHashMap<String, JLabel>(16);
			// Layout: Panel
			panel = new Box(BoxLayout.LINE_AXIS);
			panel.setBorder(INFO_BORDER);
			// Label: Group Name
			final JLabel lbl = new JLabel(label);
			lbl.setHorizontalAlignment(SwingConstants.RIGHT);
			lbl.setForeground(INFO_TITLE);
			lbl.setFont(lbl.getFont().deriveFont(Font.BOLD));
			panel.add(lbl);
			panel.add(Box.createHorizontalStrut(5));
			// Combo Box: Visible Item
			names = Utils.createComboBox("Item to show");
			names.addItemListener(new ItemListener() {
				public void itemStateChanged(ItemEvent e) {
					if (e.getStateChange() == ItemEvent.SELECTED && e.getItem() != null)
						switchTo(e.getItem().toString());
				}
			});
			names.setVisible(false);
			panel.add(names);
			panel.add(Box.createHorizontalStrut(10));
			panel.add(Box.createHorizontalGlue());
			setValue(initialName, " ");
			names.setSelectedIndex(0);
		}
		/**
		 * Gets the displayable panel.
		 *
		 * @return the displayable part of this panel
		 */
		public JComponent getPanel() {
			return panel;
		}
		/**
		 * Changes the value shown on the panel.
		 *
		 * @param name the name of the value to update
		 * @param text the value to display
		 */
		public void setValue(String name, String text) {
			synchronized (entries) {
				if (entries.containsKey(name))
					entries.get(name).setText(text);
				else {
					// Create new label
					final JLabel lbl = new JLabel(text);
					lbl.setVisible(false);
					lbl.setHorizontalAlignment(SwingConstants.LEFT);
					entries.put(name, lbl);
					panel.add(lbl, panel.getComponentCount() - 1);
					names.addItem(name);
					names.setMaximumSize(names.getPreferredSize());
					if (names.getItemCount() > 1)
						names.setVisible(true);
					panel.revalidate();
				}
			}
		}
		/**
		 * Switches the display to show this value.
		 *
		 * @param name the name of the value to show
		 */
		public void switchTo(String name) {
			synchronized (entries) {
				JLabel show = entries.get(name);
				for (JLabel label : entries.values())
					label.setVisible(label == show);
			}
		}
	}

	/**
	 * Change the available options in the joint "Opcode" dialog by
	 */
	private class OpcodeModel extends DefaultComboBoxModel {
		private static final long serialVersionUID = 0L;

		/**
		 * Notifies the list that this data has changed.
		 */
		public void fireChange() {
			fireContentsChanged(this, 0, getSize());
		}
		public Object getElementAt(int index) {
			String element = "";
			switch (setType.getSelectedIndex()) {
			case 0:
				element = OPT_JOINTS[index];
				break;
			case 1:
				element = OPT_GRIPPER[index];
				break;
			case 2:
				element = OPT_CAMERA[index];
				break;
			default:
			}
			return element;
		}
		public int getSize() {
			int len = 0;
			switch (setType.getSelectedIndex()) {
			case 0:
				// Angle, Velocity, Torque
				len = OPT_JOINTS.length;
				break;
			case 1:
				// Open, Close
				len = OPT_GRIPPER.length;
				break;
			case 2:
				// FOV
				len = OPT_CAMERA.length;
				break;
			default:
			}
			return len;
		}
	}
}