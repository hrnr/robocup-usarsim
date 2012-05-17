#include "usarsimlink.h"
#include <QTimer>

usarsimlink::usarsimlink(QString IP,int port,QObject *parent) :
        QObject(parent)
{
    tcpSocket=new QTcpSocket(this);
    tcpSocket->connectToHost(IP,port);
    if(!tcpSocket->isOpen())
        emit errorConnenction("Connection could not be established");

    connect(tcpSocket,SIGNAL(readyRead()),this,SLOT(pendingDataToRead()));
    timer=new QTimer(this);
    timer->setInterval(100);
    timer->start();
    connect(timer,SIGNAL(timeout()),this,SLOT(timeOut()));

}
void usarsimlink::close()
{
    timer->stop();
    tcpSocket->close();
}

void usarsimlink::timeOut()
{
    tcpSocket->write("{Actors}\r\n");
}

void usarsimlink::pendingDataToRead()
{
    QString str;
    QVector<UsarItem*> items;
    while(tcpSocket->canReadLine())
    {
        str=tcpSocket->readLine();

        QRegExp exp("\\{Name (.*)\\} \\{Class (.*)\\} \\{Time (?:.*)\\} \\{Location (.*),(.*),(.*)\\} \\{Rotation (.*),(.*),(.*)\\}");
        if(exp.indexIn(str)==0)
        {
            QStringList paramlst= exp.capturedTexts();
            UsarItem* t;
#ifdef DEBUG
            std::cout<<str.toStdString()<<std::endl;
#endif
            if(paramlst.at(2).contains("P3AT",Qt::CaseInsensitive)||paramlst.at(2).contains("Kenaf",Qt::CaseInsensitive)||paramlst.at(2).contains("AirRobot",Qt::CaseInsensitive))
            {

                t=new Robot(paramlst.at(1),paramlst.at(3).toDouble(),paramlst.at(4).toDouble(),paramlst.at(5).toDouble(),paramlst.at(6).toDouble(),paramlst.at(7).toDouble(),paramlst.at(8).toDouble());
                items.push_back(t);
            }
            else if(paramlst.at(2).contains("KAsset",Qt::CaseInsensitive)||paramlst.at(2).contains("FemaleVictim",Qt::CaseInsensitive))
            {

                t=new victim(paramlst.at(1),paramlst.at(3).toDouble(),paramlst.at(4).toDouble(),paramlst.at(5).toDouble(),paramlst.at(6).toDouble(),paramlst.at(7).toDouble(),paramlst.at(8).toDouble());
                items.push_back(t);
            }

#ifdef DEBUG
            std::cout<<"INFO: Read"<<str.toStdString()<<std::endl;

#endif
        }
    }
    emit updateditems(items);
}
