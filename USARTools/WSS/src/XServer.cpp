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

#include "XServer.h"
#include "debug.h"


XServer::XServer()
	: XSocket()
{
}

XServer::~XServer()
{
}

void XServer::createSocket() {
	XSocket::createSocket();
	
	// make sure that we can reopen previously opened ports again
#ifndef __IS_WINDOWS__
	int yes=1;
	if (setsockopt(sockfd,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(int)) == -1) {
#else
	BOOL yes = TRUE;
	if (setsockopt(sockfd,SOL_SOCKET,SO_REUSEADDR,(char*)&yes,sizeof(BOOL)) == -1) {
#endif
		aIsConnected = false;
		ERR("Couldn't set sockopt SO_REUSEADDR. %s", lastError().c_str());
	}
}

void XServer::listen(unsigned int port, int allowedQueuedConnections)
{
	if( sockfd == -1 )
		createSocket();
	
	remoteAddr.sin_family = AF_INET;         // host byte order
	if(port == 0 && localAddrInitialized) {
		remoteAddr.sin_port = localAddr.sin_port;
	} else {
    	remoteAddr.sin_port = htons(port);     // short, network byte order
	}
    remoteAddr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
	
	localAddrInitialized = false;
	
	// re? bind
    if ( ::bind(sockfd, (sockaddr *)&remoteAddr, sizeof(remoteAddr)) == -1) {
		aIsConnected = false;
		ERR("Couldn't bind to port. %s", lastError().c_str());
        return;
    }

    if ( ::listen(sockfd, allowedQueuedConnections) == -1) {
		aIsConnected = false;
		ERR("Couldn't start listening. %s", lastError().c_str());
        return;
    }
	aIsConnected = true;
}

// default XSocket implementation, overrideable
XSocket* XServer::newXSocket(int descriptor)
{
	XSocket* ret = new XSocket(descriptor);
	
	return ret;
}

XSocket* XServer::accept(unsigned int msec)
{
	fd_set sock_set;
	FD_ZERO(&sock_set);
	FD_SET( sockfd, &sock_set);
	timeval timeout;
	timeout.tv_sec = msec/1000;
	timeout.tv_usec = msec%1000 * 1000;
	
	int sel = select( sockfd+1,  &sock_set, NULL, NULL, &timeout );
	if( sel == -1 )
	{
		aIsConnected = false;
		ERR("Couldn't wait for new connection: %s", lastError().c_str());
        return NULL;
	}

	if( sel == 0 ) {
		//ERR(("XServer: nothing to accept ");
		return NULL; // nothing to accept
    }
        
		
	int newSock = 0;
	sockaddr_in their_addr;

#ifndef __IS_WINDOWS__
	socklen_t sin_size = sizeof(sockaddr_in);
	if ((newSock = ::accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == -1) {
#else
	int sin_size = sizeof(sockaddr_in);
	if ((newSock = ::WSAAccept(sockfd, (struct sockaddr *)&their_addr, &sin_size, NULL, NULL)) == -1) {
#endif
		aIsConnected = false;
		ERR("Couldn't accept new connection: %s", lastError().c_str());
        return NULL;
	}
    
    //std::cerr<<"XServer: accepted a connection!\n";    
	return newXSocket(newSock);
	
}
