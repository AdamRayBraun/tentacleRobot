import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;

final String ARDUINO_PORT   = "";
final boolean SERIAL_DEBUG  = true;
final boolean USING_KINECT  = true;
final boolean USING_ARDUINO = false;

Kinect2 kinect2;

final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;

// XY position of the tentacle compared to the camera
final int tentacleX    = 301;
final int tentacleY    = 239;

// graphics canvases
PGraphics kinectCanvas, blobCanvas;

// Movement modes
final byte eyeContact = 0;
final byte wiggle     = 1;
byte currentState     = eyeContact;
byte lastState        = currentState;

void settings(){
  size(kinectDepthW * scale, kinectDepthH * scale * 2, P3D);
}

void setup(){
  setupKinect();
  setupBlobDetection();
  setupArduino();
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

  handleMovementState();
}

void changeState(byte newState){
  lastState = currentState;
  currentState = newState;

  // hand changes of states
  if (currentState != lastState){
    switch(currentState){
      case eyeContact:
      break;

      case wiggle:
      break;
    }
  }
}

void handleMovementState(){
  switch(currentState){
    case eyeContact:
      moveTentacleToUser();
      break;

    case wiggle:
      wiggle();
      break;
  }
}
