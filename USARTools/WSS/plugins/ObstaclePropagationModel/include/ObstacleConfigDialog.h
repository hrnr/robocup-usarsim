#ifndef _OBSTACLECONFIGDIALOG_H_
#define _OBSTACLECONFIGDIALOG_H_

#include <QDialog>

#include "ui_ConfigDialog.h"

#include "ObstaclePropagationModel.h"

class ObstacleConfigDialog : public QDialog, private Ui::ConfigDialog {
	Q_OBJECT
	
public:
	ObstacleConfigDialog(QWidget* = NULL);
	
	void setValues(ObstaclePropagationModel*);
	void getValues(ObstaclePropagationModel*);
	
	void disableAll();
	
public slots:
	void recomputeMeterCutoff();
	void recomputeParameters();
};

#endif /* _OBSTACLECONFIGDIALOG_H_ */
