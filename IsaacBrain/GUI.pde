GUI gui;

void setupInterface(){
  gui = new GUI(this);
}

class GUI {
  public Slider2D topMotorSlider, bottomMotorSlider;
  public Slider pointSkip, pointDiam, touchThresh;
  public Group motorGroup, pointCloudGroup, pcbGroup;

  private ControlP5 cp5;
  private final int border = 20;
  private final int sliderSize = 200;

  GUI(PApplet par){
    this.cp5 = new ControlP5(par);
    this.cp5.setAutoDraw(false);

    this.motorGroup = this.cp5.addGroup("motorGroup")
                          .setPosition(this.border, this.border / 2)
                          .setBackgroundColor(color(255,50))
                          .setBackgroundHeight((this.sliderSize * 2) + (this.border * 3))
                          .setWidth(this.sliderSize + (this.border * 2))
                          ;

    this.topMotorSlider = this.cp5.addSlider2D("TopPositions")
                              .setPosition(this.border, this.border)
                              .setSize(this.sliderSize, this.sliderSize)
                              .setMinMax(-motors.maxMotorSteps[motors.MOTOR_TOP_X],
                                         -motors.maxMotorSteps[motors.MOTOR_TOP_Y],
                                          motors.maxMotorSteps[motors.MOTOR_TOP_X],
                                          motors.maxMotorSteps[motors.MOTOR_TOP_Y])
                              .setValue(0, 0)
                              .setGroup(motorGroup)
                              ;

    this.bottomMotorSlider = this.cp5.addSlider2D("BottomPositions")
                                     .setPosition(this.border, this.border * 2 + this.sliderSize)
                                     .setSize(this.sliderSize, this.sliderSize)
                                     .setMinMax(-motors.maxMotorSteps[motors.MOTOR_BOTTOM_X],
                                                -motors.maxMotorSteps[motors.MOTOR_BOTTOM_Y],
                                                 motors.maxMotorSteps[motors.MOTOR_BOTTOM_X],
                                                 motors.maxMotorSteps[motors.MOTOR_BOTTOM_Y])
                                     .setValue(0, 0)
                                     .setGroup(motorGroup)
                                     ;

    this.pointCloudGroup = this.cp5.addGroup("pointCloudGroup")
                                   .setPosition((this.sliderSize) + (this.border * 3), this.border / 2)
                                   .setBackgroundColor(color(255,50))
                                   .setWidth(this.sliderSize + (this.border * 2))
                                   .setBackgroundHeight(int((this.sliderSize * 0.5) + (this.border * 2)))
                                   .setWidth(this.sliderSize + (this.border * 2))
                                   ;

    this.pointSkip = this.cp5.addSlider("pointSkip")
                                   .setPosition(this.border, this.border)
                                   .setWidth(this.sliderSize - this.border)
                                   .setRange(0, 8)
                                   .setValue(2)
                                   .setNumberOfTickMarks(9)
                                   .setSliderMode(Slider.FLEXIBLE)
                                   .setGroup(pointCloudGroup)
                                   ;

    this.pointDiam = this.cp5.addSlider("pointDiam")
                               .setPosition(this.border, (this.border * 2))
                               .setWidth(this.sliderSize - this.border)
                               .setRange(0, 8)
                               .setValue(2)
                               .setNumberOfTickMarks(9)
                               .setSliderMode(Slider.FLEXIBLE)
                               .setGroup(pointCloudGroup)
                               ;

    this.pcbGroup = this.cp5.addGroup("pcbGroup")
                            .setPosition((this.sliderSize * 2) + (this.border * 5), this.border / 2)
                            .setBackgroundColor(color(255,50))
                            .setWidth(this.sliderSize + (this.border * 2))
                            .setBackgroundHeight(int((this.sliderSize * 0.5) + (this.border * 2)))
                            .setWidth(this.sliderSize + (this.border * 2))
                            ;


    this.touchThresh = this.cp5.addSlider("touchThresh")
                          .setPosition(this.border, this.border)
                          .setWidth(this.sliderSize - this.border)
                          .setRange(0, 100)
                          .setValue(50)
                          .setSliderMode(Slider.FLEXIBLE)
                          .setGroup(pcbGroup)
                          ;

    this.cp5.getController("pointSkip").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    this.cp5.getController("pointDiam").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    this.cp5.getController("touchThresh").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  }

  void render(){
    cam.beginHUD();

    this.cp5.draw();

    fill(255);
    textSize(10);
    // TODO add current state tag to cp5
    // text("Current state:  " + state Names[currentState], this.border, (this.border * 3) + (this.sliderSize * 2));
    cam.endHUD();
  }
}

void keyPressed(){
  if (key == 'f'){
    presenceSensor.depthMode = presenceSensor.DEPTH_THRESH;
  } else if (key == 'a'){
    presenceSensor.depthMode = presenceSensor.DEPTH_ALL;
  } else if (key == 'b'){
    blobDetector.updateMinBlobSize(-100);
  } else if (key == 'B'){
    blobDetector.updateMinBlobSize(100);
  } else if (key == 'h'){
    motors.homeMotors();
  } else if (key == '['){
    presenceSensor.depthMin += 50;
    println("depthMin,depthMax: " + presenceSensor.depthMin + "," + presenceSensor.depthMax);
  } else if (key == '{'){
    presenceSensor.depthMin -= 50;
    println("depthMin,depthMax: " + presenceSensor.depthMin + "," + presenceSensor.depthMax);
  } else if (key == ']'){
    presenceSensor.depthMax -= 50;
    println("depthMin,depthMax: " + presenceSensor.depthMin + "," + presenceSensor.depthMax);
  } else if (key == '}'){
    presenceSensor.depthMax += 50;
    println("depthMin,depthMax: " + presenceSensor.depthMin + "," + presenceSensor.depthMax);
  } else if (key == 'd'){
    showBlobs = !showBlobs;
    if (showBlobs) lookAtMouse = false;
  } else if (key == 'm'){
    if (showBlobs){
      lookAtMouse = !lookAtMouse;
      println("Following debug mouse: " + lookAtMouse);
    }
  } else if (key == 'T'){
    pcbVertebrae.polling = !pcbVertebrae.polling;
    println("Touch polling: " + pcbVertebrae.polling);
  } else if (key == 't'){
    showTouchPoll = !showTouchPoll;
  } else if (key == 'O'){
    pcbVertebrae.sendOTAMsg();
  } else if (key == 'S'){
    pcbVertebrae.selectPCB = !pcbVertebrae.selectPCB;
  } else if (key == 'R'){
    pcbVertebrae.sendTouchThreshUpdate();
  } else if (key == 'P'){
    pcbVertebrae.polling = !pcbVertebrae.polling;
  }

  if (key == CODED){
    if (keyCode == DOWN){
      if (pcbVertebrae.selectPCBIndex < pcbVertebrae.NUM_VERTEBRAE - 1) pcbVertebrae.selectPCBIndex++;
    } else if (keyCode == UP){
      if (pcbVertebrae.selectPCBIndex > 0) pcbVertebrae.selectPCBIndex--;
    }
  }

  // numbers 0 - 9
  byte keyNum = (byte)key;
  if (keyNum >= 48 && keyNum <= 57){
    changeState((byte)(keyNum - 48));
  }
}

void mousePressed(){
  if (showBlobs){
    if (mouseX > debugImgPos.x && mouseX < debugImgPos.x + kinectDepthW &&
        mouseY > debugImgPos.y && mouseY < debugImgPos.y + kinectDepthH){

      int kinectXCoord = (int)(mouseX - debugImgPos.x);
      int kinectYCoord = (int)(mouseY - debugImgPos.y);
      int kinDepth = presenceSensor.getDepthValue(kinectXCoord, kinectYCoord);
      println("Kinect coordinate : " + kinectXCoord + ", " + kinectYCoord + " depth: " + kinDepth);
    }
  }
}
