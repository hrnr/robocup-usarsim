package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.addons.*;
import org.nist.worldgen.mif.*;
import org.nist.worldgen.t3d.*;
import org.nist.worldgen.xml.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.tree.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.List;

/**
 * USARSim World Generator
 *
 * User interface (generally independent of logic) for the World Generator.
 *
 * @author Stephen Carlson
 * @version 4.0
 */
public class WorldGeneratorUI implements ActionListener, Constants, ProgressListener {
	private JProgressBar bgProgress;
	private Action delRoomAction;
	private JFileChooser exportDialog;
	private JFileChooser fileDialog;
	private final JFrame frame;
	private JPanel mainPanel;
	private RoomTreeModel model;
	private JTree objectTree;
	private final WorldPainter painter;
	private transient final Collection<WGRoomInstance> singleRoom;
	private JPopupMenu roomPopup;
	private final WGRoomDB rooms;
	private Action selectionAddDoors;
	private Action selectionDelDoors;
	private World world;

	/**
	 * Creates and initializes the UI.
	 */
	public WorldGeneratorUI() {
		final File toRoot = new File(O_ROOT_PATH);
		painter = new WorldPainter();
		bindKeys();
		rooms = new WGRoomDB(new File(toRoot, "rooms.xml"));
		singleRoom = new ArrayList<WGRoomInstance>(1);
		world = null;
		loadRooms();
		frame = new JFrame(O_TITLE);
		frame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				exit();
			}
		});
		frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
		frame.setResizable(true);
		setupUI();
		frame.getContentPane().add(mainPanel, BorderLayout.CENTER);
		frame.setSize(800, 600);
		postEvent("index");
	}
	public void actionPerformed(ActionEvent e) {
		final String cmd = e.getActionCommand();
		if (cmd == null)
			throw new IllegalArgumentException("Invalid command");
		else if (cmd.equals("place"))
			try {
				final WGRoomInstance room = painter.getPlacing();
				world.addRoom(room);
				rooms.computePreview(room.getRoom());
				singleRoom.clear();
				singleRoom.add(room);
				world.rebuildDoors(singleRoom);
				painter.repaint();
			} catch (IllegalArgumentException ex) {
				frame.getToolkit().beep();
			}
		else if (cmd.equals("rotate") && !painter.getPlacing().getRoom().isHallway()) {
			final int dir;
			// Determine direction
			if ((e.getModifiers() & KeyEvent.SHIFT_MASK) == 0)
				dir = 1;
			else
				dir = 3;
			final WGRoomInstance room = painter.getPlacing();
			room.setRotation((room.getRotation() + dir) % 4);
			painter.repaint();
		} else if (cmd.equals("select") && world != null) {
			// Enable or disable options as needed
			final boolean enable = !painter.getSelectedRooms().isEmpty();
			selectionAddDoors.setEnabled(enable);
			selectionDelDoors.setEnabled(enable);
		}
		postEvent(cmd);
	}
	/**
	 * Adds a room to the database.
	 */
	public void addRoom() {
		exportDialog.setDialogTitle("Select Room to Add");
		if (exportDialog.showOpenDialog(mainPanel) == JFileChooser.APPROVE_OPTION) {
			final File in = exportDialog.getSelectedFile();
			final AddRoomDialog params = new AddRoomDialog(mainPanel, in.getName(), this);
			if (params.show("Import Parameters") == AbstractDialog.DIALOG_OK) {
				final WGRoom current = rooms.getRoom(params.getFileName());
				if (current == null || current.getSize().equals(params.getSize()))
					startDoing("Importing", new Runnable() {
						public void run() {
							final WGRoom room = params.getRoom();
							try {
								T3DIO.parse(in, room, rooms.getRoomFinder(), params);
								rooms.addRoom(room);
								saveRooms();
							} catch (IOException e) {
								Utils.showWarning(mainPanel, "Could not import world.");
							} catch (T3DException e) {
								Utils.showWarning(mainPanel, "Error while importing:<br>" +
									e.getMessage());
							} finally {
								progressComplete();
								postEvent("drop");
								model.rebuildList();
							}
							postEvent("parseComplete");
						}
					});
				else
					Utils.showWarning(mainPanel, "Room already exists with a different size.");
			}
		}
	}
	private void bindKeys() {
		painter.addActionListener(this);
		painter.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(
			KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0), "drop");
		painter.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(
			KeyStroke.getKeyStroke(KeyEvent.VK_DELETE, 0), "delsel");
		painter.getActionMap().put("drop", new GeneralAction("Drop Room", "drop", -1, " "));
		painter.getActionMap().put("delsel", new GeneralAction("Delete", "delsel", -1, " "));
	}
	// Returns true if the world can be closed, false if aborted
	private boolean confirmClose() {
		return !(world != null && world.isDirty() && Utils.showConfirm(mainPanel,
			"World has been changed. Save?")) || saveWorld();
	}
	/**
	 * Deletes the specified room.
	 */
	public void delRoom() {
		final TreePath sel = objectTree.getSelectionPath();
		if (sel != null) {
			final WGRoomContainer selected = (WGRoomContainer)sel.getLastPathComponent();
			if (selected != null && selected.canDelete()) {
				if (world != null && world.containsRoom(selected.getRoom()))
					Utils.showWarning(mainPanel, "Cannot delete room; room is in use.");
				else if (Utils.showConfirm(mainPanel, "Really delete \"" +
						selected.getName() + "\"?")) {
					final WGRoom room = selected.getRoom();
					final File file = rooms.lookup(room.getFileName());
					if (file.delete()) {
						rooms.removeRoom(room);
						saveRooms();
						postEvent("drop");
						model.rebuildList();
					} else
						Utils.showWarning(mainPanel, "Cannot delete room from file system.");
				}
			}
		}
	}
	/**
	 * Exits the application after prompting for save.
	 *
	 * @return whether the user cancelled the exit
	 */
	public boolean exit() {
		final boolean exit = confirmClose();
		if (exit) {
			painter.removeActionListener(this);
			frame.dispose();
		}
		return exit;
	}
	/**
	 * Exports the world to a T3D file.
	 */
	public void exportWorld() {
		if (world != null) {
			// Check for this condition before the user begins
			boolean hasHallway = false;
			for (WGRoomInstance room : world)
				if (room.getRoom().isHallway()) {
					hasHallway = true;
					break;
				}
			if (hasHallway) {
				exportDialog.setDialogTitle("Export World to UDK");
				if (exportDialog.showSaveDialog(mainPanel) == JFileChooser.APPROVE_OPTION) {
					final ExportWorldDialog exportParams = new ExportWorldDialog(mainPanel,
						this, rooms.getRoomFinder());
					if (exportParams.show("Export World") == AbstractDialog.DIALOG_OK)
						startDoing("Exporting", new Runnable() {
							public void run() {
								try {
									world.toT3D(exportDialog.getSelectedFile(), exportParams);
								} catch (IOException e) {
									Utils.showWarning(mainPanel, "Could not export world.");
								} catch (T3DException e) {
									Utils.showWarning(mainPanel, "Error while exporting:<br>" +
										e.getMessage());
								} finally {
									progressComplete();
								}
								postEvent("exportComplete");
							}
						});
				}
			} else
				Utils.showWarning(mainPanel, "The world needs at least one hallway to be " +
					"exported.");
		}
	}
	/**
	 * Prompts the user to generate a template world.
	 */
	public void generateTemplate() {
		final TemplateSizeDialog dialog = new TemplateSizeDialog(mainPanel);
		if (dialog.show("Export Template Room") == AbstractDialog.DIALOG_OK) {
			final IntDimension3D size = dialog.getSize();
			exportDialog.setDialogTitle("Template Room Location");
			exportDialog.setSelectedFile(new File(exportDialog.getCurrentDirectory(),
				String.format("Template%dx%dx%d.t3d", size.depth, size.width, size.height)));
			if (exportDialog.showSaveDialog(mainPanel) == JFileChooser.APPROVE_OPTION)
				try {
					T3DIO.createTemplate(size, exportDialog.getSelectedFile());
				} catch (IOException e) {
					Utils.showWarning(mainPanel, "Could not export template world.");
				}
		}
	}
	/**
	 * Generates a maze.
	 */
	public void generateMaze() {
		final CreateMazeDialog dialog = new CreateMazeDialog(mainPanel);
		if (dialog.show("Create Maze") == AbstractDialog.DIALOG_OK)
			startDoing("Generating Maze", new Runnable() {
				public void run() {
					bgProgress.setIndeterminate(false);
					final int per = WGConfig.getInteger("WorldGen.MazeCellsPerGrid");
					final String name = dialog.getName();
					final IntDimension3D size = dialog.getSize();
					final WGRoom newRoom = new WGRoom(name + ".t3d", size, name,
						"Maze");
					final File out = rooms.getRoomFinder().getOutputLocation(newRoom);
					try {
						final Maze maze = new Maze(size.depth * per, size.width * per,
							dialog.getDifficulty(), dialog.getIncline());
						maze.generate();
						rooms.getRoomFinder().writeOutputLocation(newRoom);
						T3DIO.writeWorld(out, maze.createMap(), UT_COMPAT_UDK);
						rooms.addRoom(newRoom);
						saveRooms();
					} catch (IOException e) {
						Utils.showWarning(mainPanel, "Could not export maze!");
					} finally {
						postEvent("drop");
						model.rebuildList();
						postEvent("complete");
					}
				}
			});
	}
	/**
	 * Generates a MIF file from an older T3D file.
	 */
	public void generateMIF() {
		exportDialog.setDialogTitle("Existing T3D Map");
		if (exportDialog.showOpenDialog(mainPanel) == JFileChooser.APPROVE_OPTION)
			startDoing("Generating MIF", new Runnable() {
				public void run() {
					bgProgress.setIndeterminate(true);
					try {
						final File file = exportDialog.getSelectedFile();
						final String baseName = Utils.baseName(file.getName());
						MifWriter.writeMIF(file.getParentFile(), baseName,
							MifWriter.mifFromMap(T3DIO.readMap(file)));
					} catch (IOException e) {
						Utils.showWarning(mainPanel, "Error while writing MIF file.");
					} catch (T3DException e) {
						Utils.showWarning(mainPanel, "Error while reading map:<br>" +
							e.getMessage());
					} finally {
						progressComplete();
					}
				}
			});
	}
	/**
	 * Retrieves the specified image from the icon file.
	 *
	 * @param path the path to the image without leading /
	 * @return the image
	 */
	private ImageIcon getImage(String path) {
		final URL url = getClass().getResource("/" + path); final ImageIcon icon;
		if (url != null)
			icon = new ImageIcon(url);
		else
			icon = null;
		return icon;
	}
	/**
	 * Indexes the room list.
	 */
	public void index() {
		loadRooms();
		bgProgress.setIndeterminate(true);
		startDoing("Indexing", new Runnable() {
			public void run() {
				WGRoom src;
				try {
					rooms.getRoomFinder().index();
					if (world != null)
						for (WGRoomInstance room : world) {
							src = room.getRoom();
							if (src.getPreviewImage() == null)
								rooms.computePreview(src);
						}
				} finally {
					postEvent("complete");
				}
			}
		});
	}
	/**
	 * Loads the room list from file.
	 */
	public void loadRooms() {
		try {
			rooms.read();
		} catch (IOException e) {
			Utils.showWarning(mainPanel, "Error when reading rooms.");
		}
	}
	/**
	 * Maximizes the window.
	 */
	public void maximize() {
		frame.setExtendedState(JFrame.MAXIMIZED_BOTH);
	}
	/**
	 * Creates a new world.
	 */
	public void newWorld() {
		final NewWorldDialog params = new NewWorldDialog(mainPanel);
		if (params.collect()) {
			world = new World(params, rooms);
			painter.clearSelection();
			painter.setWorld(world);
			rooms.clearPreviews();
			// This only runs for random maps
			for (WGRoomInstance room : world)
				rooms.computePreview(room.getRoom());
			model.updateTree();
			frame.setTitle(O_TITLE + " -- " + world.getName());
		}
		params.dispose();
	}
	/**
	 * Opens a user created world.
	 *
	 * @return whether the world was opened successfully
	 */
	public boolean openWorld() {
		boolean opened = false; World loaded;
		fileDialog.setDialogTitle("Open XML World");
		if (fileDialog.showOpenDialog(mainPanel) == JFileChooser.APPROVE_OPTION) {
			try {
				loaded = new World(fileDialog.getSelectedFile(), rooms);
				final String[] missing = loaded.findMissingRooms();
				if (missing.length > 0) {
					final StringBuilder message = new StringBuilder(512);
					message.append("The following rooms were not found when loading:<br>");
					for (String name : missing) {
						message.append("<code>");
						message.append(name);
						message.append("</code><br>");
					}
					message.append("<br>Continue loading world without them?");
					if (!Utils.showConfirm(mainPanel, message.toString()))
						loaded = null;
				}
				// Load complete, commit now
				if (loaded != null) {
					rooms.clearPreviews();
					world = loaded;
					for (WGRoomInstance room : world)
						rooms.computePreview(room.getRoom());
					opened = true;
				}
			} catch (IOException e) {
				Utils.showWarning(mainPanel, "Could not load world.");
			}
			model.updateTree();
			painter.clearSelection();
			painter.setWorld(world);
			if (world != null)
				frame.setTitle(O_TITLE + " -- " + world.getName());
		}
		return opened;
	}
	/**
	 * Posts the event to the world generator's event queue. Processing occurs on the event
	 * thread after all pending events have been dispatched.
	 *
	 * @param event the event to process
	 */
	public void postEvent(final String event) {
		if (EventQueue.isDispatchThread())
			uiEvent(event);
		else
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					uiEvent(event);
				}
			});
	}
	public void progressComplete() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				bgProgress.setIndeterminate(false);
				bgProgress.setString("Done");
				bgProgress.setValue(100);
				bgProgress.setVisible(false);
			}
		});
	}
	public void progressMade(final String name, final int progress) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				bgProgress.setString(name);
				bgProgress.setValue(progress);
			}
		});
	}
	/**
	 * Resizes the world to a user-specified size.
	 */
	public void resizeWorld() {
		if (world != null) {
			final ResizeWorldDialog newSize = new ResizeWorldDialog(mainPanel, world);
			if (newSize.show("Resize World") == AbstractDialog.DIALOG_OK) {
				final int width = newSize.getWidth(), depth = newSize.getDepth();
				if (width != world.getWidth() || depth != world.getDepth()) {
					final World newWorld = new World(width, depth, world.getName());
					boolean finished = true;
					// Encroach check
					for (WGRoomInstance room : world)
						if (room.getX() + room.getDepth() <= depth &&
								room.getY() + room.getHeight() <= width)
							newWorld.addRoom(room);
						else {
							Utils.showWarning(mainPanel, "Cannot resize world to that size.");
							finished = false;
							break;
						}
					if (finished) {
						for (WGItem item : world.getItems())
							newWorld.addItem(item);
						// Swap worlds
						world = newWorld;
						painter.setWorld(world);
						model.updateTree();
						painter.clearSelection();
					}
				}
			}
		}
	}
	/**
	 * Saves the room list.
	 */
	public void saveRooms() {
		try {
			rooms.write();
		} catch (IOException e) {
			Utils.showWarning(mainPanel, "Error when saving room database.");
		}
	}
	/**
	 * Saves the world (will always Save As... dialog if dirty, but not too bad)
	 *
	 * @return whether the user chose to save the world
	 */
	public boolean saveWorld() {
		boolean saved = false;
		if (world != null) {
			fileDialog.setDialogTitle("Save World as XML");
			if (fileDialog.showSaveDialog(mainPanel) == JFileChooser.APPROVE_OPTION)
				try {
					Utils.flatten(fileDialog.getSelectedFile(), world);
					world.setDirty(false);
					saved = true;
				} catch (IOException e) {
					Utils.showWarning(mainPanel, "Could not save world.");
				}
		}
		return saved;
	}
	/**
	 * Creates the buttons and menu items.
	 */
	private void setupMenuUI() {
		final JMenuBar menus = new JMenuBar();
		frame.setJMenuBar(menus);
		final JToolBar stdBar = new JToolBar("Standard Buttons");
		mainPanel.add(stdBar, BorderLayout.NORTH);
		setupMenuUIFile(menus, stdBar);
		setupMenuUIEdit(menus, stdBar);
		setupMenuUITools(menus, stdBar);
	}
	private void setupMenuUIEdit(final JMenuBar menus, final JToolBar stdBar) {
		final JMenu editMenu = new JMenu("Edit");
		editMenu.setMnemonic(KeyEvent.VK_E);
		menus.add(editMenu);
		roomPopup = new JPopupMenu();
		final Action addRoomAction = new GeneralAction("Add Room...", "addroom", KeyEvent.VK_R,
			"Import a new room into the list");
		roomPopup.add(new JMenuItem(addRoomAction));
		editMenu.add(new JMenuItem(addRoomAction));
		stdBar.add(Utils.createToolbarButton(addRoomAction));
		delRoomAction = new GeneralAction("Delete Room", "delroom", -1,
			"Delete the selected room from the list");
		delRoomAction.setEnabled(false);
		roomPopup.add(new JMenuItem(delRoomAction));
		editMenu.add(new JMenuItem(delRoomAction));
		editMenu.add(new JMenuItem(new GeneralAction("Select All", "selectall", KeyEvent.VK_A,
			"Selects all rooms in the world.")));
		editMenu.addSeparator();
		selectionDelDoors = new GeneralAction("Remove Doors from Selection", "deldoors", -1,
			"Removes all doors between the selected rooms");
		selectionDelDoors.setEnabled(false);
		editMenu.add(new JMenuItem(selectionDelDoors));
		selectionAddDoors = new GeneralAction("Restore Doors to Selection", "alldoors", -1,
			"Restores all doors between the selected rooms");
		selectionAddDoors.setEnabled(false);
		editMenu.add(new JMenuItem(selectionAddDoors));
		editMenu.add(new JMenuItem(new GeneralAction("Resize World", "resize", KeyEvent.VK_I,
			"Changes the size of the world")));
		stdBar.add(Utils.createToolbarButton(selectionAddDoors));
		stdBar.add(Utils.createToolbarButton(selectionDelDoors));
		stdBar.add(new JToolBar.Separator());
	}
	private void setupMenuUIFile(final JMenuBar menus, final JToolBar stdBar) {
		final JMenu fileMenu = new JMenu("File");
		fileMenu.setMnemonic(KeyEvent.VK_F);
		menus.add(fileMenu);
		final Action newAction = new GeneralAction("New...", "new", KeyEvent.VK_N,
			"Creates a new world of the specified size");
		stdBar.add(Utils.createToolbarButton(newAction));
		fileMenu.add(new JMenuItem(newAction));
		final Action openAction = new GeneralAction("Open", "open", KeyEvent.VK_O,
			"Opens a previously created world's XML file");
		stdBar.add(Utils.createToolbarButton(openAction));
		fileMenu.add(new JMenuItem(openAction));
		fileMenu.addSeparator();
		final Action saveAction = new GeneralAction("Save", "save", KeyEvent.VK_S,
			"Saves the world as an XML file");
		stdBar.add(Utils.createToolbarButton(saveAction));
		fileMenu.add(new JMenuItem(saveAction));
		final Action exportAction = new GeneralAction("Export...", "export", KeyEvent.VK_E,
			"Exports the world as a T3D file to import into UDK");
		stdBar.add(Utils.createToolbarButton(exportAction));
		stdBar.add(new JToolBar.Separator());
		fileMenu.add(new JMenuItem(exportAction));
		fileMenu.addSeparator();
		fileMenu.add(new JMenuItem(new GeneralAction("Exit", "exit", KeyEvent.VK_Q,
			"Closes the world generator")));
	}
	private void setupMenuUITools(final JMenuBar menus, final JToolBar stdBar) {
		final JMenu toolsMenu = new JMenu("Tools");
		toolsMenu.setMnemonic(KeyEvent.VK_T);
		menus.add(toolsMenu);
		final JMenu external = new JMenu("External");
		external.setMnemonic(KeyEvent.VK_E);
		external.setToolTipText(Utils.asHTML("Actions applicable to existing T3D files"));
		toolsMenu.add(external);
		final JMenu generate = new JMenu("Generate");
		generate.setMnemonic(KeyEvent.VK_G);
		generate.setToolTipText(Utils.asHTML("Generates a pre-made room"));
		toolsMenu.add(generate);
		toolsMenu.addSeparator();
		toolsMenu.add(new JMenuItem(new GeneralAction("Refresh Rooms", "index", -1,
			"Refresh all room data if interface becomes inconsistent or stale")));
		final Action mifAction = new GeneralAction("Generate MIF...", "mif", KeyEvent.VK_F,
			"Generates a MIF from a pre-existing T3D file");
		external.add(new JMenuItem(mifAction));
		stdBar.add(Utils.createToolbarButton(mifAction));
		external.add(new JMenuItem(new GeneralAction("Victimize Map...", "victims", -1,
			"Adds victims to a pre-existing T3D file<br>" +
			"To add victims to this world, export it and victimize the generated T3D")));
		final Action templateAction = new GeneralAction("Template Room...", "template", -1,
			"Generates a template room for use when designing rooms");
		generate.add(new JMenuItem(templateAction));
		stdBar.add(Utils.createToolbarButton(templateAction));
		final Action mazeAction = new GeneralAction("Maze...", "maze", KeyEvent.VK_M,
			"Generates a maze room");
		generate.add(new JMenuItem(mazeAction));
		stdBar.add(Utils.createToolbarButton(mazeAction));
	}
	/**
	 * Initializes the GUI.
	 */
	private void setupUI() {
		mainPanel = new JPanel(new BorderLayout(1, 1));
		bgProgress = new JProgressBar(JProgressBar.HORIZONTAL, 0, 100);
		bgProgress.setString("Ready");
		bgProgress.setStringPainted(true);
		bgProgress.setVisible(false);
		mainPanel.add(bgProgress, BorderLayout.SOUTH);
		objectTree = new JTree(model = new RoomTreeModel());
		final TreeEventListener treeEvents = new TreeEventListener();
		objectTree.addMouseListener(treeEvents);
		objectTree.addTreeSelectionListener(treeEvents);
		objectTree.setCellRenderer(model);
		objectTree.setEditable(false);
		objectTree.setRootVisible(false);
		objectTree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
		objectTree.setShowsRootHandles(true);
		objectTree.setToolTipText("Objects that can be placed in the world");
		final JScrollPane left = new JScrollPane(objectTree);
		left.getVerticalScrollBar().setUnitIncrement(16);
		// Arbitrary... but probably OK for 99.9% of uses
		left.setPreferredSize(new Dimension(200, 1));
		left.setMinimumSize(new Dimension(100, 1));
		final JScrollPane mid = new JScrollPane(painter);
		mid.getHorizontalScrollBar().setUnitIncrement(16);
		mid.getVerticalScrollBar().setUnitIncrement(16);
		mid.setColumnHeaderView(painter.getTopHeader());
		mid.setCorner(JScrollPane.UPPER_LEFT_CORNER, new CompassRosePainter());
		mid.setMinimumSize(new Dimension(100, 1));
		mid.setRowHeaderView(painter.getLeftHeader());
		final JSplitPane pane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, false, left, mid);
		pane.setBorder(BorderFactory.createEmptyBorder());
		mainPanel.add(pane);
		setupMenuUI();
		fileDialog = new JFileChooser();
		fileDialog.setFileFilter(new ExtensionFileFilter("xml", "XML files"));
		fileDialog.setFileHidingEnabled(true);
		fileDialog.setMultiSelectionEnabled(false);
		exportDialog = new JFileChooser();
		exportDialog.setFileFilter(new ExtensionFileFilter("t3d", "UDK Text files"));
		exportDialog.setFileHidingEnabled(true);
		exportDialog.setMultiSelectionEnabled(false);
		model.rebuildList();
	}
	/**
	 * Shows or hides the UI window.
	 * 
	 * @param visible whether the window should be visible
	 */
	public void setVisible(boolean visible) {
		if (visible)
			Utils.centerWindow(frame);
		frame.setVisible(visible);
	}
	private void startDoing(final String taskName, final Runnable run) {
		bgProgress.setString(taskName);
		bgProgress.setVisible(true);
		final Thread runThread = new Thread(run, "Background Task - " + taskName);
		runThread.setPriority(Thread.MIN_PRIORITY);
		runThread.setDaemon(true);
		runThread.start();
	}
	private void uiEvent(final String cmd) {
		if (cmd.equals("addroom"))
			addRoom();
		else if (cmd.equals("alldoors") && world != null) {
			world.rebuildDoors(painter.getSelectedRooms());
			painter.repaint();
		} else if (cmd.equals("complete")) {
			bgProgress.setString("Done");
			bgProgress.setVisible(false);
			bgProgress.setIndeterminate(false);
		} else if (cmd.equals("deldoors") && world != null) {
			world.removeDoors(painter.getSelectedRooms());
			painter.repaint();
		} else if (cmd.equals("delroom"))
			delRoom();
		else if (cmd.equals("delsel"))
			painter.removeSelected();
		else if (cmd.equals("drop")) {
			if (painter.getPlacing() != null) {
				objectTree.clearSelection();
				painter.setPlacing(null);
			} else
				painter.clearSelection();
		} else if (cmd.equals("exit"))
			exit();
		else if (cmd.equals("export"))
			exportWorld();
		else if (cmd.equals("index"))
			index();
		else if (cmd.equals("maze"))
			generateMaze();
		else if (cmd.equals("mif"))
			generateMIF();
		else if (cmd.equals("new") && confirmClose())
			newWorld();
		else if (cmd.equals("open") && confirmClose())
			openWorld();
		else if (cmd.equals("resize"))
			resizeWorld();
		else if (cmd.equals("save"))
			saveWorld();
		else if (cmd.equals("selectall"))
			painter.selectAll();
		else if (cmd.equals("template"))
			generateTemplate();
		else if (cmd.equals("victims"))
			victimize();
	}
	/**
	 * Adds victims to a user-specified file.
	 */
	public void victimize() {
		// Show dialog for T3D input file
		exportDialog.setDialogTitle("Select file to victimize");
		if (exportDialog.showOpenDialog(mainPanel) == JFileChooser.APPROVE_OPTION) {
			final VictimizeDialog dialog = new VictimizeDialog(mainPanel);
			if (dialog.show("Add Victims") == AbstractDialog.DIALOG_OK)
				startDoing("Victimizing", new Runnable() {
					public void run() {
						bgProgress.setIndeterminate(true);
						try {
							Victimizer.victimize(exportDialog.getSelectedFile(),
								dialog.getVictimCount(), dialog.getCompatMode());
						} catch (IOException e) {
							Utils.showWarning(mainPanel, "Error while writing victim file.");
						} catch (T3DException e) {
							Utils.showWarning(mainPanel, "Error while reading map:<br>" +
								e.getMessage());
						} finally {
							progressComplete();
						}
					}
				});
		}
	}

	/**
	 * Handles events originating from the room tree.
	 */
	private class TreeEventListener extends MouseAdapter implements TreeSelectionListener {
		public void mousePressed(MouseEvent e) {
			mouseReleased(e);
		}
		public void mouseReleased(MouseEvent e) {
			final TreePath path = objectTree.getPathForLocation(e.getX(), e.getY());
			if (e.isPopupTrigger() && path != null) {
				objectTree.setSelectionPath(path);
				roomPopup.show(objectTree, e.getX(), e.getY());
			}
		}
		public void valueChanged(TreeSelectionEvent e) {
			final WGRoomContainer sel = (WGRoomContainer)e.getPath().getLastPathComponent();
			if (e.isAddedPath()) {
				if (sel == null)
					delRoomAction.setEnabled(false);
				else {
					delRoomAction.setEnabled(sel.canDelete());
					if (world != null) {
						painter.clearSelection();
						painter.setPlacing(sel.getRoom());
					}
				}
			}
		}
	}

	/**
	 * Action handler for the vast majority of the buttons in the application.
	 */
	private class GeneralAction extends AbstractAction {
		private static final long serialVersionUID = 0L;

		/**
		 * Creates a new action handler.
		 *
		 * @param title the action text
		 * @param action the command (also used to find the image)
		 * @param key the accelerator key
		 * @param tip the tool tip to display
		 */
		public GeneralAction(String title, String action, int key, String tip) {
			super(title, getImage("icons/" + action.toLowerCase() + ".gif"));
			putValue(SHORT_DESCRIPTION, Utils.asHTML(tip));
			if (key >= 0) {
				putValue(MNEMONIC_KEY, Integer.valueOf(key));
				putValue(ACCELERATOR_KEY, KeyStroke.getKeyStroke(key, KeyEvent.CTRL_MASK));
			}
			putValue(ACTION_COMMAND_KEY, action);
		}
		public void actionPerformed(ActionEvent e) {
			uiEvent(e.getActionCommand());
		}
	}

	/**
	 * A tree model based on the available room list.
	 */
	private class RoomTreeModel extends DefaultTreeCellRenderer implements TreeModel {
		private List<TreeModelListener> listenerList;
		private WGRoomContainer root;

		public RoomTreeModel() {
			listenerList = new ArrayList<TreeModelListener>(5);
			root = new WGRoomContainer(new IntDimension3D(0, 0, 0));
		}
		public void addTreeModelListener(TreeModelListener l) {
			listenerList.add(l);
		}
		public Object getChild(Object parent, int index) {
			final WGRoomContainer container = (WGRoomContainer)parent;
			return container.getRoomAt(index);
		}
		public int getChildCount(Object parent) {
			final WGRoomContainer container = (WGRoomContainer)parent;
			return container.countRooms();
		}
		public int getIndexOfChild(Object parent, Object child) {
			final int index;
			if (parent != null && child != null) {
				final WGRoomContainer container = (WGRoomContainer)parent;
				index = container.indexOf((WGRoomContainer)child);
			} else
				index = -1;
			return index;
		}
		public Object getRoot() {
			return root;
		}
		public Component getTreeCellRendererComponent(JTree tree, Object value, boolean sel,
				boolean expanded, boolean leaf, int row, boolean focus) {
			final WGRoomContainer container = (WGRoomContainer)value;
			super.getTreeCellRendererComponent(tree, value, sel, expanded, leaf, row, false);
			setText(container.getName());
			if (container.isPlaceable()) {
				setIcon(null);
				setBorder(O_ENTRY_BORDER);
				setToolTipText(Utils.generateTooltip(container.getRoom()));
			} else {
				setBorder(BorderFactory.createEmptyBorder());
				setToolTipText(Utils.asHTML("Rooms with dimensions " + container.getSize()));
			}
			return this;
		}
		public boolean isLeaf(Object node) {
			final WGRoomContainer container = (WGRoomContainer)node;
			return container.isPlaceable();
		}
		public void removeTreeModelListener(TreeModelListener l) {
			listenerList.remove(l);
		}
		/**
		 * Rebuilds the list. For alphabetical order to work, the room list must be sorted.
		 */
		public void rebuildList() {
			boolean found;
			// Let the GC eat the old subrooms
			root.clearSubrooms();
			root.addSubroom(new WGRoomContainer(rooms.getHallway(), true));
			for (WGRoom room : rooms) {
				found = false;
				for (WGRoomContainer container : root.getRoomList())
					// Look for existing one
					if (container.getSize().equals(room.getSize()) &&
							!container.isPlaceable()) {
						container.addSubroom(new WGRoomContainer(room));
						found = true;
						break;
					}
				if (!found) {
					// Create new one if not found
					final WGRoomContainer tree = new WGRoomContainer(room.getSize());
					root.addSubroom(tree);
					tree.addSubroom(new WGRoomContainer(room));
				}
			}
			Collections.sort(root.getRoomList());
			updateTree();
		}
		/**
		 * Updates the whole tree. There are never enough items to justify piecewise editing.
		 */
		protected void updateTree() {
			TreeModelEvent evt = new TreeModelEvent(this, new Object[] { root });
			for (TreeModelListener l : listenerList)
				l.treeStructureChanged(evt);
			painter.setPlacing(null);
		}
		public void valueForPathChanged(TreePath path, Object newValue) { }
	}
}