GUI gui;

void setupInterface(){
  gui = new GUI(this);
}

class GUI {
  public Slider2D topMotorSlider, bottomMotorSlider;
  public Slider pointSkipSlider, pointDiamSlider;
  public Group motorGroup, pointCloudGroup;

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

    // TODO : error including more sliders: running out of heap space
    // this.pointCloudGroup = this.cp5.addGroup("pointCloudGroup")
    //                                .setPosition((this.sliderSize) + (this.border * 3), this.border / 2)
    //                                .setBackgroundColor(color(255,50))
    //                                .setWidth(this.sliderSize + (this.border * 2))
    //                                .setBackgroundHeight(int((this.sliderSize * 0.5) + (this.border * 2)))
    //                                .setWidth(this.sliderSize + (this.border * 2))
    //                                ;
    //
    // this.pointSkipSlider = this.cp5.addSlider("pointSkipSlider")
    //                                .setPosition(this.border, this.border)
    //                                .setWidth(this.sliderSize - this.border)
    //                                .setRange(0, 8)
    //                                .setValue(pointSkip)
    //                                .setNumberOfTickMarks(9)
    //                                .setGroup(pointCloudGroup)
    //                                ;

    // this.pointDiamSlider = this.cp5.addSlider("pointDiamSlider")
    //                            .setPosition(this.border, (this.border * 2))
    //                            .setWidth(this.sliderSize - this.border)
    //                            .setRange(0, 8)
    //                            .setValue(pointDiam)
    //                            .setNumberOfTickMarks(9)
    //                            .setSliderMode(Slider.FLEXIBLE)
    //                            .setGroup(pointCloudGroup)
    //                            ;
    //
    // this.cp5.getController("pointSkipSlider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    // this.cp5.getController("pointDiamSlider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
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
  }

  // numbers 0 - 9
  byte keyNum = (byte)key;
  if (keyNum >= 48 && keyNum <= 57){
    changeState((byte)(keyNum - 48));
  }
}

void mousePressed(){
  if (mouseY < kinectDepthH * scale && mouseX > kinectDepthW * scale){
    print("coordinate : " + (mouseX -  kinectDepthW * scale) + ", " + mouseY);
    println(presenceSensor.getDepthValue(mouseX, mouseY));
  }
}
