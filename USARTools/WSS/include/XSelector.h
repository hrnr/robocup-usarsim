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

#ifndef _XSELECTOR_H_
#define _XSELECTOR_H_

#include <list>

#include "XSocket.h"

/**
*	class to wrap a "select" call for multiple XSockets at once
*/
class XSelector {
public:
	
	XSelector();
	~XSelector();
	
	void addSocket(XSocket*);
	
	bool waitForRead(unsigned long);
	
	bool isReadyRead(XSocket*);
	
private:
	
	std::list< XSocket* > aSocketList;
#ifndef __IS_WINDOWS__
	int aMaxSock;
#else
	unsigned int aMaxSock;
#endif
	
	fd_set aREADSocketSet;
};

#endif /* _XSELECTOR_H_ */
