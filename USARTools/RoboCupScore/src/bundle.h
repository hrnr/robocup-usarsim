#ifndef BUNDLE_H
#define BUNDLE_H

#include <QWidget>
#include "robot.h"
#include "victim.h"
class bundle:public QObject,public QGraphicsItem
{
 Q_OBJECT
 Q_INTERFACES(QGraphicsItem)
public:
    explicit bundle(Robot* robot,victim* victim,double score=0,QGraphicsItem* parent = 0);
    bundle();
    void updateBundle(victim* vict,double score);
    double getScore();
    QString getRobotName();
    QString getVictimName();
    void setCompleted(bool=true);
private:
    Robot* robot;
    victim* vict;
    double score;
    double width,height;
    int x,y;
protected:
    void paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget);
    QRectF boundingRect() const;
};

#endif // BUNDLE_H
