ControlP5 cp5;

final int border = 50;
final int sliderSize = 200;

void setupGui(){
  cp5 = new ControlP5(this);

  topMotorSlider = cp5.addSlider2D("TopPositions")
                      .setPosition(border, border)
                      .setSize(sliderSize, sliderSize)
                      .setMinMax(-STEPPER_TOP_MAX_STEPS_X,
                                 -STEPPER_TOP_MAX_STEPS_Y,
                                  STEPPER_TOP_MAX_STEPS_X,
                                  STEPPER_TOP_MAX_STEPS_Y)
                      .setValue(0, 0)
                      ;

  bottomMotorSlider = cp5.addSlider2D("BottomPositions")
                         .setPosition(border * 2 + sliderSize, border)
                         .setSize(sliderSize, sliderSize)
                         .setMinMax(-STEPPER_BOTTOM_MAX_STEPS_X,
                                    -STEPPER_BOTTOM_MAX_STEPS_Y,
                                     STEPPER_BOTTOM_MAX_STEPS_X,
                                     STEPPER_BOTTOM_MAX_STEPS_Y)
                         .setValue(0, 0)
                         ;
}

void gui(){
  background(0);
}
