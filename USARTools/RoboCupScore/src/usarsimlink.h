#ifndef USARSIMLINK_H
#define USARSIMLINK_H

#include <QObject>
#include <QTcpSocket>
#include <QRegExp>
#include <QStringList>
#include "robot.h"
#include "usaritem.h"
class usarsimlink : public QObject
{
    Q_OBJECT
public:
    explicit usarsimlink(QString IP,int port,QObject *parent = 0);
    void close();

signals:
    void updateditems(QVector<UsarItem*> items);
    void errorConnenction(QString connError);
private slots:
    void pendingDataToRead();
    void timeOut();
private:
    QTcpSocket *tcpSocket;
    QTimer* timer;
};

#endif // USARSIMLINK_H
