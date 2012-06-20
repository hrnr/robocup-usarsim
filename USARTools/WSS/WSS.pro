# Copyright (C) 2008 Jacobs University
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


TEMPLATE = app
TARGET = WSS
DEPENDPATH += . src
INCLUDEPATH += . include obj

OBJECTS_DIR = obj
MOC_DIR = obj
UI_DIR = obj

win32:LIBS+= libws2_32
win32:CONFIG += embed_manifest_dll

win32:debug {
	CONFIG += console
}

FORMS += ui/MainWindow.ui

HEADERS += include/debug.h \
			include/XSocket.h \
			include/XServer.h \
			include/XSelector.h \
			include/StringUtils.h \
			include/SmartPtr.h \
			include/Message.h \
			include/RobotConnectionManager.h \
			include/RobotManagementConnection.h \
			include/RobotConnectionSource.h \
			include/RobotConnection.h \
			include/PropagationModel.h \
			include/NoopPropagationModel.h \
			include/MainWindow.h \
			include/Logger.h \
			include/ManagerViewAdapters.h \
			include/EventListener.h \
			include/EventLogger.h

SOURCES += src/main.cpp \
			src/XSocket.cpp \
			src/XServer.cpp \
			src/XSelector.cpp \
			src/Message.cpp \
			src/RobotConnectionManager.cpp \
			src/RobotManagementConnection.cpp \
			src/RobotConnectionSource.cpp \
			src/RobotConnection.cpp \
			src/MainWindow.cpp \
			src/Logger.cpp \
			src/ManagerViewAdapters.cpp
