/*****************************************************************************
  DISCLAIMER:
  This software was produced in part by the National Institute of Standards
  and Technology (NIST), an agency of the U.S. government, and by statute is
  not subject to copyright in the United States.  Recipients of this software
  assume all responsibility associated with its operation, modification,
  maintenance, and subsequent redistribution.
*****************************************************************************/

package org.nist.usarui;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

/**
 * Main program for launching the IRIDIUM utility for USAR
 */
public class Main {
	@SuppressWarnings( {"Since15"})
	public static void main(String[] args) {
		Errors.handleErrors();
		Utils.setUI();
		final Iridium program = new Iridium();
		final Image icon16 = Utils.loadImage("images/icon16.png").getImage();
		final Image icon32 = Utils.loadImage("images/icon32.png").getImage();
		final Image icon48 = Utils.loadImage("images/icon48.png").getImage();
		final JFrame mainFrame = new JFrame("Iridium");
		try {
			mainFrame.setIconImages(Arrays.asList(icon16, icon32, icon48));
		} catch (NoSuchMethodError e) {
			// Not supported on jdk 5
			mainFrame.setIconImage(icon16);
		}
		mainFrame.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				program.getUI().exit();
			}
		});
		mainFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		mainFrame.setResizable(true);
		mainFrame.getContentPane().add(program.getUI().getRoot(), BorderLayout.CENTER);
		mainFrame.setSize(640, 480);
		Utils.centerWindow(mainFrame);
		mainFrame.setVisible(true);
		program.getUI().grabJoystick();
	}
}