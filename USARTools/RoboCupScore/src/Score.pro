#-------------------------------------------------
#
# Project created by QtCreator 2011-01-13T11:03:22
#
#-------------------------------------------------

QT       += core gui network plugin

TARGET = Score
TEMPLATE = app
RESOURCES = rsc.qrc

SOURCES += main.cpp\
        mainwindow.cpp \
    usarsimlink.cpp \
    robot.cpp \
    usaritem.cpp \
    victim.cpp \
    bundle.cpp \
    logger.cpp

HEADERS  += mainwindow.h \
    usarsimlink.h \
    robot.h \
    usaritem.h \
    victim.h \
    bundle.h \
    logger.h

FORMS    += mainwindow.ui

VERSION = 12.5.0
