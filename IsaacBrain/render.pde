PeasyCam cam;
boolean showPointCloud = true;
float pointDiam = 2;
int pointSkip   = 2;
int pointCol = 200;

void setupRendering(){
  cam = new PeasyCam(this, 555.38727, 256.59683, 1047.7106, 2712.309326171875);
  cam.setSuppressRollRotationMode();
  cam.setWheelScale(0.5);
}

void renderPointloud(){
  if (!showPointCloud){
    return;
  }

  if (!KINECT_EN){
    return;
  }

  stroke(pointCol);
  strokeWeight(pointDiam);

  beginShape(POINTS);
  for (int x = 0; x < kinectDepthW; x += pointSkip){
    for (int y = 0; y < kinectDepthH; y += pointSkip){
      int rawDepth = presenceSensor.depthData[x + y * kinectDepthW];
      // get point position
      PVector point = presenceSensor.depthToPointCloudPos(x, y, rawDepth);
      // render point cloud
      vertex(point.x, point.y, point.z);
    }
  }
  endShape();
}

void render(){
  background(0);

  renderPointloud();
  pcbVertebrae.render();
  gui.render();
}
