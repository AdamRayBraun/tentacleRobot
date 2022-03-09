/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware
**/

// Pin connections
#define servo1Pin      9
#define servo2Pin      10
#define joystickButton 7

// different modes
#define JOYSTICK      0
#define SINEWAVE      1
byte mode = SINEWAVE;

int angle1 = 90;
int angle2 = 90;
int valueX = 0;
int valueY = 0;
int valueZ = 0;

void setup() {
  Serial.begin(9600);
  setupServos();
  setupInputs();
}

void loop() {
  switch (controlMode){
    case JOYSTICK:
      joystickControl();
      break;

    case SINEWAVE:
      sineMove();
      break;
  }
}

void setupServos(){
  pinMode(servo1Pin, OUTPUT);
  pinMode(servo2Pin, OUTPUT);
}

void setupInputs(){
  pinMode(joystickButton, INPUT_PULLUP);
}

void joystickControl(){
  valueX = analogRead(A0);
  Serial.print("X:");
  Serial.print(valueX, DEC);
  valueY = analogRead(A1);
  Serial.print(" | Y:");
  Serial.print(valueY, DEC);
  valueZ = digitalRead(7);
  Serial.print(" | Z: ");
  Serial.println(valueZ, DEC);

  if(valueZ == 0){
    servoSet(servo1Pin, angle1);
    servoSet(servo2Pin, angle2);
  }

  if(valueX > 900){
    angle1 = angle1 - 2;
    servoMove(servo1Pin, angle1);
  } else if(valueX < 100){
    angle1 = angle1 + 2;
    servoMove(servo1Pin, angle1);
  }

  if(valueY > 900){
    angle2 = angle2 + 2;
    servoMove(servo2Pin, angle2);
  } else if(valueY < 100){
    angle2 = angle2 - 2;
    servoMove(servo2Pin, angle2);
  }
}

void servoSet(int servo,int angle){
  digitalWrite(servo,HIGH);
  delayMicroseconds(1500);
  digitalWrite(servo,LOW);
  delay(15);
}

void servoMove(int servo,int angle){
  int j = map(angle,0,180,500,2500);
  digitalWrite(servo,HIGH);
  delayMicroseconds(j);
  digitalWrite(servo,LOW);
  delay(15);
}
