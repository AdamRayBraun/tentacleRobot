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
final byte packet_header              = 0x69;
final byte packet_footer              = 0x42;
final byte packet_flag_motor_top_x    = 0x10;
final byte packet_flag_motor_top_y    = 0x11;
final byte packet_flag_motor_bottom_x = 0x20;
final byte packet_flag_motor_bottom_y = 0x21;
final byte packet_flag_motor_eyelid   = 0x30;
final byte packet_flag_led_eyeball    = 0x40;

byte[] txPacket = new byte[packet_len];
Serial bus;

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
      txPacket[packet_pos_data]     = byte((position >> 16) & 0xFF);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      break;

    case MOTOR_TOP_Y:
      txPacket[packet_pos_flag]     = packet_flag_motor_top_y;
      txPacket[packet_pos_data]     = byte((position >> 16) & 0xFF);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      break;

    case MOTOR_BOTTOM_X:
      txPacket[packet_pos_flag]     = packet_flag_motor_bottom_x;
      txPacket[packet_pos_data]     = byte((position >> 16) & 0xFF);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
      break;

    case MOTOR_BOTTOM_Y:
      txPacket[packet_pos_flag]     = packet_flag_motor_bottom_y;
      txPacket[packet_pos_data]     = byte((position >> 16) & 0xFF);
      txPacket[packet_pos_data + 1] = byte((position >> 8) & 0xFF);
      txPacket[packet_pos_data + 2] = byte(position & 0xFF);
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

void eyeLight(int intensity){
  txPacket[packet_pos_flag] = packet_flag_led_eyeball;
  txPacket[packet_pos_data] = (byte)intensity;
  serialTx(txPacket);
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
