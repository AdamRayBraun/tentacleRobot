final int  ROBOT_PACKET_LEN    = 6;
final byte ROBOT_PACKET_HEADER = (byte)0x69;
final byte ROBOT_PACKET_FOOTER = (byte)0x42;

final byte TOP_X    = (byte)0x10;
final byte TOP_Y    = (byte)0x11;
final byte BOTTOM_X = (byte)0x20;
final byte BOTTOM_Y = (byte)0x21;

final int STEPPER_BOTTOM_MAX_STEPS_X = 2000;
final int STEPPER_BOTTOM_MAX_STEPS_Y = 2000;
final int STEPPER_TOP_MAX_STEPS_X = 6000;
final int STEPPER_TOP_MAX_STEPS_Y = 6000;

Serial robotBus;

final int mostUpdatePeriod = 1000 / 60;
long lastMotorUpdate;

byte[] robotTxBuff = new byte[ROBOT_PACKET_LEN];

void setupRobot(){
  robotBus = new Serial(this, robotPort, 115200);

  robotTxBuff[0] = (byte)0x69;
  robotTxBuff[5] = (byte)0x42;
}

void updateMotors(){
  if (millis() - lastMotorUpdate < mostUpdatePeriod){
    return;
  }

  sendMotorMsg(TOP_X,    leftX);
  sendMotorMsg(TOP_Y,    leftY);
  sendMotorMsg(BOTTOM_X, rightX);
  sendMotorMsg(BOTTOM_Y, rightY);

  lastMotorUpdate = millis();
}

void sendMotorMsg(byte motor, int val){
  byte dir = (byte)((val > 0) ? 0 : 1);

  robotTxBuff[1] = motor;
  robotTxBuff[2] = dir;
  robotTxBuff[3] = byte((val >> 8) & 0xFF);;
  robotTxBuff[4] = byte(val & 0xFF);

  robotBus.write(robotTxBuff);
}

void robotRx(){
  while (robotBus.available() > 0) {
    String rxMsg = robotBus.readStringUntil(10); // 10 == \n
    if (rxMsg != null) {
      println(rxMsg);
    }
  }
  robotBus.clear();
}
