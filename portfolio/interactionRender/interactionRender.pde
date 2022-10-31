/*
  Kinect2 point cloud portraits
  Adam Ray Braun
  Point cloud rendering & tracking lifted from Shiffman's Open-kinect library
  2022
*/

import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import peasy.PeasyCam;
import processing.video.*;

Kinect2 kinect2;
PeasyCam cam;

final boolean USING_KINECT = true;
final boolean USING_MOVIE  = true;

void setup(){
  // fullScreen(P3D, 1);
  size(1920, 1080, P3D);
  smooth(16);

  cam = new PeasyCam(this, 560.6446, 357.20773, 1047.7106, 2934.7064445564793);
  cam.setSuppressRollRotationMode();
  cam.setWheelScale(0.5);

  if (USING_KINECT)     setupKinect();
  if (USING_MOVIE)      setupMovie();
}

void draw(){
  background(0);

  if (USING_MOVIE)      playMovie();
  if (USING_KINECT)     renderPointCloud();

  drawInstructions();
}
