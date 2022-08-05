/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware

  Using Arduino Pro Micro - set board to "Arduino Leonardo"
**/

// #define SERIAL_DEBUG true
#define SERIAL_HEARTBEAT true

#include <AccelStepper.h>
#include <Servo.h>
// #include <Wire.h>
#include <Adafruit_NeoPixel.h>
// #include <EEPROM.h>

// Pin connections
#define bottom_servo_X_PUL_pin  9
#define bottom_servo_X_DIR_pin  8
#define bottom_servo_Y_PUL_pin  6
#define bottom_servo_Y_DIR_pin  5

#define top_servo_X_PUL_pin     10
#define top_servo_X_DIR_pin     16
#define top_servo_Y_PUL_pin     14
#define top_servo_Y_DIR_pin     15

#define end_effector_led_pin    A0

#define eyelid_servo_pin_L      A2
#define eyelid_servo_pin_R      A1

#define MOTOR_TOP_X    0
#define MOTOR_TOP_Y    1
#define MOTOR_BOTTOM_X 2
#define MOTOR_BOTTOM_Y 3

#define checkpointFrequency 500

unsigned long lastCheckpoint;

void setup()
{
  setupSerial();
  setupAccelSteppers();
  setupEndEffector();
}

void loop()
{
  serialRx();
  handleSteppers();
  serialHeartBeat();
}
