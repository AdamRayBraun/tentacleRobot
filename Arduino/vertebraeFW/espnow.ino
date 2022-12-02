// #define VERBOSE_ENOW_DEBUG 1

#define ENOW_CHANNEL       1
#define broadcastAdr       0x69

//****** ESP-NOW vars ******//
uint8_t lastRXmac[6];

//****** ESP-NOW flags ******//
RTC_DATA_ATTR bool handleEnowRx = false;

#define enow_flag_leds         0x10
#define enow_flag_OTA          0x40
#define enow_flag_touchThresh  0x20
#define enow_flag_touchPoll_Q  0x22

typedef struct enow_packet_rx {
  byte address;
  byte flag;
  byte led1;
  byte led2;
  byte led3;
  byte led4;
  byte neoR;
  byte neoG;
  byte neoB;
} enow_packet_rx;

#define enow_flag_touch        0x30
#define enow_flag_touchPoll_A  0x33

typedef struct enow_packet_tx {
  byte id;
  byte flag;
  int touchSide;
  bool shortTouch;
} enow_packet_tx;

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
  WiFi.disconnect();

  delay(2000);

  WiFi.mode(WIFI_AP);

  const char* pass = "pointlessPassword";
  bool result = WiFi.softAP(WiFi.macAddress().c_str(), pass, ENOW_CHANNEL, 0);
  if (!result) Serial.println("ERR: ENOW AP Config failed.");

  WiFi.disconnect();

  if (esp_now_init() != ESP_OK) {
    Serial.println("ERROR initializing ESP-NOW");
    updateStatusLed(100, 0, 0);
    return;
  }

  updateStatusLed(0, 0, 0);

  esp_now_register_send_cb(espNowTxCB);
  esp_now_register_recv_cb(espNowRxCB);
  WiFi.scanNetworks(); // needed to initialise WiFi before sending broadcasts

  setPeerToBroadcast();

  Serial.println("ESPNOW setup");
}

/**
  If a ESPNOW message has been receives, handles logic based on packet's flag
**/
void handleENowRx()
{
  if (!handleEnowRx){
    return;
  } else {
    handleEnowRx = false;
  }

  if (enowRxPacket.address != id && enowRxPacket.address != broadcastAdr){
    return;
  }

  switch(enowRxPacket.flag){
    case(enow_flag_leds):
      updateLedTarget(0, enowRxPacket.led1);
      updateLedTarget(1, enowRxPacket.led2);
      updateLedTarget(2, enowRxPacket.led3);
      updateLedTarget(3, enowRxPacket.led4);
      updateStatusLed(enowRxPacket.neoR, enowRxPacket.neoG, enowRxPacket.neoB);
      break;
    case(enow_flag_OTA):
      changeState(STATE_UPDATE);
      break;
    case(enow_flag_touchThresh):
      updateTouchThresh(enowRxPacket.led1);
      break;
    case(enow_flag_touchPoll_Q):
      sendTouchPollA();
      break;
  }
}

void sendTouchMsg(int touchSide, bool isShortTouch)
{
  enowTxPacket.id         = id;
  enowTxPacket.flag       = enow_flag_touch;
  enowTxPacket.touchSide  = touchSide;
  enowTxPacket.shortTouch = isShortTouch;

  const uint8_t *peer_addr = peer.peer_addr;
  esp_err_t result = esp_now_send(peer_addr, (uint8_t *) &enowTxPacket, sizeof(enow_packet_tx));
}

void sendTouchPollA()
{
  enowTxPacket.id         = id;
  enowTxPacket.flag       = enow_flag_touchPoll_A;
  enowTxPacket.touchSide  = (int)((touchReading1() + touchReading2()) / 2);

  const uint8_t *peer_addr = peer.peer_addr;
  esp_err_t result = esp_now_send(peer_addr, (uint8_t *) &enowTxPacket, sizeof(enow_packet_tx));
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
