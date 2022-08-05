#define NUM_STEPPERS 4

#define STEPPER_BOTTOM_MAX_STEPS_X 2000
#define STEPPER_BOTTOM_MAX_STEPS_Y 2000

#define STEPPER_TOP_MAX_STEPS_X 6000
#define STEPPER_TOP_MAX_STEPS_Y 6000

byte motorPULpins[] = {top_servo_X_PUL_pin, top_servo_Y_PUL_pin, bottom_servo_X_PUL_pin, bottom_servo_Y_PUL_pin};
byte motorDIRpins[] = {top_servo_X_DIR_pin, top_servo_Y_DIR_pin, bottom_servo_X_DIR_pin, bottom_servo_Y_DIR_pin};

AccelStepper *motors[NUM_STEPPERS];

int motorMaxSpeeds[]        = {6000, 6000, 2000, 2000};
int motorMaxAccelerations[] = {900, 900, 300, 300};

int dirBottomX, dirBottomY, dirTopX, dirTopY;
int targetBottomX, targetBottomY, targetTopX, targetTopY;

int stepperMax = 2000;

void setupAccelSteppers()
{
  for (int m = 0; m < NUM_STEPPERS; m++){
    motors[m] = new AccelStepper(AccelStepper::DRIVER, motorPULpins[m], motorDIRpins[m]);
    motors[m]->setMaxSpeed(motorMaxSpeeds[m]);
    motors[m]->setAcceleration(motorMaxSpeeds[m]);
  }
}

void handleSteppers()
{
  for (int m = 0; m < NUM_STEPPERS; m++){
    motors[m]->run();
  }
}

void updateMotorSpeed(byte motorIndex, int newMotorSpeed)
{
  if (motorIndex > 0 && motorIndex < NUM_STEPPERS){
    motorMaxSpeeds[motorIndex] = newMotorSpeed;
    motors[motorIndex]->setMaxSpeed(motorMaxSpeeds[motorIndex]);
  }
}

void updateMotorAcceleration(byte motorIndex, int newMotorAccel)
{
  if (motorIndex > 0 && motorIndex < NUM_STEPPERS){
    motorMaxAccelerations[motorIndex] = newMotorAccel;
    motors[motorIndex]->setAcceleration(motorMaxAccelerations[motorIndex]);
  }
}

void homeMotors()
{
  for (int m = 0; m < NUM_STEPPERS; m++){
    motors[m]->setCurrentPosition(0);
  }
}

void stopMotors()
{
  for (int m = 0; m < NUM_STEPPERS; m++){
    motors[m]->stop();
  }
}
