#include "usaritem.h"
#include <QToolTip>
UsarItem::UsarItem(QString Name,double x,double y,double z,double ox,double oy,double oz,QGraphicsItem* parent) :
        QGraphicsItem(parent),x(x),y(y),z(z),ox(ox),oy(oy),oz(oz),name(Name),binded(false)
{

}
QPoint UsarItem::centerPos()
{
    QRectF rect=boundingRect();
    QPoint center=rect.center().toPoint()+this->pos().toPoint();
    return center;
}

void UsarItem::Update(UsarItem* item)
{
    x=item->x;
    y=item->y;
    z=item->z;
    ox=item->ox;
    oy=item->oy;
    oz=item->oz;
    binded=false;
}
void UsarItem::clearFlag()
{
    binded=false;
}

void UsarItem::paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget)
{
    this->setPos(this->x*20,this->y*20);
}
void UsarItem::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    QGraphicsItem::mousePressEvent(event);
    this->setToolTip(name);
}

