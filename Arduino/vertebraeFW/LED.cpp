#include "LED.h"

#define PWM_FREQ       500
#define PWM_RESOLUTION 8

LED::LED(int pwmChannel, int pin, uint32_t steps)
{
  _pwmChannel = pwmChannel;
  _steps = steps;
  _pin = pin;
  ledcSetup(_pwmChannel, PWM_FREQ, PWM_RESOLUTION);
  ledcAttachPin(_pin, _pwmChannel);
  _maxBright = (int)(pow(2, PWM_RESOLUTION) - 1);
}

void LED::fadeTo(float nVal)
{
  if (nVal > _maxBright) nVal = _maxBright;

  int diff = nVal - _val;
  bool increasing = diff > 0;
  diff = abs(diff);

  if (diff > 0){
    if (increasing){
      _val += diff / _steps;
    } else {
      _val -= diff / _steps;
    }

    if (increasing){
      if (diff > _steps){
        _val += diff / _steps;
      } else {
        _val++;
      }
    } else {
      if (diff > _steps){
        _val -= diff / _steps;
      } else {
        _val--;
      }
    }
  }
}

void LED::fadeDown(int speed)
{
  _val -= speed;
  if (_val < 0) _val = 0;
}

void LED::setVal(float nVal)
{
  if (nVal > _maxBright) nVal = _maxBright;
  _val = nVal;
}

float LED::getVal()
{
  return _val;
}

void LED::updateSteps(int newSteps)
{
  _steps = newSteps;
}

void LED::run()
{
  ledcWrite(_pwmChannel, (int)(_val));
}
