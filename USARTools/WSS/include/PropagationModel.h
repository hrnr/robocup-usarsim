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

#ifndef _PROPAGATIONMODEL_H_
#define _PROPAGATIONMODEL_H_

#include <QObject>
#include <QtPlugin>

#include "EventListener.h"

#include "XSocket.h"

#include "RobotLinkModel.h"

/**
 * Interface for all wave propagation models. May be extended in the future.
 *
 * Doesn't impose any constraints on the final implementation. 
 */
class PropagationModel : public QObject {
	Q_OBJECT
	
public:
	PropagationModel() {
		aRobotLinkModel = NULL;
		aListener = NULL;
	}
	virtual ~PropagationModel() {}
	
	void setRobotLinkModel(RobotLinkModel* model) {
		aRobotLinkModel = model;
	}
	
	void setEventListener(EventListener* list) {
		aListener = list;
	}
	
	bool hasListener() {
		return aListener != NULL;
	}
	
	EventListener* getListener() {
		return aListener;
	}
	
	/// starts the underlying processing if needed
	/// return true if configuration was complete and correct
	/// (i.e. if control connection to USARSim is needed, make sure to try to open socket here, report errors here)
	/// return false if starting failed because of incomplete or incorrect config
	virtual bool start() { return true; }
	/// stops the underlying processing if needed
	virtual void shutdown() {}
	/// return if the underlying processing is running or not
	virtual bool isActive() { return true; }
	
	/// subclasses must indicate if they allow configuration of parameters
	virtual bool isConfigurable() = 0;
	/// shows a modal QDialog which configures the current instance, if the given bool is false, show a disabled dialog (for inspection only)
	virtual void showConfigurationDialog(bool) {}
	
	/// needed for external access of signal strengths by clients, should only be accessing 
	virtual double getSignalStrengthForPair(const std::string&, const std::string&) = 0;
	
	/// needed for external access to check if two robots may connect
	virtual bool connectionIsPossibleForPair(const std::string&, const std::string&) = 0;
	
protected:
	RobotLinkModel* aRobotLinkModel;
	
private:
	EventListener* aListener;
};

Q_DECLARE_INTERFACE(PropagationModel, "org.robocup.WSS.PropagationModel/1.0")

#endif /* _PROPAGATIONMODEL_H_ */
