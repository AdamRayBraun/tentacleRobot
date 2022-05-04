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
#define packet_flag_stepper_home   0x25
#define packet_flag_motor_eyelid   0x30
#define packet_flag_led_eyeball    0x40
#define packet_flag_change_state   0x60
#define packet_flag_STOP           0xFF

char rxBuff[packet_len];
char txBuff[packet_len];

void setupSerial()
{
  Serial.begin(115200);
  txBuff[0] = packet_header;
  txBuff[packet_len - 1] = packet_footer;
}

// look for USB serial commands from processing skech
void serialRx()
{
  if (Serial.peek() == packet_header){
    Serial.readBytes(rxBuff, packet_len);
    if (rxBuff[packet_pos_footer] == packet_footer){
      switch(rxBuff[packet_pos_flag]){
        case packet_flag_motor_top_x:
          dirTopX = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetTopX = (rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2];
          topX.moveTo(dirTopX * targetTopX);
          topXEnabled = true;

          state = STATE_USB;

          #ifdef SERIAL_DEBUG
            Serial.print("top x moving to: ");
            Serial.println(dirTopX * targetTopX);
          #endif
          break;

        case packet_flag_motor_top_y:
          dirTopY = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetTopY = (rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2];
          topY.moveTo(dirTopY * targetTopY);
          topYEnabled = true;

          state = STATE_USB;

          #ifdef SERIAL_DEBUG
            Serial.print("top Y moving to: ");
            Serial.println(dirTopY * targetTopY);
          #endif
          break;

        case packet_flag_motor_bottom_x:
          dirBottomX = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetBottomX = (rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2];
          bottomX.moveTo(dirBottomX * targetBottomX);
          bottomXEnabled = true;

          state = STATE_USB;

          #ifdef SERIAL_DEBUG
            Serial.print("bottom X moving to: ");
            Serial.println(dirBottomX * targetBottomX);
          #endif
          break;

        case packet_flag_motor_bottom_y:
          dirBottomY = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetBottomY = (rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2];
          bottomY.moveTo(dirBottomY * targetBottomY);
          bottomYEnabled = true;

          state = STATE_USB;

          #ifdef SERIAL_DEBUG
            Serial.print("bottom Y moving to: ");
            Serial.println(dirBottomY * targetBottomY);
          #endif
          break;

        case packet_flag_stepper_home:
          bottomX.setCurrentPosition(0);
          bottomY.setCurrentPosition(0);
          topX.setCurrentPosition(0);
          topY.setCurrentPosition(0);

          #ifdef SERIAL_DEBUG
            Serial.println("all motors homed ");
          #endif
          break;

        case packet_flag_motor_eyelid:
          setEyelidPosition(rxBuff[packet_pos_data]);

          #ifdef SERIAL_DEBUG
            Serial.print("eyeball motor updated: ");
            Serial.println(rxBuff[packet_pos_data]);
          #endif
          break;

        case packet_flag_led_eyeball:
          setEndEffectorLEDBrightness(rxBuff[packet_pos_data]);

          #ifdef SERIAL_DEBUG
            Serial.print("eyeball led updated: ");
            Serial.println(rxBuff[packet_pos_data]);
          #endif
          break;

        case packet_flag_STOP:
          bottomXEnabled = false;
          bottomYEnabled = false;
          topXEnabled    = false;
          topYEnabled    = false;

          if (SERIAL_DEBUG) Serial.println("STOPPED");
          break;

        case packet_flag_change_state:
          state = rxBuff[packet_pos_data];
          break;
      }
    }
  }
}

// void sendIMUData(){
//
// }
//
// void serialTx(byte[] packet)
// {
//   Serial.write(packet);
// }
