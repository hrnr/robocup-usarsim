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

#ifndef _MAINWINDOW_H_
#define _MAINWINDOW_H_

#include <vector>

#include <QWidget>
#include <QSortFilterProxyModel>

#include "ui_MainWindow.h"

#include "RobotConnectionManager.h"
#include "PropagationModel.h"
#include "SmartPtr.h"
#include "ManagerViewAdapters.h"

class MainWindow : public QWidget, private Ui::MainWindow  {
	Q_OBJECT
	
public:
	MainWindow(RobotConnectionManager*, QWidget* = NULL);
	~MainWindow();
	
	void loadModels();
	
public slots:
	void startStopManager();
	void configureModel();
	void modelChanged(int);
	void portChanged();
	void managerStarted();
	void managerFinished();
	void logging(const QString&);
	void setEventLogginEnabled(int);

private:
	QSortFilterProxyModel* filterModel( QLineEdit* , QPushButton* , int , QAbstractItemModel* );
	
	RobotConnectionManager* aManager;
	IncomingConnectionModelAdapter aManagerIncomingAdapter;
	EstablishedConnectionModelAdapter aManagerEstablishedAdapter;
	ConnectedRobotsModelAdapter aManagerRobotAdapter;
	
	std::vector< SmartPtr< PropagationModel > > aModels;
};

#endif /* _MAINWINDOW_H_ */
