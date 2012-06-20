#include "DistanceOnlyConfigDialog.h"

DistanceOnlyConfigDialog::DistanceOnlyConfigDialog(QWidget* parent)
	: QDialog(parent)
{
	setupUi(this);
	setWindowTitle("DistanceOnlyPropagationModel Configuration");
}

void DistanceOnlyConfigDialog::setValues(DistanceOnlyPropagationModel* model) {
	hostEdit->setText( QString( model->aUSARSimIpAddress.c_str()) );
	portEdit->setValue( model->aUSARSimPort );
	eDoEdit->setValue( model->eDo );
	eNEdit->setValue( model->eN );
	ePdoEdit->setValue( model->ePdo );
	cutoffEdit->setValue( model->aDistanceCutoff );
}

void DistanceOnlyConfigDialog::getValues(DistanceOnlyPropagationModel* model) {
	model->aUSARSimIpAddress = hostEdit->text().toStdString();
	model->aUSARSimPort = portEdit->value();
	
	model->aDistanceCutoff = cutoffEdit->value();
	model->ePdo = ePdoEdit->value();
	model->eN = eNEdit->value();
	model->eDo = eDoEdit->value();
}

void DistanceOnlyConfigDialog::disableAll() {
	hostEdit->setEnabled(false);
	portEdit->setEnabled(false);
	eDoEdit->setEnabled(false);
	eNEdit->setEnabled(false);
	ePdoEdit->setEnabled(false);
	cutoffEdit->setEnabled(false);
	distance->setEnabled(false);
}

void DistanceOnlyConfigDialog::recomputeMeterCutoff() {
	double Sc = cutoffEdit->value();
	double Pd0 = ePdoEdit->value();
	double d0 = eDoEdit->value();
	double N = eNEdit->value();
	
	distance->blockSignals(true);
	distance->setValue( d0 * pow( 10, (Pd0-Sc)/(10*N) ) );
	distance->blockSignals(false);
}

void DistanceOnlyConfigDialog::recomputeParameters() {
	double Sc = cutoffEdit->value();
	double Pd0 = ePdoEdit->value();
	double d0 = eDoEdit->value();
	double dm = distance->value();
	
	eNEdit->blockSignals(true);
	eNEdit->setValue( (Pd0 - Sc)/(10*log10(dm/d0)) );
	eNEdit->blockSignals(false);
}
