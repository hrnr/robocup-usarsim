/*
Copyright (C) 2008 Jacobs University

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


#include <QDir>
#include <QPluginLoader>
#include <QSortFilterProxyModel>
#include <QtDebug>

#include "MainWindow.h"

#include "NoopPropagationModel.h"


using namespace std;

MainWindow::MainWindow(RobotConnectionManager* man, QWidget* parent)
	: QWidget(parent), aManagerIncomingAdapter(man), aManagerEstablishedAdapter(man), aManagerRobotAdapter(man)
{
	aManager = man;
	
	setupUi(this);
	
	portEdit->setText( QString::number( aManager->getListenPort() ) );
	
	loadModels();
	
	connect(chooseModelBox,       SIGNAL(activated(int)),     this, SLOT(modelChanged(int))          );
	connect(startStopButton,      SIGNAL(clicked()),          this, SLOT(startStopManager())         );
	connect(configureModelButton, SIGNAL(clicked()),          this, SLOT(configureModel())           );
	connect(portEdit,             SIGNAL(editingFinished()),  this, SLOT(portChanged())              );
	connect(loggingCheck,         SIGNAL(stateChanged(int)),  this, SLOT(setEventLogginEnabled(int)) );
	
	connect(aManager, SIGNAL(started()),    this, SLOT(managerStarted())  );
	connect(aManager, SIGNAL(finished()),   this, SLOT(managerFinished()) );
	connect(aManager, SIGNAL(terminated()), this, SLOT(managerFinished()) );
	
	incomingView->setModel(
		filterModel(
			filterIncomingEdit, 
			clearFilterIncomingButton, 
			IncomingConnectionModelAdapter::FILTER_ROLE, 
			&aManagerIncomingAdapter
		)
	);
	incomingView->setSortingEnabled(true);
	
	establishedView->setModel( 
		filterModel(
			filterEstablishedEdit, 
			clearFilterEstablishedButton, 
			EstablishedConnectionModelAdapter::FILTER_ROLE, 
			&aManagerEstablishedAdapter 
		)
	);
	establishedView->setSortingEnabled(true);
	
	connectedView->setModel( &aManagerRobotAdapter );
	
	setWindowTitle("WSS");
}

MainWindow::~MainWindow() {
	
}

QSortFilterProxyModel* MainWindow::filterModel( QLineEdit* edit, QPushButton* button, int role, QAbstractItemModel* model ) {
	QSortFilterProxyModel* filter = new QSortFilterProxyModel(this);
	connect( edit, SIGNAL(textChanged(const QString&)), filter, SLOT(setFilterWildcard(const QString&)) );
	connect( button, SIGNAL(clicked()), filter, SLOT(clear()));
	filter->setFilterRole( role );
	filter->setFilterCaseSensitivity( Qt::CaseInsensitive );
	filter->setSourceModel( model );
	return filter;
}

void MainWindow::loadModels() {
	aModels.clear();
	aModels.push_back( SmartPtr<PropagationModel>( new NoopPropagationModel() ) );
	
	QDir pluginsDir = QDir(qApp->applicationDirPath());

#if defined(Q_OS_WIN)
	if (pluginsDir.dirName().toLower() == "debug" || pluginsDir.dirName().toLower() == "release") {
		pluginsDir.cdUp();
	}
#elif defined(Q_OS_MAC)
	if (pluginsDir.dirName() == "MacOS") {
		pluginsDir.cdUp();
		pluginsDir.cdUp();
		pluginsDir.cdUp();
	}
#endif
	pluginsDir.cd("plugins");
	
	foreach (QString fileName, pluginsDir.entryList(QDir::Files)) {
		//qDebug() << "checking filename " << fileName << " for plugins";
		QPluginLoader loader(pluginsDir.absoluteFilePath(fileName));
		
		if(!loader.load()) {
			qWarning() << "couldn't load plugin " << fileName << " because: " << loader.errorString();
			continue;
		}
		
		QObject *plugin = loader.instance();
		if (plugin) {
			PropagationModel* model = qobject_cast<PropagationModel*>(plugin);
			if(model) {
				model->setRobotLinkModel(aManager);
				aModels.push_back( SmartPtr<PropagationModel>(model) );
				qDebug() << "Plugin loaded: '"+fileName+"' -> class '"+(model->metaObject()->className())+"'";
			} else {
				qWarning() << "Plugin " << fileName << " not a PropagationModel!";
				delete plugin;
				loader.unload();
			}
		}
	}
	
	chooseModelBox->clear();
	vector< SmartPtr<PropagationModel> >::iterator it;
	for(it = aModels.begin(); it != aModels.end(); it++) {
		chooseModelBox->addItem( (*it)->metaObject()->className() );
	}
	chooseModelBox->setCurrentIndex(0);
	configureModelButton->setEnabled( aModels.front()->isConfigurable() );
	aManager->setPropagationModel( aModels.front() );
}

void MainWindow::logging(const QString& message) {
	QTextCursor c(logWindow->document());
	c.movePosition(QTextCursor::End);
	c.insertBlock();
	c.insertText(message);
	c.movePosition(QTextCursor::End);
	logWindow->setTextCursor(c);
	logWindow->ensureCursorVisible();
}

void MainWindow::setEventLogginEnabled(int state) {
	aManager->setEventLoggingEnabled( state == Qt::Checked );
}

void MainWindow::startStopManager() {
	if( aManager->isRunning() ) {
		startStopButton->setText("Stopping...");
		startStopButton->setEnabled(false);

		aManager->shutdown();
	} else {
		startStopButton->setText("Starting...");
		startStopButton->setEnabled(false);
		
		portEdit->setEnabled(false);
		chooseModelBox->setEnabled(false);
		loggingCheck->setEnabled(false);
		
		aManager->start();
	}
}

void MainWindow::managerStarted() {
	startStopButton->setText("Stop");
	startStopButton->setEnabled(true);
}

void MainWindow::managerFinished() {
	startStopButton->setText("Start");
	startStopButton->setEnabled(true);
	portEdit->setEnabled(true);
	chooseModelBox->setEnabled(true);
	loggingCheck->setEnabled(true);
}

void MainWindow::configureModel() {
	if( aManager->getPropagationModel()->isConfigurable() )
		aManager->getPropagationModel()->showConfigurationDialog( !aManager->isRunning() );
}

void MainWindow::modelChanged(int index) {
	SmartPtr<PropagationModel> ptr = aModels[index];
	if(!ptr.isNull()) {
		aManager->setPropagationModel(ptr);
		
		configureModelButton->setEnabled( ptr->isConfigurable() );
	}
}

void MainWindow::portChanged() {
	unsigned int port = portEdit->text().toUInt();
	if(port > 0) {
		aManager->setListenPort(port);
		portEdit->setText( QString::number(aManager->getListenPort()) );
	}
}

