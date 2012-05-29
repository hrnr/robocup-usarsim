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

#ifndef MESSAGE_H_
#define MESSAGE_H_

#include <string>
#include <map>
#include <vector>
#include <ostream>
#include <iostream>

typedef std::map<std::string,std::string> Segment;

/**
	generic message object containing the complete usarsim message structure
	
	Example message:
	
	SEN {Time 240.1} {Type Sonar} {Name F1 Range 3.2} {Name F2 Range 4.2}
	
	The message consists of a message type (here SEN) and one or more segments contained in {} and seperated by a space.
	Each segment itself consists of one or more Name-Value pairs, separated by a space.
	
	Segment is a typedef for std::map<std::string,std::string>.
*/
class Message {

public:
	/// constructor, given the message type
	Message(const std::string&);

	/// returns the message type
	const std::string& getType();
	/// get a const ref to a value of a single name-value segment by name (like {Type Sonar} above)
	const std::string& getValueConstRef(const std::string&);
	/// get a non-const ref, see getValueConstRef()
	std::string& getValueRef(const std::string&);
	/// get copy of value, see getValueConstRef()
	std::string getValue(const std::string&);
	/// checks if a single name-value segment with given name exists
	bool hasValue(const std::string&);
	
	/// for segments with multiple name-value pairs, get the i-th one.
	const Segment& getSegment(const int&);
	/// get the number of segments with multiple name-value pairs. Segment is a typedef for std::map<std::string,std::string>.
	int getNumberOfSegments();
	
	/// add a new segment with multiple name-value pairs
	void addSegment(Segment&);
	/// add a new single name-value segment, i.e. a normal name-value pair accessible directly
	void addMainSegment(const std::string&, const std::string&);
	
	/// checks if getType() == CONF
	bool isConfMessage();
	/// checks if getType() == SEN
	bool isSensorMessage();
	/// checks if getType() == RES
	bool isResponseMessage();
	/// checks if getType() == STA
	bool isStatusMessage();
	/// checks if a status name-value pair exists and if the value is OK
	bool isStatusOK();
	/// checks if a status name-value pair exists and if the value is FAIL
	bool isStatusFail();
	
	void print(std::ostream&);

	/// static helper to construct a Message object from its string representation
	static Message* parse(const std::string&);
	/// can turn this Message object into its string form, maybe for sending to the server
	std::string serialize() const;
	
private:
	/// the type of this message, like SEN or RES or GETCONF, etc.
	std::string aType;
	
	/// A "segment" containing all single name-value segments
	Segment aMainSegment;
	/// vector of segments with multiple name-value pairs
	std::vector<Segment> aSegments;
};
#endif //MESSAGE_H_
