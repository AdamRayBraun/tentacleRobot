#define packet_len                 6
#define packet_pos_flag            1
#define packet_pos_data            2
#define packet_pos_footer          (packet_len - 1)

// packet values
#define packet_header              0x69
#define packet_footer              0x42

#define packet_flag_motor_top_x    0x10
#define packet_flag_motor_top_y    0x11
#define packet_flag_motor_bottom_x 0x12
#define packet_flag_motor_bottom_y 0x13

#define packet_flag_speed_top_x    0x20
#define packet_flag_speed_top_y    0x21
#define packet_flag_speed_bottom_x 0x22
#define packet_flag_speed_bottom_y 0x23

#define packet_flag_accel_top_x    0x30
#define packet_flag_accel_top_y    0x31
#define packet_flag_accel_bottom_x 0x32
#define packet_flag_accel_bottom_y 0x33

#define packet_flag_stepper_home   0x09

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

        //// MOVING MOTOR CASES /////////////////////////////////////
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

        //// CHANGING MOTOR SPEED CASES /////////////////////////////////////
        case packet_flag_speed_top_x:
          speedTopX = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          topX.setMaxSpeed(speedTopX);

          #ifdef SERIAL_DEBUG
            Serial.print("TX speed : ");
            Serial.println(speedTopX);
          #endif
          break;

        case packet_flag_speed_top_y:
          speedTopY = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          topY.setMaxSpeed(speedTopY);

          #ifdef SERIAL_DEBUG
            Serial.print("TY speed : ");
            Serial.println(speedTopY);
          #endif
          break;

        case packet_flag_speed_bottom_x:
          speedBottomX = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          bottomX.setMaxSpeed(speedBottomX);

          #ifdef SERIAL_DEBUG
            Serial.print("BX speed : ");
            Serial.println(speedBottomX);
          #endif
          break;

        case packet_flag_speed_bottom_y:
          speedBottomY = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          bottomY.setMaxSpeed(speedBottomY);

          #ifdef SERIAL_DEBUG
            Serial.print("BY speed : ");
            Serial.println(speedBottomY);
          #endif
          break;

        //// CHANGING MOTOR ACCELERATION CASES /////////////////////////////////////
        case packet_flag_accel_top_x:
          accelTopX = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          topX.setAcceleration(accelTopX);

          #ifdef SERIAL_DEBUG
            Serial.print("TX accel : ");
            Serial.println(accelTopX);
          #endif
          break;

        case packet_flag_accel_top_y:
          accelTopY = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          topY.setAcceleration(accelTopY);

          #ifdef SERIAL_DEBUG
            Serial.print("TY accel : ");
            Serial.println(accelTopY);
          #endif
          break;

        case packet_flag_accel_bottom_x:
          accelBottomX = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          bottomX.setAcceleration(accelBottomX);

          #ifdef SERIAL_DEBUG
            Serial.print("BX accel : ");
            Serial.println(accelBottomX);
          #endif
          break;

        case packet_flag_accel_bottom_y:
          accelBottomY = (rxBuff[packet_pos_data] << 8) | rxBuff[packet_pos_data + 1];
          bottomY.setAcceleration(accelBottomY);

          #ifdef SERIAL_DEBUG
            Serial.print("BY accel : ");
            Serial.println(accelBottomY);
          #endif
          break;

        // RESET ALL STEPPER POSITIONS TO 0
        case packet_flag_stepper_home:
          homeMotors();

          #ifdef SERIAL_DEBUG
            Serial.println("all motors homed");
          #endif
          break;

        // EMERGENCY STOP ALL MOTORS
        case packet_flag_STOP:
          stopMotors();

          #ifdef SERIAL_DEBUG
            Serial.println("STOPPED");
          #endif
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
