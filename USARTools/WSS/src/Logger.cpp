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

#include "Logger.h"

#include <QMutexLocker>
#include <stdlib.h>

QQueue<QString> Logger::logMessages;
QMutex Logger::logMutex;
Logger* Logger::instance = NULL;

void wss_Logger_qMessageHandler(QtMsgType type, const char *msg) {
	switch (type) {
		case QtDebugMsg:
			Logger::debug(msg);
			break;
		case QtWarningMsg:
			Logger::warn(msg);
			break;
		case QtCriticalMsg:
			Logger::critical(msg);
			break;
		case QtFatalMsg:
			std::cerr << "FATAL ERROR: " << msg << std::endl;
			exit(1);
	};
}

Logger::Logger() {
	startTimer(100);
}

void Logger::registerQtHandler() {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	qInstallMsgHandler(wss_Logger_qMessageHandler);
}
	
void Logger::debug(const QString& msg) {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	logMessages.enqueue("debug: "+msg);
}

void Logger::warn(const QString& msg) {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	logMessages.enqueue("WARNING: "+msg);
}

void Logger::critical(const QString& msg) {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	logMessages.enqueue("!!CRIT!!: "+msg);
}

void Logger::fatal(const QString& msg) {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	logMessages.enqueue("!!FATAL!!: "+msg);
}
	
void Logger::timerEvent(QTimerEvent *) {
	QMutexLocker lock(&logMutex);
	
	while( !logMessages.empty() ) {
		emit logged( logMessages.dequeue() );
	}
}

Logger* Logger::getInstance() {
	QMutexLocker lock(&logMutex);
	ensureLiveInstance();
	
	return instance;
}

void Logger::destroyInstance() {
	QMutexLocker lock(&logMutex);
	qInstallMsgHandler(NULL);
	delete instance;
	instance = NULL;
}

void Logger::ensureLiveInstance() {
	if(instance == NULL) {
		instance = new Logger();
	}
}
