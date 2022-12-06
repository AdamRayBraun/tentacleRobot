AccelStepper bottomX(AccelStepper::DRIVER, bottom_servo_X_PUL_pin, bottom_servo_X_DIR_pin);
AccelStepper bottomY(AccelStepper::DRIVER, bottom_servo_Y_PUL_pin, bottom_servo_Y_DIR_pin);
AccelStepper topX(AccelStepper::DRIVER, top_servo_X_PUL_pin, top_servo_X_DIR_pin);
AccelStepper topY(AccelStepper::DRIVER, top_servo_Y_PUL_pin, top_servo_Y_DIR_pin);

#define STEPPER_BOTTOM_MAX_SPEED 2000
#define STEPPER_BOTTOM_MAX_ACCEL 300
#define STEPPER_BOTTOM_MAX_STEPS_X 2000
#define STEPPER_BOTTOM_MAX_STEPS_Y 2000

#define STEPPER_TOP_MAX_SPEED 6000
#define STEPPER_TOP_MAX_ACCEL 900
#define STEPPER_TOP_MAX_STEPS_X 10000
#define STEPPER_TOP_MAX_STEPS_Y 10000

int dirBottomX, dirBottomY, dirTopX, dirTopY;
int targetBottomX, targetBottomY, targetTopX, targetTopY;

int speedBottomX = STEPPER_BOTTOM_MAX_SPEED;
int speedBottomY = STEPPER_BOTTOM_MAX_SPEED;
int speedTopX    = STEPPER_TOP_MAX_SPEED;
int speedTopY    = STEPPER_TOP_MAX_SPEED;

int accelBottomX = STEPPER_BOTTOM_MAX_ACCEL;
int accelBottomY = STEPPER_BOTTOM_MAX_ACCEL;
int accelTopX    = STEPPER_BOTTOM_MAX_ACCEL;
int accelTopY    = STEPPER_BOTTOM_MAX_ACCEL;

int stepperMax   = 2000;

void setupAccelSteppers()
{
  bottomX.setMaxSpeed(speedBottomX);
  bottomY.setMaxSpeed(speedBottomY);
  topX.setMaxSpeed(speedTopX);
  topY.setMaxSpeed(speedTopY);

  bottomX.setAcceleration(accelBottomX);
  bottomY.setAcceleration(accelBottomY);
  topX.setAcceleration(accelTopX);
  topY.setAcceleration(accelTopY);
}

void handleSteppers()
{
  bottomY.run();
  bottomX.run();
  topY.run();
  topX.run();
}

void homeMotors()
{
  bottomY.setCurrentPosition(0);
  bottomX.setCurrentPosition(0);
  topY.setCurrentPosition(0);
  topX.setCurrentPosition(0);
}

void stopMotors()
{
  bottomY.stop();
  bottomX.stop();
  topY.stop();
  topX.stop();
}
