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

#include "Message.h"


#include <sstream>
#include <deque>

using namespace std;
Message::Message(const std::string& pType) {
	aType = pType;
}

const std::string& Message::getType() {
	return aType;
}

const std::string& Message::getValueConstRef(const std::string& pKey) {
	return aMainSegment[pKey];
}

std::string& Message::getValueRef(const std::string& pKey) {
	return aMainSegment[pKey];
}

std::string Message::getValue(const std::string& pKey) {
	return aMainSegment[pKey];
}

bool Message::hasValue(const std::string& pKey) {
	return aMainSegment.find(pKey)!=aMainSegment.end();
}


const Segment& Message::getSegment(const int& pIndex) {
	return aSegments[pIndex];
}

int Message::getNumberOfSegments() {
	return aSegments.size();
}


void Message::addSegment(Segment& pSegment) {
	aSegments.push_back(pSegment);
}

void Message::addMainSegment(const std::string& pKey, const std::string& pValue) {
	aMainSegment[pKey] = pValue;
}


bool Message::isConfMessage() {
    return aType == "CONF";
}
bool Message::isSensorMessage() {
    return aType == "SEN";
}
bool Message::isResponseMessage() {
    return aType == "RES";
}
bool Message::isStatusMessage() {
    return aType == "STA";
}
bool Message::isStatusOK() {
	Segment::iterator pos = aMainSegment.find("Status");
	if(pos!=aMainSegment.end() && (*pos).second == "OK")
	return true;
		return false;
}
bool Message::isStatusFail() {
    Segment::iterator pos = aMainSegment.find("Status");
	if(pos!=aMainSegment.end() && (*pos).second == "FAILED")
	return true;
		return false;
}


void Message::print(std::ostream& out) {
	out <<"Type: "<< getType() << endl;
	
	for(Segment::const_iterator it = aMainSegment.begin(); it != aMainSegment.end(); ++it) {
		out << (*it).first << " -> " << (*it).second << endl;
	}
	
	int nSeg = getNumberOfSegments();
	for(int i=0; i<nSeg; i++) {
		const Segment& s = getSegment(i);
		
		for(Segment::const_iterator it = s.begin(); it!=s.end(); ++it) {
			out << "seg " << i << " " << (*it).first << " -> " << (*it).second << endl;
		}
	}
}

std::string Message::serialize() const {
	ostringstream stream;
	
	stream << aType << " ";
	
	for(Segment::const_iterator it = aMainSegment.begin(); it != aMainSegment.end(); ++it) {
		stream << "{" << (*it).first << " " << (*it).second << "} ";
	}
	
	ostringstream segStream;
	for(vector<Segment>::const_iterator it = aSegments.begin(); it != aSegments.end(); ++it) {
		stream << "{";
		
		segStream.str("");
		
		for(Segment::const_iterator jt = (*it).begin(); jt != (*it).end(); ++jt) {
			segStream << (*jt).first << " " << (*jt).second << " ";
		}
		string seg = segStream.str();
		seg.erase(seg.size()-1,1);
		
		stream << seg << "} ";
	}
	
	string ret = stream.str();
	ret.erase(ret.size()-1,1);
	
	return ret;
}

Message* Message::parse(const string& pString) {
//  cout<<pString<<endl;
	if(pString.size() == 0)
		return NULL;
  //cout<<pString<<endl;
	char* start = (char *)pString.c_str();
	char* current=start;
	char* end = start+pString.size();
	
	deque<string> strQueue;
	
	while(*start != ' ')
		start++;
	
	Message* msg = new Message(string(pString.c_str(),start-pString.c_str()));
	
	start++;
	
	while(start < end && *start == '{') {
		start++;
		current = start;
		strQueue.clear();
		
		while(1) {
			while(*current != ' ' && *current != '}' && current < end)
				current++;
			
			//cout << "parsed: " << string(start,current-start) << endl;
			
			strQueue.push_back(string(start,current-start));
			current++;
			start = current;
			
			if(*(current-1) == '}' || current == end)
				break;
		}
		
		start++;
		//cout<<"strqueueu size was "<<strQueue.size()<<endl;	
		
		string type = msg->getValueRef("Type");
		string msgType = msg->getType();
		if(strQueue.size()==1) {
			msg->addMainSegment(strQueue.front(), "");
		} else if((strQueue.size() == 2) && !( ( (msgType=="MISSTA") || (type=="RFID") || (type=="VictRFID") || (type=="VictSensor")) && !(strQueue.front()=="Name") ) ) {
			msg->addMainSegment(strQueue.front(), strQueue.back());
		} else {
			Segment s;
			string k,v;
			
			while(!strQueue.empty()) {
				k = strQueue.front();
				strQueue.pop_front();
				
				if(strQueue.size()!=0) {
					v = strQueue.front();
					strQueue.pop_front();
				}
				
				s[k]=v;
			}
			
			msg->addSegment(s);
		}
	}
	
	return msg;
}
