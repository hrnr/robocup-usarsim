/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui.ui;

import com.centralnexus.input.*;
import org.nist.usarui.*;
import org.nist.usarui.handlers.*;
import javax.swing.*;
import javax.swing.Timer;
import javax.swing.border.Border;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import java.awt.image.ImageObserver;
import java.io.*;
import java.net.MalformedURLException;
import java.util.*;
import java.util.List;

/**
 * Iridium graphical user interface (hand cleaned)
 *
 * @author Stephen Carlson (NIST)
 */
public class IridiumUI implements IridiumListener {
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
	 * Maximum number of messages to display in the window. Messages parsed by sensor or data
	 * handlers do not count towards this limit.
	 */
	public static final int MAX_SIZE = 100;
	/**
	 * Insets applied to field labels.
	 */
	public static final Insets NO_INSETS = new Insets(0, 0, 0, 0);
	/**
	 * The distance between the main window and auxiliary windows.
	 */
	public static final int PAD = 5;

	private JTextField actLink;
	private JComboBox actName;
	private JTextField actValue;
	private final float[] axes;
	private Icon badIcon;
	private JLabel batteryLife;
	private JComboBox commandType;
	private final Object commandTypeLock;
	private JButton connectButton;
	private JComboBox controlClass;
	private JTextField controlDims;
	private JComboBox controlFilter;
	private JComboBox controlLocation;
	private JTextField controlMat;
	private JTextField controlName;
	private JTextField controlNewLocation;
	private JTextField controlNewRotation;
	private JCheckBox controlPhys;
	private JTextField controlRotation;
	private JTextField controlSpeed;
	private JComboBox controlType;
	private JComponent controlView;
	private final Map<String, View> dialogs;
	private JTextField driveAltitude;
	private JTextField driveFront;
	private JCheckBox driveHeadlights;
	private JCheckBox driveInvert;
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
	private boolean frozen;
	private JTextField geoName;
	private JComboBox geoType;
	private Icon goodIcon;
	private final List<StatusHandler> handlers;
	private final Map<String, InfoPanel> infoPanels;
	private JComboBox initClass;
	private JComboBox initLocation;
	private JTextField initRotation;
	private JLabel levelName;
	private JLabel levelName2;
	private EventListener listener;
	private JComponent mainUI;
	private JComboBox rawCommand;
	private JList responseList;
	private JCheckBox rotDegrees;
	private JButton sendButton;
	private JTextField serverName;
	private JComboBox setName;
	private JComboBox setOpcode;
	private JTextField setParams;
	private JComboBox setType;
	private final IridiumConnector state;
	private Joystick stick;
	private JButton stopButton;
	private JButton swapButton;
	private JComponent topInfo;
	private JComponent typePanel;
	private JCheckBox keepSensors;
	private final List<USARPacket> usarData;
	
	//-- Variables associated to the MOVE command
	private JComponent moveView;
	private JComboBox actionType;
	private JComboBox walkType;
	private JComboBox waypointType;
	private JTextField coordX;
	private JTextField coordY;
	private JTextField pathnodeID;
	private static JLabel robotLabel;
	private String imageName;
	private String emptyString;

	/**
	 * Initializes the Iridium GUI.
	 *
	 * @param state the program to link
	 */
	public IridiumUI(IridiumConnector state) {
		axes = new float[4];
		commandTypeLock = new Object();
		dialogs = new HashMap<String, View>(8);
		frozen = false;
		handlers = new ArrayList<StatusHandler>(16);
		infoPanels = new HashMap<String, InfoPanel>(24);
		usarData = new LinkedList<USARPacket>();
		this.state = state;
		stick = null;
		loadHandlers();
		loadImages();
		setupUI();
		setConnected(false);
		state.addIridiumListener(this);
	}
	/**
	 * Iterate through the properties and add items to the combo box as required.
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
		if (rawCommand.getItemCount() > MAX_SIZE)
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
	 * Clears the log.
	 */
	public void clearLog() {
		synchronized (usarData) {
			usarData.clear();
		}
	}
	/**
	 * Closes all dialogs opened by sensor panels.
	 */
	private void closeAllDialogs() {
		synchronized (dialogs) {
			for (View view : dialogs.values())
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
		updateActuators(null);
		setConnected(true);
		commandType.removeAllItems();
		commandType.addItem("INIT");
		commandType.setSelectedIndex(0);
		// Startup info that would be nice to populate boxes
		sendInternalMessage("GETSTARTPOSES");
	}
	/**
	 * Creates a button.
	 *
	 * @param text the text label to display
	 * @param tooltip the tool tip text to show
	 * @param action the action event to fire when clicked
	 * @return the button with default options set
	 */
	private JButton createButton(String text, String tooltip, String action) {
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
	private JTextField createFloatTextField(String tooltip) {
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
	private JTextField createTextField(String text, int columns, String tooltip) {
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
		updateActuators(null);
		updateStartPoses(null);
		updateTime(-1.f);
		updateBattery(Integer.MAX_VALUE);
	}
	/**
	 * Exits the program cleanly.
	 */
	public void exit() {
		final Frame frame = Utils.findParent(mainUI);
		state.disconnect();
		state.removeIridiumListener(this);
		closeJoystick();
		if (frame != null)
			frame.dispose();
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
				// Disable r and y (skid only)
				x = stick.getX();
				z = stick.getY();
				y = r = 0.f;
			}
			if (driveInvert.isSelected()) {
				// Invert R and Y (vertical) axes
				y = -y; r = -r;
			}
			if (!Utils.isFloatEqual(x, axes[0]) || !Utils.isFloatEqual(y, axes[1]) ||
				!Utils.isFloatEqual(z, axes[2]) || !Utils.isFloatEqual(r, axes[3])) {
				// Send message; if error, treat like any other
				if (state.isConnected())
					sendJoystickValues(driveType.getSelectedIndex(), x, y, z, r);
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
	 * @param type the view class name to fetch
	 * @param title the view title
	 * @return the view, or null if the view cannot be created
	 */
	public View getView(final String type, final String title) {
		View ret = dialogs.get(title); final Rectangle ss, thisWin;
		if (ret == null) {
			// Instantiate specified type
			try {
				ret = (View)Utils.instantiate(type, mainUI, title);
			} catch (InstantiationException e) {
				ret = null;
			}
			if (ret != null) {
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
		}
		return ret;
	}
	/**
	 * Grabs the joystick input if possible. Warns the user if their joystick may not work.
	 */
	private void grabJoystick() {
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
	 * Gets whether the UI is in degree mode.
	 *
	 * @return whether UI values should be degrees, not radians
	 */
	public boolean isInDegrees() {
		return rotDegrees.isSelected();
	}
	/**
	 * Gets whether sensor output messages should be logged
	 *
	 * @return whether sensor output should be logged to the raw window
	 */
	public boolean keepSensors() {
		return keepSensors.isSelected();
	}
	/**
	 * Loads the data handlers from the ActiveStatusHandlers.properties file.
	 */
	@SuppressWarnings( "ConstantConditions" )
	private void loadHandlers() {
		Properties specs = new Properties(); String key, value;
		try {
			InputStream is = getClass().getResourceAsStream("ActiveStatusHandlers.properties");
			if (is != null) {
				specs.load(is);
				is.close();
			}
			// If not available, none will be loaded
		} catch (IOException ignore) { }
		for (Object oKey : specs.keySet()) {
			key = (String)oKey;
			value = specs.getProperty(key).trim();
			// Key name is only partially relevant
			if (key.startsWith("Activate") && value != null)
				try {
					handlers.add((StatusHandler)Utils.instantiate(value, this));
				} catch (InstantiationException ignore) { }
		}
	}
	/**
	 * Loads the images required to run.
	 */
	private void loadImages() {
		badIcon = Utils.loadImage("images/bad.png");
		goodIcon = Utils.loadImage("images/good.png");
	}
	public void processEvent(final String cmd) {
		if (EventQueue.isDispatchThread())
			uiEvent(cmd);
		else
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					uiEvent(cmd);
				}
			});
	}
	public void processPacket(final USARPacket packet) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				processPacketEvt(packet);
			}
		});
	}
	/**
	 * Adds a packet to the list. If a data handler can handle it instead, the packet is not
	 * added and the handler gets the message instead. This method should be called on the event
	 * thread since UI updating occurs.
	 *
	 * @param packet the packet to insert
	 */
	@SuppressWarnings("unchecked")
	private void processPacketEvt(USARPacket packet) {
		boolean cont = true;
		ListDataModel<USARPacket> model = ((ListDataModel<USARPacket>)responseList.getModel());
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
					// Fire message
					int len = usarData.size();
					model.fireIntervalRemoved(len - 1, len - 1);
				}
				usarData.add(0, packet);
				// Fire message
				model.fireIntervalAdded(0, 0);
			}
	}
	/**
	 * Sends an ACT command with the appropriate values.
	 */
	private void sendCmdAct() {
		int link; float value;
		try {
			link = Integer.parseInt(actLink.getText());
			value = Float.parseFloat(actValue.getText());
			// Convert if needed
			if (isInDegrees())
				value = (float)Math.toRadians(value);
			sendMessage("ACT {Name " + actName.getEditor().getItem() +
				String.format("} {Link %d} {Value %.4f}", link, value));
		} catch (NumberFormatException e) {
			Utils.showWarning(mainUI, "Enter valid link index and target value for actuator.");
		}
	}
	/**
	 * Sends a CONTROL command with the appropriate values.
	 */
	private void sendCmdControl() {
		String name = controlName.getText(), cmd = "", item; float speed;
		// Send appropriate command
		switch (controlType.getSelectedIndex()) {
		case 0:
			// Create
			sendCmdControlCreate(name);
			break;
		case 1:
			// GetSTA
			item = controlFilter.getEditor().getItem().toString();
			if (item.length() > 0)
				cmd = " {ClassName " + item + "}";
			if (name.length() > 0)
				cmd += " {Name " + name + "}";
			// Ask for status (handler will not clobber it now)
			sendMessage("CONTROL {Type GetSTA}" + cmd);
			break;
		case 2:
			// RelMove
			sendCmdControlMove("RelMove", name);
			break;
		case 3:
			// AbsMove
			sendCmdControlMove("AbsMove", name);
			break;
		case 4:
			// Conveyor
			if (name.length() > 0) {
				try {
					speed = Float.parseFloat(controlSpeed.getText());
				} catch (NumberFormatException e) {
					Utils.showWarning(mainUI, "Enter a valid speed for the conveyor.");
					break;
				}
				sendMessage("CONTROL {Type Conveyor} {Name " + name + "} {Speed " + speed + "}");
			} else
				Utils.showWarning(mainUI, "Enter a conveyor name to change.");
			break;
		case 5:
			// Kill
			if (name.length() > 0)
				sendMessage("CONTROL {Type Kill} {Name " + name + "}");
			else
				Utils.showWarning(mainUI, "Enter an object name to remove.");
			break;
		case 6:
			// KillAll
			sendMessage("CONTROL {Type KillAll}");
			break;
		default:
		}
	}
	/**
	 * Sends a CONTROL Create command with the appropriate values.
	 *
	 * @param name the name of the object to create
	 */
	private void sendCmdControlCreate(String name) {
		String item = controlClass.getEditor().getItem().toString(), cmd, scale;
		Vec3 loc, rot; float uSize; StartPose pose = Utils.getPlayerStart(controlLocation);
		if (name.length() < 1 || item.length() < 1)
			Utils.showWarning(mainUI, "Enter an object name and class.");
		else {
			cmd = item + "} {Name " + name + "} {Location ";
			try {
				// Find loc + rot from pose or user entry
				if (pose == null) {
					loc = Utils.read3Vector(controlLocation.getEditor().getItem().toString());
					rot = Utils.read3Vector(controlRotation.getText());
				} else {
					loc = pose.getLocation();
					rot = pose.getRotation();
				}
				scale = controlDims.getText();
				// Can be either uniform or 3D
				if (scale.indexOf(',') >= 0)
					scale = Utils.read3Vector(scale).toPrecisionString();
				else {
					uSize = Float.parseFloat(scale);
					scale = new Vec3(uSize, uSize, uSize).toPrecisionString();
				}
				// Convert if necessary
				rot = rot.degToRad(isInDegrees());
				cmd += loc.toPrecisionString() + "} {Rotation " + rot.toPrecisionString() +
					"} {Scale " + scale + "}";
				item = controlMat.getText();
				// Add material, physics and permanent status
				if (item.length() > 0)
					cmd += " {Material " + item + "}";
				if (controlPhys.isSelected())
					cmd += " {Physics RigidBody}";
				// Send command
				sendMessage("CONTROL {Type Create} {ClassName " + cmd);
			} catch (RuntimeException e) {
				Utils.showWarning(mainUI, "Enter a valid location, orientation, and size.");
			}
		}
	}
	/**
	 * Sends a RelMove or AbsMove CONTROL command with the appropriate values.
	 *
	 * @param type the command type - RelMove or AbsMove
	 * @param name the object name to move
	 */
	private void sendCmdControlMove(String type, String name) {
		Vec3 loc, rot;
		if (name.length() > 0) {
			try {
				// Get target pose
				loc = Utils.read3Vector(controlNewLocation.getText());
				rot = Utils.read3Vector(controlNewRotation.getText());
				// Convert if necessary and send
				rot = rot.degToRad(isInDegrees());
				sendMessage("CONTROL {Type " + type + "} {Name " + name + "} {Location " +
					loc.toPrecisionString() + "} {Rotation " + rot.toPrecisionString() + "}");
			} catch (RuntimeException e) {
				Utils.showWarning(mainUI, "Enter a valid delta location and orientation.");
			}
		} else
			Utils.showWarning(mainUI, "Enter an object name to move.");
	}
	
	/**
	 * Sends a MOVE command to control avatars with the appropriate values.
	 */
	private void sendCmdMove() {
		
		//-- If New or Append are selected, we need to retrieve information on waypoints
		if (actionType.getSelectedItem().equals("New")||actionType.getSelectedItem().equals("Append")) {

			//-- Type of action selected
			String selectedActionType=actionType.getSelectedItem().toString();
			
			//-- Type of Walk selected
			String selectedWalkType=walkType.getSelectedItem().toString();
			

			//-- Check if Location or Pathnode is selected
			//-- and retrieve the proper information
			switch (waypointType.getSelectedIndex()) {
			//-- Location
			case 0:
				float xLoc, yLoc;
				try {
					xLoc=Float.parseFloat(coordX.getText());
					yLoc=Float.parseFloat(coordY.getText());
				} catch (NumberFormatException e){
					Utils.showWarning(mainUI, "Enter valid X and Y coordinates.");
					break;
				}
				sendMessage(String.format("MOVE {Action %s} {Location %.2f, %.2f} {Type %s}", selectedActionType, xLoc, yLoc, selectedWalkType));
				break;
				
			case 1:
				String pathnID;
				pathnID=pathnodeID.getSelectedText().toString();
			
				sendMessage(String.format("MOVE {Action %s} {Pathnode %s} {Type %s}", selectedActionType, pathnID, selectedWalkType));
				break;
			}
		}
		else if (actionType.getSelectedItem().equals("Pause")||actionType.getSelectedItem().equals("Resume")){
			//-- Type of action selected
			String selectedActionType=actionType.getSelectedItem().toString();
			sendMessage(String.format("MOVE {Action %s}", selectedActionType));
		}
	}
	
	/**
	 * Sends a DRIVE command with the appropriate values.
	 */
	private void sendCmdDrive() {
		// Set up normalization and headlights
		String ex = "";
		if (driveHeadlights.isSelected())
			ex = " {Light true}";
		if (driveNormalized.isSelected())
			ex += " {Normalized true}";
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
			sendMessage(String.format("DRIVE {Left %.2f} {Right %.2f}%s", left, right, ex));
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
				speed, front, back, ex));
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
				"{LateralVelocity %.2f} {RotationalVelocity %.2f}%s", alt, lin, lat, rot, ex));
			break;
		default:
		}
	}
	/**
	 * Sends an INIT command with the appropriate values.
	 */
	private void sendCmdInit() {
		String botClass = initClass.getEditor().getItem().toString(), etc = null;
		StartPose pose = Utils.getPlayerStart(initLocation); Vec3 rot, loc;
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
		if (etc != null) {
			sendMessage("INIT {ClassName " + botClass + "} " + etc);
			updateActuators(null);
			updateJoints(null);
			if (!botClass.equalsIgnoreCase("USARBotAPI.WorldController")) {
				// Would have liked to use listener, but setActionCommand is @since 1.6...
				final Timer actConf = new Timer(200, new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						sendInternalMessage("GETCONF {Type Actuator}");
					}
				});
				actConf.setRepeats(false);
				actConf.start();
			}
		}
	}
	/**
	 * Sends a SET command with the appropriate values.
	 */
	private void sendCmdSet() {
		float params; final String name, extra;
		try {
			params = Float.parseFloat(setParams.getText());
			// Convert if needed
			if (isInDegrees() && setOpcode.getSelectedIndex() == 0)
				params = (float)Math.toRadians(params);
			name = (String)setName.getEditor().getItem();
			if (name == null || name.length() < 1)
				extra = "";
			else
				extra = " {Name " + name + "}";
			sendMessage("SET {Type " + setType.getEditor().getItem() + "}" + extra +
				" {Opcode " + setOpcode.getEditor().getItem() + String.format(
				"} {Params %.4f}", params));
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
	 * Sends joystick (or input field) commands to the robot drive. Expected range is from
	 * -1 to 1. X is left/right, Y is up/down.
	 *
	 * @param type the drive type (e.g. DRIVETYPE_SKID)
	 * @param lx left control stick, X axis
	 * @param ly left control stick, Y axis
	 * @param rx right control stick, X axis
	 * @param ry right control stick, Y axis
	 */
	private void sendJoystickValues(int type, double lx, double ly, double rx, double ry) {
		switch (type) {
		case DRIVETYPE_SKID:
			sendInternalMessage(String.format("DRIVE {Left %.2f} {Right %.2f}", ly, ry));
			break;
		case DRIVETYPE_ACKERMAN:
			sendInternalMessage(String.format("DRIVE {Speed %.2f} {FrontSteer %.2f} " +
				"{RearSteer %.2f}", ly, lx, ry));
			break;
		case DRIVETYPE_AIR:
			sendInternalMessage(String.format("DRIVE {AltitudeVelocity %.2f} {LinearVelocity " +
				"%.2f} {LateralVelocity %.2f} {RotationalVelocity %.2f}", ry, ly, lx, rx));
			break;
		default:
			throw new IllegalArgumentException("Invalid drive type: " + type);
		}
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
			processPacketEvt(new USARPacket(message, false));
		}
	}
	/**
	 * Sends whatever message has been coded in the input fields.
	 */
	public void sendWSIWYG() {
		synchronized (commandTypeLock) {
			String type = commandType.getSelectedItem().toString();
			if (state.isConnected()) {
				if (type.equals("INIT"))
					// INIT
					sendCmdInit();
				else if (type.equals("DRIVE"))
					// DRIVE
					sendCmdDrive();
				else if (type.equals("MOVE"))
					// DRIVE
					sendCmdMove();
				else if (type.equals("SET"))
					// SET
					sendCmdSet();
				else if (type.equals("ACT"))
					// ACT
					sendCmdAct();
				else if (type.equals("GETGEO"))
					// GETGEO
					sendMessage("GETGEO " + getGeoconfParameters());
				else if (type.equals("GETCONF"))
					// GETCONF
					sendMessage("GETCONF " + getGeoconfParameters());
				else if (type.equals("CONTROL"))
					// CONTROL
					sendCmdControl();
				else
					Utils.showWarning(mainUI, "Unimplemented command: " +
						commandType.getSelectedItem());
			}
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
	 * Initializes the UI for "ACT" options.
	 */
	private void setupActUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Actuator Options
		final JComponent act = new JPanel(new GridBagLayout());
		typePanel.add(act, "act");
		// Combo Box: Actuator Name
		actName = Utils.createEntryBox("Actuator name to control", "");
		Utils.armActionListener(actName, listener, "send");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		act.add(actName, gbc);
		// Text Field: Link to Move
		actLink = createTextField("0", 4, "Link index to move");
		actLink.setDocument(new RestrictInputDocument("0123456789", "0"));
		gbc.gridy = 1;
		act.add(actLink, gbc);
		// Text Field: Target Position
		actValue = createFloatTextField("Angle or position to move joint");
		gbc.gridy = 2;
		act.add(actValue, gbc);
		// Label: Name
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		act.add(Utils.createFieldLabel("Name ", actName), gbc);
		// Label: Link
		gbc.gridy = 1;
		act.add(Utils.createFieldLabel("Link ", actLink), gbc);
		// Label: Value
		gbc.gridy = 2;
		act.add(Utils.createFieldLabel("Value ", actValue), gbc);
	}
	/**
	 * Initializes the UI for the bottom panel (command buttons and entries)
	 * @throws Throwable 
	 * @throws MalformedURLException 
	 */
	private void setupBottomUI()  {
		robotLabel = new JLabel();
		emptyString=".";
		try {
			updateRobotImage("");
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		robotLabel.setBorder(BorderFactory.createLineBorder(Color.black));
		
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
		gbc.gridy = 0;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		sendPanel.add(swapButton, gbc);
		// Spacer: 4px
		gbc.gridy = 1;
		gbc.fill = GridBagConstraints.VERTICAL;
		sendPanel.add(Box.createVerticalStrut(4), gbc);
		// Layout: Command Panel
		final JComponent commandPanel = new JPanel(new BorderLayout());
		bottomPanel.add(commandPanel, BorderLayout.WEST);
		// Combo Box: Command Type
		commandType = Utils.createComboBox("Command type to send", "INIT");
		commandType.addActionListener(listener);
		commandType.setActionCommand("card");
		commandPanel.add(commandType, BorderLayout.NORTH);
		commandPanel.add(robotLabel, BorderLayout.SOUTH);
	}
	
	/**
	 * This action listener changes the picture of the robot
	 */
	 ActionListener actionListener = new ActionListener() {
	      public void actionPerformed(ActionEvent actionEvent) {
	        ItemSelectable is = (ItemSelectable)actionEvent.getSource();
	        imageName=Utils.extension(selectedString(is));
	        System.out.println("ImageName: "+imageName);
	        try {
				updateRobotImage(imageName);
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	      }
	    };
	    
	    static private String selectedString(ItemSelectable is) {
	        Object selected[] = is.getSelectedObjects();
	        return ((selected.length == 0) ? "null" : (String)selected[0]);
	      }  
	    
	    static void updateRobotImage(String robotName) throws MalformedURLException, IOException{
	    	ImageIcon robotIcon1 ;
			ImageIcon robotIcon2 ;
			Image avatarImage;
			robotIcon1 = Utils.loadRobotImage("images/"+robotName+".jpg");
			avatarImage=robotIcon1.getImage();
			Image robotScaledImage=avatarImage.getScaledInstance(133, 132,  java.awt.Image.SCALE_SMOOTH);  
			robotIcon2=new ImageIcon(robotScaledImage);
			robotLabel.setIcon(robotIcon2);
	    }
	
	/**
	 * Initializes the UI for the "CONTROL" Create option.
	 */
	private void setupControlCreateUI() {
		GridBagConstraints gbc = new GridBagConstraints();
		// Layout: Create Item
		final JComponent ctrlCreate = new JPanel(new GridBagLayout());
		controlView.add(ctrlCreate, "create");
		// Combo Box: Item Type
		controlClass = Utils.createEntryBox("Item class to spawn", "WCCrate", "WCPallet");
		Utils.armActionListener(controlClass, listener, "send");
		addToComboBox(controlClass, "ControlClass");
		gbc.gridx = 1;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		ctrlCreate.add(controlClass, gbc);
		// Text Field: Item Location
		controlLocation = Utils.createEntryBox("Location of object", "0.00, 0.00, 0.00");
		Utils.armActionListener(controlLocation, listener, "send");
		gbc.gridx = 4;
		ctrlCreate.add(controlLocation, gbc);
		// Add a listener to selectively enable/disable the rotation field as appropriate
		final JTextField text = Utils.getEditorTextField(controlLocation);
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
				StartPose pose = Utils.getPlayerStart(controlLocation);
				if (pose == null)
					controlRotation.setEnabled(true);
				else {
					Vec3 outRot = pose.getRotation().radToDeg(isInDegrees());
					controlRotation.setText(outRot.toString());
					controlRotation.setEnabled(false);
				}
			}
		});
		// Text Field: Item Rotation
		controlRotation = createTextField("0.00, 0.00, 0.00", 10, "Orientation of object");
		gbc.gridx = 1;
		gbc.gridy = 1;
		ctrlCreate.add(controlRotation, gbc);
		// Text Field: Item Size
		controlDims = createTextField("1.0, 1.0, 1.0", 8, "Dimensions of object");
		gbc.gridx = 4;
		ctrlCreate.add(controlDims, gbc);
		// Text Field: Item Material
		controlMat = createTextField("", 10, "Material to apply to object");
		gbc.gridx = 1;
		gbc.gridy = 2;
		ctrlCreate.add(controlMat, gbc);
		// Check Box: Physics
		controlPhys = Utils.createCheckBox("Physics", "Should physics be enabled?");
		controlPhys.setSelected(true);
		gbc.fill = GridBagConstraints.NONE;
		gbc.insets = NO_INSETS;
		gbc.gridx = 4;
		ctrlCreate.add(controlPhys, gbc);
		// Label: ClassName
		gbc.gridx = 0;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.EAST;
		ctrlCreate.add(Utils.createFieldLabel("ClassName ", controlClass), gbc);
		// Spacer: 10px
		gbc.gridx = 2;
		ctrlCreate.add(Box.createHorizontalStrut(10), gbc);
		// Label: Location
		gbc.gridx = 3;
		// Label: Rotation
		gbc.gridx = 0;
		gbc.gridy = 1;
		ctrlCreate.add(Utils.createFieldLabel("Rotation ", controlRotation), gbc);
		// Label: Scale
		gbc.gridx = 3;
		ctrlCreate.add(Utils.createFieldLabel("Scale ", controlDims), gbc);
		// Label: Material
		gbc.gridx = 0;
		gbc.gridy = 2;
		ctrlCreate.add(Utils.createFieldLabel("Material ", controlMat), gbc);
	}
	/**
	 * Initializes the UI for "CONTROL" options.
	 */
	private void setupControlUI() {
		// Layout: Control
		final JComponent ctrl = new JPanel(new BorderLayout(0, 0));
		typePanel.add(ctrl, "control");
		// Layout: General Options
		final JComponent ctrlTop = Utils.createSingleRow();
		// Combo Box: Control Command
		controlType = Utils.createComboBox("Command type to send", "Create", "GetSTA",
			"RelMove", "AbsMove", "Conveyor", "Kill", "KillAll");
		controlType.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				CardLayout flip = (CardLayout)controlView.getLayout();
				String item = ((String)controlType.getSelectedItem()).toLowerCase();
				switch (controlType.getSelectedIndex()) {
				case 2:
				case 3:
					// RelMove, AbsMove
					controlName.setEnabled(true);
					flip.show(controlView, "move");
					break;
				case 6:
					// KillAll
					controlName.setEnabled(false);
					flip.show(controlView, "kill");
					break;
				default:
					// Create, GetSTA, Conveyor, Kill
					controlName.setEnabled(true);
					flip.show(controlView, item);
				}
				Utils.focusFirstComponent(controlView);
			}
		});
		// Label: Type
		ctrlTop.add(Utils.createFieldLabel("Type", controlType));
		ctrlTop.add(controlType);
		// Spacer: 5px
		ctrlTop.add(Box.createHorizontalStrut(5));
		// Text Field: Item Name
		controlName = createTextField("", 10, "Name of item to reference");
		// Label: Name
		ctrlTop.add(Utils.createFieldLabel("Name", controlName));
		ctrlTop.add(controlName);
		ctrl.add(ctrlTop, BorderLayout.NORTH);
		// Layout: Control View
		controlView = new JPanel(new CardLayout());
		ctrl.add(controlView, BorderLayout.CENTER);
		setupControlCreateUI();
		// Layout: GetSTA
		final JComponent ctrlSta = Utils.createSingleRow();
		controlView.add(ctrlSta, "getsta");
		// Combo Box: Item Type Filter
		controlFilter = Utils.createEntryBox("Filter by item class", "", "WCCrate", "WCPallet");
		addToComboBox(controlFilter, "ControlClass");
		// Label: ClassName
		ctrlSta.add(Utils.createFieldLabel("ClassName", controlFilter));
		ctrlSta.add(controlFilter);
		// Layout: Move
		final JComponent ctrlMove = Utils.createSingleRow();
		controlView.add(ctrlMove, "move");
		// Text Field: New Location
		controlNewLocation = createTextField("0.00, 0.00, 0.00", 10, "Target location");
		// Label: Location
		ctrlMove.add(Utils.createFieldLabel("Location", controlNewLocation));
		ctrlMove.add(controlNewLocation);
		// Spacer: 5px
		ctrlMove.add(Box.createHorizontalStrut(5));
		// Text Field: New Rotation
		controlNewRotation = createTextField("0.00, 0.00, 0.00", 10, "Target orientation");
		// Label: Rotation
		ctrlMove.add(Utils.createFieldLabel("Rotation", controlNewRotation));
		ctrlMove.add(controlNewRotation);
		// Layout: Conveyor
		final JComponent ctrlZone = Utils.createSingleRow();
		controlView.add(ctrlZone, "conveyor");
		// Text Field: Conveyor Speed
		controlSpeed = createFloatTextField("Conveyor speed factor");
		// Label: Speed
		ctrlZone.add(Utils.createFieldLabel("Speed", controlSpeed));
		ctrlZone.add(controlSpeed);
		// Blank (Kill, KillAll)
		final JComponent ctrlBlank = new JPanel();
		controlView.add(ctrlBlank, "kill");
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
	 * Initializes the UI for the "MOVE" Location option.
	 */
	private void setupMoveLocationUI() {
		// Layout: Move Options Location
		final JComponent moveLocation = Utils.createSingleRow();
		moveView.add(moveLocation, "location");
		// Text Box: X coordinate
		coordX = createFloatTextField("X coordinate in m");
		// Label: X
		moveLocation.add(Utils.createFieldLabel("X", coordX));
		moveLocation.add(coordX);
		// Spacer: 5px
		moveLocation.add(Box.createHorizontalStrut(5));
		// Text Box: Y coordinate
		coordY = createFloatTextField("Y coordinate in m");
		// Label: Y
		moveLocation.add(Utils.createFieldLabel("Y", coordY));
		moveLocation.add(coordY);
		
	}
	
	/**
	 * Initializes the UI for the "MOVE" Pathnode option.
	 */
	private void setupMovePathnodeUI() {
		// Layout: Move Options Pathnode
		final JComponent movePathnode = Utils.createSingleRow();
		moveView.add(movePathnode, "pathnode");
		// Text Box: Pathnode ID
		pathnodeID = createFloatTextField("ID of the pathnode");
		// Label: ID
		movePathnode.add(Utils.createFieldLabel("ID", pathnodeID));
		movePathnode.add(pathnodeID);	
	}
	
	/**
	 * Initializes the UI for "MOVE" options.
	 */
	private void setupMoveUI() {
		// Layout: Move Options
		final JComponent movePanel = new JPanel(new BorderLayout(0, 2));
		typePanel.add(movePanel, "move");
		final JComponent moveMaster = new JPanel(new FlowLayout(FlowLayout.CENTER, 2, 2));
		movePanel.add(moveMaster, BorderLayout.NORTH);
		// Combo Box: Action
		actionType = Utils.createComboBox("Type of MOVE command", "New", "Append",
					"Pause", "Resume");
		actionType.setActionCommand("move");
		actionType.addActionListener(listener);
		// Label: ActionType
		moveMaster.add(Utils.createFieldLabel("Action", actionType));
		moveMaster.add(actionType);
		// Spacer: 5px
		moveMaster.add(Box.createHorizontalStrut(5));
		// Combo Box: Waypoint
		waypointType = Utils.createComboBox("Waypoint using (x,y) coordinates or pathnodes", "Location", "Pathnode");
		waypointType.setActionCommand("move");
		waypointType.addActionListener(listener);
		// Label: WaypointType
		moveMaster.add(Utils.createFieldLabel("Waypoint", waypointType));
		moveMaster.add(waypointType);
		// Spacer: 5px
		moveMaster.add(Box.createHorizontalStrut(5));
		// Combo Box: Walk
		walkType = Utils.createComboBox("Type of walk", "Walk_Forward", "Walk_Backward", "Run");
		walkType.setActionCommand("move");
		walkType.addActionListener(listener);
		// Label: WalkType
		moveMaster.add(Utils.createFieldLabel("Movement", walkType));
		moveMaster.add(walkType);
				
		
		
		// Layout: Move Views
		moveView = new JPanel(new CardLayout(0, 0));
		movePanel.add(moveView, BorderLayout.CENTER);
		setupMoveLocationUI();
		setupMovePathnodeUI();
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
		// Spacer: 5px
		driveMaster.add(Box.createHorizontalStrut(5));
		// Check Box: Invert Joystick
		driveInvert = Utils.createCheckBox("Invert Axes",
			"Inverts the vertical axes of the joystick");
		driveInvert.setSelected(true);
		// Default value from config
		if (state.getConfig().getProperty("NoInvert", "false").equalsIgnoreCase("true"))
			driveInvert.setSelected(false);
		driveMaster.add(driveInvert);
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
		geoType = Utils.createEntryBox("Configuration type to request", 
				"Accel", "AcceleroMeter", "Acoustic", "Actuator", "AltitudeSensor", 
				"Camera", "Effector", "Encoder", "GPS", "Gripper", "GroundTruth", "IMU", 
				"INS", "IR", "IRScanner", "LineLaser", "MageticCompas", "MissionTime", 
				"Odometry", "PCL", "RangeImager", "RangeScanner", "Range", "Robot", 
				"Sonar", "TouchArray", "WheelSensor");
		Utils.armActionListener(geoType, listener, "send");
		gbc.gridx = 1;
		gbc.gridy = 0;
		gbc.anchor = GridBagConstraints.WEST;
		gbc.fill = GridBagConstraints.HORIZONTAL;
		gbc.insets = FIELD_INSETS;
		geoOptions.add(geoType, gbc);
		// Text Field: Device Name
		geoName = createTextField("", 16, "(Optional) Name of device to request");
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
		// TODO
		initClass.addActionListener(actionListener);
		
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
				StartPose pose = Utils.getPlayerStart(initLocation);
				if (pose == null)
					initRotation.setEnabled(true);
				else {
					Vec3 outRot = pose.getRotation().radToDeg(isInDegrees());
					initRotation.setText(outRot.toString());
					initRotation.setEnabled(false);
				}
			}
		});
		gbc.gridy = 1;
		initPanel.add(initLocation, gbc);
		// Text Field: Rotation Select
		initRotation = createTextField(" ", 10, "Rotation in rads to spawn robot");
		initRotation.setDocument(new RestrictInputDocument("-0123456789.Ee, ",
			"0.00, 0.00, 0.00"));
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
		gbc.gridy = 1;
		initPanel.add(Utils.createFieldLabel("Location ", initLocation), gbc);
		// Label: Rotation
		gbc.gridy = 2;
		initPanel.add(Utils.createFieldLabel("Rotation ", initRotation), gbc);
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
		setType = Utils.createEntryBox("Type of item to control", "Joint", "Camera",
			"Gripper");
		setType.addItemListener(new ItemListener() {
			public void itemStateChanged(ItemEvent e) {
				// Update the opcode box if the type is changed
				if (e.getStateChange() == ItemEvent.SELECTED) {
					final String item = (String)setType.getSelectedItem();
					boolean update = true;
					if (item.equals("Joint")) {
						setOpcode.removeAllItems();
						setOpcode.addItem("Value");
						setOpcode.addItem("Angle");
						setOpcode.addItem("Velocity");
						setOpcode.addItem("Torque");
					} else if (item.equals("Camera")) {
						setOpcode.removeAllItems();
						setOpcode.addItem("FOV");
					} else if (item.equals("Gripper")) {
						setOpcode.removeAllItems();
						setOpcode.addItem("Open");
						setOpcode.addItem("Close");
					} else
						update = false;
					if (update)
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
		gbc.gridy = 1;
		setOptions.add(setName, gbc);
		// Combo Box: Opcode
		setOpcode = Utils.createEntryBox("Type of manipulation to apply");
		gbc.gridx = 4;
		gbc.gridy = 0;
		setOptions.add(setOpcode, gbc);
		// Text Field: Param Values
		setParams = createFloatTextField("Value(s) corresponding with opcode");
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
		gbc.gridy = 1;
		setOptions.add(Utils.createFieldLabel("Name ", setName), gbc);
		// Label: Opcode
		gbc.gridx = 3;
		gbc.gridy = 0;
		setOptions.add(Utils.createFieldLabel("Opcode ", setOpcode), gbc);
		// Label: Params
		gbc.gridy = 1;
		setOptions.add(Utils.createFieldLabel("Params ", setParams), gbc);
		// Spacer: 10px
		gbc.gridx = 2;
		gbc.gridy = 0;
		setOptions.add(Box.createHorizontalStrut(10), gbc);
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
		// Check box: keep sensors
		keepSensors = Utils.createCheckBox("Log sensors", Utils.asHTML(
				"Log all sensor messages to raw window"));
		rotDegrees.setMnemonic('D');
		// Default value from config
		if (state.getConfig().getProperty("Degrees", "false").equalsIgnoreCase("true"))
			rotDegrees.setSelected(true);
		gbc.gridx = 5;
		topPanel.add(rotDegrees, gbc);
		gbc.gridx = 6;
		topPanel.add(Box.createHorizontalStrut(10), gbc);
		gbc.gridx = 7;
		topPanel.add(keepSensors, gbc);
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
		gbc.anchor = GridBagConstraints.NORTH;
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
		responseList = new JList(new ListDataModel<USARPacket>(usarData));
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
		// Repair slow-scrolling bug
		final JScrollPane sp = new JScrollPane(responseList);
		sp.setSize(500, 200);
		sp.getVerticalScrollBar().setUnitIncrement(16);
		sp.getHorizontalScrollBar().setUnitIncrement(16);
		mainUI.add(sp, BorderLayout.CENTER);
		// DO THIS!
		setupTopUI();
		setupBottomUI();
		setupInitUI();
		setupDriveUI();
		setupMoveUI();
		setupSetUI();
		setupActUI();
		setupGeoUI();
		setupControlUI();
		grabJoystick();
	}
	/**
	 * Shows or hides the "Advanced command" box.
	 *
	 * @param show whether the box should be shown (and basic UI hidden)
	 */
	public void showRawCommand(boolean show) {
		rawCommand.setVisible(show);
		swapButton.setSelected(show);
		typePanel.setVisible(!show);
		commandType.setVisible(!show);
		if (show)
			rawCommand.requestFocusInWindow();
	}
	/**
	 * Processes the specified UI event or Iridium system event.
	 *
	 * @param eventName the UI event that was triggered
	 */
	private void uiEvent(String eventName) {
		if (eventName.equals("swap"))
			// Show/hide Advanced Input
			showRawCommand(!rawCommand.isVisible());
		else if (eventName.equals("send") && state.isConnected()) {
			// Send message
			if (swapButton.isSelected())
				sendMessage((String)rawCommand.getEditor().getItem());
			else
				sendWSIWYG();
		} else if (eventName.equals("freeze")) {
			// Freeze/Unfreeze
			frozen = !frozen;
			if (frozen)
				freezeButton.setText("Unfreeze");
			else
				freezeButton.setText("Freeze");
		} else if (eventName.equals("card")) {
			// Change available type
			Object item = commandType.getSelectedItem();
			if (item != null) {
				eventName = item.toString().toLowerCase();
				if (eventName.equals("getgeo") || eventName.equals("getconf"))
					eventName = "geoconf";
				((CardLayout)typePanel.getLayout()).show(typePanel, eventName);
				Utils.focusFirstComponent(typePanel);
			}
		} else if (eventName.equals("drive")) {
			// Change drive type
			eventName = driveType.getSelectedItem().toString();
			((CardLayout)driveView.getLayout()).show(driveView, eventName.toLowerCase());
			Utils.focusFirstComponent(driveView);
		} else if (eventName.equals("move")) {
			// Change waypoint type
			eventName = waypointType.getSelectedItem().toString();
			((CardLayout)moveView.getLayout()).show(moveView, eventName.toLowerCase());
			Utils.focusFirstComponent(moveView);
			
			if (actionType.getSelectedItem().toString().equals("Pause") || actionType.getSelectedItem().toString().equals("Resume"))
			{
				
				walkType.setEnabled(false);
				waypointType.setEnabled(false);
				coordX.setEnabled(false);
				coordY.setEnabled(false);
				pathnodeID.setEnabled(false);
				moveView.repaint();
				//Utils.showWarning(mainUI, "<b>Pause</b>");
			}
			else
			{
				walkType.setEnabled(true);
				waypointType.setEnabled(true);
				coordX.setEnabled(true);
				coordY.setEnabled(true);
				pathnodeID.setEnabled(true);
				moveView.repaint();
			}
			
				
		} 
		
		
		else if (eventName.equals("connect")) {
			// Connect/disconnect
			if (state.isConnected())
				state.disconnect();
			else {
				String host = serverName.getText();
				try {
					state.connect(host);
				} catch (IOException e) {
					// Error when connecting
					Utils.showWarning(mainUI, "<b>Cannot connect to \"" + host +
						"\".</b><br><br>1-Make sure Windows Firewall is not blocking UDK<br><br>2-Make sure a Map is already running");
				}
			}
		} else if (eventName.equals("connected"))
			// Connect explicitly
			connected();
		else if (eventName.equals("disconnect"))
			// Disconnect explicitly
			disconnected();
		else if (eventName.equals("clear")) {
			// Clear log
			clearLog();
			((ListDataModel)responseList.getModel()).fireCleared();
		} else if (eventName.equals("estop"))
			// Stop robot!
			sendInternalMessage("DRIVE {Left 0} {Right 0} {Speed 0} {AltitudeVelocity 0} " +
				"{LinearVelocity 0} {LateralVelocity 0} {RotationalVelocity 0}");
		else if (eventName.equals("feed"))
			// Joystick
			feedJoystickToRobot();
	}
	/**
	 * Enables the ACT item in the drop down menu if it is not already there.
	 */
	public void updateActuatorEnable() {
		boolean hasAct = false;
		synchronized (commandTypeLock) {
			for (int i = 0; i < commandType.getItemCount(); i++)
				if (commandType.getItemAt(i).toString().equals("ACT")) {
					hasAct = true;
					break;
				}
			if (!hasAct)
				commandType.addItem("ACT");
			commandType.removeItem("INIT");
		}
	}
	/**
	 * Updates the list of available actuators.
	 *
	 * @param packet the packet containing actuator information
	 * @return whether actuator information was updated
	 */
	public boolean updateActuators(USARPacket packet) {
		String value; boolean updated = false;
		if (packet != null && actName.getItemCount() == 0) {
			// Go through the packet (all Name, Name_0, ... are actuators)
			value = packet.getParam("Name");
			if (value != null) actName.addItem(value);
			for (int i = 0; (value = packet.getParam("Name_" + i)) != null; i++)
				actName.addItem(value);
			if (actName.getItemCount() > 0) {
				actName.setSelectedIndex(0);
				updated = true;
			}
		}
		// Manual clean
		if (packet == null) actName.removeAllItems();
		if (updated && actName.getItemCount() > 0)
			// Add ACT to the menu (and remove INIT if still hanging around)
			updateActuatorEnable();
		return updated;
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
		else {
			batteryLife.setText(String.format("Battery: %d:%02d", battery / 60, battery % 60));
			// Got a status, remove the INIT item if necessary
			synchronized (commandTypeLock) {
				if (commandType.getItemCount() > 1)
					commandType.removeItem("INIT");
			}
		}
	}
	/**
	 * Fired whenever an INIT command is sent through any channel by AdaptiveInputHandler to
	 * adjust the GUI inputs accordingly.
	 *
	 * @param isWC whether the fields should be set up for world control
	 */
	public void updateInitComplete(boolean isWC) {
		// Populate with useful items
		synchronized (commandTypeLock) {
			if (isWC) {
				commandType.removeItem("INIT");
				commandType.addItem("CONTROL");
				commandType.setSelectedIndex(0);
			} else {
				commandType.addItem("DRIVE");
				commandType.addItem("SET");
				commandType.addItem("GETGEO");
				commandType.addItem("GETCONF");
				commandType.addItem("MOVE");
				// Might not be the first command since INIT might still be hanging around
				commandType.setSelectedItem("DRIVE");
			}
		}
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
	 * Updates the list of available start poses.
	 *
	 * @param packet the packet containing start pose information
	 */
	public void updateStartPoses(USARPacket packet) {
		StringTokenizer str; String tag; Vec3 loc, rot;
		initLocation.removeAllItems();
		initLocation.addItem("0.00, 0.00, 0.00");
		controlLocation.removeAllItems();
		controlLocation.addItem("0.00, 0.00, 0.00");
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
							controlLocation.addItem(new StartPose(loc, rot, tag));
						}
						// Ignore exceptions
					} catch (NumberFormatException ignore) {
					} catch (NoSuchElementException ignore) { }
		}
		// Select appropriate item
		if (initLocation.getItemCount() < 2)
			initLocation.setSelectedIndex(0);
		else
			initLocation.setSelectedIndex(1);
		controlLocation.setSelectedIndex(0);
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
			uiEvent(e.getActionCommand());
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
		
		private void updateRobotImage(){
			
		}
	}
}