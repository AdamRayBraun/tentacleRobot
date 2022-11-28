PeasyCam cam;
boolean showPointCloud = true;
boolean showDepthSlice = true;
boolean showBlobs      = false;

float pointDiam = 2;
int pointSkip   = 2;
int pointCol = 200;

void setupRendering(){
  cam = new PeasyCam(this, 555.38727, 256.59683, 1047.7106, 2712.309326171875);
  cam.setSuppressRollRotationMode();
  cam.setWheelScale(0.5);
}

void renderPointloud(){
  if (!showPointCloud) return;

  if (!KINECT_EN) return;

  stroke(0, 0, pointCol);
  strokeWeight(pointDiam);

  beginShape(POINTS);
  for (int x = 0; x < kinectDepthW; x += pointSkip){
    for (int y = 0; y < kinectDepthH; y += pointSkip){
      // get point position
      PVector point = presenceSensor.depthToPointCloudPos(x, y, presenceSensor.depthData[x + y * kinectDepthW]);
      // render point cloud
      vertex(point.x, point.z, point.y);
    }
  }
  endShape();
}

void renderDepthSlice(){
  cam.beginHUD();

  if (!showDepthSlice) return;

  int boxHeight = (int)(presenceSensor.depthMax - presenceSensor.depthMin);

  pushMatrix();
  translate((kinectDepthW / 2) * scale, presenceSensor.depthMin + boxHeight / 2, (kinectDepthH / 2) * scale);
  noFill();
  stroke(100, 0, 0);
  box(kinectDepthW * scale, boxHeight, kinectDepthW * scale);
  popMatrix();
  cam.endHUD();
}

void renderRawBlobs(){
  if (!showBlobs) return;

  for (Blob b : blobDetector.blobs){
    b.show();
  }

  cam.beginHUD();
  image(presenceSensor.depthSlice, (width / 2) - (kinectDepthW / 2), (height / 2) - (kinectDepthH / 2), kinectDepthW, kinectDepthH);
  image(blobDetector.blobCanvas,   (width / 2) - (kinectDepthW / 2), (height / 2) - (kinectDepthH / 2), kinectDepthW, kinectDepthH);
  cam.endHUD();
}

void render(){
  background(0);

  renderPointloud();
  renderDepthSlice();
  renderRawBlobs();
  pcbVertebrae.render();
  gui.render();
}
