/*
Copyright (C) 2009 Jacobs University

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

#ifndef OBSTACLEPROPAGATIONMODEL_H
#define OBSTACLEPROPAGATIONMODEL_H

#include <QThread>
#include <QMap>
#include <QMutex>
#include <QReadWriteLock>

#include <limits>
#include <utility>
#include <cmath>

#include "XSocket.h"
#include "PropagationModel.h"

struct RobotPosition {
	double x, y, z;
	bool valid;
	
	RobotPosition(double px, double py, double pz) {
		x = px;
		y = py;
		z = pz;
		valid = true;
	}
	
	RobotPosition() {
		valid = false;
	}
	
	double distance(const RobotPosition& o) const {
		if(!valid) return std::numeric_limits<double>::max();
		
		double dx = o.x-x;
		double dy = o.y-y;
		double dz = o.z-z;
		return std::sqrt(dx*dx + dy*dy + dz*dz);
	}
	
	double sqdistance(const RobotPosition& o) const {
		if(!valid) return std::numeric_limits<double>::max();
		
		double dx = o.x-x;
		double dy = o.y-y;
		double dz = o.z-z;
		return dx*dx + dy*dy + dz*dz;
	}
};

struct ObstacleCountCache {
	RobotPosition r1, r2;
	
	unsigned int obstacles;
	
	ObstacleCountCache(const RobotPosition& o1, const RobotPosition& o2, unsigned int obs) {
		r1 = o1;
		r2 = o2;
		obstacles = obs;
	}
	
	bool withinSqDist(const RobotPosition& o1, const RobotPosition& o2, double d) {
		return r1.sqdistance(o1) <= d &&  r2.sqdistance(o2) <= d;
	}
};

class ObstaclePropagationModel : public PropagationModel {
	Q_OBJECT
	Q_INTERFACES(PropagationModel)
	
public:
	ObstaclePropagationModel();
	~ObstaclePropagationModel();
	
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
	double eAttenuationFactor;
	unsigned int eMaxObstacles;
	double aMaxAllowedCachedDistance;
	double aMaxAllowedCachedSquaredDistance;
	
	// usarsim connection params
	std::string aUSARSimIpAddress;
	unsigned int aUSARSimPort;
	
protected:
	
	double computeSignalStrength(const RobotPosition&, const RobotPosition&, unsigned int);
	
	unsigned int getNumObs(std::string, std::string);
	unsigned int requestNewObsCount(const std::string&, const std::string&);
	
	std::pair< RobotPosition, RobotPosition > getPositions(const std::string&, const std::string&);
	bool updatePositions();
	
	class Worker : public QThread {
	public:
		Worker(ObstaclePropagationModel* m) {
			model = m;
		}
		void run() {
			model->run();
		}
		
		void msleep(unsigned long msec) {
			QThread::msleep(msec);
		}
		
		ObstaclePropagationModel* model;
	};
	friend class Worker;
	
	Worker aWorker;
	
	void run();
	
	bool aKeepRunning;
	
	QMutex aUSARSimConnectionMutex;
	XSocket aUSARSimConnection;
	
	QReadWriteLock aRobotPositionsLock;
	QMap< std::string, RobotPosition > aRobotPositions;
	QMutex aObstacleCountCacheMutex;
	QMap< std::pair< std::string, std::string>, ObstacleCountCache > aObstacleCountCache;
};

#endif /* end of include guard: OBSTACLEPROPAGATIONMODEL_H */
