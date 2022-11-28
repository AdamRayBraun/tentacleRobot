// Movement modes
final byte HOME          = 0;
final byte WIGGLE_INC    = 1;
final byte WIGGLE        = 2;
final byte EYE_CONTACT   = 3;
final byte AUDIENCE_LOOK = 4;
final byte AUDIENCE_MOVE = 5;
final byte PRESENT_WAIST = 6;
final byte MANUAL        = 10;

final String[] stateNames = { "Homing",
                              "Increasing wiggling",
                              "Wiggling",
                              "Eye contact",
                              "Looking at audience",
                              "Looking around audience",
                              "Presenting waist",
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
  if (currentState != newState) currentState = newState;

  switch(currentState){
    case WIGGLE:
      break;

    case EYE_CONTACT:
      break;

    case HOME:
      homeMotors();
      break;
  }

  println("New state:  " + stateNames[currentState]);
}
