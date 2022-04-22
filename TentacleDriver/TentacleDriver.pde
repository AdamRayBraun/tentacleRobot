import org.openkinect.processing.*;
import java.nio.FloatBuffer;
import processing.serial.*;

final String ARDUINO_PORT   = "";
final boolean SERIAL_DEBUG  = true;
final boolean USING_KINECT  = true;
final boolean USING_ARDUINO = false;

Kinect2 kinect2;

boolean blobsEnabled   = true;
final int kinectDepthW = 512;
final int kinectDepthH = 424;
final int scale        = 1;

// XY position of the tentacle compared to the camera
final int tentacleX    = 256;
final int tentacleY    = 212;

PGraphics kinectCanvas, blobCanvas;

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
  }

  if (blobsEnabled){
    detectBlobs();
    drawBlobs();
    directTentacleToBlob();
    image(blobCanvas, 0, 0, width, height / 2);
  }
}

void directTentacleToBlob(){
  // if we have at least one person detected
  if (blobs.length() > 0){
    // get position of oldest blob
    Blob person = blobs.get(0);

    int xDifference = tentacleX - (person.minx + (person.maxx / 2));
    int yDifference = tentacleY - (person.miny + (person.maxy / 2));


  }
}
