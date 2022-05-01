#define packet_len              6
#define packet_pos_flag         1
#define packet_pos_data         2
#define packet_pos_footer       (packet_len - 1)

// packet values
#define packet_header              0x69
#define packet_footer              0x42
#define packet_flag_motor_top_x    0x10
#define packet_flag_motor_top_y    0x11
#define packet_flag_motor_bottom_x 0x20
#define packet_flag_motor_bottom_y 0x21
#define packet_flag_motor_eyelid   0x30
#define packet_flag_led_eyeball    0x40

char rxBuff[packet_len];

// look for USB serial commands from processing skech
void serialRx()
{
  if (Serial.read() == packet_header){
    Serial.readBytes(rxBuff, packet_len - 1);
    if (rxBuff[packet_pos_footer - 1] == packet_footer){
      switch(rxBuff[packet_pos_flag]){
        case packet_flag_motor_top_x:
          topX.setSpeed(rxBuff[packet_pos_data - 1]);
          break;

        case packet_flag_motor_top_y:
          topY.setSpeed(rxBuff[packet_pos_data - 1]);
          break;

        case packet_flag_motor_bottom_x:
          bottomX.setSpeed(rxBuff[packet_pos_data - 1]);
          break;

        case packet_flag_motor_bottom_y:
          bottomY.setSpeed(rxBuff[packet_pos_data - 1]);
          break;
      }
    }
  }
}
