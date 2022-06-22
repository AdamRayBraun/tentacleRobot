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

#define heartbeatPeriod            500
unsigned long lastHeartbeat;

byte rxBuff[packet_len];
byte txBuff[packet_len];

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
          targetTopX = constrain(abs((rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2]), 0, STEPPER_TOP_MAX_STEPS_X);
          topX.moveTo(dirTopX * targetTopX);

          #ifdef SERIAL_DEBUG
            Serial.print("TX : ");
            Serial.println(dirTopX * targetTopX);
          #endif
          break;

        case packet_flag_motor_top_y:
          dirTopY = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetTopY = constrain(abs((rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2]), 0, STEPPER_TOP_MAX_STEPS_Y);
          topY.moveTo(dirTopY * targetTopY);

          #ifdef SERIAL_DEBUG
            Serial.print("TY : ");
            Serial.println(dirTopY * targetTopY);
          #endif
          break;

        case packet_flag_motor_bottom_x:
          dirBottomX = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetBottomX = constrain(abs((rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2]), 0, STEPPER_BOTTOM_MAX_STEPS_X);
          bottomX.moveTo(dirBottomX * targetBottomX);

          #ifdef SERIAL_DEBUG
            Serial.print("BX : ");
            Serial.println(dirBottomX * targetBottomX);
          #endif
          break;

        case packet_flag_motor_bottom_y:
          dirBottomY = (rxBuff[packet_pos_data] == 0) ? -1 : 1;
          targetBottomY = constrain(abs((rxBuff[packet_pos_data + 1] << 8) | rxBuff[packet_pos_data + 2]), 0, STEPPER_BOTTOM_MAX_STEPS_Y);
          bottomY.moveTo(dirBottomY * targetBottomY);

          #ifdef SERIAL_DEBUG
            Serial.print("BY : ");
            Serial.println(dirBottomY * targetBottomY);
          #endif
          break;

        case packet_flag_stepper_home:
          bottomX.setCurrentPosition(0);
          bottomY.setCurrentPosition(0);
          topX.setCurrentPosition(0);
          topY.setCurrentPosition(0);

          #ifdef SERIAL_DEBUG
            Serial.println("all motors homed");
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
          endEffectorLedRing(rxBuff[packet_pos_data], rxBuff[packet_pos_data + 1], rxBuff[packet_pos_data + 2]);

          #ifdef SERIAL_DEBUG
            Serial.print("eyeball led updated: ");
            Serial.println(rxBuff[packet_pos_data]);
          #endif
          break;

        case packet_flag_STOP:
          bottomX.stop();
          bottomY.stop();
          topX.stop();
          topY.stop();

          #ifdef SERIAL_DEBUG
            Serial.println("STOPPED");
          #endif
          break;

        case packet_flag_change_state:
          break;
      }
    }
  }
}

void serialHeartBeat()
{
  #ifdef SERIAL_HEARTBEAT
    if (millis() - lastHeartbeat > heartbeatPeriod){
      lastHeartbeat = millis();
      Serial.println(random(1, 10));
    }
  #endif
}
