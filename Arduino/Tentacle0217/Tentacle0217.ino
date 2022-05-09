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
#include <Servo.h>
// #include <Wire.h>
#include <Adafruit_NeoPixel.h>
#include <EEPROM.h>

// Pin connections
#define bottom_servo_X_PUL_pin  20
#define bottom_servo_X_DIR_pin  21
#define bottom_servo_Y_PUL_pin  18
#define bottom_servo_Y_DIR_pin  19

// #define top_servo_X_PUL_pin     7
// #define top_servo_X_DIR_pin     8
// #define top_servo_Y_PUL_pin     10
// #define top_servo_Y_DIR_pin     11

#define end_effector_led_pin    15

#define eyelid_servo_pin_L      16
#define eyelid_servo_pin_R      10

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

  if (millis() - lastCheckpoint > checkpointFrequency){
    updateLastSavedPosition();
  }
}
