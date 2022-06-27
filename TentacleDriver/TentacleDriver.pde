import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;
import controlP5.*;

final String  ARDUINO_PORT  = "/dev/tty.usbmodem1443401";
final boolean SERIAL_DEBUG  = false;
final boolean USING_KINECT  = true;
final boolean USING_ARDUINO = true;

Kinect2 kinect2;

final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;
final int shift        = kinectDepthW * scale;

// graphics canvases
PGraphics kinectCanvas, blobCanvas;

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

  changeState(HOME);
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
    image(blobCanvas, kinectDepthW * scale, 0, kinectDepthW * scale, height / 2);
  }
  drawInterface();

  // Movement
  if (!reconnectingArduino) handleMovementState();

  // Hardware
  runHardware();

  // check for change in presence
  if (millis() - lastStateChange > 5000 && currentState != HOME){
    lastStateChange = millis();
    if (blobs.size() > 0){
      if (currentState != EYE_CONTACT) changeState(EYE_CONTACT);
    } else {
      if (currentState != WIGGLE) changeState(WIGGLE);
    }
  }
}

void changeState(byte newState){
  lastStateChange = newState;
  lastState = currentState;
  currentState = newState;

  // hand changes of states
  if (currentState != lastState){
    switch(currentState){
      case EYE_CONTACT:
        eyeLight(0, 0, 200);
        break;

      case WIGGLE:
        eyeLight(0, 0, 120);
        break;

      case WIGGLE_INC:
        eyeLight(0, 0, 120);
        eyeLidPosition(EYELID_CLOSED);
        for (byte m = 0; m < 4; m++){
          sinAmplitude[m] = 0;
        }
        break;

      case AUDIENCE_LOOK:
        eyeLight(0, 50, 0);
        eyeLidPosition(EYELID_OPEN);
        lookTowardsAudience();
        break;

      case PRESENT_WAIST:
        eyeLight(0, 0, 0);
        eyeLidPosition(EYELID_CLOSED);
        presentWaist();
        break;

      case HOME:
        eyeLidPosition(EYELID_CLOSED);
        eyeLight(0, 0, 0);
        moveHome();
        break;

      case AUDIENCE_MOVE:
        eyeLight(0, 0, 120);
        for (byte m = 0; m < 4; m++){
          moveTentacle(m, audienceLookPositions[m]);
        }
        break;
    }
    println("State changed from " + lastState + " to " + newState);
  }
}

void handleMovementState(){
  switch(currentState){
    case EYE_CONTACT:
      moveTentacleToUser();
      blinkingEyelid();
      break;

    case WIGGLE:
      wiggle();
      blinkingEyelid();
      break;

    case WIGGLE_INC:
      wiggleIncreasing();
      break;

    case AUDIENCE_MOVE:
      lookAroundAudience();
      blinkingEyelid();
      break;
  }
}
