package org.nist.worldgen;

import org.nist.worldgen.ui.*;
import java.io.*;

/**********************************************************
 * USARSim World Generator
 *
 * Collects predefined room modules exported from the UDK editor and arranges them in a
 * building-like structure. Compatible with USARSim for UT3 and multiple operating systems.
 *
 * @author Taylor Brent, Stephen Carlson, and Jon Dutko
 * @version 4.0
 ***********************************************************/
public class WorldGenerator {
	private static void createModulesDirectory() {
		final File modDir = new File("Modules");
		if ((modDir.exists() && modDir.isFile() && !modDir.delete()) ||
				(!modDir.exists() && !modDir.mkdir())) {
			Utils.showWarning(null, "Failed to create modules directory.");
			System.exit(1);
		}
	}
	public static void main(String[] args) {
		Errors.handleErrors();
		Utils.setSystemUI();
		// Fix this now
		createModulesDirectory();
		final WorldGeneratorUI ui = new WorldGeneratorUI();
		ui.maximize();
		ui.setVisible(true);
		// Oh how much simpler it looks once UI and code are apart!
		ui.postEvent("new");
	}
}