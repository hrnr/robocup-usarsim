#include "victim.h"
#include <QPainter>
#include <QPaintEvent>
#include <QPixmap>
#include <QFile>
victim::victim(QString Name,double x,double y,double z,double ox,double oy,double oz,QGraphicsItem *parent) :
    UsarItem(Name,x,y,z,ox,oy,oz,parent),rescued(false),RescueV(":/victimR.png"),V(":/victim.png"),range(10)
{




}
void victim::setAcceptanceThreshold(float range_thresh)
{

    if(this->range!=range_thresh)
    {
        this->range=range_thresh;

    }
}

float victim::getAcceptanceThreshold()
{

    return this->range;
}
void victim::Update(UsarItem* item)
{

    victim* v=dynamic_cast<victim*>(item);
    setAcceptanceThreshold(v->getAcceptanceThreshold());
    UsarItem::Update(item);
}

void victim::paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget)
{
    QRectF rec= boundingRect();
    int x=rec.width()/2;
    int y=rec.height()/2;
    if(rescued)
    {
        painter->setBrush(QBrush(QColor(0,255,0,100)));
        painter->setPen(Qt::NoPen);
        painter->drawEllipse(x-range*scale/2,y-range*scale/2,range*scale,range*scale);
        painter->drawPixmap(0,0,RescueV.width(),RescueV.height(),RescueV);
    }
    else
    {
        painter->setBrush(QBrush(QColor(255,0,0,100)));
        painter->setPen(Qt::NoPen);
        painter->drawEllipse(x-range*scale/2,y-range*scale/2,range*scale,range*scale);
        painter->drawPixmap(x-V.width()/2,y-V.height()/2,V.width(),V.height(),V);
    }

#ifdef DEBUG
    std::cout<<"paintEvent called"<<event->rect().height()<<","<<event->rect().width()<<std::endl;
#endif
    UsarItem::paint(painter,options,widget);
}
QRectF victim::boundingRect() const
{
    int r=(int)(range*scale);
    return QRectF(0,0,std::max(2*r,RescueV.width()),std::max(2*r,RescueV.height()));
}
void victim::setRescued(bool rescued)
{
    this->rescued=rescued;
}
bool victim::Rescued()
{
    return rescued;
}
