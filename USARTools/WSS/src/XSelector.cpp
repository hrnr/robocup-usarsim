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

#include "XSelector.h"

#include "debug.h"

using namespace std;

XSelector::XSelector() {
}

XSelector::~XSelector() {
	
}

void XSelector::addSocket(XSocket* s) {
	if(aMaxSock < s->getFD()) {
		aMaxSock = s->getFD();
	}
	
	aSocketList.push_back(s);
}

bool XSelector::waitForRead(unsigned long msec) {
	timeval timeout;
	timeout.tv_sec = msec/1000;
	timeout.tv_usec = msec%1000 * 1000;
	
	FD_ZERO(&aREADSocketSet);

	list<XSocket*>::iterator it = aSocketList.begin();
	for(; it != aSocketList.end(); it++ ) {
		if( !(*it)->isConnected() || (*it)->getFD() == -1 ) continue;
		FD_SET( (*it)->getFD(), &aREADSocketSet );
	}

	int sel = select( aMaxSock+1,  &aREADSocketSet, NULL, NULL, &timeout );
	if( sel == -1 )
	{
		ERR( "select failed!" );
		return false;
	}
	if( sel == 0 ) {
		DBG("select timed out");
		return false;
	}
	
	return true;
}

bool XSelector::isReadyRead(XSocket* s) {
	return FD_ISSET( s->getFD(), &aREADSocketSet)>0;
}
