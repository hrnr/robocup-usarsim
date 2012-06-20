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

#ifndef _ROBOTMANAGEMENTCONNECTION_H_
#define _ROBOTMANAGEMENTCONNECTION_H_

#include <QThread>

#include <string>

#include "XSocket.h"
#include "Message.h"

class RobotManagementConnection;
#include "RobotConnectionManager.h"

class RobotManagementConnection : public QThread {
public:
	RobotManagementConnection(XSocket*, RobotConnectionManager*);
	~RobotManagementConnection();
	
	void run();
	
	const std::string getRobotName();

public slots:
	void shutdown();
	
protected:
	RobotConnectionManager* aManager;
	XSocket* aSocket;
	
	std::string aLocalRobotName;
	
	bool aIsInitialized;
	bool aKeepRunning;
};

#endif /* _ROBOTMANAGEMENTCONNECTION_H_ */
