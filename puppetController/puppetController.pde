import processing.serial.*;

final String controllerPort = "";
final String robotPort      = "";

int guiW = 300;
int guiH = 300;

int leftX, leftY, rightX, rightY;

void settings(){
  size(guiW * 2, guiH * 2);
}

void setup(){
  setupController();
  setupRobot();
}

void draw(){
  controllerInput();
  updateMotors();
  robotRx();
}
