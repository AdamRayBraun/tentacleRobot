import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;

final String  ARDUINO_PORT  = "/dev/tty.usbmodem14401";
final boolean SERIAL_DEBUG  = false;
final boolean USING_KINECT  = false;
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

byte currentState      = EYE_CONTACT;
byte lastState         = currentState;
long lastStateChange;

void settings(){
  size(kinectDepthW * scale, kinectDepthH * scale * 2, P3D);
}

void setup(){
  setupKinect();
  setupBlobDetection();
  setupArduino();

  changeState(WIGGLE_INC);
}

void draw(){
  if (USING_KINECT){
    drawDepth();
    image(kinectCanvas, 0, 0, width, height / 2);
    image(kinect2.getVideoImage(), 0, height / 2, width, height / 2);
    detectBlobs();
    drawBlobs();
    image(blobCanvas, 0, 0, width, height / 2);
  }

  if (!reconnectingArduino) handleMovementState();

  serialRx();

  if (USING_ARDUINO) checkForArduinoDropOut();
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
