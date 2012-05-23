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

#ifndef _LOGGER_H_
#define _LOGGER_H_

#include <QObject>
#include <QString>
#include <QMutex>
#include <QQueue>

#include <iostream>


class Logger : public QObject {
	Q_OBJECT
public:
	static void registerQtHandler();
	
	static Logger* getInstance();
	static void destroyInstance();
	
	static void debug(const QString&);	
	static void warn(const QString&);
	static void critical(const QString&);	
	static void fatal(const QString&);
	
signals:
	void logged(const QString&);
	
protected:
	void timerEvent(QTimerEvent *event);
	
private:
	Logger();
	
	static void ensureLiveInstance();
	
	static Logger* instance;
	static QQueue<QString> logMessages;
	static QMutex logMutex;
};

#endif /* _LOGGER_H_ */
