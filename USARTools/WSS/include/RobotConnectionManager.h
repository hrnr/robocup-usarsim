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

#ifndef _ROBOTCONNECTIONMANAGER_H_
#define _ROBOTCONNECTIONMANAGER_H_

#include <QThread>
#include <QReadWriteLock>

#include <list>
#include <map>

#include "XServer.h"
#include "RobotLinkModel.h"
#include "SmartPtr.h"

class RobotConnectionManager;
#include "RobotConnection.h"
#include "RobotConnectionSource.h"
#include "RobotManagementConnection.h"
#include "PropagationModel.h"

struct RobotConnectionConfiguration {
	std::string ip;
	std::vector< unsigned int > ports;
};

class RobotConnectionManager : public QThread, public RobotLinkModel {
	Q_OBJECT
	
public:
	RobotConnectionManager(QObject* = NULL);
	~RobotConnectionManager();
	void run();
	
	bool hasListener() {
		return aListener != NULL;
	}
	EventListener* getListener() {
		return aListener;
	}
	
	SmartPtr<PropagationModel> getPropagationModel();
	void setEventLoggingEnabled(bool);
	
	// implemented from RobotLinkModel
	bool breakConnectionsForPair(const std::string&, const std::string&);
	bool resumeConnectionsForPair(const std::string&, const std::string&);
	void kickOutRobot(const std::string&);
	std::list< std::string > getListOfRegisteredRobots();
	
	bool robotExists(const std::string&);
	bool robotListensOnPort(const std::string&, const unsigned int&);
	
	void unsetConnectionPortsForRobot(const std::string&);
	void setConnectionPortsForRobot(const std::string&, const std::string&, const std::vector<unsigned int>&);
	RobotConnectionConfiguration getConnectionPortsForRobot(const std::string&);
	std::string getConnectionAddressForRobot(const std::string&);
	
	void addNewRobotConnection( XSocket* sock, RobotConnectionSource* src );
	
	unsigned int getConnectionPortFor(const std::string&, const std::string&, unsigned int = 0);
	std::string getConnectingEntity(const std::string&, const unsigned int);
	double getSignalStrengthFor(const std::string&, const std::string&);
	
	static std::string getKey(const std::string&, const std::string&);
	
	unsigned int getListenPort();
	
	
public slots:
	void setListenPort(unsigned int);
	void shutdown();
	void setPropagationModel(SmartPtr<PropagationModel> model);
	
// MUST ALWAYS CONNECT WITH "QUEUED" OPTION!!!
signals:
	void addedRobot(const std::string&);
	void removedRobot(const std::string&);
	void addedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	void removedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	void changedRobotConnectionSource(const std::string&, const std::string&, unsigned int, bool);
	void addedRobotConnection(const std::string&, const std::string&, unsigned int);
	void removedRobotConnection(const std::string&, const std::string&, unsigned int);
	
	void clearAll();
	
protected:
	void cleanupManagementConnections();
	void cleanupEstablishedConnections();
	void clearAllConnections();
	void stopSourcesFor(const std::string&);
	void removeConnectionsFor(const std::string&);
	void removeSourcesFor(const std::string&);
	
	XServer aControlServer;
	
	unsigned int aListenPort;
	bool aKeepRunning;
	bool aShouldLog;
	
	EventListener* aListener;
	
	SmartPtr<PropagationModel> aModel;
	
	QMutex aManagementConnectionsMutex;
	std::list< RobotManagementConnection* > aManagementConnections;
	
	QReadWriteLock aRobotConfigurationsLock;
	std::map< std::string, RobotConnectionConfiguration > aRobotConfigurations;
	
	QReadWriteLock aConnectionSourcesLock;
	std::map<std::string, std::map< unsigned int, RobotConnectionSource* > > aConnectionSources;
	
	QReadWriteLock aConnectionsLock;
	std::map<std::string, std::list< RobotConnection* > > aConnections;
};


#endif /* _ROBOTCONNECTIONMANAGER_H_ */
