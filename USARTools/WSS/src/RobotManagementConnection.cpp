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

#include "RobotManagementConnection.h"

#include "StringUtils.h"
#include "EventListener.h"

#include <iostream>
#include <cmath>

using namespace std;
using namespace StringUtils;

#ifndef isnan
inline bool isnan(const double& f) {
	return f != f; // comp with nan is always false, so nan is the only one not equal to itself
}
#endif

RobotManagementConnection::RobotManagementConnection(XSocket* sock, RobotConnectionManager* man) {
	aSocket = sock;
	aManager = man;
	
	aKeepRunning = false;
	aIsInitialized = false;
}

RobotManagementConnection::~RobotManagementConnection() {
	if(aKeepRunning) {
		shutdown();
		wait();
	}
	
	delete aSocket;
}

void RobotManagementConnection::shutdown() {
	aKeepRunning = false;
}

const std::string RobotManagementConnection::getRobotName() {
	return aLocalRobotName;
}

void RobotManagementConnection::run() {
	if(aKeepRunning == true) {
		return;
	}
	
	aKeepRunning = true;
	
	while(aKeepRunning) {		
		// read socket
		
		string msg;
		int status = aSocket->receive(msg, 1000);
		
		if(status == -1) {
			aKeepRunning = false;
		} else if(status == 1) {
			SmartPtr<Message> m( Message::parse(msg) );
			
			if(!aIsInitialized) {
				if(m->getType() == "INIT") {
					aLocalRobotName = m->getValueConstRef("Robot");
					
					bool unstringifyWorked = true;
					vector<unsigned int> ports = unstringifyList<unsigned int>(m->getValueRef("Port"), ',', true, &unstringifyWorked);
					
					if(!unstringifyWorked) {
						aSocket->send("ERROR {Reason Ports.List.Must.Be.Integer}");
					} else if( aLocalRobotName.length() == 0 ) {
						aSocket->send("ERROR {Reason Robot.Name.Must.Not.Be.Empty}");
					} else if( aManager->robotExists(aLocalRobotName) ) {
						aSocket->send("ERROR {Reason Robot.Alread.Exists}");
					} else {
						aManager->setConnectionPortsForRobot(aLocalRobotName, aSocket->getRemoteIP(), ports);
			
						aIsInitialized = true;
						
						aSocket->send("INITREPLY {Status OK}");
					}
				} else {
					aSocket->send("ERROR {Reason Must.Use.INIT.Method.First}");
				}
			} else {
				if(m->getType() == "GETSS") {
					string otherRobot = m->getValueConstRef("Robot");
					
					if( otherRobot.length() == 0 ) {
						aSocket->send("ERROR {Reason Robot.Name.Must.Not.Be.Empty}");
					} else {
						string strength;
						string error;
						if(otherRobot == aLocalRobotName) {
							strength = "INF";
							error = "SS.To.Self";
						} else if(!aManager->robotExists(otherRobot)) {
							strength = "NaN";
							error = "Robot.Does.Not.Exist";
						} else {
							if( !aKeepRunning ) break;
							double ss = aManager->getSignalStrengthFor(aLocalRobotName, otherRobot);
							if( ss == numeric_limits<double>::infinity() ) {
								strength = "INF";
								error = "Model.Returned.INF";
							} else if( ss > 0 || isnan(ss) ) {
								strength = "NaN";
								error = "Model.Returned.NaN";
							} else {
								strength = stringify(ss);
							}
						}
						
						if( error.size() > 0 ) {
							aSocket->send("SS {Robot "+otherRobot+"} {Strength "+strength+"} {Error "+error+"}");
						} else {
							aSocket->send("SS {Robot "+otherRobot+"} {Strength "+strength+"}");
						}
					}
				} else if(m->getType() == "DNS") {
					string otherRobot = m->getValueConstRef("Robot");
					bool unstringifyWorked = true;
					unsigned int otherPort = 0;
					
					if( m->hasValue("Port") ) {
						otherPort = unstringify<unsigned int>( m->getValueConstRef("Port"), &unstringifyWorked);
						if( !unstringifyWorked ) {
							aSocket->send("ERROR {Reason Port.Must.Be.Integer}");
						}
					}
					
					if( unstringifyWorked ) { // port has a valid value
						if( otherRobot.length() == 0 ) {
							aSocket->send("ERROR {Reason Robot.Name.Must.Not.Be.Empty}");
						} else {
							if(!aManager->robotExists(otherRobot) || otherRobot == aLocalRobotName) {
								aSocket->send("DNSREPLY {Robot "+otherRobot+"} {Port -1} {Error NoSuchRobot}");
							} else if( otherPort != 0 && !aManager->robotListensOnPort( otherRobot, otherPort ) ) {
								aSocket->send("DNSREPLY {Robot "+otherRobot+"} {Port -1} {Error RobotDoesNotListenOnThisPort}");
							} else {
								unsigned int p = aManager->getConnectionPortFor(aLocalRobotName, otherRobot, otherPort);
								if( p == std::numeric_limits<unsigned int>::max() ) {
									aSocket->send("ERROR {Reason Could.Not.Allocate.Port}");
								} else {
									aSocket->send("DNSREPLY {Robot "+otherRobot+"} {Port "+stringify(p)+"}");
								}
							}
						}
					}
				} else if(m->getType() == "REVERSEDNS") {
					bool unstringifyWorked = true;
					unsigned int port = unstringify<unsigned int>(m->getValueConstRef("Port"), &unstringifyWorked);
					
					if(!unstringifyWorked) {
						aSocket->send("ERROR {Reason Port.Must.Be.Integer}");
					} else {
						string otherRobot = aManager->getConnectingEntity(aLocalRobotName, port);
					
						if(otherRobot.length() == 0) {
							aSocket->send("REVERSEDNSREPLY {Port "+stringify(port)+"} {Error UnknownOrIllegalPort}");
						} else {
							aSocket->send("REVERSEDNSREPLY {Port "+stringify(port)+"} {Robot "+otherRobot+"}");
						}
					}
				} else {
					aSocket->send("ERROR {Reason Method.Unknown.Or.Can.INIT.only.once}");
				}
			}
		}
	}
	
	// aKeepRunning is false, connected robot quit
	aManager->unsetConnectionPortsForRobot(aLocalRobotName);
}
