/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware
**/

 // #define SERIAL_DEBUG true
// #define SERIAL_HEARTBEAT true

#include <AccelStepper.h>
#include <Adafruit_NeoPixel.h>

// Pin connections
#define top_servo_X_PUL_pin    2
#define top_servo_X_DIR_pin    5
#define bottom_servo_Y_DIR_pin 7
#define bottom_servo_Y_PUL_pin 6
#define top_servo_Y_PUL_pin    9
#define top_servo_Y_DIR_pin    8
#define bottom_servo_X_PUL_pin 4
#define bottom_servo_X_DIR_pin 3

#define end_effector_led_pin  A0

// L top X & bottom Y
// R top Y & bottom X

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
  // setupEndEffector();
}

void loop()
{
  serialRx();
  handleSteppers();
  serialHeartBeat();
}
