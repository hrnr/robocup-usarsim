Iridium - An improved UI for USARSim

by Stephen Carlson, NIST

Description:
Iridium is a basic Java program used to communicate with USARSim. While it lacks the advanced functionality of
some MOAST programs, it has an easy-to-use GUI that helps people who are unfamiliar with USAR commands to get
started quickly. It also has a display of the current real-time sensor and status data without getting bogged
down. It is meant to replace the "USAR_UI" program from the UT distribution.

Quick Start:
Double click on "Iridium.jar" in the bin/ folder. A window should come up seemingly similar to USAR. Hover the
mouse over components for a description of that component. Click "Connect" to connect to a USAR server, which
will allow commands to be entered through the UI or the Advanced box.

Features:
- Syntax highlighting of commands.
- Real time sensor reporting via custom information bars; no output overflow like USAR UI.
- Real time map for ground truth.
- GUI interface for common commands cuts down on errors and reduces typing. Available values can often be
  suggested automatically by the UI.
- Rerun commands by double clicking in the log window; if they have scrolled off, use the drop down box
  available by clicking "Raw" and select the command again.
- Freeze sensor data and log messages to observe key values, or clear the log window at any time.
- Many angles can optionally be input or output in degrees.
- Easy to customize the premade entries for robot class and raw command.
- Emergency stop button to stop robot drive movement.
- Joystick control of vehicles (partially working).

Error Reporting:
If an "Oh No!" message appears when running the program, please note the text on the "Error Details" window.
This information is helpful for debugging. It can be sent to stephen.carlson@nist.gov or
stephen.balakirsky@nist.gov for troubleshooting.

Known Issues:
- Joystick support is poor on Linux or Mac. 64 bit JREs will also cause a joystick failure.
- Underwater vehicles, world controllers, and other features not in the UI have to use the Advanced command box
  (available by clicking the "Raw" button near the Send button)
- The UI employs some features documented on the USARSim Wiki (http://usarsim.sourceforge.net/) that are not
  supported by the USAR UDK port.

Notes:
Some libraries used by this software were not developed at NIST.
For details see the included license.txt file.
