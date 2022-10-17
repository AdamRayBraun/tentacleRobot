#define ssid "H&M"
#define pwd  "weLoveInternetting"

WiFiUDP Udp;
const IPAddress outIp(192, 168, 194, 105); // laptop IP
const unsigned int outPort   = 9999;    // TX port
const unsigned int localPort = 7777;    // RX port

OSCErrorCode oscError;

unsigned long lastHeartbeat;
int heartbeatPeriod      = 4000;
bool connectionHandshake = false;

void setupOSC()
{
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
  delay(1000);

  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pwd);

  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Udp.begin(localPort);

  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

   // so all vertebrae heartbeats aren't sent at the same time
  randomSeed(touchReading());
  heartbeatPeriod += random(10, 2000);
}

void led(OSCMessage &msg)
{
  updateLeds(UPDATE_LED_1, msg.getInt(0));
  updateLeds(UPDATE_LED_2, msg.getInt(1));
  updateLeds(UPDATE_LED_3, msg.getInt(2));
  updateLeds(UPDATE_LED_4, msg.getInt(3));
}

// check that handshake has sent the correct MAC back as confirmation
void handshake(OSCMessage &msg)
{
  String MSB = WiFi.macAddress().substring(12, 14);
  String LSB = WiFi.macAddress().substring(15, 17);

  String msgMsb = (String(msg.getInt(0), HEX));
  String msgLsb = (String(msg.getInt(1), HEX));

  msgMsb.toUpperCase();
  msgLsb.toUpperCase();

  if (MSB.equals(msgMsb) && LSB.equals(msgLsb)){
    connectionHandshake = true;
    updateStatusLed(244, 253, 255);
    Serial.println("Successful handshake");
  } else {
    updateStatusLed(200, 0, 0);
    Serial.print("ERR: received mismatching MAC from handshake: ");
    Serial.print("MSG: ");
    Serial.print(msgMsb);
    Serial.print(" ");
    Serial.println(msgLsb);
  }
}

void oscRx()
{
  // check for message
  OSCMessage msg;
  int size = Udp.parsePacket();

  // if message received, unpack and store in msg
  if (size > 0) {
    while (size--) {
      msg.fill(Udp.read());
    }
    if (!msg.hasError()) {
      msg.dispatch("/led", led);
      msg.dispatch("/handshake", handshake);
    } else {
      oscError = msg.getError();
      Serial.print("ERROR: ");
      Serial.println(oscError);
    }
  }
}

void runOSC()
{
  oscRx();

  if (millis() - lastHeartbeat > heartbeatPeriod){
    sendHeartbeat();
    lastHeartbeat = millis();
  }
}

void sendHeartbeat()
{
  if (WiFi.status() == WL_CONNECTED){
    if (connectionHandshake){
      OSCMessage msg("/heartbeat/");
      msg.add(id);
      Udp.beginPacket(outIp, outPort);
      msg.send(Udp);
      Udp.endPacket();
      msg.empty();
    } else {
      OSCMessage msg("/register/");
      msg.add(getIDfromMac());
      Udp.beginPacket(outIp, outPort);
      msg.send(Udp);
      Udp.endPacket();
      msg.empty();
    }
  } else {
    updateStatusLed(100, 0, 0);
    connectionHandshake = false;
    setupOSC();
  }
}
