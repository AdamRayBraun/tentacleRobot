AccelStepper bottomX(AccelStepper::DRIVER, bottom_servo_X_PUL_pin, bottom_servo_X_DIR_pin);
AccelStepper bottomY(AccelStepper::DRIVER, bottom_servo_Y_PUL_pin, bottom_servo_Y_DIR_pin);
// AccelStepper topX(AccelStepper::DRIVER, top_servo_X_PUL_pin, top_servo_X_DIR_pin);
// AccelStepper topY(AccelStepper::DRIVER, top_servo_Y_PUL_pin, top_servo_Y_DIR_pin);

#define STEPPER_MAX_SPEED 2000
#define STEPPER_MAX_ACCEL 300
#define STEPPER_MAX_STEPS_X 2000
#define STEPPER_MAX_STEPS_Y 2000

int dirBottomX, dirBottomY, dirTopX, dirTopY;
int targetBottomX, targetBottomY, targetTopX, targetTopY;

int stepperMax = 2000;

void setupAccelSteppers()
{
  resetFromLastSavedPosition();
  bottomX.setMaxSpeed(STEPPER_MAX_SPEED);
  bottomY.setMaxSpeed(STEPPER_MAX_SPEED);
  // topX.setMaxSpeed(STEPPER_MAX_SPEED);
  // topY.setMaxSpeed(STEPPER_MAX_SPEED);

  bottomX.setAcceleration(STEPPER_MAX_ACCEL);
  bottomY.setAcceleration(STEPPER_MAX_ACCEL);
  // topX.setAcceleration(STEPPER_MAX_ACCEL);
  // topY.setAcceleration(STEPPER_MAX_ACCEL);
}

void handleSteppers()
{
  bottomY.run();
  bottomX.run();
}
