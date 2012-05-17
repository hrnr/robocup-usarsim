#ifndef USARITEM_H
#define USARITEM_H

#include <QWidget>
#include <QFrame>
#include <QGraphicsItem>
class UsarItem :public QObject, public QGraphicsItem
{
    Q_OBJECT
    Q_INTERFACES(QGraphicsItem)
public:
    explicit UsarItem(QString Name,double x=0,double y=0,double z=0,double ox=0,double oy=0,double oz=0,QGraphicsItem* parent = 0);
    void Update(UsarItem* item);
    QPoint centerPos();
    double x;
    double y;
    double z;
    double ox;
    double oy;
    double oz;
    QString name;
    bool binded;
    void clearFlag();

signals:

public slots:

protected:
    void paint(QPainter* painter,const QStyleOptionGraphicsItem* options,QWidget* widget);
    void mousePressEvent(QGraphicsSceneMouseEvent *event);

};

#endif // USARITEM_H
