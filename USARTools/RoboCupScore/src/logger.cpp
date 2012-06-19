#include "logger.h"

logger::logger(QString robotName,QObject *parent) :
    name(robotName),QObject(parent)
{
    QString fileName =robotName+" "+QDateTime::currentDateTime().toString();
    data=new QFile(fileName);
    data->open(QFile::WriteOnly);
    stream = new QTextStream(data);
}
void logger::write(QString message)
{
    *stream<<QDateTime::currentDateTime().toString()<<" "<<message<<"\r\n";
}
logger::~logger()
{
    data->close();
    delete data;
    delete stream;

}
