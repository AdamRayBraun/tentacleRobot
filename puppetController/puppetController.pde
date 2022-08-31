import processing.serial.*;
import controlP5.*;

final String controllerPort = "/dev/tty.usbmodem14401";
final String robotPort      = "/dev/tty.usbmodem14501";

int guiW = 300;
int guiH = 300;

final int MOTOR_TOP_X =    0;
final int MOTOR_TOP_Y =    1;
final int MOTOR_BOTTOM_X = 2;
final int MOTOR_BOTTOM_Y = 3;

int leftX, leftY, rightX, rightY;

Slider2D topMotorSlider, bottomMotorSlider;

void settings(){
  size((sliderSize2D * 2) + (border * 4), (sliderSize2D * 2) + (border * 4));
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
