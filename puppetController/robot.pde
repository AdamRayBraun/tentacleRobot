final int  ROBOT_PACKET_LEN    = 6;
final byte ROBOT_PACKET_HEADER = (byte)0x69;
final byte ROBOT_PACKET_FOOTER = (byte)0x42;

final byte TOP_X    = (byte)0x10;
final byte TOP_Y    = (byte)0x11;
final byte BOTTOM_X = (byte)0x12;
final byte BOTTOM_Y = (byte)0x13;

final int STEPPER_BOTTOM_MAX_STEPS_X = 2000;
final int STEPPER_BOTTOM_MAX_STEPS_Y = 2000;
final int STEPPER_TOP_MAX_STEPS_X    = 6000;
final int STEPPER_TOP_MAX_STEPS_Y    = 6000;

final byte packet_flag_motor_speed = (byte)0x20;
final byte packet_flag_motor_accel = (byte)0x30;

final int rxTimeout = 1000;
long entryTime;

Serial robotBus;

final int mostUpdatePeriod = 1000 / 60;
long lastMotorUpdate;

byte[] robotTxBuff = new byte[ROBOT_PACKET_LEN];

void setupRobot(){
  robotBus = new Serial(this, robotPort, 115200);
  println("Robot opened on bus: " + robotPort);

  robotTxBuff[0] = (byte)0x69;
  robotTxBuff[5] = (byte)0x42;

  robotBus.clear();
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
  entryTime = millis();
  while (robotBus.available() > 0) {
    String rxMsg = robotBus.readStringUntil(10); // 10 == \n
    if (rxMsg != null) {
      println(rxMsg);
    }

    if (millis() - entryTime > rxTimeout){
      break;
    }
  }
  robotBus.clear();
}

void moveHome(){
  sendMotorMsg(TOP_X,    0);
  sendMotorMsg(TOP_Y,    0);
  sendMotorMsg(BOTTOM_X, 0);
  sendMotorMsg(BOTTOM_Y, 0);
}

void updateMaxSpeed(byte motor, int newSpeed){
  if (newSpeed <= 0){
    return;
  }

  motorMaxSpeeds[motor - TOP_X] = newSpeed;

  robotTxBuff[1] = packet_flag_motor_speed;
  robotTxBuff[2] = motor;
  robotTxBuff[3] = byte((newSpeed >> 8) & 0xFF);;
  robotTxBuff[4] = byte(newSpeed & 0xFF);

  robotBus.write(robotTxBuff);
}

void updateMaxAccel(byte motor, int newAccel){
  if (newAccel <= 0){
    return;
  }

  motorMaxSpeeds[motor - TOP_X] = newAccel;

  robotTxBuff[1] = packet_flag_motor_accel;
  robotTxBuff[2] = motor;
  robotTxBuff[3] = byte((newAccel >> 8) & 0xFF);;
  robotTxBuff[4] = byte(newAccel & 0xFF);

  robotBus.write(robotTxBuff);
}
