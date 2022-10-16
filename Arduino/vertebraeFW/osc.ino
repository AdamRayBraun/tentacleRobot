#ifdef EN_OSC

#define ssid "H&M"
#define pwd  "weLoveInternetting"

WiFiUDP Udp;
const IPAddress outIp(192, 168, 194, 105); // laptop IP
const unsigned int outPort   = 9999;         // TX port - works
const unsigned int localPort = 7777;       // RX port

OSCErrorCode oscError;

#define heartbeatPeriod 4000
unsigned long lastHeartbeat;

void setupOSC()
{
  // // Setting static IP address
  // IPAddress local_IP(192, 168, 1, getIDfromMac().toInt());
  // IPAddress gateway(192, 168, 194, 195);
  // IPAddress subnet(255, 255, 0, 0); // dont fuck with
  // // IPAddress dns(192, 168, 1, 195);
  //
  // // Configures static IP address
  // if (!WiFi.config(local_IP, gateway, subnet)) {
  //   Serial.println("STA Failed to configure");
  // }

  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, pwd);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Udp.begin(localPort);

  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
}

void led(OSCMessage &msg)
{
  Serial.print("/led: ");
  Serial.print(msg.getInt(0));
  Serial.print(" ");
  Serial.print(msg.getInt(1));
  Serial.print(" ");
  Serial.print(msg.getInt(2));
  Serial.print(" ");
  Serial.println(msg.getInt(3));
}

void oscRx()
{
  // check for message
  OSCMessage msg;
  int size = Udp.parsePacket();

  // if message received, unpack and store in msg
  if (size > 0) {

    Serial.print("UDP Size: ");
    Serial.println(size);

    while (size--) {
      msg.fill(Udp.read());
    }
    if (!msg.hasError()) {
      msg.dispatch("/led", led);
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
  if (WiFi.status() == WL_CONNECTED)
  {
    OSCMessage msg("/register/");
    msg.add(getIDfromMac());

    Udp.beginPacket(outIp, outPort);
    msg.send(Udp);
    Udp.endPacket();
    msg.empty();
    Serial.println("sending HB");
  }
}

#endif
