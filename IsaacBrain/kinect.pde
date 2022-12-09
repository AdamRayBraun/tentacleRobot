KinectSensor presenceSensor;

void setupKinect(){
  presenceSensor = new KinectSensor(this);
}

class KinectSensor {
  public PGraphics graphics, depthSlice;
  public int[] depthData;
  public float depthMin          = 1500;
  public float depthMax          = 2616;
  public int yCrop               = 254;
  public final int DEPTH_ALL     = 0;
  public final int DEPTH_THRESH  = 1;
  public int depthMode           = DEPTH_THRESH;

  private PApplet parent;
  private Kinect2 kinect;
  private int numKinectPixels = kinectDepthW * kinectDepthH;

  KinectSensor(PApplet par){
    this.parent = par;

    if (KINECT_EN){
      this.kinect = new Kinect2(this.parent);
      this.kinect.initDepth();
      this.kinect.initVideo();
      this.kinect.initDevice();
    }

    this.depthSlice = createGraphics(kinectDepthW, kinectDepthH);
    this.depthSlice.beginDraw();
    this.depthSlice.background(0);
    this.depthSlice.endDraw();
  }

  public void run(){
    if (!KINECT_EN){
      return;
    }

    // get raw depth data
    this.depthData = this.kinect.getRawDepth();

    // build image of depth sliced threshold for blob detection
    this.depthSlice.loadPixels();

    switch(this.depthMode){
      case DEPTH_ALL:
        for (int p = 0; p < this.numKinectPixels; p++){
          this.depthSlice.pixels[p] = color(map(this.depthData[p], 0, 4000, 0, 255));
        }
        break;

      case DEPTH_THRESH:
        for (int x = 0; x < kinectDepthW; x++){
          for (int y = 0; y < kinectDepthH; y++){
            int i = y * kinectDepthW + x;
            if (y < this.yCrop){
              if (this.depthData[i] < this.depthMax && this.depthData[i] > this.depthMin){
                this.depthSlice.pixels[i] = color(255);
              } else {
                this.depthSlice.pixels[i] = color(0);
              }
            } else {
              this.depthSlice.pixels[i] = color(0);
            }
          }
        }
        break;
    }
    this.depthSlice.updatePixels();
  }

  public int getDepthValue(int x, int y){
    if (!KINECT_EN){
      return -1;
    }

    return this.depthData[floor(y * kinectDepthW + x)];
  }

  //calculte the xyz position based on the depth data
  private PVector depthToPointCloudPos(int x, int y, float depthValue){
    PVector point = new PVector();
    point.z = (depthValue);
    point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
    point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
    return point;
  }
}

//camera information based on the Kinect v2 hardware
static class CameraParams {
  static float cx = 254.878f;
  static float cy = 205.395f;
  static float fx = 365.456f;
  static float fy = 365.456f;
  static float k1 = 0.0905474;
  static float k2 = -0.26819;
  static float k3 = 0.0950862;
  static float p1 = 0.0;
  static float p2 = 0.0;
}
