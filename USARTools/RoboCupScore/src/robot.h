#ifndef ROBOT_H
#define ROBOT_H

#include <QWidget>
#include <QPaintEvent>
#include <QPainter>
#include <usaritem.h>
#include <victim.h>
#include <math.h>
#include <limits>
#include <iostream>
#include "logger.h"

#define Z_HEIGHT 0.5 //this needs to be moved out.
class Robot : public UsarItem
{
    Q_OBJECT
public:
    explicit Robot(QString Name,double x=0,double y=0,double z=0,double ox=0,double oy=0,double oz=0,QGraphicsItem *parent = 0);
    double Score(const victim& victim);
    void RecordVictim(const victim& victim);
    ~Robot();
signals:

private slots:

private:
    double measureDistance(const UsarItem&);
    QPixmap robot;
    logger* log;


protected:
   void paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget);
   QRectF boundingRect() const;
};

#endif // ROBOT_H
