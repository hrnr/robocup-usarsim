#ifndef _EVENTLISTENER_H_
#define _EVENTLISTENER_H_

#include <string>
#include <vector>

class EventListener {
public:
	virtual ~EventListener() {}
	
	virtual void robotRegistered(const std::string& name, const std::string& ip, const std::vector<unsigned int>& listenports) = 0;
	virtual void robotDeregistered(const std::string& name) = 0;
	
	virtual void robotOutOfBattery(const std::string& name) = 0;
	
	virtual void connectionOutOfRange(const std::string& from, const std::string& to, double sigStrength, double distance) = 0;
	virtual void connectionInRange(const std::string& from, const std::string& to) = 0;
	
	virtual void connectionEstablished(const std::string& from, const std::string& to, unsigned int toport) = 0;
	virtual void connectionTerminated(const std::string& from, const std::string& to, unsigned int toport) = 0;
	
	virtual void dataSent(const std::string& from, const std::string& to, const char* bytes, unsigned int numBytes) = 0;
};

#endif /* _EVENTLISTENER_H_ */
