AccelStepper bottomX(AccelStepper::DRIVER, bottom_servo_X_PUL_pin, bottom_servo_X_DIR_pin);
AccelStepper bottomY(AccelStepper::DRIVER, bottom_servo_Y_PUL_pin, bottom_servo_Y_DIR_pin);
AccelStepper topX(AccelStepper::DRIVER, top_servo_X_PUL_pin, top_servo_X_DIR_pin);
AccelStepper topY(AccelStepper::DRIVER, top_servo_Y_PUL_pin, top_servo_Y_DIR_pin);

#define STEPPER_MAX_SPEED 1000
#define STEPPER_MAX_ACCEL 300

boolean bottomXEnabled, bottomYEnabled, topXEnabled, topYEnabled;
boolean dirBottomX, dirBottomY, dirTopX, dirTopY;
int targetBottomX, targetBottomY, targetTopX, targetTopY;

int stepperMax = 1000;

void setupAccelSteppers()
{
  bottomX.setMaxSpeed(STEPPER_MAX_SPEED);
  bottomY.setMaxSpeed(STEPPER_MAX_SPEED);
  topX.setMaxSpeed(STEPPER_MAX_SPEED);
  topY.setMaxSpeed(STEPPER_MAX_SPEED);

  bottomX.setAcceleration(STEPPER_MAX_ACCEL);
  bottomY.setAcceleration(STEPPER_MAX_ACCEL);
  topX.setAcceleration(STEPPER_MAX_ACCEL);
  topY.setAcceleration(STEPPER_MAX_ACCEL);
}

void handleSteppers()
{
  switch(state){
    case STATE_USB:
      break;

    case STATE_WIGGLE:
      if (bottomY.distanceToGo() == 0)
      {
        delay(1000);
        if (dirBottomY){
          bottomY.moveTo(random(-stepperMax, 0));
        } else {
          bottomY.moveTo(random(0, stepperMax));
        }
        dirBottomY = !dirBottomY;
      }

      if (bottomX.distanceToGo() == 0)
      {
        delay(1000);
        if (dirBottomX){
          bottomX.moveTo(random(-stepperMax, 0));
        } else {
          bottomX.moveTo(random(0, stepperMax));
        }
        dirBottomX = !dirBottomX;
      }

      bottomY.run();
      bottomX.run();
      break;
  }
}
