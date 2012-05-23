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

#ifndef _ROBOTLINKMODEL_H_
#define _ROBOTLINKMODEL_H_

#include <list>
#include <string>

class RobotLinkModel {
public:
	RobotLinkModel() {}
	virtual ~RobotLinkModel() {}
	
	virtual bool breakConnectionsForPair(const std::string&, const std::string&) = 0;
	virtual bool resumeConnectionsForPair(const std::string&, const std::string&) = 0;
	
	virtual void kickOutRobot(const std::string&) = 0;
	
	virtual std::list< std::string > getListOfRegisteredRobots() = 0;
};

#endif /* _ROBOTLINKMODEL_H_ */
