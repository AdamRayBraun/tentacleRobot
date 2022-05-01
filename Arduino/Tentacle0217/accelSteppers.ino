AccelStepper bottomX(AccelStepper::DRIVER, bottom_servo_X_PUL_pin, bottom_servo_X_DIR_pin);
AccelStepper bottomY(AccelStepper::DRIVER, bottom_servo_Y_PUL_pin, bottom_servo_Y_DIR_pin);
AccelStepper topX(AccelStepper::DRIVER, top_servo_X_PUL_pin, top_servo_X_DIR_pin);
AccelStepper topY(AccelStepper::DRIVER, top_servo_Y_PUL_pin, top_servo_Y_DIR_pin);

#define STEPPER_MAX_SPEED 200
#define STEPPER_MAX_ACCEL 100

boolean bottomXEnabled, bottomYEnabled, topXEnabled, topYEnabled;
int dirBottomX, dirBottomY, dirTopX, dirTopY;
int targetBottomX, targetBottomY, targetTopX, targetTopY;

void setupAccelSteppers()
{
  bottomX.setMaxSpeed(STEPPER_MAX_SPEED);
  bottomX.setAcceleration(STEPPER_MAX_ACCEL);
  bottomY.setMaxSpeed(STEPPER_MAX_SPEED);
  bottomY.setAcceleration(STEPPER_MAX_ACCEL);
  topX.setMaxSpeed(STEPPER_MAX_SPEED);
  topX.setAcceleration(STEPPER_MAX_ACCEL);
  topY.setMaxSpeed(STEPPER_MAX_SPEED);
  topY.setAcceleration(STEPPER_MAX_ACCEL);
}

void handleSteppers()
{
  if (bottomXEnabled){
    bottomX.enableOutputs();
    bottomX.run();
  } else {
    bottomX.disableOutputs();
  }

  if (bottomYEnabled){
    bottomY.enableOutputs();
    bottomY.run();
  } else {
    bottomY.disableOutputs();
  }

  if (topXEnabled){
    topX.enableOutputs();
    topX.run();
  } else {
    topX.disableOutputs();
  }

  if (topYEnabled){
    topY.enableOutputs();
    topY.run();
  } else {
    topY.disableOutputs();
  }
}
