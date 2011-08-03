package org.nist.worldgen.ui;

import javax.swing.*;
import java.awt.*;

/**
 * Rather simple component which only paints a compass rose.
 *
 * @author Stephen Carlson (NIST)
 * @version 4.0
 */
public class CompassRosePainter extends JComponent {
	public CompassRosePainter() {
		setFont(new Font("Verdana", Font.PLAIN, 6));
	}
	public void paint(Graphics g2) {
		final Graphics2D g = (Graphics2D)g2; final int w = getWidth(), h = getHeight();
		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		g.setColor(Color.GREEN);
		g.drawLine(1, h / 2, w - 2, h / 2);
		g.setColor(Color.RED);
		g.drawLine(w / 2, 1, w / 2, h - 2);
		g.setColor(Color.BLACK);
		g.drawString("N", w / 2.f + 2.f, 6.f);
	}
}