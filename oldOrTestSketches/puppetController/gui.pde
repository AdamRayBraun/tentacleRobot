ControlP5 cp5;

final int border = 50;
final int sliderSize2D = 200;

final int sliderW = 200;
final int sliderH = 40;

int motorMaxSpeeds[]        = {6000, 6000, 2000, 2000};
int motorMaxAccelerations[] = {900,  900,  300,  300};

void setupGui(){
  cp5 = new ControlP5(this);

  topMotorSlider = cp5.addSlider2D("TopPositions")
                      .setPosition(border, border)
                      .setSize(sliderSize2D, sliderSize2D)
                      .setMinMax(-STEPPER_TOP_MAX_STEPS_X,
                                 -STEPPER_TOP_MAX_STEPS_Y,
                                  STEPPER_TOP_MAX_STEPS_X,
                                  STEPPER_TOP_MAX_STEPS_Y)
                      .setValue(0, 0)
                      ;

  bottomMotorSlider = cp5.addSlider2D("BottomPositions")
                         .setPosition(border * 2 + sliderSize2D, border)
                         .setSize(sliderSize2D, sliderSize2D)
                         .setMinMax(-STEPPER_BOTTOM_MAX_STEPS_X,
                                    -STEPPER_BOTTOM_MAX_STEPS_Y,
                                     STEPPER_BOTTOM_MAX_STEPS_X,
                                     STEPPER_BOTTOM_MAX_STEPS_Y)
                         .setValue(0, 0)
                         ;

  cp5.addSlider("tXSpeed")
               .setPosition(border, (border * 2) + sliderSize2D)
               .setRange(0, 10000)
               .setSize(sliderW, sliderH)
               .setValue(motorMaxSpeeds[MOTOR_TOP_X])
               ;

   cp5.addSlider("tYSpeed")
      .setPosition(border, (border * 3) + sliderSize2D + (sliderH * 0.5))
      .setRange(0, 10000)
      .setSize(sliderW, sliderH)
      .setValue(motorMaxSpeeds[MOTOR_TOP_Y])
      ;

   cp5.addSlider("tXAccel")
      .setPosition(border, (border * 4) + sliderSize2D + (sliderH * 1))
      .setRange(0, 1500)
      .setSize(sliderW, sliderH)
      .setValue(motorMaxAccelerations[MOTOR_TOP_X])
      ;

   cp5.addSlider("tYAccel")
      .setPosition(border, (border * 5) + sliderSize2D + (sliderH * 1.5))
      .setRange(0, 1500)
      .setSize(sliderW, sliderH)
      .setValue(motorMaxAccelerations[MOTOR_TOP_Y])
      ;

   cp5.addSlider("bXSpeed")
      .setPosition((border * 2) + sliderW, (border * 2) + sliderSize2D)
      .setRange(0, 10000)
      .setSize(sliderW, sliderH)
      .setValue(motorMaxSpeeds[MOTOR_BOTTOM_X])
      ;

    cp5.addSlider("bYSpeed")
       .setPosition((border * 2) + sliderW, (border * 3) + sliderSize2D + (sliderH * 0.5))
       .setRange(0, 10000)
       .setSize(sliderW, sliderH)
       .setValue(motorMaxSpeeds[MOTOR_BOTTOM_Y])
       ;

    cp5.addSlider("bXAccel")
       .setPosition((border * 2) + sliderW, (border * 4) + sliderSize2D + (sliderH * 1))
       .setRange(0, 1500)
       .setSize(sliderW, sliderH)
       .setValue(motorMaxAccelerations[MOTOR_BOTTOM_X])
       ;

    cp5.addSlider("bYAccel")
       .setPosition((border * 2) + sliderW, (border * 5) + sliderSize2D + (sliderH * 1.5))
       .setRange(0, 1500)
       .setSize(sliderW, sliderH)
       .setValue(motorMaxAccelerations[MOTOR_BOTTOM_Y])
       ;
}

void gui(){
  background(0);
}

void tXSpeed(float newSpeed){
  updateMaxSpeed(TOP_X, (int)newSpeed);
}

void tYSpeed(float newSpeed){
  updateMaxSpeed(TOP_Y, (int)newSpeed);
}

void tXAccel(float newAccel){
  updateMaxAccel(TOP_X, (int)newAccel);
}

void tYAccel(float newAccel){
  updateMaxAccel(TOP_Y, (int)newAccel);
}

void bXSpeed(float newSpeed){
  updateMaxSpeed(BOTTOM_X, (int)newSpeed);
}

void bYSpeed(float newSpeed){
  updateMaxSpeed(BOTTOM_Y, (int)newSpeed);
}

void bXAccel(float newAccel){
  updateMaxAccel(BOTTOM_X, (int)newAccel);
}

void bYAccel(float newAccel){
  updateMaxAccel(BOTTOM_Y, (int)newAccel);
}

void keyPressed(){
  if (key == '0'){
    moveHome();
    usingContrInput = false;
  } else if (key == 'c'){
    usingContrInput = true;
  }
}
