import processing.serial.*;
import controlP5.*;

final String controllerPort = "";
final String robotPort      = "";

int guiW = 300;
int guiH = 300;

int leftX, leftY, rightX, rightY;

Slider2D topMotorSlider, bottomMotorSlider;

void settings(){
  size((sliderSize * 2) + (border * 4), sliderSize + (border * 2));
}

void setup(){
  setupController();
  setupRobot();
  setupGui();
}

void draw(){
  controllerInput();
  updateMotors();
  robotRx();
  gui();
}
