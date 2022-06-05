import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;

final String  ARDUINO_PORT  = "/dev/tty.usbmodem14601";
final boolean SERIAL_DEBUG  = false;
final boolean USING_KINECT  = false;
final boolean USING_ARDUINO = true;

Kinect2 kinect2;

final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;

// graphics canvases
PGraphics kinectCanvas, blobCanvas;

// Movement modes
final byte EYE_CONTACT = 0;
final byte WIGGLE      = 1;
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

  changeState(WIGGLE);
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
    }
  }

  println("State changed from " + lastState + " to " + newState);
}

void handleMovementState(){
  switch(currentState){
    case EYE_CONTACT:
      moveTentacleToUser();
      break;

    case WIGGLE:
      wiggle();
      break;
  }

  // check for change in presence
  if (millis() - lastStateChange > 3000){
    lastStateChange = millis();
    if (blobs.size() > 0){
      if (currentState != EYE_CONTACT) changeState(EYE_CONTACT);
    } else {
      if (currentState != WIGGLE) changeState(WIGGLE);
    }
  }

  blinkingEyelid();
}
