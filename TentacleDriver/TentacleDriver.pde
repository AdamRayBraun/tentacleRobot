import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;
import controlP5.*;

final String  ARDUINO_PORT  = "/dev/tty.usbmodem1463401";
final boolean SERIAL_DEBUG  = false;
final boolean USING_KINECT  = true;
final boolean USING_ARDUINO = false;

Kinect2 kinect2;

final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;

// graphics canvases
PGraphics kinectCanvas, blobCanvas;

// Movement modes
final byte HOME          = 0;
final byte EYE_CONTACT   = 1;
final byte WIGGLE        = 2;
final byte WIGGLE_INC    = 3;
final byte AUDIENCE_LOOK = 4;
final byte AUDIENCE_MOVE = 5;
final byte PRESENT_BODY  = 6;
final byte PRESENT_WAIST = 7;
final byte PRESENT_HEAD  = 8;
final byte END_EFFECTOR  = 9;
final byte MANUAL        = 10;

final String[] stateNames = { "Homing",
                              "Eye contact",
                              "Wiggling",
                              "Increasing wiggling",
                              "Looking at audience",
                              "Looking around audience",
                              "Presenting body",
                              "Presenting waist",
                              "Presenting head",
                              "Showing end effector"
                          };

byte currentState      = EYE_CONTACT;
byte lastState         = currentState;
long lastStateChange;

void settings(){
  size(kinectDepthW * scale * 2, kinectDepthH * scale * 2, P3D);
}

void setup(){
  setupKinect();
  setupBlobDetection();
  setupArduino();
  setupInterface();

  changeState(WIGGLE_INC);

  eyeLight(0, 100, 0);
}

void draw(){
  // GUI
  background(0);
  if (USING_KINECT){
    drawDepth();
    image(kinectCanvas, kinectDepthW * scale, 0, kinectDepthW * scale, height / 2);
    image(kinect2.getVideoImage(), kinectDepthW * scale, height / 2, kinectDepthW * scale, height / 2);
    detectBlobs();
    drawBlobs();
    image(blobCanvas, kinectDepthW * scale, 0, width, height / 2);
  }
  drawInterface();

  // Movement
  if (!reconnectingArduino) handleMovementState();

  // Hardware
  runHardware();

  blinkingEyelid();
}

void changeState(byte newState){
  lastStateChange = newState;
  lastState = currentState;
  currentState = newState;

  // hand changes of states
  if (currentState != lastState){
    switch(currentState){
      case EYE_CONTACT:
        eyeLight(90, 90, 90);
        break;

      case WIGGLE:
        eyeLight(0, 0, 120);
        break;

      case WIGGLE_INC:
        for (byte m = 0; m < 4; m++){
          sinAmplitude[m] = 0;
        }
        break;

      case AUDIENCE_LOOK:
        lookTowardsAudience();
        break;

      case PRESENT_BODY:
        presentBody();
        break;

      case PRESENT_WAIST:
        presentWaist();
        break;

      case PRESENT_HEAD:
        presentHead();
        break;

      case HOME:
        moveHome();
        break;
    }
    println("State changed from " + lastState + " to " + newState);
  }
}

void handleMovementState(){
  switch(currentState){
    case EYE_CONTACT:
      moveTentacleToUser();
      break;

    case WIGGLE:
      wiggle();
      break;

    case WIGGLE_INC:
      wiggleIncreasing();
      break;

    case AUDIENCE_MOVE:
      lookAroundAudience();
      break;
  }
}
