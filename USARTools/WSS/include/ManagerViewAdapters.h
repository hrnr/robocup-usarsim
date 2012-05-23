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

#ifndef _MANAGERVIEWADAPTERS_H_
#define _MANAGERVIEWADAPTERS_H_

#include <QAbstractTableModel>
#include <QAbstractListModel>
#include <QList>
#include <QStringList>

#include "RobotConnectionManager.h"

struct IncomingConnection {
	QString from;
	QString to;
	unsigned int listenPort;
	bool isListening;
};

class IncomingConnectionModelAdapter : public QAbstractTableModel {
	Q_OBJECT
	
public:
	IncomingConnectionModelAdapter(RobotConnectionManager*);
	
	static const int FILTER_ROLE;
	
	QVariant data(const QModelIndex&, int = Qt::DisplayRole) const;
	int rowCount( const QModelIndex & parent = QModelIndex() ) const;
	int columnCount( const QModelIndex & parent = QModelIndex() ) const;
	QVariant headerData(int, Qt::Orientation, int = Qt::DisplayRole) const;
	
public slots:
	void addedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	void removedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	void changedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	
	void clearAll();
	
	
private:
	RobotConnectionManager* aManager;
	
	QList< IncomingConnection > aConnections;
};


// *************************************************************************************************


struct EstablishedConnection {
	QString from;
	QString to;
	unsigned int outgoingPort;
};

class EstablishedConnectionModelAdapter : public QAbstractTableModel {
	Q_OBJECT
	
public:
	EstablishedConnectionModelAdapter(RobotConnectionManager*);
	
	static const int FILTER_ROLE;
	
	QVariant data(const QModelIndex&, int = Qt::DisplayRole) const;
	int rowCount( const QModelIndex & parent = QModelIndex() ) const;
	int columnCount( const QModelIndex & parent = QModelIndex() ) const;
	QVariant headerData(int, Qt::Orientation, int = Qt::DisplayRole) const;
	
public slots:
	void addedRobotConnection(const std::string&, const std::string&, unsigned int);
	void removedRobotConnection(const std::string&, const std::string&, unsigned int);
	
	void clearAll();
	
	
private:
	RobotConnectionManager* aManager;
	
	QList< EstablishedConnection > aConnections;
};


// *************************************************************************************************

class ConnectedRobotsModelAdapter : public QAbstractListModel {
	Q_OBJECT
public:
	ConnectedRobotsModelAdapter(RobotConnectionManager*);
	
	QVariant data(const QModelIndex&, int = Qt::DisplayRole) const;
	int rowCount( const QModelIndex & parent = QModelIndex() ) const;
	
public slots:
	void addedRobot(const std::string&);
	void removedRobot(const std::string&);

	void clearAll();
	
private:
	RobotConnectionManager* aManager;
	
	QStringList aRobots;
};

#endif /* _MANAGERVIEWADAPTERS_H_ */
