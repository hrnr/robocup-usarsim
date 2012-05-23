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

#ifndef _ROBOTCONNECTION_H_
#define _ROBOTCONNECTION_H_

#include <string>
#include <QThread>

#include "XSocket.h"

class RobotConnection;
#include "RobotConnectionSource.h"
#include "RobotConnectionManager.h"

class RobotConnection : public QThread {

public:
	RobotConnection(XSocket* from, RobotConnectionSource*, RobotConnectionManager*);
	~RobotConnection();

	bool isConnected();
	unsigned int getOutgoingPort();
	
	const std::string& getTargetName();
	const unsigned int& getTargetPort();
	const std::string& getSourceName();
	
	
	void run();
	
private:
	XSocket* aFromSocket;
	XSocket* aToSocket;
	
	std::string aToRobotName;
	std::string aFromRobotName;
	unsigned int aToRobotPort;
	
	unsigned int aOutgoingPort;
	bool aKeepRunning;
	
	RobotConnectionSource* aSource;
	RobotConnectionManager* aManager;
};


#endif /* _ROBOTCONNECTION_H_ */
