int[] depthData;
float depthMin  = 1500;
float depthMax  = 2319;
int numKinectPixels = kinectDepthW * kinectDepthH;

final int DEPTH_ALL             = 0;
final int DEPTH_FLAT_THRESH     = 1;
int depthMode = DEPTH_FLAT_THRESH;

void setupKinect(){
  if (USING_KINECT){
    kinect2 = new Kinect2(this);
    kinect2.initDepth();
    kinect2.initVideo();
    kinect2.initDevice();
  }

  kinectCanvas = createGraphics(kinectDepthW, kinectDepthH);
  kinectCanvas.beginDraw();
  kinectCanvas.background(0);
  kinectCanvas.endDraw();
}

void drawDepth(){
  depthData = kinect2.getRawDepth();

  kinectCanvas.loadPixels();

  switch(depthMode){
    case DEPTH_ALL:
      for (int p = 0; p < numKinectPixels; p++){
        kinectCanvas.pixels[p] = color(map(depthData[p], 0, 4000,0, 255));
      }
      break;

    case DEPTH_FLAT_THRESH:
      for (int p = 0; p < numKinectPixels; p++){
        kinectCanvas.pixels[p] = (depthData[p] < depthMax && depthData[p] > depthMin) ? color(255) : color(0);
      }
      break;
  }
  kinectCanvas.updatePixels();
}
