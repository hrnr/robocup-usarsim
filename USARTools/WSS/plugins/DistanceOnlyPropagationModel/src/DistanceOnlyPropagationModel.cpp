#include "DistanceOnlyPropagationModel.h"

#include <QtDebug>

#include <QDialog>
#include <QSettings>

#include <limits>
#include <list>
#include <string>
#include <vector>
#include <iostream>
#include <cmath>

#include "DistanceOnlyConfigDialog.h"

#include "Message.h"
#include "EventListener.h"
#include "StringUtils.h"

using namespace std;
using namespace StringUtils;

DistanceOnlyPropagationModel::DistanceOnlyPropagationModel()
	: PropagationModel(), aWorker(this)
{
	QSettings settings;
	settings.beginGroup("plugins/DistanceOnlyPropagationModel");
	
	aDistanceCutoff = settings.value("cutoff", -93).toDouble();
	ePdo = settings.value("Pd0", -49.67).toDouble();
	eN = settings.value("N", 1).toDouble();
	eDo = settings.value("d0", 2).toDouble();
	
	aUSARSimIpAddress = settings.value("usarsim address").toString().toStdString();
	aUSARSimPort = settings.value("usarsim port", 7435).toUInt();
	
	settings.endGroup();
}

DistanceOnlyPropagationModel::~DistanceOnlyPropagationModel() {
	QSettings settings;
	settings.beginGroup("plugins/DistanceOnlyPropagationModel");
	
	settings.setValue("cutoff", aDistanceCutoff);
	settings.setValue("Pd0", ePdo);
	settings.setValue("N", eN);
	settings.setValue("d0", eDo);
	
	settings.setValue("usarsim address", QString(aUSARSimIpAddress.c_str()));
	settings.setValue("usarsim port", aUSARSimPort);
	
	settings.endGroup();
}

bool DistanceOnlyPropagationModel::isActive() {
	return aWorker.isRunning();
}

double DistanceOnlyPropagationModel::computeSignalStrength(const RobotPosition& p1, const RobotPosition& p2) {
	double dm = p1.distance(p2);
	return ePdo - 10*eN*log10(dm/eDo);
}

void DistanceOnlyPropagationModel::showConfigurationDialog(bool enabled) {
	DistanceOnlyConfigDialog dialog;
	
	dialog.setValues(this);

	
	if(!enabled) {
		dialog.disableAll();
	}
	
	int ret = dialog.exec();
	
	if( enabled && ret == QDialog::Accepted ) {
		dialog.getValues(this);
	}
}

bool DistanceOnlyPropagationModel::start() {
	if(aWorker.isRunning())  return false;
	
	aUSARSimConnection.connect(aUSARSimIpAddress, aUSARSimPort);
	
	if(!aUSARSimConnection.isConnected()) {
		qWarning() << "DistanceOnlyPropagationModel couldn't connect to USARSim at " << aUSARSimIpAddress.c_str() << ":" << aUSARSimPort << "! error: " << QString(aUSARSimConnection.lastError().c_str());
		return false;
	}
	
	aWorker.start();
	
	return true;
}

void DistanceOnlyPropagationModel::shutdown() {
	if(aWorker.isRunning()) {
		aKeepRunning = false;
		aWorker.wait();
	}
}

double DistanceOnlyPropagationModel::getSignalStrengthForPair(const std::string& r1, const std::string& r2) {
	QMutexLocker lock(&aRobotPositionsMutex);
	
	QMap< std::string, RobotPosition >::iterator it1 = aRobotPositions.find(r1);
	QMap< std::string, RobotPosition >::iterator it2 = aRobotPositions.find(r2);
	
	// if we don't know, return NaN
	if(it1 == aRobotPositions.end() || it2 == aRobotPositions.end()) {
		return 1;
	}
	
	return computeSignalStrength(it1.value(), it2.value());
}

bool DistanceOnlyPropagationModel::connectionIsPossibleForPair(const std::string& r1, const std::string& r2) {
	QMutexLocker lock(&aRobotPositionsMutex);
	
	QMap< std::string, RobotPosition >::iterator it1 = aRobotPositions.find(r1);
	QMap< std::string, RobotPosition >::iterator it2 = aRobotPositions.find(r2);
	
	// be optimistic, these robots might have spawned since the last usarsim poll, so allow.
	// if they aren't in the next usarsim message, they will be kicked
	if(it1 == aRobotPositions.end() || it2 == aRobotPositions.end()) {
		return true;
	}
	
	return computeSignalStrength(it1.value(), it2.value()) >= aDistanceCutoff;
}

void DistanceOnlyPropagationModel::run() {
	aKeepRunning = true;
	
	qDebug() << "DistanceOnlyPropagationModel: started!";
	
	while(aKeepRunning && aUSARSimConnection.isConnected()) {
		aWorker.msleep(1000); // 1sec
		
		string msg;
		aUSARSimConnection.send("GETPOS");
		
		int ret = aUSARSimConnection.receive(msg, 1000);
		if(ret == -1) {
			qWarning() << "DistanceOnlyPropagationModel: Connection to USARSim dropped!";
			break;
		}
		if(ret == 0) {
			qDebug() << "DistanceOnlyPropagationModel: nothing to read from USARSim";
			continue;
		}
		if(msg.size() == 0) {
			qDebug() << "DistanceOnlyPropagationModel: Empty message from USARSim!";
			continue;
		}
		
		//cout << "MESSAGE: " << msg << endl;
		
		Message* m = Message::parse(msg);
		
		{
			QMutexLocker lock(&aRobotPositionsMutex);
			aRobotPositions.clear();
			
			//qDebug() << "Message received: '" << msg.c_str() << "'";
			
			
			list<string> knownRobots = aRobotLinkModel->getListOfRegisteredRobots();
			
			/*
			{
				list<string>::iterator listit = knownRobots.begin();
				for(; listit != knownRobots.end(); listit++) {
					cout << "registered robot: " << *listit << endl;
				}
			}
			*/
			
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
				
				RobotPosition pos;
				pos.x = unstringify<double>(loc[0]);
				pos.y = unstringify<double>(loc[1]);
				pos.z = unstringify<double>(loc[2]);
				
				aRobotPositions[name] = pos;
				
				cout << name << ": " << pos.x << "," << pos.y << "," << pos.z << endl;
				
				list<string>::iterator rec;
				for(rec = knownRobots.begin(); rec != knownRobots.end(); rec++) {
					if( (*rec) == name ) {
						knownRobots.erase(rec);
						break;
					}
				}
			}
			
			// now, knownRobots has only robots left that aren't registered with USARSim, so kick them out
			list<string>::iterator listit = knownRobots.begin();
			for(; listit != knownRobots.end(); listit++) {
				//cout << "kicking robot " << *listit << endl;
				aRobotLinkModel->kickOutRobot( *listit );
			}
			
			// compute signal strengths and allow/break connections accordingly
			QMap< std::string, RobotPosition >::iterator it1;
			for(it1 = aRobotPositions.begin(); it1 != aRobotPositions.end(); it1++ ) {
				QMap< std::string, RobotPosition >::iterator it2;
				for(it2 = it1+1; it2 != aRobotPositions.end(); it2++) {
					double signalStrength = computeSignalStrength(it1.value(), it2.value());
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
		
		delete m;
	}
	
	aKeepRunning = false;
	
	qDebug() << "DistanceOnlyPropagationModel: stopped!";
	
	aUSARSimConnection.disconnect();
}


Q_EXPORT_PLUGIN2(wss_distanceOnlyModel, DistanceOnlyPropagationModel)
