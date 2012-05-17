#include "victim.h"
#include <QPainter>
#include <QPaintEvent>
#include <QPixmap>
#include <QFile>
victim::victim(QString Name,double x,double y,double z,double ox,double oy,double oz,QGraphicsItem *parent) :
        UsarItem(Name,x,y,z,ox,oy,oz,parent),rescued(false),RescueV(":/victimR.png"),V(":/victim.png")
{




}
void victim::paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget)
{


    if(rescued)
    {
        painter->setBrush(QBrush(Qt::green));
        painter->drawPixmap(0,0,RescueV.width(),RescueV.height(),RescueV);
    }
    else
    {
        painter->setBrush(QBrush(Qt::red));
        painter->drawPixmap(0,0,RescueV.width(),RescueV.height(),V);
    }

#ifdef DEBUG
    std::cout<<"paintEvent called"<<event->rect().height()<<","<<event->rect().width()<<std::endl;
#endif
    UsarItem::paint(painter,options,widget);
}
QRectF victim::boundingRect() const
{

    return QRectF(0,0,RescueV.width(),RescueV.height());
}
void victim::setRescued(bool rescued)
{
    this->rescued=rescued;
}
bool victim::Rescued()
{
    return rescued;
}
