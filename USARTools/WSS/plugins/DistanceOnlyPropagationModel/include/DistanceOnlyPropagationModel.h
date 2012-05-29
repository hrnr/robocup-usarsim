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

#ifndef _DISTANCEONLYPROPAGATIONMODEL_H_
#define _DISTANCEONLYPROPAGATIONMODEL_H_

#include <QThread>
#include <QMap>
#include <QMutex>

#include <math.h>

#include "XSocket.h"
#include "PropagationModel.h"

struct RobotPosition {
	double x, y, z;
	
	double distance(const RobotPosition& o) const {
		double dx = o.x-x;
		double dy = o.y-y;
		double dz = o.z-z;
		return sqrt(dx*dx + dy*dy + dz*dz);
	}
};

class DistanceOnlyPropagationModel : public PropagationModel {
	Q_OBJECT
	Q_INTERFACES(PropagationModel)
	
public:
	DistanceOnlyPropagationModel();
	~DistanceOnlyPropagationModel();
	
	inline bool isConfigurable(){
		return true;
	}
	
	void showConfigurationDialog(bool);
	
	bool start();
	void shutdown();
	
	bool isActive();
	
	double getSignalStrengthForPair(const std::string&, const std::string&);
	bool connectionIsPossibleForPair(const std::string&, const std::string&);
	
	// signal strength parameters
	double ePdo;
	double eN;
	double eDo;
	double aDistanceCutoff;
	
	// usarsim connection params
	std::string aUSARSimIpAddress;
	unsigned int aUSARSimPort;
	
protected:
	
	double computeSignalStrength(const RobotPosition&, const RobotPosition&);
	
	class Worker : public QThread {
	public:
		Worker(DistanceOnlyPropagationModel* m) {
			model = m;
		}
		void run() {
			model->run();
		}
		
		void msleep(unsigned long msec) {
			QThread::msleep(msec);
		}
		
		DistanceOnlyPropagationModel* model;
	};
	friend class Worker;
	
	Worker aWorker;
	
	void run();
	
	bool aKeepRunning;
	
	XSocket aUSARSimConnection;
	
	QMutex aRobotPositionsMutex;
	QMap< std::string, RobotPosition > aRobotPositions;
};

#endif /* _DISTANCEONLYPROPAGATIONMODEL_H_ */
