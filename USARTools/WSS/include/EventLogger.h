#ifndef _EVENTLOGGER_H_
#define _EVENTLOGGER_H_

#include <QDateTime>
#include <QTime>
#include <QMutex>

#include <fstream>

#include "EventListener.h"

class NULLEventListener : public EventListener {
public:
	
	inline void robotRegistered(const std::string& , const std::string& , const std::vector<unsigned int>& ) {}
	inline void robotDeregistered(const std::string& ) {}
	
	inline void robotOutOfBattery(const std::string& ) {}
	
	inline void connectionOutOfRange(const std::string& , const std::string& , double , double ) {}
	inline void connectionInRange(const std::string& , const std::string& ) {}
	
	inline void connectionEstablished(const std::string& , const std::string&, unsigned int ) {}
	inline void connectionTerminated(const std::string& , const std::string&, unsigned int ) {}
	
	inline void dataSent(const std::string& , const std::string& , const char* , unsigned int ) {}
	
};

class EventLogger : public EventListener {
public:
	EventLogger() {
		QString filename("log-");
		filename += QDateTime::currentDateTime().toString("yyyy.MM.dd-hh.mm.ss.zzz");
		filename += ".txt";
		aLog.open( filename.toAscii() );
	}
	
	virtual ~EventLogger() {
		QMutexLocker log(&aLogMutex);
		
		aLog.close();
	}
	
	void robotRegistered(const std::string& name, const std::string& ip, const std::vector<unsigned int>& listenports) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "REGISTERED," << t.toStdString() << "," << name << "," << ip << ",";
		for(unsigned int i=0; i<listenports.size(); i++) {
			aLog << listenports[i];
			if(i != listenports.size()-1)
				aLog << ":";
		}
		aLog << std::endl;
//		aLog << t.toStdString() << ": robot registered (name='" << name << "',ip='" << ip << "',listenport='" << listenport << "')" << std::endl;
	}
	void robotDeregistered(const std::string& name) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "DEREGISTERED," << t.toStdString() << "," << name << std::endl;
//		aLog << t.toStdString() << ": robot deregistered (name='" << name << "')" << std::endl;
	}
	
	void robotOutOfBattery(const std::string& name) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "OUT_OF_BATTERY," << t.toStdString() << "," << name << std::endl;
//		aLog << t.toStdString() << ": robot out of battery (name='" << name << "')" << std::endl;
	}
	
	void connectionOutOfRange(const std::string& from, const std::string& to, double sigStrength, double distance) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "OUT_OF_RANGE," << t.toStdString() << "," << from << "," << to << "," << sigStrength << "," << distance << std::endl;
//		aLog << t.toStdString() << ": connection out of range (from='"<<from<<"',to='"<<to<<"',signal stength='"<<sigStrength<<"',distance='"<<distance<<"')" << std::endl;
	}
	void connectionInRange(const std::string& from, const std::string& to) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "IN_RANGE," << t.toStdString() << "," << from << "," << to << std::endl;
//		aLog << t.toStdString() << ": connection in range (from='"<<from<<"',to='"<<to<<"')" << std::endl;
	}
	
	void connectionEstablished(const std::string& from, const std::string& to, unsigned int toport) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "CON_ESTABLISHED," << t.toStdString() << "," << from << "," << to << "," << toport << std::endl;
//		aLog << t.toStdString() << ": connection established (from='"<<from<<"',to='"<<to<<"')" << std::endl;
	}
	void connectionTerminated(const std::string& from, const std::string& to, unsigned int toport) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "CON_TERMINATED," << t.toStdString() << "," << from << "," << to << "," << toport << std::endl;
//		aLog << t.toStdString() << ": connection terminated (from='"<<from<<"',to='"<<to<<"')" << std::endl;
	}
	
	void dataSent(const std::string& from, const std::string& to, const char* , unsigned int numBytes) {
		QMutexLocker lock(&aLogMutex);
		
		QString t = QTime::currentTime().toString("hh:mm:ss.zzz");
		aLog << "DATA_SENT," << t.toStdString() << "," << from << "," << to << "," << numBytes << std::endl;
		//aLog << t.toStdString() << ": data sent (from='"<<from<<"',to='"<<to<<"',length='"<<numBytes<<"')" << std::endl;
	}
	
protected:
	QMutex aLogMutex;

	std::ofstream aLog;
};


#endif /* _EVENTLOGGER_H_ */
