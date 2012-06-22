#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

class logger : public QObject
{
    Q_OBJECT
public:
    explicit logger(QString robotName,QObject *parent = 0);
    void write(QString message);
    ~logger();
signals:
    
public slots:

private:
    QString name;
    QTextStream* stream;
    QFile* data;
};

#endif // LOGGER_H
