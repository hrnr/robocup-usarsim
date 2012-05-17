#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "usarsimlink.h"
//#define DEBUG
#include <QGraphicsProxyWidget>
#include <QString>
#include <QFile>
MainWindow::MainWindow(QWidget *parent) :
        QMainWindow(parent),
        ui(new Ui::MainWindow),time(0)
{

    ui->setupUi(this);

    connect(ui->btnConnect,SIGNAL(clicked()),this,SLOT(connect_clicked()));
    scene=new QGraphicsScene(this);
    ui->graphicsView->setScene(scene);
    timer=new QTimer(this);
    timer->setInterval(1000);

    connect(timer,SIGNAL(timeout()),this,SLOT(timer_ticked()));
    connect (this,SIGNAL(updateScore()),this,SLOT(updateScore_slot()));
    connect(this,SIGNAL(changeState(RunMode)),this,SLOT(on_changeState(RunMode)));
    emit changeState(MainWindow::STOP);
    QIcon ZInico(":/zoom_in.png");
    ui->btnZoom->setIcon(ZInico);
    QIcon ZOutico(":/zoom_out.png");
    ui->btnZoomOut->setIcon(ZOutico);
    QPixmap rVict(":/victim.png");
    ui->lblVict->setPixmap(rVict);
    QPixmap Vict(":/victimR.png");
    ui->lblRVict->setPixmap(Vict);



}

MainWindow::~MainWindow()
{
    delete ui;

}
void MainWindow::timer_ticked()
{
    if(time==0)
    {
        emit changeState(MainWindow::STOP);
        return;
    }
    time--;
    QString a;
    a=a.setNum(time);
    ui->lblTimeRes->setText(a);
}

void MainWindow::connect_clicked()
{
    usarLink=new usarsimlink(ui->txtIP->text(),ui->txtPort->text().toInt(),this);
    connect(usarLink,SIGNAL(updateditems(QVector<UsarItem*>)),this,SLOT(updateditems(QVector<UsarItem*>)));
}
void MainWindow::updateditems(QVector<UsarItem *> items)
{
    QVector<UsarItem*>::iterator iter=items.begin();
    for(QMap<QString,Robot*>::iterator i=robots.begin();i!=robots.end();i++)
    {
        i.value()->binded=false;
    }
    for(QMap<QString,victim*>::iterator i=victims.begin();i!=victims.end();i++)
    {
        i.value()->binded=false;
    }
    for(;iter<items.end();iter++)
    {
        if (typeid(**iter).name()==typeid(Robot).name())
        {
            Robot* r=dynamic_cast<Robot*>(*iter);
            QMap<QString,Robot*>::iterator Olditer=robots.find(r->name);
            if(Olditer==robots.end())
            {
                robots.insert(r->name,r);
                scene->addItem(r);
            }
            else
            {
                Olditer.value()->Update(r);
                delete *iter;

                continue;
            }
        }
        if (typeid(**iter).name()==typeid(victim).name())
        {
            victim* v=dynamic_cast<victim*>(*iter);
            QMap<QString,victim*>::iterator Olditer=victims.find(v->name);
            if(Olditer==victims.end())
            {
                victims.insert(v->name,v);
                scene->addItem(v);
            }
            else
            {
                Olditer.value()->Update(v);
                delete *iter;
                continue;
            }
        }
    }
    int vSize=victims.size();
    int rSize=robots.size();
    while(vSize>0&&rSize>0)
    {
        double score=std::numeric_limits<double>::max();
        Robot* nRobot=0;
        int rIndex=0;
        victim* nVict=0;
        int vIndex=0;
        int srIndex=0,svIndex=0;

        for(QMap<QString,victim*>::iterator vIter=victims.begin();vIter!=victims.end();vIter++)
        {
            if(vIter.value()->binded)
            {

                continue;
            }
            rIndex=0;
            for(QMap<QString,Robot*>::iterator rIter=robots.begin();rIter!=robots.end();rIter++)
            {
                if(rIter.value()->binded)
                {
                    continue;
                }

                double nScore=(*rIter)->Score((**vIter));
#ifdef DEBUG
                std::cout<<"INFO: Score between "<<(*rIter)->name.toStdString()<<" and "<<(*vIter)->name.toStdString()<<" is "<<nScore<<std::endl;
#endif
                if(nScore<score)
                {
                    score=nScore;
                    nRobot=rIter.value();
                    nVict=vIter.value();
                    svIndex=vIndex;
                    srIndex=rIndex;

                }

                rIndex++;
            }
            vIndex++;
        }
#ifdef DEBUG
        std::cout<<"INFO: Removing "<<std::endl;
#endif
        QMap<QString,bundle*>::iterator bIter= bundles.find(nRobot->name);
        bundle* bndl;
        if(bIter==bundles.end())
        {
            bndl=new bundle(nRobot,nVict,score);
            nRobot->binded=true;
            nVict->binded=true;
            scene->addItem(bndl);
            bundles.insert(nRobot->name,bndl);
        }
        else
        {
            nRobot->binded=true;
            nVict->binded=true;
            bIter.value()->updateBundle(nVict,score);
            bndl=bIter.value();
        }
        vSize--;
        rSize--;
    }
#ifdef DEBUG
    std::cout<<"INFO: Reporting Bundles between "<<std::endl;
    QMap<QString,bundle*>::iterator bIter= bundles.begin();
    for(;bIter!=bundles.end();bIter++)
        std::cout<<"INFO: Bundle between "<<bIter.value()->getRobotName().toStdString()<<" and "<<bIter.value()->getVictimName().toStdString()<<" with score "<<bIter.value()->getScore()<<std::endl;
#endif

    scene->update();
    emit updateScore();
}

void MainWindow::on_btnZoom_clicked()
{
    ui->graphicsView->scale(1.4,1.4);

}

void MainWindow::on_btnZoomOut_clicked()
{
    ui->graphicsView->scale(1/1.4,1/1.4);
}
void MainWindow::initialize()
{
    time=maxTime=ui->txtTimer->text().toInt()*60;
    operators=ui->txtOperators->text().toInt();
    threshold=ui->txtThreshold->text().toDouble();
}

void MainWindow::on_btnStart_clicked()
{
    if(mod==MainWindow::STOP)
    {
        initialize();
        emit changeState(MainWindow::PLAY);

    }
    else if(mod==MainWindow::PLAY)
    {
        emit changeState(MainWindow::PAUSE);
    }
    else if(mod==MainWindow::PAUSE)
    {
        emit changeState(MainWindow::PLAY);

    }
}
void MainWindow::updateScore_slot()
{
    int nRescued=0;

    QMap<QString,bundle*>::iterator Ibundle=bundles.begin();
    for(;Ibundle!=bundles.end();Ibundle++)
    {
        if (Ibundle.value()->getScore()<threshold)
        {
            nRescued++;
            Ibundle.value()->setCompleted(true);
        }
    }

    double finalScore=50*(((double)nRescued)/victims.size()+(1-(maxTime-(double)time)/maxTime))/(operators*operators);
    QString scoreS;
    scoreS=QString::number(finalScore,'f',0);
    ui->lblScoreRes->setText(scoreS);
    ui->lblVictCount->setText(QString::number(victims.size()-nRescued));
    ui->lblRVictCount->setText(QString::number(nRescued));
}
void MainWindow::on_changeState(RunMode nMode)
{
    if(nMode==MainWindow::STOP)
    {
        timer->stop();
        mod=MainWindow::STOP;
        //ui->btnStart->setText("Play");
        //ui->btnStop->setText("Stop");
        ui->btnStop->setEnabled(false);
        QIcon Pico(":/play.png");
        ui->btnStart->setIcon(Pico);
        QIcon Sico(":/stop.png");
        ui->btnStop->setIcon(Sico);
    }
    else if(nMode==MainWindow::PLAY)
    {

        timer->start();
        mod=MainWindow::PLAY;
        //ui->btnStart->setText("Pause");
        //ui->btnStop->setText("Stop");
        ui->btnStop->setEnabled(true);
        QIcon Pico(":/pause.png");
        ui->btnStart->setIcon(Pico);
        QIcon Sico(":/stop.png");
        ui->btnStop->setIcon(Sico);
    }
    else if(nMode==MainWindow::PAUSE)
    {
        timer->stop();
        mod=MainWindow::PAUSE;
        //ui->btnStart->setText("Play");
        //ui->btnStop->setText("Stop");
        ui->btnStop->setEnabled(true);
        QIcon Pico(":/play.png");
        ui->btnStart->setIcon(Pico);
        QIcon Sico(":/stop.png");
        ui->btnStop->setIcon(Sico);
    }
}

void MainWindow::on_btnStop_clicked()
{
    emit changeState(MainWindow::STOP);
}
