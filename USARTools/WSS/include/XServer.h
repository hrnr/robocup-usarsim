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

#ifndef XSERVER_H_
#define XSERVER_H_

#include "XSocket.h"

class XServer : public XSocket
{
protected:

	virtual XSocket* newXSocket(int);
	virtual void createSocket();
	
public:
	XServer();
	virtual ~XServer();
	
	/// args: port==0 means any port, can later be queried by getLocalPort()
	virtual void listen(unsigned int /* port */ = 0, int /* allowedQueuedConnections */ = 10);
	
	virtual XSocket* accept(unsigned int /* timeout */);
};

#endif /*XSERVER_H_*/
