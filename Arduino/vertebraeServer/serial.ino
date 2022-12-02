#define packet_len              11
#define packet_pos_flag         1
#define packet_pos_data         2
#define packet_pos_footer       10

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

void setupSerial()
{
  Serial.begin(115200);

  txBuff[0]              = packet_header;
  txBuff[1]              = 0;
  txBuff[2]              = 0;
  txBuff[3]              = 0;
  txBuff[4]              = 0;
  txBuff[5]              = 0;
  txBuff[6]              = 0;
  txBuff[7]              = 0;
  txBuff[8]              = 0;
  txBuff[9]              = 0;
  txBuff[10]             = 0;
  txBuff[packet_len - 1] = packet_footer;
}

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
  txBuff[1]              = packet_flag_touch;
  txBuff[2]              = id;
  txBuff[3]              = (shortTouch) ? 1 : 0;
  Serial.write(txBuff, sizeof(txBuff));
}

void sendTouchPollA(byte id, int amt)
{
  txBuff[1]              = packet_flag_touchPoll_A;
  txBuff[2]              = id;
  txBuff[3]              = amt;
  Serial.write(txBuff, sizeof(txBuff));
}
