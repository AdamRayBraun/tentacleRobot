#define packet_len              11
#define packet_pos_flag         1
#define packet_pos_data         2
#define packet_pos_footer       (packet_len - 1)

// packet values
#define packet_header           0x69
#define packet_footer           0x42

#define packet_flag_led         0x10
#define packet_flag_touch       0x20

/*
0  header
1  flag
2  address
3  led1
4  led2
5  led3
6  led4
7  neoR
8  neoG
9  neoB
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
      }
    }
  }
}

void sendTouch(byte id, byte touchSide, boolean shortTouch){
  Serial.print(id);
  Serial.print(",");
  Serial.print((shortTouch) ? "1" : "0");
  Serial.println();
}
