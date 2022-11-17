KinectSensor presenceSensor;

void setupKinect(){
  presenceSensor = new KinectSensor(this, KINECT_EN);
}

class KinectSensor {
  public PGraphics graphics, depthSlice;
  public int[] depthData;
  public float depthMin  = 1500;
  public float depthMax  = 3500;

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

  void run(){
    if (!KINECT_EN){
      return;
    }

    // get raw depth data
    this.depthData = this.kinect.getRawDepth();

    // build image of depth sliced threshold for blob detection
    this.depthSlice.loadPixels();
    for (int p = 0; p < this.numKinectPixels; p++){
      if (this.depthData[p] < this.depthMax && this.depthData[p] > this.depthMin){
        this.depthSlice.pixels[p] = color(255);
      } else {
        this.depthSlice.pixels[p] = color(0);
      }
    }
    this.depthSlice.updatePixels();
  }

  //calculte the xyz position based on the depth data
  PVector depthToPointCloudPos(int x, int y, float depthValue){
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
