#ifndef _DISTANCEONLYCONFIGDIALOG_H_
#define _DISTANCEONLYCONFIGDIALOG_H_

#include <cmath>

#include <QDialog>

#include "ui_ConfigDialog.h"

#include "DistanceOnlyPropagationModel.h"

class DistanceOnlyConfigDialog : public QDialog, private Ui::ConfigDialog {
	Q_OBJECT
	
public:
	DistanceOnlyConfigDialog(QWidget* = NULL);
	
	void setValues(DistanceOnlyPropagationModel*);
	void getValues(DistanceOnlyPropagationModel*);
	
	void disableAll();
	
public slots:
	void recomputeMeterCutoff();
	void recomputeParameters();
};

#endif /* _DISTANCEONLYCONFIGDIALOG_H_ */
