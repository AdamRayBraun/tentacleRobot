// #define VERBOSE_ENOW_DEBUG 1

#define ENOW_CHANNEL       1
#define broadcastAdr       0x69

//****** ESP-NOW vars ******//
uint8_t lastRXmac[6];

//****** ESP-NOW flags ******//
RTC_DATA_ATTR bool handleEnowRx = false;

typedef struct enow_packet_tx {
  byte address;
  byte led1;
  byte led2;
  byte led3;
  byte led4;
  byte neoR;
  byte neoG;
  byte neoB;
} enow_packet_tx;

typedef struct enow_packet_rx {
  byte id;
  byte touchSide;
  bool shortTouch;
} enow_packet_rx;

enow_packet_rx enowRxPacket;
enow_packet_tx enowTxPacket;
esp_now_peer_info_t peer;

/**
  Callback called on reception of ESPNOW packet
**/
void espNowRxCB(const uint8_t * mac, const uint8_t *incomingData, int len)
{
  memcpy(&enowRxPacket, incomingData, sizeof(enow_packet_rx));
  memcpy(&lastRXmac, mac, sizeof(lastRXmac));
  handleEnowRx = true;
}

/**
  Callback called on sending of ESPNOW packet
**/
void espNowTxCB(const uint8_t *mac_addr, esp_now_send_status_t status)
{
  #ifdef VERBOSE_ENOW_DEBUG
    char macStr[18];
    Serial.print("Last Packet Send Status:\t");
    Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success\n\r" : "Delivery Fail\n\r");
  #endif
}

void setupEspNow()
{
  WiFi.mode(WIFI_AP);

  const char* pass = "pointlessPassword";
  bool result = WiFi.softAP(WiFi.macAddress().c_str(), pass, ENOW_CHANNEL, 0);
  if (!result) Serial.println("ERR: ENOW AP Config failed.");

  WiFi.disconnect();

  if (esp_now_init() != ESP_OK) {
    Serial.println("ERROR initializing ESP-NOW");
    return;
  }

  esp_now_register_send_cb(espNowTxCB);
  esp_now_register_recv_cb(espNowRxCB);
  WiFi.scanNetworks(); // needed to initialise WiFi before sending broadcasts

  setPeerToBroadcast();
}

void sendUpdate(byte address, byte led1, byte led2, byte led3, byte led4, byte neoR, byte neoG, byte neoB)
{
  enowTxPacket.address = address;
  enowTxPacket.led1 = led1;
  enowTxPacket.led2 = led2;
  enowTxPacket.led3 = led3;
  enowTxPacket.led4 = led4;
  enowTxPacket.neoR = neoR;
  enowTxPacket.neoG = neoG;
  enowTxPacket.neoB = neoB;

  const uint8_t *peer_addr = peer.peer_addr;
  esp_err_t result = esp_now_send(peer_addr, (uint8_t *) &enowTxPacket, sizeof(enow_packet_tx));

  #ifdef VERBOSE_ENOW_DEBUG
    debugSentStatus(result);
  #endif
}

void sendBroadcast(byte led1, byte led2, byte led3, byte led4, byte neoR, byte neoG, byte neoB)
{
  enowTxPacket.address = broadcastAdr;
  enowTxPacket.led1 = led1;
  enowTxPacket.led2 = led2;
  enowTxPacket.led3 = led3;
  enowTxPacket.led4 = led4;
  enowTxPacket.neoR = neoR;
  enowTxPacket.neoG = neoG;
  enowTxPacket.neoB = neoB;

  const uint8_t *peer_addr = peer.peer_addr;
  esp_err_t result = esp_now_send(peer_addr, (uint8_t *) &enowTxPacket, sizeof(enow_packet_tx));

  #ifdef VERBOSE_ENOW_DEBUG
    debugSentStatus(result);
  #endif
}

void handleENowRx()
{
  if (!handleEnowRx){
    return;
  } else {
    handleEnowRx = false;
  }

  sendTouch(enowRxPacket.id, enowRxPacket.touchSide, enowRxPacket.shortTouch);
}

/**
  Sets ESPNOW peer to broadcast mode
**/
void setPeerToBroadcast()
{
  memset(&peer, 0, sizeof(peer)); // clean peer object

  for (byte i = 0; i < 6; i++ ) {
    // broadcast adress = ff:ff:ff:ff:ff:ff
    peer.peer_addr[i] = (uint8_t) 0xFF;
  }

  peer.channel = ENOW_CHANNEL;
  peer.encrypt = 0;

  bool peerExists = esp_now_is_peer_exist(peer.peer_addr);

  if (peerExists){
    #ifdef VERBOSE_ENOW_DEBUG
    Serial.println("Peer already paired");
    #endif
  } else {
    esp_err_t addStatus = esp_now_add_peer(&peer);
    #ifdef VERBOSE_ENOW_DEBUG
    switch(addStatus){
      case ESP_OK:
      Serial.println("Pair success");
      break;
      case ESP_ERR_ESPNOW_NOT_INIT:
      Serial.println("ERROR adding peer: ESPNOW not init");
      break;
      case ESP_ERR_ESPNOW_ARG:
      Serial.println("ERROR adding peer: Invalid argument");
      break;
      case ESP_ERR_ESPNOW_FULL:
      Serial.println("ERROR adding peer: peer list full");
      break;
      case ESP_ERR_ESPNOW_NO_MEM:
      Serial.println("ERROR adding peer: out of memory");
      break;
      case ESP_ERR_ESPNOW_EXIST:
      Serial.println("Peer already exists");
      break;
      default:
      Serial.println("ERROR adding peer: unknown err");
      break;
    }
    #endif
  }
}

/**
  Verbose print outs of ESPNOW message status for debugging
**/
#ifdef VERBOSE_ENOW_DEBUG
void debugSentStatus(esp_err_t result)
{
  Serial.print("Send Status: ");
  if (result == ESP_OK) {
    Serial.println("Success");
  } else if (result == ESP_ERR_ESPNOW_NOT_INIT) {
    Serial.println("ESPNOW not Init.");
  } else if (result == ESP_ERR_ESPNOW_ARG) {
    Serial.println("Invalid Argument");
  } else if (result == ESP_ERR_ESPNOW_INTERNAL) {
    Serial.println("Internal Error");
  } else if (result == ESP_ERR_ESPNOW_NO_MEM) {
    Serial.println("ESP_ERR_ESPNOW_NO_MEM");
  } else if (result == ESP_ERR_ESPNOW_NOT_FOUND) {
    Serial.println("Peer not found.");
  } else {
    Serial.println("Not sure what happened");
  }
}
#endif
