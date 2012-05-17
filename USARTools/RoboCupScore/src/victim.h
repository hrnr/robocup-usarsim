#ifndef VICTIM_H
#define VICTIM_H

#include <usaritem.h>
#include <iostream>
class victim : public UsarItem
{
public:
    victim(QString Name,double x=0,double y=0,double z=0,double ox=0,double oy=0,double oz=0,QGraphicsItem* parent = 0);
    void setRescued(bool rescued);
    bool Rescued();
protected:
    void paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget);
    QRectF boundingRect() const;

private:
   bool rescued;
   QPixmap RescueV;
   QPixmap V;
};

#endif // VICTIM_H
