final int  CONTR_PACKET_LEN    = 12;
final byte CONTR_PACKET_HEADER = (byte)0x69;
final byte CONTR_PACKET_FOOTER = (byte)0x42;

Serial controllerBus;

boolean usingContrInput = true;

final int buttDebounce = 100;
long lastLButtonPress, lastRButtonPress;

String rxBuff = null;

void setupController(){
  controllerBus = new Serial(this, controllerPort, 115200);
  println("Controller opened on bus: " + controllerPort);
  controllerBus.clear();
}

void controllerInput(){
  while (controllerBus.available() > 0) {
    rxBuff = controllerBus.readStringUntil(10); // 10 == \n
    if (rxBuff != null) {
      int[] packetVals = int(split(rxBuff, ','));

      leftY  =  (int)map(packetVals[0], 1023, 0, -STEPPER_TOP_MAX_STEPS_X,    STEPPER_TOP_MAX_STEPS_X);
      leftX  =  (int)map(packetVals[1], 0, 1023, -STEPPER_TOP_MAX_STEPS_Y,    STEPPER_TOP_MAX_STEPS_Y);
      rightY =  (int)map(packetVals[2], 1023, 0, -STEPPER_BOTTOM_MAX_STEPS_X, STEPPER_BOTTOM_MAX_STEPS_X);
      rightX =  (int)map(packetVals[3], 0, 1023, -STEPPER_BOTTOM_MAX_STEPS_Y, STEPPER_BOTTOM_MAX_STEPS_Y);

      if (packetVals[3] == 0) leftButton();
      if (packetVals[4] == 0) rightButton();

      topMotorSlider.setValue((float)leftX, (float)leftY);
      bottomMotorSlider.setValue((float)rightX, (float)rightY);
    }
  }
}

void leftButton(){
  if (millis() - lastLButtonPress > buttDebounce){
    lastLButtonPress = millis();
  }
}

void rightButton(){
  if (millis() - lastRButtonPress > buttDebounce){
    lastRButtonPress = millis();
  }
}
