#include "XSocket.h"
#include "XServer.h"
#include "XSelector.h"
#include "Message.h"
#include "StringUtils.h"

#include <sys/time.h>
#include <stdlib.h>

#include <string>
#include <iostream>
#include <list>
#include <csignal>
using namespace std;
using namespace StringUtils;

bool gKeepRunning = true;

void catch_sig(int) {
	if(gKeepRunning) {
		gKeepRunning = false;
		cerr << "quitting. ctr-c again to terminate" << endl;
	} else {
		exit(10);
	}
}

string sendAndReceive(XSocket& sock, string message) {
	sock.send(message);
	cout << "SEND:     '"+message+"'" << endl;

	int ret;
	if( (ret = sock.receive(message, 1000)) > 0 ) {
		cout << "RECEIVED: '"+message+"'" << endl;
		return message;
	} else {
		cerr << "ERROR! returned " << ret << endl;
		exit(1);
	}
}

int main (int argc, char *argv[])
{
	if(argc != 6) {
		cerr << "usage: " << argv[0] << " <wssip> <wssport> <robotname> <otherrobotname> <listen?>" << endl;
		exit(0);
	}

	signal(SIGINT,catch_sig);

	string wssip = argv[1];
	unsigned int wssport = atoi(argv[2]);
	string robot1 = argv[3];
	string robot2 = argv[4];
	bool listen = strcmp(argv[5],"true") == 0;

	string message;

	XSocket controlconn;
	controlconn.connect(wssip, wssport);
	if(!controlconn.isConnected()) {
		cerr << "couldn't connect to wss!" << endl;
		return 1;
	}

	XServer server;
	server.listen(3333);

	sendAndReceive(controlconn,"INIT {Robot "+robot1+"} {Port "+stringify(server.getLocalPort())+",2323,223}");

	sleep(1);

	//while(1) {
		message = sendAndReceive(controlconn,"GETSS {Robot "+robot2+"}");
	//	sleep(1);
	//}

	if(!listen) {
		XSocket connToOther;

		message = sendAndReceive(controlconn,"DNS {Robot "+robot2+"}");
		
		
		Message *m = Message::parse(message);
		unsigned int otherPort = unstringify<unsigned int>(m->getValue("Port"));
		delete m;
		
		cout << "connecting to " << robot2 << " on port " << otherPort << endl;
		connToOther.connect(wssip, otherPort);

		if(!connToOther.isConnected()) {
			cerr << "Connection currently not possible, out of range?" << endl;
			return 0;
		}

		string test = "This is a test!";

		unsigned int count = 0;
		for(int i=0; i<1; i++) {
			string testtmp = test+stringify(count++);
			
			cerr << "sending '" << testtmp << "'" << endl;
			int ret = connToOther.send(testtmp);
			if(ret<=0){
				cerr << "ERROR!" << endl;
				break;
			}
		}
		
		sleep(1);
		
		connToOther.disconnect();
		
	} else {


		while(gKeepRunning) {
			cout << "accepting..." << flush;
			XSocket* otherSock = server.accept(120000);
		
			if(otherSock == NULL) {
				cout << "ERROR: no connection" << endl;
				continue;
			}
		
			cout << "accepted!" << endl;
		
			sendAndReceive(controlconn,"REVERSEDNS {Port "+stringify(otherSock->getRemotePort())+"}");
			message = sendAndReceive(controlconn,"GETSS {Robot "+robot2+"}");

			while( otherSock->isConnected() ) {
				string buf;
				otherSock->receive(buf,100);
				cout << "read: " << buf << endl;
			}
			
			delete otherSock;
		}
	}

	return 0;
}
