World Generator (version 4.0) for UDK and UT3
by Stephen Carlson and Taylor Brent

This program is a substantial upgrade to the previous World Generator for UT2004 and UT3.

Create New World:

When the program starts, or when the "New" button is pressed, a dialog will appear prompting for the world's
dimensions and name. The dimensions are in "grid units", where one grid unit is 3 meters (750 UU) plus the 16 UU
spacing in between for doors.

Select a name that is descriptive yet not too long (it will be the default file name for the world).

If the "Add Random Rooms" box is checked, rooms will be prefilled into the new world. The default algorithm is
quite naive, so hand editing is strongly recommended afterwards.

Editing Worlds:

When a world is opened or created, the left side of the screen will show a list of available rooms, grouped
by size. Clicking the plus next to a folder will expand it to show the rooms of that size. Hovering over a room
(in either the world or the selector) will display its name, size, and tag. Rooms with the same tag will look
more consistent together than rooms with different tags.

To place a room, select its entry and mouse over the world. A picture of the world will appear in the location
where the mouse currently lies. If this icon is red, the room cannot be placed at that location. Right-clicking
will rotate the room 90 degrees. Clicking will place the room; clicking and dragging will place many rooms.

When not placing a room, clicking or dragging will select rooms, which will appear highlighted. Right-clicking
will rotate the room(s), clicking and dragging will move them, and pressing DELETE will remove the rooms.

Doors will also appear on the map as small gray rectangles. Doors can be selected, but only one at a time, and
they can only be deleted (not moved). Doors will automatically be removed and regenerated as the world changes.
It is generally best to only manually modify doors after one is satisfied with the room layout. Doors can be
deleted or recreated for many rooms at once by selecting the room(s) and using the menu option in the Edit menu.

The world can also be resized using a menu option in the Edit menu.

To load or save the world, use the appropriate option in the File menu. Load and Save will write the world as an
XML format, which is specific to the World Generator and holds all information required to completely recreate
the map as it is shown on the screen. To save the map in a format that can be used by USARSim, export the world.

Export World:

Pressing "Export" or Ctrl+E will bring up a dialog asking for the output T3D file. T3D files can be imported by
both UDK and UT3. After specifying an output file name (the file does not yet need to exist for export to finish),
another dialog box will appear.

Select "Generate MIF" if a MIF file (which describes the open and blocked areas) is required.

Selecting "Use Sky Light" will replace all lights in the world with one light that covers the whole world. This
optimization saves large quantities of resources in USARSim but causes all rooms to have the same lighting.

Change "Output For" to match the version of USARSim that will be used to view the map.

Selecting "OK" will export the world. In addition to the T3D file, another TXT file will also be created that
lists the packages required to properly load the map.

To import the world into UT3, open the UT3 editor using the "editor.bat" file in the USARSim distribution. From
the File menu, selected Import > Into New Map. Select the generated file, and when it loads, select "Build All".
For large worlds, this can take many minutes. Using a Skylight saves drastically on build time.

To import the world into UDK, open the UDK editor from the Start menu. From the File menu, select New, and click
Blank Map in the resulting dialog. Then, import the world using File > Import > Into Existing Map. Build the map
when finished. It may take less time to build the world in UDK for large worlds than UT3.

Creating and Adding New Rooms:

New rooms are always useful. To create one, select "Template" from the Tools > Generate menu. Enter the desired
size in grid units in the dialog box, then select a location to save the empty template file. This file can be
imported into Unreal (just like a generated world) to create a new room. When the room is complete, export it
using File > Export > All; ensure that Unreal Text (T3D) file is selected as the output format.

To add a constructed room to the room list, use "Add Room" from the Edit menu. After selecting the desired room
T3D file from the dialog, another dialog box will appear prompting for the room's attributes.

The dimensions of the room are critical; they determine the size of the box the World Generator places in the
world to hold that room. "Depth" is in the Unreal X direction and "Width" is in the Unreal Y direction. The
sizes must be entered in Grid Units (the same numbers used when generating the template).

Do not change the File Name field. Add a meaningful but short title for the room in the Description field.

Use the Tag field to identify something meaningful about the room that could allow it to be associated with
similar rooms. In the default library, the tag field is used to describe which set of textures the room uses.

After selecting OK, the World Generator will import the room. A warning message will appear if the room appears
to be the wrong size. It can be ignored, but rooms that are mis-sized may cause errors or crashes in the final
map. Often this warning is the result of entering the wrong room dimensions.

To remove a room from the list, right click it and select Delete Room.

Creating a Maze:

Select Tools > Generate > Maze. A dialog will appear prompting for the maze name and dimensions. Dimensions
follow the same format as room dimensions.

Ramps can also be added to simulate an Orange or Yellow maze. Select the desired maze type in the Ramps field.
The desired ramp angle (approximate) can then be selected in the Incline field.

Configuration:

For advanced users, the World Generator can be configured by editing the "WorldGen.properties" file located in
the same directory as the program.

Other Tools:

Selecting "Generate MIF" from the Tools > External menu allows a MIF to be generated from a previously made map
which is in T3D format.

The Victimize Map utility, also in Tools > External, will add victims to an existing map in T3D format. Select
the map from the dialog; another dialog will then appear asking for the number of victims to add. The resulting
file will be saved in the same directory as the old map with "victim-" prefixed to its name.

If rooms are crashing on output or are displaying corrupted previews, use Tools > Refresh Rooms.

Error reports should go to stephen.carlson@nist.gov or stephen.balakirsky@nist.gov for troubleshooting. If the
error resulted from an "Oh, No!" dialog box, please provide some of the first few lines of text in the "Error
Details" window.
