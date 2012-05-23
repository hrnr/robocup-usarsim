/*
Copyright (C) 2008 Jacobs University

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <QApplication>

#ifdef Q_WS_WIN
#include <stdio.h>
#endif

#include "RobotConnectionManager.h"
#include "StringUtils.h"
#include "Message.h"
#include "NoopPropagationModel.h"
#include "MainWindow.h"
#include "Logger.h"

#include <iostream>
using namespace std;
using namespace StringUtils;


int main (int argc, char *argv[])
{
	QApplication app(argc, argv);
	qRegisterMetaType<std::string>("std::string");
	
	QCoreApplication::setOrganizationName("USARSim");
	QCoreApplication::setOrganizationDomain("usarsim.sourceforge.net");
	QCoreApplication::setApplicationName("WirelessSimulationServer");
	
	Logger::registerQtHandler();

	RobotConnectionManager man;
	man.setListenPort(50000);
	
	MainWindow win(&man);
	
	QObject::connect( Logger::getInstance(), SIGNAL(logged(const QString&)), &win, SLOT(logging(const QString&)) );
	
	win.show();
	
	int ret = app.exec();
	
	Logger::destroyInstance();
	
	return ret;
}
