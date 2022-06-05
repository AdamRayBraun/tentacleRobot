/**
  Packet structure
  header    0x69
  flag      0x1X (motors) 0x2X (lights) etc
  data1     ---
  data2     ---
  data3     ---
  footer    0x42
**/

// packet structure
final byte packet_len                 = 6;
final byte packet_pos_flag            = 1;
final byte packet_pos_data            = 2;
final byte packet_pos_footer          = packet_len - 1;

// packet values
final byte packet_header              = (byte)0x69;
final byte packet_footer              = (byte)0x42;
final byte packet_flag_motor_top_x    = (byte)0x10;
final byte packet_flag_motor_top_y    = (byte)0x11;
final byte packet_flag_motor_bottom_x = (byte)0x20;
final byte packet_flag_motor_bottom_y = (byte)0x21;
final byte packet_flag_stepper_home   = (byte)0x25;
final byte packet_flag_motor_eyelid   = (byte)0x30;
final byte packet_flag_led_eyeball    = (byte)0x40;
final byte packet_flag_change_state   = (byte)0x60;
final byte packet_flag_STOP           = (byte)0xFF;

int[] lastMotorPositions = new int[4];

byte[] txPacket = new byte[packet_len];
Serial bus;

final byte STATE_WIGGLE = 0;
final byte STATE_USB    = 1;

// eye lid vars
long lastBlink;
int blinkRate;
final int blinkMin = 500;
final int blinkMax = 10000;
boolean eyeLidOpening;

// heartbeat vars
long lastHeartbeatCheck;
final int heartbeatTimer = 3000;
boolean reconnectingArduino = false;

void setupArduino(){
  // setup serial connection to arduino
  if (USING_ARDUINO){
    bus = new Serial(this, ARDUINO_PORT, 115200);
  }

  // build communication packet
  txPacket[0]                 = packet_header;
  txPacket[packet_pos_footer] = packet_footer;
}

void moveTentacle(byte motor, int position){
  byte err = 0;
  switch(motor){
    case MOTOR_TOP_X:
      txPacket[packet_pos_flag]     = packet_flag_motor_top_x;
      txPacket[packet_pos_data]     = byte((position > 0) ? 0 : 1);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      lastMotorPositions[MOTOR_TOP_X] = position;
      break;

    case MOTOR_TOP_Y:
      txPacket[packet_pos_flag]     = packet_flag_motor_top_y;
      txPacket[packet_pos_data]     = byte((position > 0) ? 0 : 1);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      lastMotorPositions[MOTOR_TOP_Y] = position;
      break;

    case MOTOR_BOTTOM_X:
      txPacket[packet_pos_flag]     = packet_flag_motor_bottom_x;
      txPacket[packet_pos_data]     = byte((position > 0) ? 0 : 1);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      lastMotorPositions[MOTOR_BOTTOM_X] = position;
      break;

    case MOTOR_BOTTOM_Y:
      txPacket[packet_pos_flag]     = packet_flag_motor_bottom_y;
      txPacket[packet_pos_data]     = byte((position > 0) ? 0 : 1);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      lastMotorPositions[MOTOR_BOTTOM_Y] = position;
      break;

    default:
      err = 1;
      break;
  }

  switch(err){
    case(0):
      serialTx(txPacket);
      break;
    case(1):
      println("ERROR: unknown motor requested to move");
    default:
      println("how the fuck");
      break;
  }
}

void moveEyeBall(int position){
  txPacket[packet_pos_flag] = packet_flag_motor_eyelid;
  txPacket[packet_pos_data] = (byte)position;
  serialTx(txPacket);
}

void eyeLight(int r, int g, int b){
  txPacket[packet_pos_flag] = packet_flag_led_eyeball;
  txPacket[packet_pos_data] = (byte)r;
  txPacket[packet_pos_data + 1] = (byte)g;
  txPacket[packet_pos_data + 2] = (byte)b;
  serialTx(txPacket);
}

void blinkingEyelid(){
  if (millis() - lastBlink > blinkRate){
    lastBlink = millis();
    blinkRate = (int)random(blinkMin, blinkMax);

    moveEyeBall(eyeLidOpening ? 0 : 90);
    eyeLidOpening = !eyeLidOpening;
  }
}

void serialTx(byte[] packet){
  if (USING_ARDUINO) bus.write(packet);

  if (SERIAL_DEBUG){
    String out = "Sending to arduino:\t";
    for (int a = 0; a < packet.length; a++){
      out += hex(packet[a]);
      out += " ";
    }
    println(out);
  }
}

void serialRx(){
  if (USING_ARDUINO){
    while (bus.available() > 0) {
      String rxMsg = bus.readStringUntil(10); // 10 = \n
      if (rxMsg != null) {
        println(rxMsg);
      }
    }
    bus.clear();
  }
}

void checkForArduinoDropOut(){
  if (millis() - lastHeartbeatCheck > heartbeatTimer){
    lastHeartbeatCheck = millis();
    String[] ports = Serial.list();
    boolean portStillConnected = false;

    // check if arduino port is still found by processing
    for (int p = 0; p < ports.length; p++){
      String[] m1 = match(ARDUINO_PORT, ports[p]);
      if (m1 != null){
        portStillConnected = true;
        return;
      }
    }

    if (!portStillConnected) reconnectingArduino = true;

    if (reconnectingArduino){
      try {
        printArray(Serial.list());
        bus.clear();
        bus.stop();
        bus = new Serial(this, ARDUINO_PORT, 115200);
        reconnectingArduino = false;
      } catch(Exception e) {
        println("ERR trying to re-open port, retrying...");
        delay(1000);
      }
    }
  }
}
