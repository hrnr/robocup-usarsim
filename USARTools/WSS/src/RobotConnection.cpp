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

#include "RobotConnection.h"

#include <QtDebug>

#include "debug.h"

#include "XSelector.h"

using namespace std;

RobotConnection::RobotConnection(XSocket* from, RobotConnectionSource* src, RobotConnectionManager* man) {
	aSource = src;
	aManager = man;
	
	aFromSocket = from;
	aToSocket = new XSocket();
	
	string ip = aManager->getConnectionAddressForRobot( src->getTargetName() );
	
	if( ip.length() == 0 ) {
		qDebug() << "Connection error: empty ip address from configuration! Does robot '" << src->getTargetName().c_str() << "' exist?";
	}
	
	aToSocket->connect( ip, src->getTargetPort() );
	
	if(!aToSocket->isConnected()) {
		qDebug() << "Connection error: Couln't connect to "
					<< src->getTargetName().c_str()
					<< " ("
					<< ip.c_str() << ":" << src->getTargetPort()
					<< ") error: "
					<< aToSocket->lastError().c_str();
	}
	
	if(aToSocket->isConnected()) {
		aOutgoingPort = aToSocket->getLocalPort();
	} else {
		aOutgoingPort = 0;
	}
	
	aFromRobotName = src->getSourceName();
	aToRobotName = src->getTargetName();
	aToRobotPort = src->getTargetPort();
	
	aKeepRunning = false;
}

RobotConnection::~RobotConnection() {
	if(aKeepRunning) {
		aKeepRunning = false;
		wait();
	}
	delete aToSocket;
	delete aFromSocket;
}

bool RobotConnection::isConnected() {
	return aToSocket->isConnected();
}

const std::string& RobotConnection::getTargetName() {
	return aToRobotName;
}
const std::string& RobotConnection::getSourceName() {
	return aFromRobotName;
}
const unsigned int& RobotConnection::getTargetPort() {
	return aToRobotPort;
}

unsigned int RobotConnection::getOutgoingPort() {
	return aOutgoingPort;
}

void RobotConnection::run() {
	if(!aToSocket->isConnected()) {
		aFromSocket->disconnect();
		aToSocket->disconnect();
		return;
	}
	
	if(aManager->hasListener()) aManager->getListener()->connectionEstablished( getSourceName(), getTargetName(), getTargetPort() );
	
	aKeepRunning = true;
	
	unsigned int bufLen = 2048; // make larger than largest MTU to make sure we fit packets nicely
	char* buffer = new char[bufLen];
	
	XSelector sel;
	sel.addSocket(aFromSocket);
	sel.addSocket(aToSocket);
	
	bool selectProcessed = false;
	
	while(aKeepRunning && aFromSocket->isConnected() && aToSocket->isConnected()) {
		selectProcessed = false;
		
		if( sel.waitForRead(1000) ) {
			if( sel.isReadyRead(aFromSocket) ) {
				selectProcessed = true;
				int read = aFromSocket->read(buffer, bufLen, 0);
				if( read > 0 ) {
					if(aManager->hasListener()) aManager->getListener()->dataSent( getSourceName(), getTargetName(), buffer, read );
					int sent = aToSocket->write(buffer, read);
					if( sent != read ) {
						qDebug() << "ERROR! Didn't write all"
							<< read
							<< "bytes, only wrote"
							<< sent
							<< "bytes! from "
							<< getSourceName().c_str()
							<< " to "
							<< getTargetName().c_str()
							<< " (error:"
							<< aToSocket->lastError().c_str()
							<< ")";
					}
				} else if(read != -2) {
					qDebug() << "Connection terminated," << getSourceName().c_str() << "closed the connection: "<< getSourceName().c_str() << " -> " << getTargetName().c_str() << ":" << getTargetPort();
					aKeepRunning = false;
				}
			}
			if( sel.isReadyRead(aToSocket) ) {
				selectProcessed = true;
				int read = aToSocket->read(buffer, bufLen, 0);
				if( read > 0 ) {
					if(aManager->hasListener()) aManager->getListener()->dataSent( getTargetName(), getSourceName(), buffer, read );
					int sent = aFromSocket->write(buffer, read);
					if( sent != read ) {
						qDebug() << "ERROR! Didn't write all"
							<< read
							<< "bytes, only wrote"
							<< sent
							<< "bytes! from "
							<< getTargetName().c_str()
							<< " to "
							<< getSourceName().c_str()
							<< " (error:"
							<< aFromSocket->lastError().c_str()
							<< ")";
					}
				} else if(read != -2) {
					qDebug() << "Connection terminated," << getTargetName().c_str() << "closed the connection: "<< getSourceName().c_str() << " -> " << getTargetName().c_str() << ":" << getTargetPort();
					aKeepRunning = false;
				}
			}
			
			if(!selectProcessed) {
				qDebug() << "Couldn't read from connection: " << getSourceName().c_str() << " -> " << getTargetName().c_str() << ":" << getTargetPort();
			}
		}
	}
	delete buffer;
	
	aFromSocket->disconnect();
	aToSocket->disconnect();
	
	if(aManager->hasListener()) aManager->getListener()->connectionTerminated( getSourceName(), getTargetName(), getTargetPort() );
}

