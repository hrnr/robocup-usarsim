TEMPLATE=app
TARGET=test
INCLUDEPATH=../include

OBJECTS_DIR=obj
MOC_DIR=obj

HEADERS += ../include/XSocket.h \
		../include/XServer.h

SOURCES += ../src/XSocket.cpp \
		../src/XServer.cpp \
		../src/Message.cpp \
		main.cpp
