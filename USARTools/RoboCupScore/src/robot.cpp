#include "robot.h"

Robot::Robot(QString Name,double x,double y,double z,double ox,double oy,double oz,QGraphicsItem* parent) :
    UsarItem(Name,x,y,z,ox,oy,oz,parent),robot(":/robot.png")
{
    log=new logger(Name,this);

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
    if(abs((z-victim.x)*(z-victim.z))<Z_HEIGHT)
        return measureDistance(victim);
    else
        return std::numeric_limits<double>::max();
}
void Robot::RecordVictim(const victim& victim)
{
    log->write(victim.name);
}

double Robot::measureDistance(const UsarItem& item)
{
    return sqrt((x-item.x)*(x-item.x)+(y-item.y)*(y-item.y));
}
