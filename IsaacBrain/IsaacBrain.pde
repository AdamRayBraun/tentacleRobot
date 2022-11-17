/*
  Have We Met?

  Control software for Isaac the continuum robot

  Adam Ray Braun
  Qi Qi
  2022
*/

import org.openkinect.processing.*;
import processing.serial.*;
import peasy.PeasyCam;

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
  setupInterface();

  // setup presence detection
  setupKinect();
  setupBlobDetection();

  setupMotors();
}

void draw(){
  // detect presence
  runBlobDetection();

  // handle Motor Responses
  motors.run();

  // render visuals
  renderPointloud();
}
