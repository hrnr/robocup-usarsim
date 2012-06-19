#include "bundle.h"

bundle::bundle(Robot* robot,victim* victim,double score,QGraphicsItem* parent) :
        QGraphicsItem(parent), robot(robot),vict(victim),score(score)

{

}
bundle::bundle()
{

}
void bundle::updateBundle(victim* vict,double score)
{
    this->setToolTip(this->getRobotName()+" is near "+this->getVictimName()+"\nDistance:"+QString::number(this->score,'f',2));

    this->score=score;
    int x=0;
    this->vict->setRescued(false);
    this->vict=vict;
    if (robot->centerPos().x()<vict->centerPos().x())
        x=robot->centerPos().x();
    else
        x=vict->centerPos().x();

    int width=abs(robot->centerPos().x()-vict->centerPos().x());
    int y=0;
    if (robot->centerPos().y()<vict->centerPos().y())
        y=robot->centerPos().y();
    else
        y=vict->centerPos().y();
    int height=abs(robot->centerPos().y()-vict->centerPos().y());
    this->setPos(x,y);
    this->width=width;
    this->height=height;
    this->x=x;
    this->y=y;
    this->update();
    this->prepareGeometryChange();
}
QString bundle::getRobotName()
{
    return robot->name;
}
QString bundle::getVictimName()
{
    return vict->name;
}
double bundle::getScore()
{
    return score;
}

void bundle::paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget)
{
    painter->setRenderHint(QPainter::Antialiasing);
    painter->setBrush(QBrush(Qt::red));
    if((robot->centerPos().x()<vict->centerPos().x()&&robot->centerPos().y()<vict->centerPos().y())||(robot->centerPos().x()>vict->centerPos().x()&&robot->centerPos().y()>vict->centerPos().y()))
        painter->drawLine(0,0,this->width,this->height);
    else
        painter->drawLine(0,this->height,this->width,0);
#ifdef DEBUG
    std::cout<<"INFO: Update Bundle "<<robot->name.toStdString()<<std::endl;
#endif
}
QRectF bundle::boundingRect() const
{
    return QRect(0,0,this->width,this->height);
}
void bundle::setCompleted(bool res)
{
    if(res==true)
    {
        vict->setRescued(res);
        robot->RecordVictim(*vict);
    }
}
