/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware

  Using Arduino Pro Micro - set board to "Arduino Leonardo"
**/

#include <AccelStepper.h>
#include "TentacleStepper.h"
#include <Servo.h>

// Pin connections
#define bottom_servo_X_PUL_pin  1
#define bottom_servo_X_DIR_pin  2
#define bottom_servo_X_EN_pin   3
#define bottom_servo_Y_PUL_pin  4
#define bottom_servo_Y_DIR_pin  5
#define bottom_servo_Y_EN_pin   6

#define top_servo_X_PUL_pin     7
#define top_servo_X_DIR_pin     8
#define top_servo_X_EN_pin      9
#define top_servo_Y_PUL_pin     10
#define top_servo_Y_DIR_pin     11
#define top_servo_Y_EN_pin      12

// LED pin needs to be PWM
#define end_effector_led_pin    13

#define eyelid_servo_pin        14

void setup()
{
  Serial.begin(115200);
  setupAccelSteppers();
  setupEndEffector();
}

void loop()
{
  serialRx();
  handleSteppers();
}
