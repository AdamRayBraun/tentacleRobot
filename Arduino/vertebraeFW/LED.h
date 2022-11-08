/**
 * Class to store colour values for each LED.
 * Includes method to fade to a particular colour
 */

#ifndef LED_h
#define LED_h

#include <Arduino.h>

class LED
{
  public:
    LED(int pwmChannel, int pin, uint32_t steps);
    void fadeTo(float nVal);
    void fadeDown(int speed);
    void updateSteps(int newSteps);
    void updateTarget(float newTarget);
    void setVal(float nVal);
    float getVal();
    void run();
    int index;
    int _maxBright;
    float _val = 0;
    float _targetVal;
  private:
    int _pwmChannel;
    int _pin;
    uint32_t _steps;
};

#endif
