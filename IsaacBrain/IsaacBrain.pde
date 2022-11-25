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
final float scale      = 1.2;

void settings(){
  size(int(kinectDepthW * scale * 2), int(kinectDepthH * scale * 2), P3D);
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
  // detect presence
  runBlobDetection();

  // motor movement
  wiggle();

  // handle Motor Responses
  motors.run();

  // PCB led animations
  animateLeds();
  pcbVertebrae.checkForPCBTouch();

  render();
}
