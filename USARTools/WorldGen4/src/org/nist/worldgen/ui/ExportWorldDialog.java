package org.nist.worldgen.ui;

import org.nist.worldgen.*;
import org.nist.worldgen.xml.RoomFinder;
import org.nist.worldgen.xml.WorldExportParams;

import javax.swing.*;
import java.awt.*;
import java.io.File;

/**
 * Represents the dialog shown to export the world.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class ExportWorldDialog extends AbstractDialog implements Constants, WorldExportParams {
	private final ProgressListener delegate;
	private final RoomFinder rsrc;

	/**
	 * Creates a new world export options dialog.
	 *
	 * @param parent the component managing this dialog
	 * @param delegate the delegate to pass progress events
	 * @param rsrc the room source to pass to descendents
	 */
	public ExportWorldDialog(final Component parent, final ProgressListener delegate,
			final RoomFinder rsrc) {
		super(parent);
		if (delegate == null || rsrc == null)
			throw new NullPointerException();
		this.delegate = delegate;
		this.rsrc = rsrc;
	}
	public boolean exportWarning(String message) {
		return Utils.defaultExportWarning(parent, message);
	}
	protected String getDialogPrompt() {
		return "Export Settings";
	}
	protected Field[] getFormFields() {
		final Field<Boolean> mif = new Field<Boolean>(TYPE_BOOL, "MIF");
		mif.setLabel("Create MIF? ");
		mif.setValue(Boolean.TRUE);
		final Field<Boolean> skyLight = new Field<Boolean>(TYPE_BOOL, "Skylight");
		skyLight.setLabel("Use Sky Light? ");
		skyLight.setValue(Boolean.TRUE);
		final Field<String> ut3 = new Field<String>(TYPE_CHOICE, "UT3Mode", new String[] {
			"UDK", "UT3"
		});
		ut3.setLabel("Output For: ");
		ut3.setValue("UDK");
		return new Field[] { mif, ut3, skyLight };
	}
	public File findRoom(String name) {
		return rsrc.lookup(name);
	}
	public int getCompatMode() {
		return getValue("UT3Mode").equals("UDK") ? UT_COMPAT_UDK : UT_COMPAT_UT3;
	}
	public boolean isUsingSkylight() {
		return (Boolean)getValue("Skylight");
	}
	public void progressComplete() {
		delegate.progressComplete();
	}
	public void progressMade(String message, int progress) {
		delegate.progressMade(message, progress);
	}
	public boolean shouldCreateMIF() {
		return (Boolean)getValue("MIF");
	}
}