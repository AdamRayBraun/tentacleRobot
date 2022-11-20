GUI gui;

void setupInterface(){
  gui = new GUI(this);
}

class GUI {
  public Slider2D topMotorSlider, bottomMotorSlider;

  private ControlP5 cp5;
  private final int border = 50;
  private final int sliderSize = 200;

  GUI(PApplet par){
    this.cp5 = new ControlP5(par);
    this.cp5.setAutoDraw(false);

    this.topMotorSlider = this.cp5.addSlider2D("TopPositions")
                        .setPosition(this.border, this.border)
                        .setSize(this.sliderSize, this.sliderSize)
                        .setMinMax(-motors.maxMotorSteps[motors.MOTOR_TOP_X],
                                   -motors.maxMotorSteps[motors.MOTOR_TOP_Y],
                                    motors.maxMotorSteps[motors.MOTOR_TOP_X],
                                    motors.maxMotorSteps[motors.MOTOR_TOP_Y])
                        .setValue(0, 0)
                        ;

    this.bottomMotorSlider = this.cp5.addSlider2D("BottomPositions")
                           .setPosition(this.border, this.border * 2 + this.sliderSize)
                           .setSize(this.sliderSize, this.sliderSize)
                           .setMinMax(-motors.maxMotorSteps[motors.MOTOR_BOTTOM_X],
                                      -motors.maxMotorSteps[motors.MOTOR_BOTTOM_Y],
                                       motors.maxMotorSteps[motors.MOTOR_BOTTOM_X],
                                       motors.maxMotorSteps[motors.MOTOR_BOTTOM_Y])
                           .setValue(0, 0)
                           ;
  }

  void render(){
    cam.beginHUD();

    this.cp5.draw();

    fill(255);
    textSize(10);
    text("Current state:  " + stateNames[currentState], this.border, (this.border * 3) + (this.sliderSize * 2));
    cam.endHUD();
  }
}

void keyPressed(){
  if (key == 'f'){
    presenceSensor.depthMode = presenceSensor.DEPTH_THRESH;
  } else if (key == 'a'){
    presenceSensor.depthMode = presenceSensor.DEPTH_ALL;
  } else if (key == '['){
    blobDetector.updateMinBlobSize(-100);
  } else if (key == ']'){
    blobDetector.updateMinBlobSize(100);
  } else if (key == 'h'){
    motors.homeMotors();
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
