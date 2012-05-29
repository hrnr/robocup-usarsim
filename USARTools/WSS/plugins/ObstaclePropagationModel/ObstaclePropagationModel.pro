TEMPLATE      = lib
CONFIG       += plugin

OBJECTS_DIR = obj
MOC_DIR = obj
UI_DIR = obj

INCLUDEPATH  += ../../include ./include

FORMS += ui/ConfigDialog.ui

win32:LIBS+= Ws2_32.lib
win32:CONFIG += embed_manifest_dll

mac:LIBS += -undefined dynamic_lookup

HEADERS       = include/ObstaclePropagationModel.h \
				include/ObstacleConfigDialog.h

SOURCES       = src/ObstaclePropagationModel.cpp \
				src/ObstacleConfigDialog.cpp

# for win and linux, all symbols need to be defined at link time of the DLL, so compile some extra stuff
!macx {
HEADERS      += ../../include/PropagationModel.h \
				../../include/Message.h \
				../../include/XSocket.h

SOURCES      += ../../src/Message.cpp \
				../../src/XSocket.cpp
}

TARGET        = wss_obstacleModel
DESTDIR       = ../

CONFIG(debug, debug|release) {
   mac:TARGET = $$member(TARGET, 0)_debug
   win32:TARGET = $$member(TARGET, 0)d
}
