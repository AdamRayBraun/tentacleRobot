#include "Arduino.h"
#include "TentacleStepper.h"

TentacleStepper::TentacleStepper(int PUL_pin, int DIR_pin, int EN_pin)
{
  _PUL_pin = PUL_pin;
  _DIR_pin = DIR_pin;
  _EN_pin = EN_pin;

  pinMode(_PUL_pin, OUTPUT);
  pinMode(_DIR_pin, OUTPUT);
  pinMode(_EN_pin, OUTPUT);
}

boolean TentacleStepper::isEnabled()
{
  return _enabled;
}

void TentacleStepper::enable(boolean en){
  _enabled = en;
}

void TentacleStepper::move()
{
  digitalWrite(_DIR_pin, _clockwise);
  digitalWrite(_PUL_pin, HIGH);
  delayMicroseconds(_speed);
  digitalWrite(_PUL_pin,LOW);
  delayMicroseconds(_speed);
}
