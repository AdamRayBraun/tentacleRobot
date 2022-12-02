#define packet_len              11
#define packet_pos_flag         1
#define packet_pos_data         2
#define packet_pos_footer       (packet_len - 1)

// RX packet values
#define packet_header           0x69
#define packet_footer           0x42
#define packet_flag_led         0x10
#define packet_flag_touchThresh 0x20
#define packet_flag_touchPoll_Q 0x22
#define packet_flag_ota         0x30

// TX packet flags
#define packet_flag_touch       0x30
#define packet_flag_touchPoll_A 0x33


/*
0  header
1  flag
2  address // packet_pos_data
3  led1 // + 1
4  led2 // + 2
5  led3 // + 3
6  led4 // + 4
7  neoR // + 5
8  neoG // + 6
9  neoB // + 7
10 footer
*/

byte rxBuff[packet_len];
byte txBuff[packet_len];

void handleSerialRx()
{
  if (Serial.peek() == packet_header){
    Serial.readBytes(rxBuff, packet_len);
    if (rxBuff[packet_pos_footer] == packet_footer){
      switch(rxBuff[packet_pos_flag]){
        case packet_flag_led:
          sendUpdate(rxBuff[packet_pos_data],
                     rxBuff[packet_pos_data + 1],
                     rxBuff[packet_pos_data + 2],
                     rxBuff[packet_pos_data + 3],
                     rxBuff[packet_pos_data + 4],
                     rxBuff[packet_pos_data + 5],
                     rxBuff[packet_pos_data + 6],
                     rxBuff[packet_pos_data + 7]
                    );
          break;
        case packet_flag_ota:
          sendOTAFlag(rxBuff[packet_pos_data]);
          break;
        case packet_flag_touchThresh:
          sendTouchThreshUpdate(rxBuff[packet_pos_data], rxBuff[packet_pos_data + 1]);
          break;
        case packet_flag_touchPoll_Q:
          sendTouchPollQ(rxBuff[packet_pos_data]);
          break;
      }
    }
  }
}

void sendTouch(byte id, byte touchSide, boolean shortTouch)
{
  Serial.print(id);
  Serial.print(",");
  Serial.print(packet_flag_touch);
  Serial.print(",");
  Serial.print((shortTouch) ? "1" : "0");
  Serial.println();
}

void sendTouchPollA(byte id, int amt)
{
  Serial.print(id);
  Serial.print(",");
  Serial.print(packet_flag_touchPoll_A);
  Serial.print(",");
  Serial.print(amt);
  Serial.println();
}
