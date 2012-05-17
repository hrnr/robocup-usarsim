#include "robot.h"

Robot::Robot(QString Name,double x,double y,double z,double ox,double oy,double oz,QGraphicsItem* parent) :
        UsarItem(Name,x,y,z,ox,oy,oz,parent),robot(":/robot.png")
{


}


void Robot::paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget)
{
    painter->setBrush(QBrush(Qt::black));
    painter->drawPixmap(0,0,robot.width(),robot.height(),robot);
#ifdef DEBUG
    std::cout<<"paintEvent called for a Robot"<<event->rect().height()<<","<<event->rect().width()<<std::endl;
#endif
    UsarItem::paint(painter,options,widget);
}
QRectF Robot::boundingRect() const
{
    return QRect(0,0,robot.width(),robot.height());
}

Robot::~Robot()
{

}

double Robot::Score(const victim& victim)
{
    return measureDistance(victim);
}
double Robot::measureDistance(const UsarItem& item)
{
    return sqrt((x-item.x)*(x-item.x)+(y-item.y)*(y-item.y)/*+(z-item.x)*(z-item.z)*/);
}
