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

#include "RobotConnectionManager.h"

#include "EventListener.h"
#include "EventLogger.h"

#include <iostream>

#include <QtDebug>
#include <QReadLocker>
#include <QWriteLocker>

using namespace std;

RobotConnectionManager::RobotConnectionManager(QObject* parent)
	: QThread(parent)
{
	aKeepRunning = false;
	aShouldLog = false;
	aListenPort = 0;
	
	aListener = NULL;
	
	QThread::setTerminationEnabled(false);
}

RobotConnectionManager::~RobotConnectionManager() {
	if(isRunning()) {
		shutdown();
		wait();
	}
}

void RobotConnectionManager::setEventLoggingEnabled(bool logit) {
	aShouldLog = logit;
}

bool RobotConnectionManager::breakConnectionsForPair(const std::string& one, const std::string& two) {
	string key1 = getKey(one, two);
	string key2 = getKey(two, one);
	
	bool ret = false;
	
	{
		QReadLocker lock(&aConnectionSourcesLock);
		std::map<std::string, map< unsigned int, RobotConnectionSource* > >::iterator rec = aConnectionSources.find( key1 );
		map<unsigned int, RobotConnectionSource*>::iterator it;
		if(rec != aConnectionSources.end()) {
			for(it = rec->second.begin(); it != rec->second.end(); it++) {
				if(it->second->isListening()) {
					ret = true;
				}
				it->second->stopListening();
				emit changedRobotConnectionSource(one, two, it->second->getListenPort(), false);
			}
		}
	
		rec = aConnectionSources.find( key2 );
		if(rec != aConnectionSources.end()) {
			for(it = rec->second.begin(); it != rec->second.end(); it++) {
				if(it->second->isListening()) {
					ret = true;
				}
				it->second->stopListening();
				emit changedRobotConnectionSource(two, one, it->second->getListenPort(), false);
			}
		}
	}
	
	{
		QWriteLocker lock(&aConnectionsLock);
	
		map<std::string, list< RobotConnection* > >::iterator rec = aConnections.find( key1 );
		if(rec != aConnections.end()) {
			list< RobotConnection* >::iterator c;
			for( c = rec->second.begin(); c != rec->second.end(); c++) {
				emit removedRobotConnection(one, two, (*c)->getOutgoingPort());
				delete (*c);
				ret = true;
			}
			rec->second.clear();
		}
		rec = aConnections.find( key2 );
		if(rec != aConnections.end()) {
			list< RobotConnection* >::iterator c;
			for( c = rec->second.begin(); c != rec->second.end(); c++) {
				emit removedRobotConnection(two, one, (*c)->getOutgoingPort());
				delete (*c);
				ret = true;
			}
			rec->second.clear();
		}
	}
	
	return ret;
}

bool RobotConnectionManager::resumeConnectionsForPair(const std::string& one, const std::string& two) {
	string key1 = getKey(one, two);
	string key2 = getKey(two, one);
	
	bool ret = false;
	
	QReadLocker lock(&aConnectionSourcesLock);
	std::map<std::string, map< unsigned int, RobotConnectionSource* > >::iterator rec = aConnectionSources.find( key1 );
	map<unsigned int, RobotConnectionSource*>::iterator it;
	if(rec != aConnectionSources.end()) {
		for(it = rec->second.begin(); it != rec->second.end(); it++) {
			if(!it->second->isListening()) {
				ret = true;
			}
			it->second->startListening();
			emit changedRobotConnectionSource(one, two, it->second->getListenPort(), true);
		}
	}
	
	rec = aConnectionSources.find( key2 );
	if(rec != aConnectionSources.end()) {
		for(it = rec->second.begin(); it != rec->second.end(); it++) {
			if(!it->second->isListening()) {
				ret = true;
			}
			it->second->startListening();
			emit changedRobotConnectionSource(two, one, it->second->getListenPort(), true);
		}
	}
	
	return ret;
}

void RobotConnectionManager::kickOutRobot(const std::string& name) {
	qDebug() << "kicking out robot '" << name.c_str() << "' (probably out of battery or not instantiated in simulator)";
	
	stopSourcesFor(name);
	removeConnectionsFor(name);
	removeSourcesFor(name);
	
	{
		QMutexLocker lock(&aManagementConnectionsMutex);
		
		list< RobotManagementConnection* >::iterator it = aManagementConnections.begin();
		while(it != aManagementConnections.end()) {
			if( (*it)->getRobotName() == name ) {
				RobotManagementConnection* con = *it;
				it = aManagementConnections.erase(it);
			
				qDebug() << "kicking management connection:" << con->getRobotName().c_str();
			
				delete con;
			} else {
				it++;
			}
		}
	}
}

std::list< std::string > RobotConnectionManager::getListOfRegisteredRobots() {
	list< string > ret;
	
	{
		QReadLocker lock(&aRobotConfigurationsLock);
		std::map< std::string, RobotConnectionConfiguration >::iterator it;
		for(it = aRobotConfigurations.begin(); it != aRobotConfigurations.end(); it++) {
			ret.push_back(it->first);
		}
	}
	
	return ret;
}

SmartPtr<PropagationModel> RobotConnectionManager::getPropagationModel() {
	return aModel;
}

void RobotConnectionManager::setPropagationModel(SmartPtr<PropagationModel> model) {
	aModel = model;
}

void RobotConnectionManager::setListenPort(unsigned int port) {
	if( !aControlServer.isConnected() ) {
		aListenPort = port;
	}
}

unsigned int RobotConnectionManager::getListenPort() {
	return aListenPort;
}

void RobotConnectionManager::shutdown() {
	aKeepRunning = false;
}

void RobotConnectionManager::run() {
	if(aListenPort == 0) {
		return;
	}
	
	aControlServer.listen(aListenPort);
	if(!aControlServer.isConnected()) {
		qWarning() << "ConnectionManager couldn't listen on port" << aListenPort << ":" << QString(aControlServer.lastError().c_str());
		return;
	}
	
	if(!aModel.isNull()) {
		qDebug() << "propagation model set, starting it";
		aModel->setEventListener(NULL);
		
		if( !aModel->start() ) {
			qWarning() << "Couldn't start propagation model! Check config!";
			aControlServer.disconnect();
			clearAllConnections();
			return;
		} else {
			qDebug() << "propagation model started";
		}
	}
	
	if(aShouldLog) {
		aListener = new EventLogger();
	} else {
		aListener = NULL;
	}
	
	if(!aModel.isNull()) aModel->setEventListener(aListener);
	
	qDebug() << "ConnectionManager started, listening on" << aListenPort;
	
	aKeepRunning = true;
	while(aKeepRunning && ( aModel.isNull() || aModel->isActive()) ) {		
		XSocket* sock = aControlServer.accept(1000);
		
		if(sock != NULL) {
			RobotManagementConnection* con = new RobotManagementConnection(sock, this);
			
			aManagementConnectionsMutex.lock();
			aManagementConnections.push_back( con );
			aManagementConnectionsMutex.unlock();
			
			con->start();
		}
		
		cleanupEstablishedConnections();
		
		aManagementConnectionsMutex.lock();
		cleanupManagementConnections();
		aManagementConnectionsMutex.unlock();
	}
	
	qDebug() << "ConnectionManager disconnecting and cleaning all connections...";
	
	aControlServer.disconnect();
	clearAllConnections();
	
	if(!aModel.isNull()) aModel->shutdown();
	
	qDebug() << "ConnectionManager done.";
	
	if(!aModel.isNull()) aModel->setEventListener(NULL);
	if(aListener != NULL) {
		delete aListener;
		aListener = NULL;
	}
}

std::string RobotConnectionManager::getKey(const std::string& from, const std::string& to) {
	return from+"{}"+to;
}

void RobotConnectionManager::addNewRobotConnection( XSocket* sock, RobotConnectionSource* src ) {
	QWriteLocker lock(&aConnectionsLock);
	
	RobotConnection* con = new RobotConnection(sock, src, this);
	
	string key = getKey(con->getSourceName(), con->getTargetName());

	if( con->isConnected() && ( aModel.isNull() || aModel->connectionIsPossibleForPair(con->getSourceName(), con->getTargetName()) ) ) {
		con->start();
	} else {
		delete con;
		return;
	}

	emit addedRobotConnection(con->getSourceName(), con->getTargetName(), con->getOutgoingPort() );


	list< RobotConnection* >& cons = aConnections[key];
	cons.push_back(con);
}

std::string RobotConnectionManager::getConnectingEntity(const std::string& target, const unsigned int origPort) {
	QReadLocker lock(&aConnectionsLock);
	
	map<std::string, list< RobotConnection* > >::iterator it;
	for(it = aConnections.begin(); it != aConnections.end(); it++) {
		list< RobotConnection* >::iterator c;
		for( c = it->second.begin(); c != it->second.end(); c++) {
			if( (*c)->getTargetName() == target && (*c)->getOutgoingPort() == origPort ) {
				return (*c)->getSourceName();
			}
		}
	}
	return "";
}

bool RobotConnectionManager::robotExists(const std::string& robot) {
	QReadLocker lock(&aRobotConfigurationsLock);
	std::map< std::string, RobotConnectionConfiguration >::iterator rec = aRobotConfigurations.find(robot);
	return rec != aRobotConfigurations.end();
}

bool RobotConnectionManager::robotListensOnPort(const std::string& robot, const unsigned int& port) {
	QReadLocker lock(&aRobotConfigurationsLock);
	std::map< std::string, RobotConnectionConfiguration >::iterator rec = aRobotConfigurations.find(robot);
	
	if( rec == aRobotConfigurations.end() ) return false;
	
	for(unsigned int i=0; i<rec->second.ports.size(); i++) {
		if( rec->second.ports[i] == port )
			return true;
	}
	return false;
}

void RobotConnectionManager::unsetConnectionPortsForRobot(const std::string& robot) {
	QWriteLocker lock(&aRobotConfigurationsLock);
	std::map< std::string, RobotConnectionConfiguration >::iterator rec = aRobotConfigurations.find(robot);
	if(rec != aRobotConfigurations.end()) {
		aRobotConfigurations.erase(rec);
		emit removedRobot(robot);
		qDebug () << "robot disconnected:" << robot.c_str();
		
		if(hasListener()) getListener()->robotDeregistered( robot );
	}
}

void RobotConnectionManager::setConnectionPortsForRobot(const std::string& robot, const std::string& ip, const std::vector<unsigned int>& ports) {
	RobotConnectionConfiguration conf;
	conf.ip = ip;
	conf.ports = ports;
	
	emit addedRobot(robot);
	qDebug() << "robot connected:" << robot.c_str() << "listening on:" << ip.c_str() << "and" << ports.size() << "ports:";
	for(unsigned int i=0; i<ports.size(); i++) {
		qDebug() << "port:" << ports[i];
	}
	
	if(hasListener()) getListener()->robotRegistered( robot, ip, ports );
	
	QWriteLocker lock(&aRobotConfigurationsLock);
	aRobotConfigurations[robot] = conf;
}

RobotConnectionConfiguration RobotConnectionManager::getConnectionPortsForRobot(const std::string& robot) {
	QReadLocker lock(&aRobotConfigurationsLock);
	std::map< std::string, RobotConnectionConfiguration >::iterator rec = aRobotConfigurations.find(robot);
	if(rec != aRobotConfigurations.end()) {
		return rec->second;
	}
	return RobotConnectionConfiguration();
}

std::string RobotConnectionManager::getConnectionAddressForRobot(const std::string& robot) {
	QReadLocker lock(&aRobotConfigurationsLock);
	std::map< std::string, RobotConnectionConfiguration >::iterator rec = aRobotConfigurations.find(robot);
	if(rec != aRobotConfigurations.end()) {
		return rec->second.ip;
	}
	return string();
}

unsigned int RobotConnectionManager::getConnectionPortFor(const std::string& connectingRobot, const std::string& targetRobot, unsigned int targetPort) {
	if(targetPort == 0) {
		RobotConnectionConfiguration config = getConnectionPortsForRobot(targetRobot);
		targetPort = config.ports.front();
	} else {
		if(!robotListensOnPort(targetRobot, targetPort)) {
			return std::numeric_limits<unsigned int>::max();
		}
	}
	
	string key = getKey(connectingRobot, targetRobot);
	{
		QReadLocker lock(&aConnectionSourcesLock);
		std::map<std::string, map<unsigned int, RobotConnectionSource*> >::iterator rec = aConnectionSources.find( key );
		
		if(rec != aConnectionSources.end() ) {
			map<unsigned int, RobotConnectionSource*>::iterator rec2 = rec->second.find(targetPort);
			if( rec2 != rec->second.end() ) {
				if( !rec2->second->isListening() && (aModel.isNull() || aModel->connectionIsPossibleForPair(connectingRobot, targetRobot)) ) {
					rec2->second->startListening();
				}

				return rec2->second->getListenPort();
			}
		}
	}

	QWriteLocker lock(&aConnectionSourcesLock);
	RobotConnectionSource* src = new RobotConnectionSource(connectingRobot, targetRobot, targetPort, this);
	if(src->getListenPort() == std::numeric_limits<unsigned int>::max()) {
		delete src;
		return std::numeric_limits<unsigned int>::max();
	}
	
	aConnectionSources[key][targetPort] = src;
	
	if( aModel.isNull() || aModel->connectionIsPossibleForPair(connectingRobot, targetRobot))
		src->startListening();
	
	emit addedRobotConnectionSource(connectingRobot, targetRobot, src->getListenPort(), src->isListening());
	
	return src->getListenPort();

}

double RobotConnectionManager::getSignalStrengthFor(const std::string& from, const std::string& to) {
	if( !aModel.isNull() ) {
		return aModel->getSignalStrengthForPair(from, to);
	}
	return 0.0;
}

void RobotConnectionManager::clearAllConnections() {
	
	aRobotConfigurations.clear();
	
	{
		list< RobotManagementConnection* >::iterator it;
		for(it = aManagementConnections.begin(); it != aManagementConnections.end(); it++) {
			delete (*it);
		}
		aManagementConnections.clear();
	}
	
	{
		std::map<std::string, map<unsigned int, RobotConnectionSource*> >::iterator it;
		map<unsigned int, RobotConnectionSource*>::iterator it2;
		for(it = aConnectionSources.begin(); it != aConnectionSources.end(); it++) {
			for(it2 = it->second.begin(); it2 != it->second.end(); it2++) {
				it2->second->stopListening();
			}
		}
	}
	
	{
		std::map<std::string, std::list< RobotConnection* > >::iterator it;
		for(it = aConnections.begin(); it != aConnections.end(); it++) {
			list< RobotConnection* >::iterator c;
			for( c = it->second.begin(); c != it->second.end(); c++) {
				delete (*c);
			}
			it->second.clear();
		}
		aConnections.clear();
	}
	
	{
		std::map<std::string, map<unsigned int, RobotConnectionSource*> >::iterator it;
		map<unsigned int, RobotConnectionSource*>::iterator it2;
		for(it = aConnectionSources.begin(); it != aConnectionSources.end(); it++) {
			for(it2 = it->second.begin(); it2 != it->second.end(); it2++) {
				delete it2->second;
			}
		}
		aConnectionSources.clear();
	}

	emit clearAll();
}

void RobotConnectionManager::stopSourcesFor(const std::string& robot) {
	QWriteLocker lock(&aConnectionSourcesLock);
	std::map<std::string, map<unsigned int, RobotConnectionSource* > >::iterator it;
	map<unsigned int, RobotConnectionSource*>::iterator srcit;
	
	string keyLeft = getKey(robot,"");
	string keyRight = getKey("",robot);
	
	for(it = aConnectionSources.begin(); it != aConnectionSources.end(); it++) {
		if( it->first.find(keyLeft) != string::npos || it->first.find(keyRight) != string::npos) {
			for( srcit = it->second.begin(); srcit != it->second.end(); srcit++) {
				srcit->second->stopListening();
				emit changedRobotConnectionSource(srcit->second->getSourceName(), srcit->second->getTargetName(), srcit->second->getListenPort(), false);
			}
		}
	}
}

void RobotConnectionManager::removeSourcesFor(const std::string& robot) {
	QWriteLocker lock(&aConnectionSourcesLock);
	std::map<std::string, map<unsigned int, RobotConnectionSource* > >::iterator it = aConnectionSources.begin();
	map<unsigned int, RobotConnectionSource*>::iterator srcit;
	
	string keyLeft = getKey(robot,"");
	string keyRight = getKey("",robot);
	
	while(it != aConnectionSources.end()) {
		if( it->first.find(keyLeft) != string::npos || it->first.find(keyRight) != string::npos) {
			map<unsigned int, RobotConnectionSource*> tempmap = it->second;
			
			std::map<std::string, map<unsigned int, RobotConnectionSource* > >::iterator tmp = it;
			it++;
			aConnectionSources.erase(tmp);
			
			for( srcit = tempmap.begin(); srcit != tempmap.end(); srcit++) {
				srcit->second->stopListening();
				emit removedRobotConnectionSource(srcit->second->getSourceName(), srcit->second->getTargetName(), srcit->second->getListenPort(), false);
				delete srcit->second;
			}
		} else {
			it++;
		}
	}
}

void RobotConnectionManager::removeConnectionsFor(const std::string& name) {
	QWriteLocker lock(&aConnectionsLock);
	string key1 = getKey(name, "");
	string key2 = getKey("", name);

	map<std::string, list< RobotConnection* > >::iterator rec = aConnections.begin();
	while(rec != aConnections.end()) {
		if( rec->first.find(key1) != string::npos || rec->first.find(key2) != string::npos ) {
			list< RobotConnection* >::iterator c;
			for( c = rec->second.begin(); c != rec->second.end(); c++) {
				emit removedRobotConnection((*c)->getSourceName(), (*c)->getTargetName(), (*c)->getOutgoingPort());
				delete (*c);
			}
			rec->second.clear();
			map<std::string, list< RobotConnection* > >::iterator temp = rec;
			rec++;
			aConnections.erase(temp);
		} else {
			rec++;
		}
	}
}

void RobotConnectionManager::cleanupEstablishedConnections() {
	QReadLocker lock(&aConnectionsLock);
	std::map<std::string, std::list< RobotConnection* > >::iterator it;
	
	for(it = aConnections.begin(); it != aConnections.end(); it++) {
		list< RobotConnection* >::iterator c= it->second.begin();
		while( c != it->second.end() ) {
			if( (*c)->isFinished() ) {
				RobotConnection* con = (*c);
				c = it->second.erase(c);

				qDebug() << "cleaning established connection from" 
					<< con->getSourceName().c_str() 
					<< "to" 
					<< con->getTargetName().c_str() 
					<< "on outgoing port" 
					<< con->getOutgoingPort();

				emit removedRobotConnection( con->getSourceName(), con->getTargetName(), con->getOutgoingPort() );

				delete con;
			} else {
				c++;
			}
		}
	}
}

void RobotConnectionManager::cleanupManagementConnections() {
	//cerr << "." << flush;
	
	list< RobotManagementConnection* >::iterator it = aManagementConnections.begin();
	while(it != aManagementConnections.end()) {
		if( (*it)->isFinished() ) { // delete dead threads
			RobotManagementConnection* con = *it;
			it = aManagementConnections.erase(it);
			
			stopSourcesFor(con->getRobotName());
			
			qDebug() << "cleaning management connection:" << con->getRobotName().c_str();
			
			//unsetConnectionPortForRobot( con->getRobotName() ); // just to make sure
			
			delete con;
		} else {
			it++;
		}
	}
	
	//cerr << ":" << flush;
}
