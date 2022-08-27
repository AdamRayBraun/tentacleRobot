final int  CONTR_PACKET_LEN    = 12;
final byte CONTR_PACKET_HEADER = (byte)0x69;
final byte CONTR_PACKET_FOOTER = (byte)0x42;

Serial controllerBus;

void setupController(){
  controllerBus = new Serial(this, controllerPort, 115200);
}

void controllerInput(){
  while (controllerBus.available() > 0){
    byte[] rxBuff = new byte[CONTR_PACKET_LEN];
    controllerBus.readBytesUntil(CONTR_PACKET_FOOTER, rxBuff);

    if (rxBuff != null){
      if (rxBuff[0] == CONTR_PACKET_HEADER){
        leftX  = (int)map(((rxBuff[1] << 8) | rxBuff[2]), 0, 1023, -STEPPER_TOP_MAX_STEPS_X,    STEPPER_TOP_MAX_STEPS_X);
        leftY  = (int)map(((rxBuff[3] << 8) | rxBuff[4]), 0, 1023, -STEPPER_TOP_MAX_STEPS_Y,    STEPPER_TOP_MAX_STEPS_Y);
        rightX = (int)map(((rxBuff[6] << 8) | rxBuff[7]), 0, 1023, -STEPPER_BOTTOM_MAX_STEPS_X, STEPPER_BOTTOM_MAX_STEPS_X);
        rightY = (int)map(((rxBuff[8] << 8) | rxBuff[9]), 0, 1023, -STEPPER_BOTTOM_MAX_STEPS_Y, STEPPER_BOTTOM_MAX_STEPS_Y);

        if (rxBuff[5]  != 0) leftButton();
        if (rxBuff[10] != 0) rightButton();

        topMotorSlider.setValue((float)leftX, (float)leftY);
        bottomMotorSlider.setValue((float)rightX, (float)rightY);
      }
    }
  }
}

void leftButton(){
  println("left button press");
}

void rightButton(){
  println("right button press");
}
