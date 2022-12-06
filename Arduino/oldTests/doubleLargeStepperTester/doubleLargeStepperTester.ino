#include <AccelStepper.h>

#define bottom_servo_X_PUL_pin  9
#define bottom_servo_X_DIR_pin  8

#define bottom_servo_Y_PUL_pin  7
#define bottom_servo_Y_DIR_pin  6

AccelStepper topX(AccelStepper::DRIVER, bottom_servo_X_PUL_pin, bottom_servo_X_DIR_pin);
AccelStepper topY(AccelStepper::DRIVER, bottom_servo_Y_PUL_pin, bottom_servo_Y_DIR_pin);

void setup() {
  topX.setMaxSpeed(1000);
//  topX.setAcceleration(20);
//  topX.moveTo(500);

  topY.setMaxSpeed(1000);
//  topY.setAcceleration(20);
//  topY.moveTo(500);

 topY.setSpeed(600);
 topX.setSpeed(600);
}

void loop() {
//  topX.run();
//  topY.run();

  topY.runSpeed();
  topX.runSpeed();
}
