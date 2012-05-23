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
#include <QtDebug>
#include <QApplication>

#include "ManagerViewAdapters.h"

#include "debug.h"

const int IncomingConnectionModelAdapter::FILTER_ROLE = Qt::UserRole+1;
const int EstablishedConnectionModelAdapter::FILTER_ROLE = Qt::UserRole+1;

IncomingConnectionModelAdapter::IncomingConnectionModelAdapter(RobotConnectionManager* man) {
	moveToThread(QApplication::instance()->thread());

	aManager = man;
	
	connect( aManager, SIGNAL(addedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), 
		this, SLOT(addedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), Qt::QueuedConnection );
	connect( aManager, SIGNAL(removedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), 
		this, SLOT(removedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), Qt::QueuedConnection );
	connect( aManager, SIGNAL(changedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), 
		this, SLOT(changedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool)), Qt::QueuedConnection );
	connect( aManager, SIGNAL(clearAll()), 
		this, SLOT(clearAll()), Qt::QueuedConnection );
}

QVariant IncomingConnectionModelAdapter::data(const QModelIndex& i, int role) const {
	if(!i.isValid())
		return QVariant();
		
	if(role!=Qt::DisplayRole && role != EstablishedConnectionModelAdapter::FILTER_ROLE)
		return QVariant();
	
	IncomingConnection con = aConnections[i.row()];
	
	if(role == FILTER_ROLE)
		return QVariant( con.from+" "+con.to );
	
	switch(i.column()) {
		case 0: return QVariant( con.from );
		case 1: return QVariant( con.to );
		case 2: return QVariant( con.listenPort );
		case 3: return QVariant( con.isListening );
	};
	
	return QVariant();
}

QVariant IncomingConnectionModelAdapter::headerData(int section, Qt::Orientation ori, int role) const {
	if(role != Qt::DisplayRole)
		return QVariant();
		
	if(ori == Qt::Horizontal) {
		switch(section) {
			case 0: return QVariant("From");
			case 1: return QVariant("To");
			case 2: return QVariant("WSS Port");
			case 3: return QVariant("Listening?");
		};
	}
	
	return QVariant(section+1);
}

int IncomingConnectionModelAdapter::rowCount( const QModelIndex & ) const {
	return aConnections.size();
}

int IncomingConnectionModelAdapter::columnCount( const QModelIndex & ) const {
	return 4;
}

void IncomingConnectionModelAdapter::addedRobotConnectionSource(const std::string& from, const std::string& to, unsigned int listenPort, bool isListening) {
	IncomingConnection con;
	con.from = from.c_str();
	con.to = to.c_str();
	con.listenPort = listenPort;
	con.isListening = isListening;
	
	int last = aConnections.size();
	beginInsertRows(QModelIndex(), last, last);
	aConnections.append(con);
	endInsertRows();
}

void IncomingConnectionModelAdapter::removedRobotConnectionSource(const std::string& from, const std::string& to, unsigned int listenPort, bool) {
	int index = 0;
	for(index = 0; index < aConnections.size(); index++) {
		IncomingConnection con = aConnections[index];
		if(con.from == from.c_str() && con.to == to.c_str() && con.listenPort == listenPort) {
			beginRemoveRows(QModelIndex(), index, index);
			aConnections.removeAt(index);
			endRemoveRows();
			return;
		}
	}
}

void IncomingConnectionModelAdapter::changedRobotConnectionSource(const std::string& from, const std::string& to, unsigned int listenPort, bool isListening) {
	int in = 0;
	for(in = 0; in < aConnections.size(); in++) {
		IncomingConnection con = aConnections[in];
		if(con.from == from.c_str() && con.to == to.c_str() && con.listenPort == listenPort) {
			con.isListening = isListening;
			emit dataChanged(index(in,3), index(in,3));
		}
	}
}

void IncomingConnectionModelAdapter::clearAll() {
	int size = aConnections.size();
	if(size > 0 ) {
		beginRemoveRows(QModelIndex(), 0, size-1);
		aConnections.clear();
		endRemoveRows();
	}
}


// *************************************************************************************************


EstablishedConnectionModelAdapter::EstablishedConnectionModelAdapter(RobotConnectionManager* man) {
	moveToThread(QApplication::instance()->thread());
	
	aManager = man;
	
	connect( aManager, SIGNAL(addedRobotConnection(const std::string&, const std::string&, unsigned int)), 
		this, SLOT(addedRobotConnection(const std::string&, const std::string&, unsigned int)), Qt::QueuedConnection );
	connect( aManager, SIGNAL(removedRobotConnection(const std::string&, const std::string&, unsigned int)), 
		this, SLOT(removedRobotConnection(const std::string&, const std::string&, unsigned int)), Qt::QueuedConnection );

	connect( aManager, SIGNAL(clearAll()), 
		this, SLOT(clearAll()), Qt::QueuedConnection );
}

QVariant EstablishedConnectionModelAdapter::data(const QModelIndex& i, int role) const {
	if(!i.isValid())
		return QVariant();
		
	if(role!=Qt::DisplayRole && role != EstablishedConnectionModelAdapter::FILTER_ROLE)
		return QVariant();
	
	EstablishedConnection con = aConnections[i.row()];
	
	if(role == FILTER_ROLE)
		return QVariant( con.from+" "+con.to );
	
	switch(i.column()) {
		case 0: return QVariant( con.from );
		case 1: return QVariant( con.to );
		case 2: return QVariant( con.outgoingPort );
	};
	
	return QVariant();
}

int EstablishedConnectionModelAdapter::rowCount( const QModelIndex & ) const {
	return aConnections.size();
}

int EstablishedConnectionModelAdapter::columnCount( const QModelIndex & ) const {
	return 3;
}

QVariant EstablishedConnectionModelAdapter::headerData(int section, Qt::Orientation ori, int role) const {
	if(role != Qt::DisplayRole)
		return QVariant();
		
	if(ori == Qt::Horizontal) {
		switch(section) {
			case 0: return QVariant("From");
			case 1: return QVariant("To");
			case 2: return QVariant("WSS Outgoing Port");
		};
	}
	
	return QVariant(section+1);
}

void EstablishedConnectionModelAdapter::addedRobotConnection(const std::string& from, const std::string& to, unsigned int port) {
	EstablishedConnection con;
	con.from = from.c_str();
	con.to = to.c_str();
	con.outgoingPort = port;
	
	int last = aConnections.size();
	beginInsertRows(QModelIndex(), last, last);
	aConnections.append(con);
	endInsertRows();
}

void EstablishedConnectionModelAdapter::removedRobotConnection(const std::string& from, const std::string& to, unsigned int port) {
	int index = 0;
	for(index = 0; index < aConnections.size(); index++) {
		EstablishedConnection con = aConnections[index];
		if(con.from == from.c_str() && con.to == to.c_str() && con.outgoingPort == port) {
			beginRemoveRows(QModelIndex(), index, index);
			aConnections.removeAt(index);
			endRemoveRows();
			return;
		}
	}
}

void EstablishedConnectionModelAdapter::clearAll() {
	int size = aConnections.size();
	if(size > 0 ) {
		beginRemoveRows(QModelIndex(), 0, size-1);
		aConnections.clear();
		endRemoveRows();
	}
}

// *************************************************************************************************


ConnectedRobotsModelAdapter::ConnectedRobotsModelAdapter(RobotConnectionManager* man) {
	moveToThread(QApplication::instance()->thread());
	
	aManager = man;
	
	connect( aManager, SIGNAL(addedRobot(const std::string&)), 
		this, SLOT(addedRobot(const std::string&)), Qt::QueuedConnection );
	connect( aManager, SIGNAL(removedRobot(const std::string&)), 
		this, SLOT(removedRobot(const std::string&)), Qt::QueuedConnection );

	connect( aManager, SIGNAL(clearAll()), 
		this, SLOT(clearAll()), Qt::QueuedConnection );
}

QVariant ConnectedRobotsModelAdapter::data(const QModelIndex& i, int role) const {
	if(role!=Qt::DisplayRole || !i.isValid())
		return QVariant();
	
	return QVariant( aRobots[i.row()] );
}

int ConnectedRobotsModelAdapter::rowCount( const QModelIndex &  ) const {
	return aRobots.size();
}


void ConnectedRobotsModelAdapter::addedRobot(const std::string& name) {
	int last = aRobots.size();
	beginInsertRows(QModelIndex(), last, last);
	aRobots.append(name.c_str());
	endInsertRows();
}

void ConnectedRobotsModelAdapter::removedRobot(const std::string& name) {
	int index = 0;
	for(index = 0; index < aRobots.size(); index++) {
		QString r = aRobots[index];
		if(r == name.c_str()) {
			beginRemoveRows(QModelIndex(), index, index);
			aRobots.removeAt(index);
			endRemoveRows();
			return;
		}
	}
}

void ConnectedRobotsModelAdapter::clearAll() {
	int size = aRobots.size();
	if(size > 0) {
		beginRemoveRows(QModelIndex(), 0, size-1);
		aRobots.clear();
		endRemoveRows();
	}
}

