#ifndef TentacleStepper_h
#define TentacleStepper_h

#include "Arduino.h"

class TentacleStepper
{
  public:
    TentacleStepper(int PUL_pin, int DIR_pin, int EN_pin);
    boolean isEnabled();
    void enable(boolean en);
    void setSpeed(int newSpeed);
    void move();
  private:
    int _PUL_pin;
    int _DIR_pin;
    int _EN_pin;
    int _speed;
    boolean _clockwise;
    boolean _enabled = false;
};

#endif
