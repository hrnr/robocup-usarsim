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

#ifndef _ROBOTCONNECTIONSOURCE_H_
#define _ROBOTCONNECTIONSOURCE_H_

#include <string>
#include <list>

#include <QThread>
#include <QMutex>

#include "XServer.h"

class RobotConnectionSource;
#include "RobotConnectionManager.h"
#include "RobotConnection.h"

class RobotConnectionSource : public QThread {

public:
	RobotConnectionSource(const std::string&, const std::string&, unsigned int, RobotConnectionManager*);
	~RobotConnectionSource();
	
	void stopListening();
	void startListening();
	bool isListening();
	
	inline const std::string& getTargetName() { return aToRobotName; }
	inline const std::string& getSourceName() { return aFromRobotName; }
	inline const unsigned int& getTargetPort() { return aToRobotPort; }
	
	unsigned int getListenPort();
	
	void run();
	
private:
	unsigned int aListenPort;
	bool aShouldStopListening;
	
	std::string aFromRobotName;
	std::string aToRobotName;
	unsigned int aToRobotPort;
	
	XServer aServer;
	RobotConnectionManager* aManager;
};

#endif /* _ROBOTCONNECTIONSOURCE_H_ */
