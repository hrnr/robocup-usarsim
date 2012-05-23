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

#include <limits>

#include "RobotConnectionSource.h"
#include "EventListener.h"

RobotConnectionSource::RobotConnectionSource(const std::string& source, const std::string& target, unsigned int targetPort, RobotConnectionManager* man) {
	aFromRobotName = source;
	aToRobotName = target;
	aToRobotPort = targetPort;
	aManager = man;

	aShouldStopListening = false;
	
	aServer.listen();
	if(aServer.isConnected()) {
		aListenPort = aServer.getLocalPort();
		aServer.disconnect();
	} else {
		aListenPort = std::numeric_limits<unsigned int>::max();
		qDebug() << "couldn't get local port number for Connection Source! " << source.c_str() << " -> " << target.c_str() ;
	}
}

RobotConnectionSource::~RobotConnectionSource() {
	if(isRunning()) {
		stopListening();
		QThread::wait();
	}
}

void RobotConnectionSource::stopListening() {
	aShouldStopListening = true;
}

void RobotConnectionSource::startListening() {
	if( aServer.isConnected() ) return; // already running
	
	aServer.listen();

	if(aServer.isConnected()) {
		start();
	} else {
		qDebug() << "RobotConnectionSource: couldn't start listening: " << QString(aServer.lastError().c_str());
	}
}

bool RobotConnectionSource::isListening() {
	return isRunning();
}

unsigned int RobotConnectionSource::getListenPort() {
	return aListenPort;
}

void RobotConnectionSource::run() {
	aShouldStopListening = false;
	
	qDebug() << "connection source listening on port " << aServer.getLocalPort() << " should be: " << aListenPort;
	while(!aShouldStopListening) {
		XSocket* sock = aServer.accept(1000);
		
		if(!aManager->robotExists(aToRobotName)) {
			delete sock;
			aShouldStopListening = true;
			break;
		}
		
		if(sock != NULL) {
			aManager->addNewRobotConnection( sock, this );
		}
	}
	qDebug() << "connection source stops listening";
	aServer.disconnect();
}

