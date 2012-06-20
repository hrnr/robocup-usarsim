#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <usaritem.h>
#include <usarsimlink.h>
#include <typeinfo>
#include <victim.h>
#include <limits>
#include <bundle.h>
#include <QTimer>
#include <QMap>
namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    enum RunMode{PLAY =1,PAUSE=2,STOP=0};
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
private:
    Ui::MainWindow *ui;
    usarsimlink* usarLink;
    void showBundles();
    void initialize();
    int time,maxTime;
    QTimer* timer;
    QGraphicsScene* scene;
    double threshold;
    int operators;
    RunMode mod;
    QMap<QString,Robot*> robots;
    QMap<QString,victim*> victims;
    QMap<QString,bundle*> bundles;
private slots:
    void on_btnStop_clicked();
    void on_btnStart_clicked();
    void on_btnZoomOut_clicked();
    void on_btnZoom_clicked();
    void connect_clicked();
    void timer_ticked();
    void updateditems(QVector<UsarItem*> items);
    void updateScore_slot();
    void on_changeState(RunMode);
signals:
    void updateScore();
    void changeState(RunMode);
};

#endif // MAINWINDOW_H
