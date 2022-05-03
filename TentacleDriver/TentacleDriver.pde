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
byte currentState      = WIGGLE;
byte lastState         = currentState;

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

  handleMovementState();

  serialRx();
}

void changeState(byte newState){
  lastState = currentState;
  currentState = newState;

  // hand changes of states
  if (currentState != lastState){
    switch(currentState){
      case EYE_CONTACT:
        break;

      case WIGGLE:
        eyeLight(200);
        break;
    }
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
  }
}

void keyPressed(){
  if (key == 'h'){
    txPacket[packet_pos_flag] = packet_flag_stepper_home;
    serialTx(txPacket);
  }
}
