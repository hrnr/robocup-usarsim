#include "XSocket.h"
#include "XServer.h"
#include "Message.h"
#include "StringUtils.h"

#include <sys/time.h>
#include <stdlib.h>

#include <string>
#include <iostream>
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

unsigned int gWSSPort;
string gWSSIP;
string gOtherRobotName;

void startClient(int count, int maxcount) {
	if(count >= maxcount) return;
	
	string message;
	string robot = "robot"+stringify(count);

	XSocket controlconn;
	controlconn.connect(gWSSIP, gWSSPort);
	if(!controlconn.isConnected()) {
		cerr << "couldn't connect to wss!" << endl;
		return;
	}

	sendAndReceive(controlconn,"INIT {Robot "+robot+"} {Port 10}");

//	usleep(2000);

	XSocket connToOther;

	message = sendAndReceive(controlconn,"DNS {Robot "+gOtherRobotName+"}");
	
	
	Message *m = Message::parse(message);
	unsigned int otherPort = unstringify<unsigned int>(m->getValue("Port"));
	delete m;
	
	cout << "connecting to " << gOtherRobotName << " on port " << otherPort << endl;
	connToOther.connect(gWSSIP, otherPort);

	if(!connToOther.isConnected()) {
		cerr << "Connection currently not possible, out of range?" << endl;
		return;
	}
	
	connToOther.send("Hello from "+robot);
	
//	startClient(count+1, maxcount);
}

int main (int argc, char *argv[])
{
	if(argc != 4) {
		cerr << "usage: " << argv[0] << " <wssip> <wssport> <otherrobotname>" << endl;
		exit(0);
	}

	signal(SIGINT,catch_sig);

	gWSSIP = argv[1];
	gWSSPort = atoi(argv[2]);
	gOtherRobotName = argv[3];


	for(int i=100; i<200; i++) {
		startClient(i,9999999);
	}


	return 0;
}
