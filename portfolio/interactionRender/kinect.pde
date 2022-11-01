int[] depthData;
float depthMin  = 640;
float depthMax  = 2900;
float pointDiam = 2;
int pointSkip   = 1;
int kinectXMin  = 00;
int kinectXMax  = 00;
int kinectYMin  = 020;
int kinectYMax  = 80;
boolean useDepthWindow = true;
int pointCol = 190;

void setupKinect(){
  if (USING_KINECT){
    kinect2 = new Kinect2(this);
    kinect2.initDepth();
    kinect2.initDevice();
  }
}

void renderPointCloud(){
  if (USING_KINECT){
    float sumX = 0;
    float sumY = 0;
    float sumZ = 0;
    float count = 0;

    depthData = kinect2.getRawDepth();

    stroke(pointCol);
    strokeWeight(pointDiam);
    beginShape(POINTS);

    if (useDepthWindow){
      for (int x = kinectXMin; x < kinect2.depthWidth - kinectXMax; x += pointSkip){
        for (int y = kinectYMin; y < kinect2.depthHeight - kinectYMax; y += pointSkip){
          int rawDepth = depthData[x + y * kinect2.depthWidth];

          PVector point = depthToPointCloudPos(x, y, rawDepth);
          if (point.z < depthMax && point.z > depthMin){
            // render point cloud
            vertex(point.x, point.y, point.z);
          }
        }
      }
    } else {
      for (int x = 0; x < kinect2.depthWidth; x += pointSkip){
        for (int y = 0; y < kinect2.depthHeight; y += pointSkip){
          int rawDepth = depthData[x + y * kinect2.depthWidth];

          PVector point = depthToPointCloudPos(x, y, rawDepth);
          // render point cloud
          vertex(point.x, point.y, point.z);
        }
      }
    }

    endShape();
  }
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue){
  PVector point = new PVector();
  point.z = (depthValue);
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}
