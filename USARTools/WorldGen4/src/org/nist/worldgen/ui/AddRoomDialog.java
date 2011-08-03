package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.*;
import java.awt.*;
import java.io.File;

/**
 * Presents a dialog for adding a room to the database.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class AddRoomDialog extends AbstractDialog implements Constants, WorldExportParams {
	private final ProgressListener delegate;
	private final String initialName;

	/**
	 * Creates a new add room dialog.
	 *
	 * @param parent the component managing this dialog
	 * @param initialName the initial room file name to suggest
	 * @param delegate the delegate to pass progress events
	 */
	public AddRoomDialog(final Component parent, final String initialName,
			final ProgressListener delegate) {
		super(parent);
		this.delegate = delegate;
		this.initialName = initialName;
	}
	protected String getDialogPrompt() {
		return "Room Parameters (Grid Units)";
	}
	protected Field[] getFormFields() {
		final Field<Integer> depth = new Field<Integer>(TYPE_INT, "Depth", 1, R_MAX_DIM);
		depth.setLabel("Room Dimensions (depth,width,height): ");
		depth.setDisplayLength(4);
		depth.setValue(1);
		final Field<Integer> width = new Field<Integer>(TYPE_INT, "Width", 1, R_MAX_DIM);
		width.setNewLine(false);
		width.setLabel(" * ");
		width.setDisplayLength(4);
		width.setValue(1);
		final Field<Integer> height = new Field<Integer>(TYPE_INT, "Height", 1, R_MAX_DIM);
		height.setNewLine(false);
		height.setLabel(" * ");
		height.setDisplayLength(4);
		height.setValue(1);
		final Field<String> fileName = new Field<String>(TYPE_STRING, "FileName");
		fileName.setLabel("File Name: ");
		fileName.setDisplayLength(32);
		fileName.setMinLength(4);
		fileName.setMaxLength(64);
		fileName.setValue(initialName);
		final Field<String> desc = new Field<String>(TYPE_STRING, "Description");
		desc.setDisplayLength(32);
		desc.setMaxLength(64);
		desc.setValue("Room imported by World Generator");
		final Field<String> tag = new Field<String>(TYPE_STRING, "Tag");
		tag.setDisplayLength(32);
		tag.setMaxLength(32);
		tag.setValue("General");
		return new Field[] { depth, width, height, fileName, desc, tag };
	}
	public boolean exportWarning(String message) {
		return Utils.defaultExportWarning(parent, message);
	}
	public File findRoom(String name) {
		// Never used
		return null;
	}
	public int getCompatMode() {
		return UT_COMPAT_UDK;
	}
	protected String getDescription() {
		return (String)getValue("Description");
	}
	protected String getFileName() {
		return (String)getValue("FileName");
	}
	/**
	 * Gets the room that would be created with these parameters.
	 *
	 * @return the room whose parameters were specified by the user
	 */
	public WGRoom getRoom() {
		return new WGRoom(getFileName(), getSize(), getDescription(), getTag());
	}
	protected IntDimension3D getSize() {
		final int depth = (Integer)getValue("Depth");
		final int width = (Integer)getValue("Width");
		final int height = (Integer)getValue("Height");
		return new IntDimension3D(depth, width, height);
	}
	protected String getTag() {
		return (String)getValue("Tag");
	}
	public boolean isUsingSkylight() {
		return false;
	}
	public void progressComplete() {
		delegate.progressComplete();
	}
	public void progressMade(String title, int progress) {
		delegate.progressMade(title, progress);
	}
	public boolean shouldCreateMIF() {
		return false;
	}
}