// Movement modes
final byte HOME            = 0;
final byte WIGGLE_INC      = 1;
final byte WIGGLE          = 2;
final byte EYE_CONTACT     = 3;
final byte LOOK_UP_DOWN    = 4;
final byte LOOK_LEFT_RIGHT = 5;
final byte PRESENT_WAIST   = 6;
final byte MANUAL          = 10;

final String[] stateNames = { "Homing",
                              "Increasing wiggling",
                              "Wiggling",
                              "Eye contact",
                              "Looking up down",
                              "Looking left right",
                              "",
                              "",
                              "",
                              "",
                              "",
                              "MANUAL",
                          };

byte currentState      = HOME;
byte lastState         = currentState;
long lastStateChange;

void changeState(byte newState){
  currentState = newState;
  println("New state:  " + stateNames[currentState]);

  switch(currentState){
    case WIGGLE:
      resetMotorSpeedAccel();
      showDebugPersonDetection = false;
      break;

    case EYE_CONTACT:
      resetMotorSpeedAccel();
      pickNewTarget();
      showDebugPersonDetection = true;
      break;

    case LOOK_UP_DOWN:
      for (byte m = 0; m < motors.NUM_MOTORS; m++){
        motors.updateMotorSpeed(m, (int)(motors.originalMotorSpeeds[m] * 1.5));
      }
      break;

    case LOOK_LEFT_RIGHT:
      for (byte m = 0; m < motors.NUM_MOTORS; m++){
        motors.updateMotorSpeed(m, (int)(motors.originalMotorSpeeds[m] * 1.5));
      }
      break;

    case HOME:
      resetMotorSpeedAccel();
      homeMotors();
      showDebugPersonDetection = false;
      break;
  }
}
