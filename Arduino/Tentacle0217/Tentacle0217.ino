/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware

  Using Arduino Pro Micro - set board to "Arduino Leonardo"
**/

#define SERIAL_DEBUG true

#include <AccelStepper.h>
// #include "TentacleStepper.h"
#include <Servo.h>
#include <Wire.h>

// Pin connections
#define bottom_servo_X_PUL_pin  9
#define bottom_servo_X_DIR_pin  8
// #define bottom_servo_X_EN_pin   3
#define bottom_servo_Y_PUL_pin  7
#define bottom_servo_Y_DIR_pin  6
// #define bottom_servo_Y_EN_pin   6

#define top_servo_X_PUL_pin     7
#define top_servo_X_DIR_pin     8
// #define top_servo_X_EN_pin      9
#define top_servo_Y_PUL_pin     10
#define top_servo_Y_DIR_pin     11
// #define top_servo_Y_EN_pin      12

// LED pin needs to be PWM
#define end_effector_led_pin    13

#define eyelid_servo_pin_L      2
#define eyelid_servo_pin_R      3

#define STATE_WIGGLE 0
#define STATE_USB    1
int state = STATE_WIGGLE;

void setup()
{
  setupSerial();
  setupAccelSteppers();
  setupEndEffector();
  // setupIMU();
}

void loop()
{
  serialRx();
  handleSteppers();
  // readIMUData();
}
