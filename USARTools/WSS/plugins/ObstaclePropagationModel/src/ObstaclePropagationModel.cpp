#include "ObstaclePropagationModel.h"

#include <QtDebug>
#include <QReadLocker>
#include <QWriteLocker>

#include <QDialog>
#include <QSettings>

#include <utility>
#include <list>
#include <string>
#include <vector>
#include <iostream>
#include <cmath>
#include <algorithm>

#include "ObstacleConfigDialog.h"

#include "Message.h"
#include "EventListener.h"
#include "StringUtils.h"

using namespace std;
using namespace StringUtils;

ObstaclePropagationModel::ObstaclePropagationModel()
	: PropagationModel(), aWorker(this), aRobotPositionsLock(QReadWriteLock::Recursive)
{
	QSettings settings;
	settings.beginGroup("plugins/ObstaclePropagationModel");
	
	aDistanceCutoff = settings.value("cutoff", -93).toDouble();
	ePdo = settings.value("Pd0", -49.67).toDouble();
	eN = settings.value("N", 1).toDouble();
	eDo = settings.value("d0", 2).toDouble();
	eAttenuationFactor = settings.value("atten", 6.325).toDouble();
	eMaxObstacles = settings.value("maxobs", 5).toUInt();
	aMaxAllowedCachedDistance = settings.value("maxcachedist", 1.0).toDouble();
	
	aUSARSimIpAddress = settings.value("usarsim address").toString().toStdString();
	aUSARSimPort = settings.value("usarsim port", 7435).toUInt();
	
	settings.endGroup();
}

ObstaclePropagationModel::~ObstaclePropagationModel() {
	QSettings settings;
	settings.beginGroup("plugins/ObstaclePropagationModel");
	
	settings.setValue("cutoff", aDistanceCutoff);
	settings.setValue("Pd0", ePdo);
	settings.setValue("N", eN);
	settings.setValue("d0", eDo);
	settings.setValue("atten", eAttenuationFactor);
	settings.setValue("maxobs", eMaxObstacles);
	settings.setValue("maxcachedist", aMaxAllowedCachedDistance);
	
	settings.setValue("usarsim address", QString(aUSARSimIpAddress.c_str()));
	settings.setValue("usarsim port", aUSARSimPort);
	
	settings.endGroup();
}

bool ObstaclePropagationModel::isActive() {
	return aWorker.isRunning();
}

double ObstaclePropagationModel::computeSignalStrength(const RobotPosition& p1, const RobotPosition& p2, unsigned int obs) {
	double dm = p1.distance(p2);
	return ePdo - 10*eN*log10(dm/eDo) - obs*eAttenuationFactor;
}

void ObstaclePropagationModel::showConfigurationDialog(bool enabled) {

	ObstacleConfigDialog dialog;
	
	dialog.setValues(this);

	
	if(!enabled) {
		dialog.disableAll();
	}
	
	int ret = dialog.exec();
	
	if( enabled && ret == QDialog::Accepted ) {
		dialog.getValues(this);
	}

}

bool ObstaclePropagationModel::start() {
	if(aWorker.isRunning())  return false;
	
	aUSARSimConnection.connect(aUSARSimIpAddress, aUSARSimPort);
	
	if(!aUSARSimConnection.isConnected()) {
		qWarning() << "ObstaclePropagationModel couldn't connect to USARSim at " << aUSARSimIpAddress.c_str() << ":" << aUSARSimPort << "! error: " << QString(aUSARSimConnection.lastError().c_str());
		return false;
	}
	
	aRobotPositions.clear();
	aObstacleCountCache.clear();
	
	aWorker.start();
	
	return true;
}

void ObstaclePropagationModel::shutdown() {
	if(aWorker.isRunning()) {
		aKeepRunning = false;
		aWorker.wait();
	}
}

double ObstaclePropagationModel::getSignalStrengthForPair(const std::string& s1, const std::string& s2) {
	pair<RobotPosition,RobotPosition> r;
	r = getPositions(s1, s2);
	
	if( !r.first.valid || !r.second.valid ) {
		cerr << "SIGSTR ERROR: " << s1 << "-" << s2 << ": one of pos not valid, returning nan as sigstrength" << endl;
		return numeric_limits<double>::quiet_NaN();
	}
	
	unsigned int obs = getNumObs(s1, s2);
	double ss = computeSignalStrength(r.first, r.second, obs);
	
	cerr << "SIGSTR: " << s1 << "-" << s2 << ": " << ss << endl;
	return ss;
}

bool ObstaclePropagationModel::connectionIsPossibleForPair(const std::string& s1, const std::string& s2) {
	pair<RobotPosition,RobotPosition> r;
	r = getPositions(s1, s2);
	
	if( !r.first.valid || !r.second.valid ) {
		cerr << "CONN ERROR: " << s1 << "-" << s2 << ": one of pos not valid, returning false for connection possible" << endl;
		return false;
	}
	
	return computeSignalStrength(r.first, r.second, getNumObs(s1, s2)) >= aDistanceCutoff;
}

unsigned int ObstaclePropagationModel::getNumObs(std::string s1, std::string s2) {
	pair<RobotPosition,RobotPosition> r;
	if( s1 >= s2 ) {
		swap(s1,s2);
	}
	
	r = getPositions(s1, s2);
	
	if( !r.first.valid || !r.second.valid ) {
		cerr << "OBS ERROR: " << s1 << "-" << s2 << ": one of pos not valid, returning max as num obs" << endl;
		return numeric_limits<unsigned int>::max();
	}

	{
		QMutexLocker lock2(&aObstacleCountCacheMutex);
		
		QMap< std::pair< std::string, std::string>, ObstacleCountCache >::iterator it = aObstacleCountCache.find( make_pair(s1,s2) );
		if( it == aObstacleCountCache.end() ||  !it.value().withinSqDist(r.first, r.second, aMaxAllowedCachedDistance) ) {
			unsigned int obs = requestNewObsCount(s1,s2);
			if( obs == numeric_limits<unsigned int>::max() ) return numeric_limits<unsigned int>::max();
			
			it = aObstacleCountCache.insert( make_pair(s1,s2), ObstacleCountCache(r.first,r.second,obs) );
			
			cerr << "OBS UPDATED: " << s1 << "-" << s2 << ": " << obs << endl;
		} else {
			cerr << "OBS CACHED:  " << s1 << "-" << s2 << ": " << it.value().obstacles << endl;
		}
		return it.value().obstacles;
	}
}

Message* getMessage(QMutex* m, XSocket& sock, const string& command, const string& type) {
	QMutexLocker lock(m);
	
	if( !sock.isConnected() ) return NULL;
	
	string msg;
	
	// pop old messages
	while( sock.getIncomingQueueLength() > 0 ) {
		sock.receive(msg);
	}
	
	sock.send(command);
	
	int status = sock.receive(msg, 1000);
	if( status == -1 ) {
		qWarning() << "ObstaclePropagationModel::getMessage: Connection to USARSim dropped!";
		return NULL;
	} else if( status == 0 ) {
		qDebug() << "ObstaclePropagationModel::getMessage: nothing to read from USARSim (command:" << command.c_str() << ")";
		return NULL;
	} else if( msg.size() == 0 ) {
		qDebug() << "ObstaclePropagationModel::getMessage: Empty Message from USARSim (command:" << command.c_str() << ", expected type: " << type.c_str() << ")";
		return NULL;
	} else {
		Message* m = Message::parse(msg);
		if( m->getType() == type ) {
			return m;
		}
		delete m;
	}
	
	while( sock.getIncomingQueueLength() > 0 ) {
		sock.receive(msg);
		
		Message* m = Message::parse(msg);
		if( m->getType() == type ) {
			return m;
		}
		delete m;
	}
	
	return NULL;
}

std::pair< RobotPosition, RobotPosition > ObstaclePropagationModel::getPositions(const std::string& s1, const std::string& s2) {
	
	{
		QReadLocker lock(&aRobotPositionsLock);
		
		QMap< std::string, RobotPosition >::iterator it1 = aRobotPositions.find(s1);
		QMap< std::string, RobotPosition >::iterator it2 = aRobotPositions.find(s2);

		if(it1 != aRobotPositions.end() && it2 != aRobotPositions.end()) {
			return make_pair( (it1.value()), (it2.value()) );
		}
	}
	
	if( aRobotPositionsLock.tryLockForWrite(1000) ) {
		updatePositions();

		QMap< std::string, RobotPosition >::iterator it1 = aRobotPositions.find(s1);
		QMap< std::string, RobotPosition >::iterator it2 = aRobotPositions.find(s2);

		RobotPosition r1, r2;

		if( it1 != aRobotPositions.end() ) {
			r1 = it1.value();
		}
		if( it2 != aRobotPositions.end() ) {
			r2 = it2.value();
		}
		
		aRobotPositionsLock.unlock();
		
		return make_pair( r1, r2 );
	}
	
	return make_pair( RobotPosition(), RobotPosition() );
}

bool ObstaclePropagationModel::updatePositions() {
	QWriteLocker lock(&aRobotPositionsLock);
	
	Message* m = getMessage(&aUSARSimConnectionMutex, aUSARSimConnection, "GETPOS", "POSITIONS");
	
	aRobotPositions.clear();
	
	if(m == NULL) {
		QMutexLocker lock2(&aUSARSimConnectionMutex);
		
		if( !aUSARSimConnection.isConnected() ) {
			return false;
		} else {
			return true;
		}
	}
	
	for(int i=0; i<m->getNumberOfSegments(); i++) {
		Segment s = m->getSegment(i);
		
		string name = s["Name"];
		vector<string> loc = getList(s["Location"], ',');
		bool batteryEmpty = s["BatteryEmpty"] == "True";
		
		//cout << "saw robot: " << name << " with battery " << batteryEmpty << endl;
		
		if(batteryEmpty) {
			if(hasListener()) getListener()->robotOutOfBattery(name);
			continue; // will be kicked after
		}
		
		RobotPosition pos( unstringify<double>(loc[0]), unstringify<double>(loc[1]), unstringify<double>(loc[2]) );
		
		aRobotPositions[name] = pos;
	}
	
	cerr << "updated positions of " << aRobotPositions.size() << " robots" << endl;
	
	delete m;
	
	return true;
}

unsigned int ObstaclePropagationModel::requestNewObsCount(const std::string& s1, const std::string& s2) {
	Message* m = getMessage(&aUSARSimConnectionMutex, aUSARSimConnection, "GETOBS {From "+s1+"} {To "+s2+"}", "NUMOBS");

	unsigned int ret = 0;
	
	if(m == NULL) {
		return numeric_limits<unsigned int>::max();
	}
	
	if( !m->hasValue("ObstCount") || m->getValueConstRef("ObstCount") == "-1" ) {
		ret = numeric_limits<unsigned int>::max();
	} else {
		ret = unstringify<unsigned int>(m->getValueConstRef("ObstCount"));
	}
	
	delete m;
	return ret;
}

void ObstaclePropagationModel::run() {
	aKeepRunning = true;
	
	qDebug() << "ObstaclePropagationModel: started!";
	
	while(aKeepRunning && aUSARSimConnection.isConnected()) {
		aWorker.msleep(1000); // 1sec
		
		if( !updatePositions() ) {
			break;
		}
		
		{
			QReadLocker lock(&aRobotPositionsLock);
			
			if( aRobotPositions.empty() ) {
				continue;
			}
			
			list<string> knownRobots = aRobotLinkModel->getListOfRegisteredRobots();
			
			for( list<string>::iterator it = knownRobots.begin(); it != knownRobots.end(); it++ ) {
				if( aRobotPositions.find( *it ) == aRobotPositions.end() ) {
					// kick out all those that are not in the position list we just got from usarsim
					aRobotLinkModel->kickOutRobot( *it );
				}
			}
			
			// compute signal strengths and allow/break connections accordingly
			QMap< std::string, RobotPosition >::iterator it1;
			for(it1 = aRobotPositions.begin(); it1 != aRobotPositions.end(); it1++ ) {
				QMap< std::string, RobotPosition >::iterator it2;
				for(it2 = it1+1; it2 != aRobotPositions.end(); it2++) {
					double signalStrength = computeSignalStrength(it1.value(), it2.value(), getNumObs(it1.key(), it2.key()));
					if( signalStrength < aDistanceCutoff ) {
						if(aRobotLinkModel->breakConnectionsForPair( it1.key(), it2.key() )) {
							if(hasListener()) getListener()->connectionOutOfRange( it1.key(), it2.key(), signalStrength, it1.value().distance(it2.value()) );
						}
					} else {
						if(aRobotLinkModel->resumeConnectionsForPair( it1.key(), it2.key() )) {
							if(hasListener()) getListener()->connectionInRange( it1.key(), it2.key() );
						}
					}
				}
			}
		}

	}
	
	aKeepRunning = false;
	
	qDebug() << "ObstaclePropagationModel: stopped!";
	
	aUSARSimConnection.disconnect();
}


Q_EXPORT_PLUGIN2(wss_obstacleModel, ObstaclePropagationModel)
