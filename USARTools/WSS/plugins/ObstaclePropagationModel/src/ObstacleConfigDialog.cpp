#include "ObstacleConfigDialog.h"

#include <cmath>

using namespace std;

ObstacleConfigDialog::ObstacleConfigDialog(QWidget* parent)
	: QDialog(parent)
{
	setupUi(this);
	setWindowTitle("ObstaclePropagationModel Configuration");
}

void ObstacleConfigDialog::setValues(ObstaclePropagationModel* model) {
	hostEdit->setText( QString( model->aUSARSimIpAddress.c_str()) );
	portEdit->setValue( model->aUSARSimPort );
	eDoEdit->setValue( model->eDo );
	eNEdit->setValue( model->eN );
	ePdoEdit->setValue( model->ePdo );
	cutoffEdit->setValue( model->aDistanceCutoff );
	
	attenuationEdit->setValue( model->eAttenuationFactor );
	maxObstEdit->setValue( model->eMaxObstacles );
	maxdistEdit->setValue( sqrt(model->aMaxAllowedCachedDistance) );
}

void ObstacleConfigDialog::getValues(ObstaclePropagationModel* model) {
	model->aUSARSimIpAddress = hostEdit->text().toStdString();
	model->aUSARSimPort = portEdit->value();
	
	model->aDistanceCutoff = cutoffEdit->value();
	model->ePdo = ePdoEdit->value();
	model->eN = eNEdit->value();
	model->eDo = eDoEdit->value();

	model->eAttenuationFactor = attenuationEdit->value();
	model->eMaxObstacles = maxObstEdit->value();
	model->aMaxAllowedCachedDistance = maxdistEdit->value();
	
	// we are using squared distance
	model->aMaxAllowedCachedDistance = (model->aMaxAllowedCachedDistance * model->aMaxAllowedCachedDistance);
}

void ObstacleConfigDialog::disableAll() {
	hostEdit->setEnabled(false);
	portEdit->setEnabled(false);
	eDoEdit->setEnabled(false);
	eNEdit->setEnabled(false);
	ePdoEdit->setEnabled(false);
	cutoffEdit->setEnabled(false);
	distance->setEnabled(false);
	attenuationEdit->setEnabled(false);
	maxObstEdit->setEnabled(false);
	maxdistEdit->setEnabled(false);
}

void ObstacleConfigDialog::recomputeMeterCutoff() {
	double Sc = cutoffEdit->value();
	double Pd0 = ePdoEdit->value();
	double d0 = eDoEdit->value();
	double N = eNEdit->value();
	
	distance->blockSignals(true);
	distance->setValue( d0 * pow( 10, (Pd0-Sc)/(10*N) ) );
	distance->blockSignals(false);
}

void ObstacleConfigDialog::recomputeParameters() {
	double Sc = cutoffEdit->value();
	double Pd0 = ePdoEdit->value();
	double d0 = eDoEdit->value();
	double dm = distance->value();
	
	eNEdit->blockSignals(true);
	eNEdit->setValue( (Pd0 - Sc)/(10*log10(dm/d0)) );
	eNEdit->blockSignals(false);
}
