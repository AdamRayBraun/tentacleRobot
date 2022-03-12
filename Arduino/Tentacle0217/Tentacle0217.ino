/**
  Qi Qi
  Adam Ray Braun
  Saiyuan Li
  2022

  TentacleBot firmware

  Using Arduino Pro Micro - set board to "Arduino Leonardo"
**/

#include <Servo.h>

// Pin connections
#define servoXPin      2
#define servoYPin      3

// different modes
#define NONE          0
#define SINEWAVE      1
#define HOMEING       2
byte controlMode = SINEWAVE;

// movement
#define sinwaveSpeed 0.008

Servo servoX, servoY;
float sinMoveX, sinMoveY;

int angleX = 90;
int angleY = 90;

void setup() {
  Serial.begin(9600);
  setupServos();
}

void loop() {
  switch (controlMode){
    case SINEWAVE:
      sineMove();
      break;

    case HOMEING:
      // to set middle home point of both servos - useful when attaching tendons
      servoX.write(90);
      servoY.write(90);
      delay(10000);
      break;

    case NONE:
      break;
  }
  keyboardInput();
}

void setupServos(){
  servoX.attach(servoXPin);
  servoY.attach(servoYPin);
}

void sineMove(){
  float xPos = abs(sin(sinMoveX) * 180);
  float yPos = abs(sin(sinMoveY) * 180);

  servoX.write((int)xPos);
  servoY.write((int)yPos);

  delay(15);

  sinMoveX += sinwaveSpeed;
  sinMoveY += sinwaveSpeed + 0.001;
}

void keyboardInput(){
  if (Serial.available() > 0){
    switch(Serial.read()){
      case 49:
        // '1' key
        if (angleX > 0) angleX--;
        break;

      case 50:
        // '2' key
        if (angleX < 180) angleX++;
        break;

      case 51:
        // '3' key
        if (angleY > 0) angleY--;
        break;

      case 52:
        // '4' key
        if (angleY < 180) angleY++;
        break;

      default:
        return;
        break;
    }

    Serial.print("angleX\t");
    Serial.print(angleX);
    Serial.print("\tangleY\t");
    Serial.println(angleY);
    servoX.write(angleX);
    servoY.write(angleY);
  }
}
