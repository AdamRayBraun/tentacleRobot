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
        leftX  = ((rxBuff[1] << 8) | rxBuff[2]);
        leftY  = ((rxBuff[3] << 8) | rxBuff[4]);
        rightX = ((rxBuff[6] << 8) | rxBuff[7]);
        rightY = ((rxBuff[8] << 8) | rxBuff[9]);

        if (rxBuff[5]  != 0) leftButton();
        if (rxBuff[10] != 0) rightButton();
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
