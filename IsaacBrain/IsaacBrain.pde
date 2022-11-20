/*
  Have We Met?

  Control software for Isaac the continuum robot

  Adam Ray Braun
  Qi Qi
  2022
*/

/*
  TODO:
  setup point cloud view
  debugging lines between issac and person of interest
*/

import org.openkinect.processing.*;
import processing.serial.*;
import peasy.PeasyCam;
import controlP5.*;

// render sizes
final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;

void settings(){
  size(kinectDepthW * scale * 2, kinectDepthH * scale * 2, P3D);
}

void setup(){
  loadConfig();

  setupRendering();

  // setup presence detection
  setupKinect();
  setupBlobDetection();

  // setup motors MCU connection
  setupMotors();

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

  // render visuals
  renderPointloud();
  gui.render();
}
