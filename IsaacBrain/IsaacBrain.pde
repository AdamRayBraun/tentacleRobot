/*
  Have We Met?

  Control software for Isaac the continuum robot

  Adam Ray Braun
  Qi Qi
  2022
*/

/*
  TODO:
  debugging lines between issac and person of interest
  add current state tag to cp5
*/

import org.openkinect.processing.Kinect2;
import processing.serial.*;
import peasy.PeasyCam;
import controlP5.ControlP5;
import controlP5.Slider2D;
import controlP5.Slider;
import controlP5.Group;

// render sizes
final int kinectDepthW = 512;
final int kinectDepthH = 424;
final float scale      = 2.4;

void settings(){
  size(int(kinectDepthW * scale), int(kinectDepthH * scale), P3D);
}

void setup(){
  loadConfig();

  setupRendering();

  // setup presence detection
  setupKinect();
  setupBlobDetection();

  // setup Isaac electronics
  setupMotors();
  setupVertebrae();

  setupMovement();
  setupInterface();
}

void draw(){
  // get kinect input
  presenceSensor.run();

  // run blob detection on depth slice to detect audience
  blobDetector.processBlobs();

  // motor movement
  switch(currentState){
    case WIGGLE:
      wiggle();
      break;

    case EYE_CONTACT:
      lookAtIndividual();
      break;

    case HOME:
      break;
  }

  // handle Motor Responses
  motors.run();

  // PCB led animations
  animateLeds();
  pcbVertebrae.checkForPCBTouch();

  // render screen control feedback
  render();
}
