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
final byte packet_header              = 0x69;
final byte packet_footer              = 0x42;
final byte packet_flag_motor_top_x    = 0x10;
final byte packet_flag_motor_top_y    = 0x11;
final byte packet_flag_motor_bottom_x = 0x20;
final byte packet_flag_motor_bottom_y = 0x21;
final byte packet_flag_motor_eyelid   = 0x30;
final byte packet_flag_motor_eyeball  = 0x31;
final byte packet_flag_led_eyeball    = 0x40;
final byte packet_pos_flag            = 1;
final byte packet_pos_data            = 2;
final byte packet_pos_footer          = packet_len - 1;
byte[] txPacket = new byte[packet_len];
Serial bus;

final byte TOP_SECTION    = 1;
final byte BOTTOM_SECTION = 2;
final byte X_DIRECTION    = 1;
final byte Y_DIRECTION    = 2;

void setupArduino(){
  // setup serial connection to arduino
  if (USING_ARDUINO){
    bus = new Serial(this, ARDUINO_PORT, 115200);
  }

  // build communication packet
  txPacket[0]                 = packet_header;
  txPacket[packet_pos_footer] = packet_footer;
}

void moveTentacle(byte direction, byte section){
  byte err = 0;
  switch(section){
    case TOP_SECTION:
      switch(direction){
        case X_DIRECTION:
          txPacket[packet_pos_flag] = packet_flag_motor_top_x;
          break;
        case Y_DIRECTION:
          txPacket[packet_pos_flag] = packet_flag_motor_top_y;
          break;
        default:
          err = 1;
          break;
      }
      break;
    case BOTTOM_SECTION:
      switch(direction){
        case X_DIRECTION:
          txPacket[packet_pos_flag] = packet_flag_motor_bottom_x;
          break;
        case Y_DIRECTION:
          txPacket[packet_pos_flag] = packet_flag_motor_bottom_y;
          break;
        default:
          err = 1;
          break;
      }
      break;
    default:
      err = 2;
      break;
  }

  switch(err){
    case(0):
      serialTx(txPacket);
    case(1):
      println("ERROR: unknown direction of movement requested");
      break;
    case(2):
      println("ERROR: unknown section requested to move");
      break;
    default:
      println("ERROR META");
      break;
  }
}

void serialTx(byte[] packet){
  bus.write(packet);

  if (SERIAL_DEBUG){
    String out = "Sending to arduino:\t";
    for (int a = 0; a < packet.length; a++){
      out += hex(packet[a]);
      out += " ";
    }
    println(out);
  }
}
